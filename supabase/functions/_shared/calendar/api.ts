// What calendar-sync hands the app, the same for Google and Microsoft
// (docs/09 M7.4). The app validates it again at its own boundary (06 §7).

/** One calendar of a connected account. */
export interface CalendarInfo {
  id: string;
  name: string;
  /** 0xAARRGGBB, or null when the provider has no colour for it. */
  colorArgb: number | null;
  /** Holidays, shared read-only calendars: never written back. */
  readOnly: boolean;
}

/**
 * One event instance. Timed: [start]/[end] are epoch ms. All-day: also
 * [startDate] and the exclusive [endDate] as `yyyy-MM-dd`, which the app
 * places on those calendar dates in any zone.
 */
export interface EventInfo {
  /** Addresses this one instance (a repeating event's instances differ). */
  id: string;
  title: string;
  start: number;
  end: number;
  allDay: boolean;
  startDate?: string;
  endDate?: string;
  location?: string;
  description?: string;
  /** The HTTP etag: write-back's version (If-Match). */
  etag: string;
  /** Whether a move or rename can go back (timed, editable calendar). */
  writable: boolean;
}

/** What write-back changes: start, end and maybe the title. */
export interface EventPatch {
  start: number;
  end: number;
  title?: string;
}

export type WriteResult = 'written' | 'changed' | 'gone' | 'not_writable' | 'failed';

/** One provider's calendar API, called with a fresh access token. */
export interface CalendarApi {
  calendars(token: string): Promise<CalendarInfo[]>;
  events(token: string, calendarId: string, from: number, to: number): Promise<EventInfo[]>;
  event(token: string, calendarId: string, eventId: string): Promise<EventInfo | null>;
  update(
    token: string,
    calendarId: string,
    eventId: string,
    patch: EventPatch,
    etag: string,
  ): Promise<WriteResult>;
}

/** Thrown when the provider says the access token isn't accepted. */
export class TokenRejected extends Error {
  constructor() {
    super('token rejected');
  }
}

/** The most events one read returns (90 days of a very full calendar). */
export const maxEvents = 2500;

/** `#RRGGBB` → 0xFFRRGGBB, else null. */
export function argbOf(hex: string | undefined | null): number | null {
  const m = /^#?([0-9a-fA-F]{6})$/.exec(hex ?? '');
  return m ? (0xff000000 | parseInt(m[1], 16)) >>> 0 : null;
}

/** The status of a conditional write. */
export function writeResultOf(status: number): WriteResult {
  if (status >= 200 && status < 300) return 'written';
  if (status === 412) return 'changed';
  if (status === 404 || status === 410) return 'gone';
  if (status === 403) return 'not_writable';
  if (status === 401) throw new TokenRejected();
  return 'failed';
}

/** Throws unless [r] is OK; a 401 is a [TokenRejected]. */
export function check(r: Response, what: string): void {
  if (r.status === 401) throw new TokenRejected();
  if (!r.ok) throw new Error(`${what}: ${r.status}`);
}

/** `yyyy-MM-dd` → that date's UTC midnight in ms, or NaN. */
export function dateMs(date: string): number {
  return /^\d{4}-\d{2}-\d{2}$/.test(date) ? Date.parse(`${date}T00:00:00Z`) : NaN;
}

/** The day after [date] (`yyyy-MM-dd`). */
export function nextDate(date: string): string {
  return new Date(dateMs(date) + 86_400_000).toISOString().slice(0, 10);
}

/**
 * Rich-text descriptions (Google allows HTML) as plain text: line breaks
 * kept, tags dropped, the common entities decoded. The app renders notes
 * as text, never HTML.
 */
export function plainText(html: string | undefined | null): string | undefined {
  if (!html) return undefined;
  const text = html
    .replace(/<br\s*\/?>/gi, '\n')
    .replace(/<\/(p|div|li)>/gi, '\n')
    .replace(/<[^>]*>/g, '')
    .replace(/&nbsp;/g, ' ')
    .replace(/&lt;/g, '<')
    .replace(/&gt;/g, '>')
    .replace(/&quot;/g, '"')
    .replace(/&#39;/g, "'")
    .replace(/&amp;/g, '&')
    .trim();
  return text || undefined;
}
