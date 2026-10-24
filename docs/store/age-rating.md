# Age rating and age gate

Written in M8.6 (2026-10-24). **For owner/legal review.**

## 1. Age gate (docs/06 §6)

Dottoday is for people **13 and over**. The gate is copy, not a birth-date
prompt: the app collects no age, works fully without an account, and sends
nothing to our servers unless the person signs in.

| Where | Copy (en) | Key |
|---|---|---|
| Onboarding O1 Welcome, under the buttons | "Dottoday is for people aged 13 and over." | `onboardingAgeNote` (de/fr/es in the ARB files) |
| Store descriptions | the same sentence, last line | `docs/store/listing/*.md` |
| Privacy policy | § "Children" | `app/web/privacy.html` |

Rejected: a birth-date or "I am 13+" checkbox — it would add a personal-data
field and a step to a flow whose budget is 90 seconds (docs/00), and a
self-declared checkbox proves no more than the sentence.

**Legal review needed:** under GDPR Art. 8 the age at which a child can
consent to online services is set per country (DE 16, FR 15, ES 14, IE 16,
NL 16, IT 14, AT 14, UK 13). Sync is consent-based processing of task text;
if counsel says the store-level 13+ is not enough for EU sign-in, options are
(a) raise the stated age to 16 in the EU, or (b) keep 13+ and add "if you
are under 16, ask a parent before signing in" to the account step. Both are
one ARB change.

## 2. App Store Connect — age rating questionnaire (2025+ form)

| Question | Answer |
|---|---|
| Parental controls | No |
| Age assurance | No |
| Unrestricted web access (in-app browser to arbitrary sites) | No — links in notes open the system browser |
| User-generated content shared with others | No (tasks are private to the account; no sharing in v1) |
| Messaging and chat | No |
| Advertising | No |
| Cartoon or fantasy violence / Realistic violence / Prolonged graphic violence | None |
| Profanity or crude humour | None |
| Mature or suggestive themes | None |
| Horror / fear themes | None |
| Medical or treatment information | None |
| Alcohol, tobacco or drug use or references | None |
| Simulated gambling / Gambling / Contests | None |
| Sexual content or nudity / Graphic sexual content | None |
| Loot boxes | No |
| Health or wellness topics | No (ADHD appears only as a keyword for discovery; the app gives no health advice) |

Expected rating: **4+** (Apple's lowest). The 13+ in the app is our
stated audience, not a content rating; App Store Connect has no field for
it — say it in the description (done) and, if asked in review, in notes.
**Made for Kids:** No (do not opt into the Kids category).

## 3. Google Play — content rating (IARC) and target audience

**Category:** Productivity / Utility. IARC questionnaire answers: violence,
fear, sexuality, gambling, language, controlled substances, crude humour —
all **No**; users interact or share content — **No**; shares user location —
**No**; digital purchases — **No**; unrestricted internet — **No**.
Expected: **PEGI 3 / ESRB Everyone / USK 0**.

**Target audience and content** (Play's separate form): age groups **13–15,
16–17, 18+**; do **not** select under-13 groups (that would put the app under
the Families policy). "Could the app unintentionally appeal to children?" —
No (plain productivity UI, no characters or games).
