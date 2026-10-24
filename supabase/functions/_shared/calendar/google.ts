// Google Calendar API v3 behind [CalendarApi] (docs/09 M7.4).
import {
  argbOf,
  check,
  dateMs,
  maxEvents,
  nextDate,
  plainText,
  writeResultOf,
} from './api.ts';
import type { CalendarApi, CalendarInfo, EventInfo, EventPatch, WriteResult } from './api.ts';

const base = 'https://www.googleapis.com/calendar/v3';

interface GoogleTime {
  date?: string;
  dateTime?: string;
}

interface GoogleEvent {
  id?: string;
  status?: string;
  summary?: string;
  description?: string;
  location?: string;
  start?: GoogleTime;
  end?: GoogleTime;
  etag?: string;
}

interface GoogleCalendar {
  id: string;
  summary?: string;
  summaryOverride?: string;
  backgroundColor?: string;
  accessRole?: string;
}

const auth = (token: string) => ({ Authorization: `Bearer ${token}` });
const writable = (role?: string) => role === 'owner' || role === 'writer';

/** One Google event as [EventInfo]; null when cancelled or unreadable. */
export function googleEvent(e: GoogleEvent, canEdit: boolean): EventInfo | null {
  if (!e.id || e.status === 'cancelled' || !e.start || !e.end) return null;
  const common = {
    id: e.id,
    title: e.summary ?? '',
    location: e.location || undefined,
    description: plainText(e.description),
    etag: e.etag ?? '',
  };
  if (e.start.date) {
    const endDate = e.end.date ?? nextDate(e.start.date);
    const start = dateMs(e.start.date);
    const end = dateMs(endDate);
    if (Number.isNaN(start) || Number.isNaN(end)) return null;
    return { ...common, start, end, allDay: true, startDate: e.start.date, endDate, writable: false };
  }
  const start = Date.parse(e.start.dateTime ?? '');
  const end = Date.parse(e.end.dateTime ?? '');
  if (Number.isNaN(start) || Number.isNaN(end)) return null;
  return { ...common, start, end, allDay: false, writable: canEdit };
}

export function googleApi(send: typeof fetch): CalendarApi {
  // Whether each calendar takes changes, remembered from the last listing
  // within this request (events() of an unlisted one asks once).
  const roles = new Map<string, string | undefined>();

  async function role(token: string, calendarId: string): Promise<string | undefined> {
    if (roles.has(calendarId)) return roles.get(calendarId);
    const r = await send(
      `${base}/users/me/calendarList/${encodeURIComponent(calendarId)}`,
      { headers: auth(token) },
    );
    check(r, 'calendar');
    const c = (await r.json()) as GoogleCalendar;
    roles.set(calendarId, c.accessRole);
    return c.accessRole;
  }

  return {
    async calendars(token: string): Promise<CalendarInfo[]> {
      const out: CalendarInfo[] = [];
      let page: string | undefined;
      do {
        const q = new URLSearchParams({ maxResults: '250', ...(page ? { pageToken: page } : {}) });
        const r = await send(`${base}/users/me/calendarList?${q}`, { headers: auth(token) });
        check(r, 'calendars');
        const body = (await r.json()) as { items?: GoogleCalendar[]; nextPageToken?: string };
        for (const c of body.items ?? []) {
          // Free/busy-only calendars have no events to show.
          if (c.accessRole === 'freeBusyReader') continue;
          roles.set(c.id, c.accessRole);
          out.push({
            id: c.id,
            name: c.summaryOverride ?? c.summary ?? c.id,
            colorArgb: argbOf(c.backgroundColor),
            readOnly: !writable(c.accessRole),
          });
        }
        page = body.nextPageToken;
      } while (page);
      return out;
    },

    async events(token, calendarId, from, to): Promise<EventInfo[]> {
      const canEdit = writable(await role(token, calendarId));
      const out: EventInfo[] = [];
      let page: string | undefined;
      do {
        const q = new URLSearchParams({
          timeMin: new Date(from).toISOString(),
          timeMax: new Date(to).toISOString(),
          // Each instance of a repeating event on its own, with its own id.
          singleEvents: 'true',
          maxResults: '2500',
          ...(page ? { pageToken: page } : {}),
        });
        const r = await send(
          `${base}/calendars/${encodeURIComponent(calendarId)}/events?${q}`,
          { headers: auth(token) },
        );
        check(r, 'events');
        const body = (await r.json()) as { items?: GoogleEvent[]; nextPageToken?: string };
        for (const e of body.items ?? []) {
          const info = googleEvent(e, canEdit);
          if (info) out.push(info);
        }
        page = out.length < maxEvents ? body.nextPageToken : undefined;
      } while (page);
      return out.slice(0, maxEvents);
    },

    async event(token, calendarId, eventId): Promise<EventInfo | null> {
      const r = await send(
        `${base}/calendars/${encodeURIComponent(calendarId)}/events/${encodeURIComponent(eventId)}`,
        { headers: auth(token) },
      );
      if (r.status === 404 || r.status === 410) return null;
      check(r, 'event');
      return googleEvent((await r.json()) as GoogleEvent, writable(await role(token, calendarId)));
    },

    async update(token, calendarId, eventId, patch: EventPatch, etag): Promise<WriteResult> {
      const r = await send(
        `${base}/calendars/${encodeURIComponent(calendarId)}/events/${encodeURIComponent(eventId)}`,
        {
          method: 'PATCH',
          headers: { ...auth(token), 'Content-Type': 'application/json', 'If-Match': etag },
          body: JSON.stringify({
            start: { dateTime: new Date(patch.start).toISOString() },
            end: { dateTime: new Date(patch.end).toISOString() },
            ...(patch.title === undefined ? {} : { summary: patch.title }),
          }),
        },
      );
      return writeResultOf(r.status);
    },
  };
}
