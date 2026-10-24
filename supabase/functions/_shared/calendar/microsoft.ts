// Microsoft Graph calendars behind [CalendarApi] (docs/09 M7.4).
import { argbOf, check, dateMs, maxEvents, plainText, writeResultOf } from './api.ts';
import type { CalendarApi, CalendarInfo, EventInfo, EventPatch, WriteResult } from './api.ts';

const graph = 'https://graph.microsoft.com/v1.0';
const fields = 'id,subject,bodyPreview,location,start,end,isAllDay,isCancelled,isOrganizer';

interface GraphTime {
  dateTime?: string;
  timeZone?: string;
}

interface GraphEvent {
  id?: string;
  subject?: string;
  bodyPreview?: string;
  location?: { displayName?: string };
  start?: GraphTime;
  end?: GraphTime;
  isAllDay?: boolean;
  isCancelled?: boolean;
  isOrganizer?: boolean;
  '@odata.etag'?: string;
}

interface GraphCalendar {
  id: string;
  name?: string;
  hexColor?: string;
  canEdit?: boolean;
}

// Every time comes back in UTC, so `dateTime` needs no zone lookup.
const headers = (token: string) => ({
  Authorization: `Bearer ${token}`,
  Prefer: 'outlook.timezone="UTC"',
});

/** Graph's `2026-10-24T09:00:00.0000000` (UTC) → epoch ms, or NaN. */
function utcMs(t?: GraphTime): number {
  const s = t?.dateTime ?? '';
  return /^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}/.test(s) ? Date.parse(`${s.slice(0, 19)}Z`) : NaN;
}

/** One Graph event as [EventInfo]; null when cancelled or unreadable. */
export function graphEvent(e: GraphEvent, canEdit: boolean): EventInfo | null {
  if (!e.id || e.isCancelled) return null;
  const common = {
    id: e.id,
    title: e.subject ?? '',
    location: e.location?.displayName || undefined,
    description: plainText(e.bodyPreview),
    etag: e['@odata.etag'] ?? '',
  };
  if (e.isAllDay) {
    // An all-day event's times are midnights: its dates are what count.
    const startDate = (e.start?.dateTime ?? '').slice(0, 10);
    const endDate = (e.end?.dateTime ?? '').slice(0, 10);
    const start = dateMs(startDate);
    const end = dateMs(endDate);
    if (Number.isNaN(start) || Number.isNaN(end)) return null;
    return { ...common, start, end, allDay: true, startDate, endDate, writable: false };
  }
  const start = utcMs(e.start);
  const end = utcMs(e.end);
  if (Number.isNaN(start) || Number.isNaN(end)) return null;
  // Only the organiser can move a meeting for everyone.
  return { ...common, start, end, allDay: false, writable: canEdit && e.isOrganizer !== false };
}

const isoUtc = (ms: number) => new Date(ms).toISOString().slice(0, 19);

export function microsoftApi(send: typeof fetch): CalendarApi {
  const editable = new Map<string, boolean>();

  async function canEdit(token: string, calendarId: string): Promise<boolean> {
    const known = editable.get(calendarId);
    if (known !== undefined) return known;
    const r = await send(
      `${graph}/me/calendars/${encodeURIComponent(calendarId)}?$select=id,canEdit`,
      { headers: headers(token) },
    );
    check(r, 'calendar');
    const c = (await r.json()) as GraphCalendar;
    editable.set(calendarId, c.canEdit === true);
    return c.canEdit === true;
  }

  const eventUrl = (calendarId: string, eventId: string) =>
    `${graph}/me/calendars/${encodeURIComponent(calendarId)}/events/${encodeURIComponent(eventId)}`;

  return {
    async calendars(token: string): Promise<CalendarInfo[]> {
      const out: CalendarInfo[] = [];
      let next: string | undefined = `${graph}/me/calendars?$select=id,name,hexColor,canEdit&$top=100`;
      while (next) {
        const r = await send(next, { headers: headers(token) });
        check(r, 'calendars');
        const body = (await r.json()) as { value?: GraphCalendar[]; '@odata.nextLink'?: string };
        for (const c of body.value ?? []) {
          editable.set(c.id, c.canEdit === true);
          out.push({
            id: c.id,
            name: c.name ?? c.id,
            colorArgb: argbOf(c.hexColor),
            readOnly: c.canEdit !== true,
          });
        }
        next = body['@odata.nextLink'];
      }
      return out;
    },

    async events(token, calendarId, from, to): Promise<EventInfo[]> {
      const edit = await canEdit(token, calendarId);
      const out: EventInfo[] = [];
      const q = new URLSearchParams({
        startDateTime: new Date(from).toISOString(),
        endDateTime: new Date(to).toISOString(),
        $select: fields,
        $top: '500',
      });
      // calendarView expands repeating events into their instances.
      let next: string | undefined =
        `${graph}/me/calendars/${encodeURIComponent(calendarId)}/calendarView?${q}`;
      while (next && out.length < maxEvents) {
        const r = await send(next, { headers: headers(token) });
        check(r, 'events');
        const body = (await r.json()) as { value?: GraphEvent[]; '@odata.nextLink'?: string };
        for (const e of body.value ?? []) {
          const info = graphEvent(e, edit);
          if (info) out.push(info);
        }
        next = body['@odata.nextLink'];
      }
      return out.slice(0, maxEvents);
    },

    async event(token, calendarId, eventId): Promise<EventInfo | null> {
      const r = await send(`${eventUrl(calendarId, eventId)}?$select=${fields}`, {
        headers: headers(token),
      });
      if (r.status === 404 || r.status === 410) return null;
      check(r, 'event');
      return graphEvent((await r.json()) as GraphEvent, await canEdit(token, calendarId));
    },

    async update(token, calendarId, eventId, patch: EventPatch, etag): Promise<WriteResult> {
      const r = await send(eventUrl(calendarId, eventId), {
        method: 'PATCH',
        headers: { ...headers(token), 'Content-Type': 'application/json', 'If-Match': etag },
        body: JSON.stringify({
          start: { dateTime: isoUtc(patch.start), timeZone: 'UTC' },
          end: { dateTime: isoUtc(patch.end), timeZone: 'UTC' },
          ...(patch.title === undefined ? {} : { subject: patch.title }),
        }),
      });
      return writeResultOf(r.status);
    },
  };
}
