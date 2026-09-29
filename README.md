<p align="center">
  <img src="assets/icon/app_icon.png" width="112" alt="Voya icon" />
</p>

<h1 align="center">Voya</h1>
<p align="center"><em>Practice the interview before the real one.</em></p>

<p align="center">
  <img src="https://github.com/Christian0162/voya/actions/workflows/ci.yml/badge.svg" alt="CI status" />
  <img src="https://img.shields.io/badge/version-1.0.0-4F46E5" alt="version" />
  <img src="https://img.shields.io/badge/flutter-3.35%2B-4F46E5" alt="flutter" />
  <img src="https://img.shields.io/badge/dart-3.13%2B-4F46E5" alt="dart" />
  <img src="https://img.shields.io/badge/platforms-android%20%7C%20ios-4F46E5" alt="platforms" />
</p>

An AI-powered voice interview simulator. Users speak their answers out loud
to an animated AI interviewer and get realistic, adaptive follow-up
questions — not a chat-with-a-bot experience.

---

## Installation

### 1. Install Flutter

| Platform | Command |
|---|---|
| macOS | `brew install --cask flutter` |
| Windows | `winget install --id=Google.Flutter` |
| Linux / manual | Download from [flutter.dev/get-started/install](https://flutter.dev/get-started/install) |

Verify the install:

```bash
flutter --version   # this project targets Flutter 3.35+ / Dart 3.13+
flutter doctor       # resolve any red ✗ items before continuing
```

### 2. Clone the repo

```bash
git clone <this-repo-url>
cd voya
```

### 3. Install dependencies

```bash
flutter pub get
```

### 4. Set up Supabase (required)

Voya is gated behind sign-in — accounts, profiles, and interview history all
live in a [Supabase](https://supabase.com) project (free tier is fine).

1. Create a project at [supabase.com](https://supabase.com/dashboard).
2. In the SQL Editor, run the schema in `supabase/schema.sql` (creates
   `profiles`, `interview_sessions`, `interview_results`, their RLS policies,
   and the `avatars` Storage bucket policies).
3. Copy `.env.example` to `.env` and fill in `SUPABASE_URL`/`SUPABASE_ANON_KEY`
   (Project Settings -> API).
4. (Optional, for "Continue with Google") In Authentication > Providers,
   enable Google with a Google Cloud OAuth client's ID/secret, and add
   `io.supabase.voya://login-callback/` under Authentication > URL
   Configuration > Redirect URLs.

### 5. Run it

```bash
flutter devices      # confirm a device/emulator/simulator is attached
flutter run
```

First launch will prompt for microphone permission — this is required, the
whole app is voice-first.

By default the interviewer runs entirely offline on the local, rule-based
`MockAIInterviewService` — no API key needed. See "use a real AI (Gemini)"
below to switch to Gemini instead.

### 6. (Optional) use a real AI (Gemini)

Get a [Gemini API key](https://aistudio.google.com/apikey), then pick one of:

**`.env` file (easiest for local testing)** — copy `.env.example` to `.env`
and fill in the key:

```bash
cp .env.example .env
# then edit .env:
#   GEMINI_API_KEY=your-key-here
flutter run
```

`.env` is gitignored and loaded once at startup (`main.dart`, via
`flutter_dotenv`) — nothing further to pass on the command line after that.

**`--dart-define` (no local file at all)** — never written to disk, so
there's nothing to accidentally commit:

```bash
flutter run --dart-define=GEMINI_API_KEY=your-key-here
```

`AiServiceFactory` (`lib/core/data/services/ai_service_factory.dart`) checks
`.env` first, then the `--dart-define`, and falls back to the offline mock
if neither is set — no other code path changes either way. It defaults to
the `gemini-3.8-flash` model; override with `GEMINI_MODEL` in whichever
source you're using (`.env` or `--dart-define=GEMINI_MODEL=...`).

Scoring is a hybrid by design: Gemini judges the qualitative dimensions
(communication, clarity, answer quality, consistency) and writes the
strengths/practice-area/follow-up text, while speaking pace and filler-word
counts are computed deterministically from the actual transcript/duration
data already captured per turn — real arithmetic, not something worth
asking a model to guess at.

If Gemini is configured, it's wrapped in `FallbackAIInterviewService`
(`lib/core/data/services/fallback_ai_interview_service.dart`): a provider
outage (rate limit, a 503, a network blip) drops the interview back to the
offline `MockAIInterviewService` instead of ending it with an error screen.
The fallback is sticky for that one interview — once Gemini fails once, the
rest of that session stays on the offline interviewer rather than re-trying
(and re-waiting on) a provider that's already down; the next interview you
start tries Gemini again from scratch.

### 7. (Optional) run checks

```bash
dart format --output=none --set-exit-if-changed .
flutter analyze
flutter test
```

These same checks (plus a debug Android build) run automatically in
[CI](.github/workflows/ci.yml) on every push and pull request to `main`.

---

## Description

Voya simulates a real spoken interview: the AI interviewer asks a
question out loud, an animated 2D avatar speaks it, the app listens to your
answer, transcribes it, and the AI decides whether to follow up, challenge a
vague answer, or move on — the same way a real interviewer would. Built for
practicing job, visa, immigration, and general interviews across different
countries, purposes, and difficulty levels.

Beyond the live interview itself:

- **Accounts** — email/password or Google sign-in (Supabase Auth), with an
  editable username/avatar. Every account is required; there's no guest mode,
  so history and progress are always tied to *you*, not the device.
- **Answer Coach** — a browsable question library, grouped by category (travel
  purpose, employment, finances, …), where each question has an AI-generated
  guide (what it's really asking, what a good answer covers, how to structure
  one, an example, common mistakes) and a "Practice This Question" flow that
  reuses the same voice loop as the live interview, then scores your spoken
  answer on relevance/clarity/completeness/naturalness/consistency. Also
  reachable *during* a live interview via a "Need help answering" prompt.
- **Progress tracking** — Home and History both show real numbers (total
  practices, average score, sessions this week) computed from your actual
  history, not a synthetic estimate.
- **Appearance** — System/Light/Dark, set in Settings and persisted per device.

---

## Screenshots

<table>
  <tr>
    <td align="center"><img src="docs/screenshots/home.png" width="200" alt="Home screen" /><br/>Home</td>
    <td align="center"><img src="docs/screenshots/interview_setup.png" width="200" alt="Interview setup" /><br/>Interview Setup</td>
    <td align="center"><img src="docs/screenshots/interview_result.png" width="200" alt="Interview result" /><br/>Interview Result</td>
  </tr>
  <tr>
    <td align="center"><img src="docs/screenshots/history.png" width="200" alt="History screen" /><br/>History</td>
    <td align="center"><img src="docs/screenshots/profile.png" width="200" alt="Profile screen" /><br/>Profile</td>
    <td align="center"><img src="docs/screenshots/settings.png" width="200" alt="Settings screen" /><br/>Settings</td>
  </tr>
</table>

*Rendered directly from the real app widgets (each screen's `*_template_preview.dart` fixture via `tool/screenshots/capture_screenshots_test.dart`), not mockups — regenerate with `flutter test tool/screenshots/capture_screenshots_test.dart` (it always reports "failed" due to one harmless trailing async exception from `google_fonts`; check `docs/screenshots/*.png` for the real result). Not yet pictured: the live voice interview screen (its animated Rive avatar needs a real device/emulator to render), sign-in/sign-up, and Answer Coach — those screens don't have a `*_template_preview.dart` fixture yet.*

---

## Architecture

Clean Architecture, one-way dependencies: **Presentation → Domain → Data**.

```
config/         theming, routing — no business logic
core/domain/    entities + abstract service/repository interfaces
core/data/      concrete implementations (mock + Gemini AI, on-device STT/TTS, Supabase repos)
core/presentation/  bloc, screens, templates, atoms/molecules/organisms widgets
```

Key decisions:

- **State management:** `flutter_bloc`. The interview is a real state machine
  (idle → AI speaking → listening → analyzing → next question → …), which
  maps naturally onto bloc events/states.
- **Swappable AI/voice providers:** `AIInterviewService`, `SpeechToTextService`,
  and `TextToSpeechService` are domain interfaces. `AiServiceFactory` picks
  between a local, rule-based `MockAIInterviewService` (no API key, fully
  offline) and `GeminiAIInterviewService` (real questions/scoring via the
  Gemini API) wrapped in `FallbackAIInterviewService`, which drops back to
  the mock mid-session on a provider outage — whichever it picks, nothing in
  the bloc or any screen changes. See "Using a real AI" below.
- **Avatar:** a Rive character (`assets/rive/voya-character.riv`) driven by a
  small `AiAvatarController` (idle / thinking / speaking / listening /
  processing), isolated from business logic behind that same controller.
- **Mascot, everywhere else:** the Rive rig only renders on the live
  interview screen. Elsewhere (Home, the setup wizard, sign-in) a lightweight
  painted "sticker" version of the same face — `MdMascotFace` — stands in, so
  the character feels like one consistent mascot across the app rather than a
  rig that only shows up mid-interview. See "Design" below for how this same
  painter also *is* the app icon.
- **Screens split three ways:** `*_screen.dart` (logic, navigation, dialogs),
  `*_template.dart` (pure layout, data + callbacks in, no logic), and
  `*_template_preview.dart` (a fixture-data harness for viewing a template in
  isolation).
- **Auth gates the router, not each screen:** `AuthCubit` is the single
  source of truth for sign-in state; `AppRouter` redirects based on it (via a
  small `GoRouterRefreshStream`) rather than every screen checking "am I
  signed in?" itself. Sign out from anywhere and the whole app redirects to
  `/sign-in` automatically.
- **Answer Coach reuses the interview's voice stack, not a copy of it:**
  `PracticeAnswerBloc` and the live interview's `InterviewBloc` share the same
  `SpeechToTextService`/`TextToSpeechService` interfaces and push-to-talk
  gesture (`MdPushToTalkMic`), and `AnswerGuidanceService` mirrors
  `AIInterviewService`'s Gemini-with-offline-fallback shape exactly. The
  "Need help answering" prompt mid-interview needs no `InterviewBloc` changes
  at all — it only ever shows during the bloc's existing idle
  (`InterviewStatus.listening`) window and pushes a route on top.

## Design

Voya leans into a **claymorphism-lite** visual style: chunky rounded cards
(`AppSpacing.radiusMd`/`radiusLg`) with a soft, low-opacity shadow instead of
a flat border, an indigo/violet brand gradient (`AppColors.primaryGradient`),
and a warm amber accent used sparingly to draw the eye (highlights on the
interview waveform, score pills). The goal is "friendly and tactile" without
tipping into the kids'-app territory a fully childish palette/typeface would
— the audience is adults preparing for a real interview, visa appointment, or
immigration hearing.

**The app icon *is* the mascot, not a separate illustration of it.** The
launcher icon, adaptive-icon foreground, and splash logo were all rasterized
directly from `MdMascotFace`'s own paint logic (see the doc comment on that
class), so the character on your home screen and the character in the app
are the same shape — there's no second art file to keep in sync by hand.

**The mascot wears a costume for your destination.** Once a country is
picked in the setup wizard, a small accessory — `MdCountryHat` — appears on
the mascot and stays on it through the rest of the wizard and into the live
interview (layered over the Rive avatar). Most countries get a friendly
party hat in a rotating accent color with a flag-emoji pennant; Japan gets a
purpose-built hachimaki (the red-sun headband) instead, since a country that
recognizable didn't work as a generic hat with a flag stuck on it. This is a
pure UI overlay, not a change to the `.riv` rig itself — editing that rig's
actual artwork/rigging requires the Rive editor, which is outside what this
codebase can generate; new costumes are added by extending `MdCountryHat`.

**Performance metrics are earned, not assumed.** Before a user completes
their first interview, Home and History both show an explicit "complete your
first interview to see your progress here" empty state rather than stats
seeded with a fake default. `ProgressStats` (shared by both screens) reports
exactly three real numbers — total practices, average score, sessions this
week — computed from the user's actual `interview_sessions` rows; earlier
revisions derived three separate "metrics" (Speaking/Confidence/Clarity) from
one single average score, which looked like more insight than the data
actually gave, so that was replaced outright rather than kept alongside the
honest version.

## System Design

The core loop the whole app is built around:

```
 AI speaks (TTS)
      │
      ▼
 Avatar animates (lip-sync driven by TTS amplitude)
      │
      ▼
 App listens (on-device STT, live waveform)
      │
      ▼
 User speaks → transcript
      │
      ▼
 AI analyzes the answer (vague? inconsistent? needs a follow-up?)
      │
      ├── follow-up needed → ask clarifying question ──┐
      │                                                 │
      └── move to next planned question ────────────────┤
                                                          ▼
                                                   repeat until time/
                                                   question limit hit
                                                          │
                                                          ▼
                                                 generate feedback,
                                                 save session + result
```

State lives in one place (`InterviewBloc`); everything else — the avatar, the
waveform, the transcript sheet — just renders whatever that state currently
is. Only text (transcripts, scores) is persisted, in Supabase Postgres tied
to the signed-in user (`SupabaseInterviewRepository`); no raw audio is
stored. `SharedPreferences` remains for one thing only: the local
appearance (dark/light/system) preference.

**Answer Coach** (`PracticeAnswerBloc`) runs the same four middle steps —
AI speaks the question, app listens, user speaks, AI analyzes the answer —
for a single question picked from the library (or, mid-interview, the
question currently on screen), then stops at feedback instead of looping
into a next question. It has no session/timer concept and saves nothing;
practicing a question is meant to be repeatable, not a scored event that
shows up in History.

## File Structure

```
lib/
├── main.dart
├── app.dart
├── config/
│   ├── constant/        # AppColors, AppTypography, AppSpacing, AppTheme, AppConstants
│   └── routes/          # app_router.dart (auth redirect + all routes), app_shell.dart,
│                         # go_router_refresh_stream.dart
└── core/
    ├── domain/
    │   ├── auth/entities|repositories/          # AppUser, AuthRepository
    │   ├── answer_guidance/entities|services/    # GuidanceQuestion, AnswerGuide, AnswerFeedback
    │   ├── interview_setup/entities/
    │   ├── interview/entities|services|repositories/
    │   └── interview_results/entities/
    ├── data/
    │   ├── services/     # mock + Gemini AI (interview & answer-guidance), *_service_factory.dart,
    │   │                 # gemini_config.dart / supabase_config.dart, STT/TTS impls,
    │   │                 # question bank, answer builder
    │   └── repositories/ # supabase_interview_repository.dart, supabase_auth_repository.dart
    └── presentation/
        ├── bloc/
        │   ├── auth/               # AuthCubit — the app's sign-in source of truth
        │   ├── theme/              # ThemeCubit — persisted System/Light/Dark
        │   ├── interview/          # InterviewBloc, events, states
        │   ├── answer_guide/       # AnswerGuideBloc (loads one AnswerGuide)
        │   └── practice_answer/    # PracticeAnswerBloc (practice-and-score one question)
        ├── types/                    # UI-only navigation payloads
        ├── screen/<area>/            # logic-only screens, incl. auth/, answer_guidance/, profile/
        └── widget/
            ├── atoms/                # md_primary_button.dart, md_google_logo.dart
            ├── molecules/            # md_card.dart, selectors, result cards,
            │                         # md_mascot_face.dart / md_country_hat.dart
            ├── organisms/            # md_ai_avatar.dart, md_push_to_talk_mic.dart, transcript sheet
            └── templates/<area>/     # pure-layout template + preview per screen
assets/
├── icon/         # app_icon.png, app_icon_foreground.png (Android adaptive), splash_logo.png —
│                 # all rasterized from MdMascotFace, see its doc comment
├── icons/        # google_logo.svg — the one SVG asset in the app
└── rive/         # voya-character.riv
supabase/
└── schema.sql    # profiles / interview_sessions / interview_results + RLS + storage policies
```

**Naming:** files `snake_case.dart`, classes `PascalCase`, screens
`<name>_screen.dart`, templates `<name>_template.dart` (+ `_preview`), shared
widgets `md_<name>.dart` → `Md<Name>`.

## Versioning

Follows [Semantic Versioning](https://semver.org) (`MAJOR.MINOR.PATCH`) as
set in `pubspec.yaml`'s `version:` field, e.g. `1.0.0+1` — the `+1` is the
build number bumped on every release, independent of the semver part.

| Change | Bump |
|---|---|
| Breaking change to a public API/behavior | MAJOR |
| New feature, backwards-compatible | MINOR |
| Bug fix, no behavior change | PATCH |
