/// `local_meta` keys that say who owns what on this device (CR-160,
/// docs/04 §4 "Owners"). Every synced row and outbox entry carries its
/// owner's profile id; these keys say which of those owners is which.
library;

/// The profile whose rows the app shows and writes. Empty after a sign-out:
/// then only a guest may show, never an account (CR-160 criterion 2).
const activeOwnerKey = 'active_owner';

/// Present for a profile that is an account (its id is the auth user id).
/// A profile without it is a guest: made on this device, never signed in,
/// and the only kind that may be adopted into an account.
String accountMarkerKey(String profileId) => 'owner_account:$profileId';

/// The current guest's settings when an account signed in on this device:
/// kept for an explicit choice (B1), never applied to an account that
/// already has settings.
String guestSettingsKey(String accountId) => 'guest_settings:$accountId';

/// The person's choice for the guest's tasks when [accountId] signs in
/// (`GuestChoice.name`), until the sign-in step has acted on it.
String guestChoiceKey(String accountId) => 'guest_choice:$accountId';

/// The current guest session: a random id replaced at every change of owner
/// on this device (CR-160 guest eligibility; see `GuestRowSessions`).
const guestSessionKey = 'guest_session';

/// Set when signing in found guest tasks that may not move (made before the
/// last change of owner): the app tells the person once (G1b).
String guestNoticeKey(String accountId) => 'guest_notice:$accountId';

/// Present while a deleted account's local copy is being removed; the copy
/// stays hidden, unsynced and unmovable until removal finishes.
String removalPendingKey(String accountId) => 'owner_removing:$accountId';

/// Before schema 18: the one account this device synced with.
const legacySyncAccountKey = 'sync_account';
