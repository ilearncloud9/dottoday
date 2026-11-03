# Flutter Premium Cross-Platform Native Experience Guide

**Engineering + UX design standard for iPhone (iOS), iPad (iPadOS), macOS, Android phones, Android tablets/foldables, and web**  
**Version:** 1.0  
**Updated:** November 2026  
**Audience:** Flutter engineers, product designers, UX researchers, QA engineers, technical leads, and design-system owners

> **North star:** One recognizable product, one coherent feature experience, multiple genuinely native-feeling interfaces. Users should know they are using the same product on every device, yet feel that the app belongs on the OS in front of them.

---

## 1. The design philosophy

### 1.1 One product, not one identical screen

Keep **the product model and meaning** consistent while adapting **how the product is presented and operated**.

**Share across all platforms:**

- Product name, voice, logo, icon family strategy, brand palette, core visual personality, and recognizable content styles.
- Account identity, feature availability where technically/policy feasible, data model, permissions model, business rules, validation, sync and offline principles.
- Domain terminology, content hierarchy, task sequence, success/error semantics, and accessibility commitment.
- Fundamental design tokens and quality bar: spacing rhythm, readable hierarchy, restrained effects, visual consistency, perceived responsiveness.
- Deep-link destinations and state restoration where supported; users should be able to start a task on one device and understand it on another.

**Adapt deliberately by platform:**

- Navigation shell: tab bar, navigation rail, sidebar, split view, toolbar, or browser-oriented shell.
- System controls: switches, dialogs, sheets, pickers, context menus, popovers, selection affordances, and text editing.
- Typography, density, control sizing, icon metaphors, focus, hover, keyboard commands, motion, haptics, and back behavior.
- Window management, drag and drop, clipboard, sharing, filesystem access, notifications, biometrics, payment flows, and permissions.
- Responsive composition based on **available window width**, not a guessed phone/tablet device label.

**Non-goal:** Pixel-identical UI screenshots across all devices.

**Success condition:** The same user intention maps to the same feature and outcome; the path and controls conform to the expectations of that platform.

### 1.2 Native feel is a behavior contract, not a skin

A Cupertino-looking navigation bar does **not** make an iOS app native-feeling if Back gestures, text selection, sheets, scrolling, system sharing, keyboard avoidance, and accessibility are wrong. Likewise, a Material-colored app does **not** feel Android-native when it breaks system Back or edge-to-edge behavior.

Evaluate native feel through **five layers**:

1. **Information architecture:** Where do users expect navigation and actions?
2. **Interaction physics:** What happens when users tap, swipe, scroll, select, hover, drag, or press Back?
3. **Platform chrome:** What do navigation bars, title bars, menus, dialogs, and system surfaces look and behave like?
4. **OS integration:** Does it use the correct system capabilities and obey lifecycle, permissions, and windowing rules?
5. **Finish:** Is everything sharp, aligned, fast, accessible, and free of visual glitches?

### 1.3 Define a decision hierarchy

When consistency conflicts with nativeness, use this priority:

1. Safety, correctness, user expectations, accessibility, and OS policy.
2. Task completion, clarity, and predictable user outcomes.
3. Native navigation and interaction conventions.
4. Brand expression through color, content style, illustrations, and purposeful signature details.
5. Pixel-level visual matching across devices.

**Rule:** Override a platform convention only when testing shows an important user benefit and the override does not undermine accessibility or core OS behavior.

---

## 2. Platform experience overview

| Target | Intended feeling | Primary navigation | Primary inputs | Signature expectations |
|---|---|---|---|---|
| **iPhone / iOS** | Elegant, content-first, effortless in one hand | Native-style tabs, hierarchical push, sheets | Touch, gestures, keyboard when present | Edge-swipe Back, safe areas, large/collapsing titles when appropriate, polished sheets, iOS selection and haptics |
| **iPad / iPadOS** | Spacious Apple productivity app, not a stretched phone | Sidebar + detail or multi-column; compact modes adapt | Touch, Pencil, keyboard, trackpad | Resize/multitask, split detail, drag and drop, hover/pointer, command shortcuts |
| **Mac / macOS** | True desktop app with precision and efficiency | Sidebar, toolbar, multiple panes, windows | Mouse, trackpad, keyboard | Native menu bar, standard shortcuts, selectable text, resizable windows, right-click, proper title/toolbar region |
| **Android phone** | Modern Android/Material experience | Material navigation bar, top bar, Back stack, FAB where justified | Touch, system gestures | Predictive Back, edge-to-edge, Material state feedback, native sharing/pickers, Android selection |
| **Android tablet / foldable** | Optimized large-screen Android workspace | Navigation rail/drawer, list-detail/supporting panes | Touch, keyboard, mouse, stylus | Window-size-aware layouts, multitasking, fold posture/hinge awareness, no stretched phone UI |
| **Web desktop** | First-class web application | Sidebar/top navigation, browser-compatible routes | Keyboard, mouse, trackpad | Usable URLs, browser Back/Forward, focus, hover, right-click, copy/paste, scrolling, fast load |
| **Web mobile/tablet** | Touch-friendly web app, not an awkward desktop canvas | Adapt to viewport; preserve browser conventions | Touch and optional keyboard/pointer | Browser UI, responsive reflow, link semantics, form/autofill behavior, installability only if relevant |

**Important distinction:** `iPadOS` is an OS and capability environment, while `tablet layout` is a response to the current window. An iPad in a narrow multitasking window may need a compact layout but should still support iPad keyboard, pointer, drag-and-drop, and system behavior.

---

## 3. iPhone / iOS: details that create a truly native feel

### 3.1 Navigation and screen structure

- Use an iOS-style **tab bar** for primary top-level destinations when that IA fits; reserve hierarchical push navigation for drilling into content.
- Use familiar **navigation bars** and **large titles that collapse** for scrollable primary pages when appropriate to the product and current iOS HIG.
- Place Back controls consistently, preserve navigation history, and support the iOS **edge-swipe Back** gesture wherever a standard push stack is appropriate.
- Use a **sheet** for a temporary task, confirmation, selection, or short flow; use full-screen presentation for longer or immersive tasks.
- Choose the correct sheet height and dismissal behavior; if there is unsaved work, explain the consequence or prevent accidental data loss rather than silently dismissing.
- Keep the primary action reachable without creating a permanent wall of floating buttons.
- Avoid nesting too many top bars, bottom bars, floating actions, and filters into a tiny viewport.

### 3.2 Surface treatment and visual styling

- Respect current Apple HIG regarding materials, translucency, control grouping, elevation, and scroll-edge effects. **Do not fake current Apple system materials with a generic blur and claim native parity.**
- Use platform-appropriate corner geometry and separators. Be restrained: more blur, shadow, and corner radius do not automatically mean premium.
- Use iOS-compatible system typography and optical spacing; let prominent content, not borders around everything, establish hierarchy.
- Preserve high legibility over glass/translucent backgrounds in light mode, dark mode, increased contrast, and Reduce Transparency settings where available.
- Keep system status information visible and readable; match light/dark status bar appearance to the underlying surface.
- Avoid placing important content behind the notch/Dynamic Island area or home indicator without correct safe-area treatment.

### 3.3 Native touch interactions

- Preserve iOS-style scrolling friction, bounce, nested scrolling, and scrollbar treatment.
- Support status-bar **tap to return to top** for suitable primary scroll views where supported.
- Use familiar swipe actions for lists only when discoverable and reversible; never hide the only path to a critical action behind a gesture.
- Use iOS-appropriate **context menus** for secondary item actions, with meaningful destructive-action treatment.
- Match system-like text selection, caret placement, magnification, selection menu, autocorrect, spellcheck, keyboard action labels, and keyboard dismissal.
- Use iOS-style pickers, segmented controls, toggles, action sheets, alerts, and confirmation patterns as appropriate.
- Haptic feedback should acknowledge meaningful events—selection changes, success, warnings—not every ordinary tap; check hardware and user settings.
- Never intercept system gestures just to enable a flashy custom animation.

### 3.4 Forms, keyboard, and system integration

- Choose appropriate keyboard types, autofill hints, text capitalization, `textInputAction`, and secure entry.
- Respect keyboard insets; forms must remain visible and scrollable when the keyboard opens.
- Provide a sensible Done/Next flow; make validation clear but not noisy.
- Use OS capabilities through supported Flutter plugins or native iOS integrations when appropriate: share sheet, photo picker, document picker, biometrics, notifications, secure storage, universal links, and system sign-in/payment flows where applicable.
- Request permission **in context**, after explaining what the feature needs, and gracefully handle denial or restricted access.
- Verify background and foreground transitions, interrupted authentication, app termination, and state restoration.

### 3.5 iPhone acceptance checklist

- [ ] The navigation hierarchy feels at home on iOS.
- [ ] Swipe Back, modal dismissal, Back label/title, and route transitions behave correctly.
- [ ] Safe areas work around the top cutout, home indicator, and keyboard.
- [ ] Long titles, large text settings, VoiceOver, and Dark Mode do not break the layout.
- [ ] Scroll bounce, overscroll, scrollbar, status-bar interactions, and sheet dismissal feel natural.
- [ ] System text selection, input methods, haptics, pickers, and share flows behave correctly.
- [ ] No Android ripple, FAB, overflow, or Back model appears accidentally unless intentionally justified.

---

## 4. iPad / iPadOS: a tablet-first Apple experience

### 4.1 Do not make a giant iPhone interface

- Replace long, full-screen navigation chains with **sidebar + content** or **list-detail** navigation when the window has room.
- Keep selected navigation and detail state visible together; avoid opening a sheet when an inline inspector or side panel is better.
- Use well-proportioned reading widths rather than stretching every paragraph, form, or list item across the screen.
- Use columns, content grouping, persistent filters, and resizable or collapsible panes to create productive use of space.
- On a narrow iPad window, collapse intelligently to the same task hierarchy without losing the current selection or an unfinished form.

### 4.2 Multitasking and window adaptation

- Recompute layout from the **active app window**, not the physical iPad screen.
- Support portrait/landscape, multitasking, resizing, external displays where applicable, and changes to available width while a view is open.
- When moving between compact and expanded layouts, preserve scroll position, form input, focused field, selected record, and navigation context.
- Support working beside another app rather than requiring full-screen mode.
- Test overlays and popovers near window boundaries; the anchor and positioning must remain correct during resize.

### 4.3 Apple Pencil, touch, keyboard, and pointer

- Provide touch-sized targets even when keyboard/pointer density increases elsewhere.
- Support mouse/trackpad hover, cursor states, selection and focus when pointer input exists.
- Offer keyboard navigation, command shortcuts, and discoverability for frequently repeated actions.
- Consider Pencil interactions, Scribble, precision drawing/annotation, and Pencil-specific gestures only where the product actually needs them.
- Support drag and drop between lists, views, apps, and files if doing so meaningfully improves workflows; use native integrations where Flutter alone is insufficient.
- Use context menus, command menus, and inline selection states without requiring long-press-only discovery.

### 4.4 iPad acceptance checklist

- [ ] The default expanded view is a genuine multi-pane tablet experience.
- [ ] Narrow windows reflow without clipped menus or lost application state.
- [ ] Keyboard, trackpad, touch, and optional Pencil workflows work appropriately.
- [ ] Popovers anchor correctly, and large-window layouts avoid excessive whitespace/stretching.
- [ ] Multitasking, rotation, and drag/drop workflows are tested on real hardware.

---

## 5. macOS: build a desktop application, not a phone app in a window

### 5.1 Desktop structure

- Adopt a **sidebar + toolbar + content + optional inspector** architecture when it matches the product.
- Prefer desktop information density and short paths to information over tall mobile-style cards and full-screen sheets.
- Support window resizing, minimum useful window dimensions, full screen, multiple windows where beneficial, and restoration of window position/state when feasible.
- Ensure title bar, toolbar, traffic-light window controls, window drag regions, and content insets cooperate instead of visually colliding.
- Use macOS-native window and dialog behavior for critical workflows. Flutter's Cupertino widgets are primarily an iOS-style library, **not a substitute for macOS AppKit conventions**.
- Prefer popovers, inspectors, menus, and attached sheets to inappropriate mobile bottom sheets.

### 5.2 Native Mac menus and commands

- Provide a real **application menu bar**: relevant File, Edit, View, Window, Help commands, with About/Settings/Quit in expected locations.
- Standard shortcuts should follow Mac conventions: `⌘N`, `⌘O`, `⌘S`, `⌘W`, `⌘,`, `⌘F`, `⌘Z`, `⇧⌘Z`, where relevant—not blindly all of them.
- Show disabled commands appropriately and update command availability as selection changes.
- Make keyboard-first use possible: Tab traversal, predictable arrow-key movement, Enter/Space activation, Escape dismissal, and focused selection.
- Provide contextual right-click menus with actions equivalent to their toolbar/menu counterparts.
- Support multi-selection via Command-click and ranges via Shift-click in lists/grids where expected.
- Consider `PlatformMenuBar` for macOS system menus and native platform integration for deeper AppKit behaviors.

### 5.3 Pointer, text, and desktop details

- Show correct mouse cursors on clickable, draggable, selectable, and text-entry regions.
- Differentiate hover, pressed, focused, selected, disabled, and active/inactive window states.
- Make scrollbars, mouse wheel, trackpad gestures, and horizontal scrolling behave like Mac software.
- Do not use oversized touch controls by default; do not make targets so small that accessibility suffers.
- Support text selection and copy/paste in content that users naturally expect to copy.
- Respect macOS appearance, accent preferences where suitable, reduced motion, contrast preferences, and VoiceOver.
- Treat files as first-class if relevant: Open/Save panels, drag-in/drag-out, standard keyboard actions, file associations, Finder integration, and document state.
- Consider Dock menu, badge, app icon, notifications, and deep links when they bring actual value.

### 5.4 Mac acceptance checklist

- [ ] Window layout feels like an intentional macOS app at normal and compact widths.
- [ ] Native menu bar exists, shortcuts work, and menu commands reflect enabled state.
- [ ] Mouse, trackpad, right-click, keyboard-only, and multi-select paths are tested.
- [ ] Title bar/traffic lights, fullscreen, restore, and window resizing are clean.
- [ ] Native file dialogs and drag/drop work where the feature requires them.
- [ ] The app remains useful without touching the trackpad for basic workflows.

---

## 6. Android phones: deep Material and Android behavior

### 6.1 Navigation and layout

- Use **Material 3** principles for navigation bars, top app bars, buttons, state layers, menus, sheets, and emphasis.
- Keep Android's **system Back** semantics correct: navigate within the app, dismiss transient UI, or leave appropriately. Support current **predictive Back** behavior where available and supported by your Flutter/navigation version.
- Use a Floating Action Button for a truly prominent primary creation/action flow, not as a decorative requirement.
- Respect edge-to-edge content, system gesture areas, status/navigation bar contrast, and keyboard/IME insets.
- Favor Android-style navigation and motion instead of copying iOS swipe-back interaction across the entire app.

### 6.2 Material look, feel, and feedback

- Use Material color roles and typographic hierarchy intelligently; distinguish containers, surfaces, and elevation without excessive outlines.
- Match proper state feedback: pressed, dragged, focused, selected, hovered, and disabled.
- Use appropriate Material ripple/state layers rather than iOS-style interactions by accident.
- Consider Android dynamic color when available, **without sacrificing brand recognizability or contrast**. Define the precedence of system color preferences versus product brand.
- Prefer system-appropriate icons, menus, toggles, radio buttons, checkboxes, pickers, and alerts.
- Follow system scrolling and overscroll conventions for the Android version and device.

### 6.3 System integration

- Support Android share sheet, photo/document picker, app links, notification channels/permission behavior, biometrics, autofill, and secure storage through supported integrations.
- Use Android-specific gesture navigation and properly handle Back while a sheet, dialog, keyboard, or nested navigator is open.
- Handle Android lifecycle events, process death, activity recreation, screen rotations, and state restoration.
- If using long-running tasks or background services, respect platform restrictions and be transparent to users.
- Test TalkBack, system font scaling, display size adjustments, reduced animations, and high contrast when available.

### 6.4 Android phone acceptance checklist

- [ ] System Back and predictive Back are correct at every depth and transient surface.
- [ ] Material 3 components and feedback feel like the current Android platform.
- [ ] Edge-to-edge, gesture insets, IME resize, and system bar contrast are correct.
- [ ] Dynamic color (if enabled) looks intentional and accessible.
- [ ] Pickers, notifications, share flows, and text selection use Android expectations.
- [ ] Large system font/display settings and TalkBack remain usable.

---

## 7. Android tablets, foldables, and ChromeOS-style environments

### 7.1 Large screens should gain capability

- For wider app windows, switch from bottom navigation to **navigation rail** or drawer/sidebar where appropriate.
- Use canonical large-screen patterns: **list-detail**, **supporting pane**, and content grids with bounded item widths.
- Preserve selection and editing context while resizing or moving the app to split-screen.
- Avoid phone-only layouts centered on a huge screen or card grids with unreadably wide tiles.
- Include keyboard and mouse support, hover and focus states, and stylus/pointer precision when the device supports them.

### 7.2 Foldables and resizing

- Use actual window dimensions and display features rather than hard-coded "tablet if width > X" assumptions based on device identity.
- Do not lock orientation without a compelling, tested need; orientation locks can cause letterboxing or poor foldable behavior.
- Avoid placing essential controls over a hinge/fold; evaluate display features and partitions when using fold-aware layouts.
- Support posture changes, unfold/fold, multi-window changes, external keyboard, and interrupted drag operations.

### 7.3 Android tablet acceptance checklist

- [ ] Navigation rail/drawer and two-pane layouts emerge at appropriate available widths.
- [ ] Split-screen, freeform resize, and orientation changes preserve task state.
- [ ] Foldable hinge and cutouts do not obscure essential content.
- [ ] Mouse/keyboard/stylus behavior is useful, not merely technically accepted.
- [ ] The experience passes large-screen quality testing on real or representative devices.

---

## 8. Web: a browser-native experience, not merely Flutter running in a tab

### 8.1 Browser navigation is part of the UX

- Every important view should have a meaningful, stable URL when appropriate.
- Browser Back and Forward must return users to the expected route and state.
- Direct load, refresh, open-in-new-tab, bookmarks, copied links, and deep links must work.
- Distinguish internal client navigation from external links and downloadable resources.
- Respect browser focus, selection, clipboard, text editing, and right-click conventions; do not implement a global handler that steals standard browser shortcuts.
- Preserve scroll/focus and avoid resetting the entire workspace when changing a simple filter or route.

### 8.2 Desktop web layout

- Use web-friendly top navigation/side navigation depending on app complexity.
- Treat hover, active, focus-visible, tooltips, and link appearance as meaningful interaction states.
- Use comfortable content widths for reading and efficient multi-column layouts for workspace tasks.
- Keep forms browser-friendly: clear labels, validation, autocomplete where possible, visible keyboard focus, and sensible Enter/submit behavior.
- Support full keyboard operation, browser zoom, and high contrast. Test selection/copying of content rendered by Flutter.
- Build intentional empty, offline, loading, and navigation error states. A blank canvas during initial load feels untrustworthy.

### 8.3 Mobile/tablet web

- Design to the browser viewport and responsive layout constraints; avoid unsafe assumptions about browser UI and virtual keyboards.
- Preserve scroll, overscroll, swipe, selection, and native browser gesture expectations.
- Do not imitate an iOS or Android full-screen system app so closely that browser navigation becomes confusing.
- Offer installability/PWA behavior only when the offline, update, and launch experience meets expectations.

### 8.4 Flutter-specific web caveats

- Flutter Web is an effective fit for many **application-like interfaces**, especially complex authenticated tools with a shared Flutter product.
- It is **not a drop-in substitute for semantic HTML** for every web use case. For content-heavy marketing pages, rich document semantics, native browser text affordances, discoverability/SEO, or ultra-fast first paint, evaluate an HTML-based frontend or hybrid architecture.
- Verify web screen-reader semantics and accessibility behavior with the target Flutter version; don't assume a visual widget is automatically exposed correctly to assistive technology.
- Measure real-world startup performance, download size, image cost, deferred loading opportunities, runtime frame smoothness, and route transitions on modest devices.
- Validate deployment behavior for deep-link refreshes, routing fallback, caching headers, service-worker/PWA choices, and release updates.
- Test current Chrome, Safari, Firefox, and Edge where supported by your project. Account for both mouse and touch users.

### 8.5 Web acceptance checklist

- [ ] URLs, refresh, bookmarks, copied links, and browser Back/Forward work.
- [ ] No essential action requires hover alone.
- [ ] Visible keyboard focus and correct tab order are present.
- [ ] Text selection, copy/paste, right click, browser zoom, and browser shortcuts behave reasonably.
- [ ] Screen-reader output is validated, not assumed.
- [ ] Cold start and real-world performance are measured on target browsers and slower machines.
- [ ] Deep links work when pasted into a brand-new browser tab.

---

## 9. A system-level detail matrix: what should change by platform?

| Experience element | iPhone | iPad | Mac | Android phone | Android tablet | Web |
|---|---|---|---|---|---|---|
| **Primary destinations** | Bottom tabs when appropriate | Sidebar/tab treatment based on window | Sidebar/toolbar | Material nav bar | Rail/drawer | URL-aware sidebar/top nav |
| **Secondary navigation** | Push stack | List-detail / push when compact | Panes and selection | Back stack | List-detail | Routed views / panes |
| **Temporary flows** | Sheets/action sheets | Popovers, sheets, inline panels | Popovers/menus/dialogs | Material bottom sheets/dialogs | Dialogs/side panels | Dialogs/popovers, keyboard-safe |
| **Back behavior** | Nav Back + edge swipe | Navigation with keyboard/pointer support | History/commands, Escape for dismissal | System Back/predictive Back | System Back + pane logic | Browser Back/Forward |
| **Control vocabulary** | Cupertino / current iOS HIG | Apple tablet-friendly controls | macOS/AppKit-like controls | Material 3 | Material 3 large-screen | Web-appropriate controls |
| **Pointer** | Optional | Trackpad/mouse | Primary | Optional | Mouse/stylus common enough to test | Primary on desktop |
| **Keyboard shortcuts** | Limited/contextual | Strong support | Essential; ⌘ conventions | Contextual | Valuable; Ctrl conventions | Essential; don't hijack browser |
| **Selection** | Touch long-press / edit mode | Touch + keyboard/pointer | Click/⌘/Shift range selection | Touch long-press | Touch + keyboard/pointer | Click/Ctrl/Shift selection |
| **Feedback** | Subtle iOS haptics, physics | Touch/pointer feedback | Hover/focus/menu feedback | Material state layer + haptics | Material + pointer states | Hover/focus/active state |
| **Window management** | Primarily full-screen | Resizable multitasking | Resizable/multi-window | OS-managed multi-window when supported | Multi-window/foldables | Resizable browser viewport |
| **Sharing / files** | iOS system sheet/picker | iPad system picker + drag/drop | Native panels/Finder | Android Sharesheet/picker | Android + drag/drop | Browser share/download/upload APIs |
| **Accessibility** | VoiceOver / Dynamic Type | VoiceOver / Dynamic Type | VoiceOver / keyboard | TalkBack / font and display scaling | TalkBack / keyboard | Screen readers / WCAG / zoom |

Use this as a **design decision table**, not a rule that every screen needs a unique implementation.

---

## 10. The shared design system: one identity, multiple native skins

### 10.1 Organize tokens in four layers

```text
Foundations
  brand colors • spacing scale • type roles • radii • motion intent • elevation intent
          ↓
Semantic tokens
  canvas • surface • primaryAction • textPrimary • textSecondary • border
  destructive • positive • disabled • focus • selected • interactiveState
          ↓
Platform mappings
  iOS/iPadOS • macOS • Android • Web
          ↓
Component variants
  tab bar • navigation rail • sheet • dialog • text field • item row • toolbar
```

**Do:** Share semantic intent such as `color.action.primary`, `text.heading.page`, and `motion.navigate.forward`.

**Don't:** Force `radius = 16`, `padding = 20`, one icon, one height, and one animation onto every OS component because the brand library defines them once.

### 10.2 Brand identity without fighting the OS

Brand should be instantly recognized from:

- A disciplined accent palette and clear, accessible brand highlight.
- Logo, app icon, illustration/photography direction, data visualization style, and writing tone.
- Consistent content vocabulary, information hierarchy, and meaningful signature interactions.
- A small set of brand-specific components whose use and behavior remain familiar on every platform.

Native behaviors should be recognizable from:

- Navigation and modal structure.
- OS-aligned text editing, menus, controls, scrolling, and gestures.
- Window chrome, system dialogs, pointer states, keyboard conventions, and accessibility.

**The best compromise:** Branded content area + native system-facing interaction shell.

### 10.3 Typography: premium means measured hierarchy

- Use system fonts or native-feeling type stacks for OS chrome: Apple's system typography on Apple platforms, Android system typography/Roboto conventions on Android, browser-friendly system typography on web.
- Do not bundle/redeploy Apple's San Francisco fonts on unsupported platforms; respect font licenses.
- Keep text roles consistent (`display`, `pageTitle`, `sectionTitle`, `body`, `caption`, `label`), then let each platform map role sizes, weights, line heights, and letter spacing appropriately.
- Honor user text scaling. Test the biggest **supported** accessible size before declaring a layout finished.
- Prefer 1–2 readable families, limited weights, consistent baseline alignment, and optical icon/text balance.
- Avoid letter spacing that looks stylish in a mockup but harms readability at small sizes.

### 10.4 Spacing, density, and optical alignment

- Use a coherent base spacing rhythm such as 4/8 logical units for internal consistency—but adapt platform defaults where warranted.
- Mobile touch surfaces should be forgiving; desktop controls can be denser but must retain accessible targets.
- Align baselines and icon optical centers, not merely widget bounding boxes.
- Use subtle dividers to group content; avoid outlining every card or control.
- Keep content-width caps for forms and long text in large windows.
- Account for visual weight: a 20 px outlined icon may not balance a 20 px filled icon without optical adjustment.

### 10.5 Color, light/dark, and depth

- Derive light and dark semantic palettes separately; don't just invert colors.
- Check contrast for text, icons, status states, badges, thin borders, and surfaces behind translucent overlays.
- Avoid pure black on pure white everywhere; use depth and hierarchy deliberately while preserving contrast.
- Keep elevation restrained and consistent with platform conventions; Android tonal elevation and Apple materials are not identical visual concepts.
- Respect OS high-contrast, reduced-transparency, and user theme preferences where possible.

### 10.6 Icons and imagery

- Use **one semantic icon vocabulary**, with Apple-style and Material-style realizations if the visual conventions differ.
- Prefer appropriate platform symbol families (e.g., SF Symbols on Apple where integration/licensing permits; Material symbols on Android); avoid forcing a foreign icon style into OS chrome.
- Avoid mixing unrelated icon packs within one screen.
- Supply true high-density raster assets, correctly sized vector assets where supported, and platform-correct app icon variants.
- Verify icon baselines, stroke weight, anti-aliasing, fill/cutout, and 1×/2×/3× density results.

---

## 11. The interaction quality standard

### 11.1 Every action needs visible, appropriate state

For each interactive component define:

`resting → hovered (if pointer) → focused → pressed → loading → success/error → disabled`

- Do not let buttons silently ignore rapid taps; guard repeat submissions and show progress.
- Use optimistic updates only when recoverable and backed by rollback/error handling.
- Show state transitions consistently, but let native control behaviors dominate where they are more appropriate.
- Communicate destructive outcomes clearly and provide Undo when sensible.

### 11.2 Motion: fast, purposeful, system-aware

- Animate **relationships**, not decoration: where content came from, where it went, and which item changed.
- Prefer platform page and modal transitions over one custom global animation.
- Use a consistent short motion scale for app-owned microinteractions; tune by interaction purpose and device rather than blindly applying one duration.
- Maintain stable scroll position and avoid layout jump during async loading.
- Respect reduced-motion accessibility settings; provide transitions that remain comprehensible without movement.
- Heavy blur, continuous shimmer, oversized spring animations, and large hero transitions can reduce perceived polish and real performance.

### 11.3 Scrolling and input

- Avoid fighting native scrolling with nested unconstrained scrollables.
- Keep a single clear primary scroll owner wherever possible; resolve nested gestures deliberately.
- Use distinct focus and hover visuals on web and desktop. Do not rely on the same color for hover and selection.
- Support keyboard dismissal/back behavior logically after text entry.
- Test pointer, touch, stylus, and keyboard inputs separately—"it works with a mouse" is not equal to "keyboard accessible."

### 11.4 State restoration and continuity

Persist as appropriate:

- Open route, selected workspace/record, unsaved draft, and applied filters.
- Scroll offset where return navigation implies continuity.
- Relevant window/pane layout, if the platform benefits from restoration.
- Reliable server state and conflict resolution across devices.

Do not silently share transient OS-specific presentation state such as a desktop popover or an iOS keyboard-open flag across devices.

---

## 12. Responsive and adaptive layout architecture in Flutter

### 12.1 Separate three independent axes

Never reduce adaptation to `if (Platform.isIOS)` or `if (width > 600)`.

Use three different questions:

1. **Operating environment:** iOS, Android, macOS, web, etc. Which OS conventions and integrations apply?
2. **Available space:** compact, medium, expanded. What composition fits *this window right now*?
3. **Input capabilities:** touch, mouse, trackpad, stylus, hardware keyboard. How can the user interact *right now*?

For example, an iPad with a mouse and a 520-logical-pixel window is still iPadOS, but requires a compact layout and pointer-aware controls.

### 12.2 Example Flutter environment and window-class resolver

The following code uses supported, ordinary Flutter APIs. **The breakpoints are illustrative product decisions, not magic platform-detection constants.**

```dart
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

enum ProductPlatform { appleMobile, macOS, android, web, other }
enum WindowClass { compact, medium, expanded }

ProductPlatform currentProductPlatform() {
  if (kIsWeb) return ProductPlatform.web;

  switch (defaultTargetPlatform) {
    case TargetPlatform.iOS:
      return ProductPlatform.appleMobile; // Could be iPhone or iPad.
    case TargetPlatform.macOS:
      return ProductPlatform.macOS;
    case TargetPlatform.android:
      return ProductPlatform.android;
    default:
      return ProductPlatform.other;
  }
}

WindowClass classifyWindow(double availableWidth) {
  if (availableWidth < 600) return WindowClass.compact;
  if (availableWidth < 840) return WindowClass.medium;
  return WindowClass.expanded;
}

class AdaptiveLayout extends StatelessWidget {
  const AdaptiveLayout({
    super.key,
    required this.compact,
    required this.medium,
    required this.expanded,
  });

  final Widget compact;
  final Widget medium;
  final Widget expanded;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        switch (classifyWindow(constraints.maxWidth)) {
          case WindowClass.compact:
            return compact;
          case WindowClass.medium:
            return medium;
          case WindowClass.expanded:
            return expanded;
        }
      },
    );
  }
}
```

**Engineering notes:**

- Use `LayoutBuilder` where a component's **actual allocated space** matters, and `MediaQuery.sizeOf(context)` when the **app window** matters.
- Avoid `Platform.isIOS` in web-compiled code; `kIsWeb` and Flutter's target-platform APIs are safer for cross-platform builds.
- Use actual input signals and focus/pointer mechanisms for capability-aware behavior, not device-name heuristics.
- Keep layout decision code testable and explicit; evolve breakpoints based on component constraints and UX tests.
- Avoid orientation-only branching: landscape on a narrow window is still narrow.

### 12.3 Application architecture

```text
lib/
├── app/
│   ├── app.dart
│   ├── router.dart
│   ├── app_state.dart
│   └── bootstrap.dart
├── core/
│   ├── domain/             # Models, use cases, validation
│   ├── data/               # Repositories, API, cache, sync
│   ├── services/           # Auth, telemetry, persistence
│   └── capabilities/       # Device/OS feature interfaces
├── design_system/
│   ├── tokens/             # Brand foundations + semantic roles
│   ├── platform/           # Apple/Android/macOS/web mappings
│   ├── primitives/         # Text, layout, surfaces, spacing
│   ├── adaptive/           # UI components with platform variants
│   └── motion/             # Motion intent + accessibility
├── features/
│   └── feature_name/
│       ├── domain/
│       ├── data/
│       ├── presentation/
│       │   ├── controller.dart
│       │   ├── content.dart  # Shared task/content presentation
│       │   └── screens/     # Shell/size variants where needed
│       └── widgets/
├── shells/
│   ├── ios_shell.dart
│   ├── ipad_shell.dart      # Adaptive Apple large-window shell
│   ├── macos_shell.dart
│   ├── android_shell.dart
│   ├── android_large_shell.dart
│   └── web_shell.dart
└── integrations/
    ├── notifications/
    ├── share/
    ├── files/
    ├── permissions/
    └── native_bridge/
```

**Rule:** Share domain code and feature content where beneficial; use **platform presentation adapters** when the interaction contract differs. Avoid creating six copies of the same business logic or one universal screen with 200 nested platform checks.

### 12.4 Suggested component abstraction

```text
AdaptivePageShell
AdaptivePrimaryNavigation
AdaptiveToolbar
AdaptiveActionMenu
AdaptiveDialog / AdaptiveConfirmation
AdaptiveSheet / AdaptivePopover
AdaptiveTextInput
AdaptiveSelectionControl
AdaptiveContextMenu
AdaptiveListDetail
AdaptiveScrollable
AdaptiveFeedback
```

Each adaptive component should have:

- A single semantic API (`title`, `items`, `onSelect`, `isDestructive`, etc.).
- Platform-specific implementations where behavior or styling warrants it.
- A test matrix of platform, light/dark, text scale, window width, input type, and accessibility states.
- Documented fallbacks when a native integration does not exist.

### 12.5 Flutter widgets and integrations to evaluate

| Need | Starting points | Caution |
|---|---|---|
| iOS patterns | `CupertinoNavigationBar`, `CupertinoSliverNavigationBar`, `CupertinoTabBar`, `CupertinoActionSheet`, `CupertinoDatePicker` | Cupertino widgets do not automatically recreate every current iOS system appearance or behavior |
| Android UI | Material 3 `ThemeData`, `NavigationBar`, `NavigationRail`, `AppBar`, `BottomSheet`, `FloatingActionButton` | Confirm Material version and styling against current Android guidance |
| Simple adaptive input | `Switch.adaptive`, `Slider.adaptive`, `CircularProgressIndicator.adaptive`, `AlertDialog.adaptive` | Adaptive constructors cover only some component choices; test actual results |
| Window-responsive UI | `LayoutBuilder`, `MediaQuery`, `SafeArea`, `Sliver*`, constraints | Use app window/allocated space, not physical screen size |
| Keyboard and focus | `Shortcuts`, `Actions`, `Focus`, `FocusTraversalGroup`, `CallbackShortcuts` | Implement expected platform shortcut variants and avoid browser conflicts |
| Pointer | `MouseRegion`, hover/focus states, pointer-device-aware interaction | Hover cannot be the only way to discover an essential action |
| Mac native menu | `PlatformMenuBar`, `PlatformMenu`, `PlatformMenuItem` | macOS-specific native menus; verify menu delegate and app lifecycle |
| OS APIs | Flutter plugins, platform channels, Swift/Objective-C, Kotlin/Java, AppKit/UIKit/SwiftUI integration | Verify plugin maintenance and support for each target OS/version |
| Routing | Router-based navigation with platform-aware transitions/deep links | Browser URLs, Android Back, iOS swipe Back, and nested stacks must agree |
| Accessibility | `Semantics`, `MergeSemantics`, text scaling, focus controls | Screen-reader behavior requires hands-on testing, especially on web |

**Platform-view escape hatch:** If the product critically depends on OS-exact menus, sheets, current Apple materials, advanced text editing, specialized file interactions, or other native widgets that Flutter cannot faithfully provide, use a **native view/plugin** or platform-specific implementation for that bounded feature. One codebase does not mean every pixel must be painted by Flutter.

---

## 13. Cross-platform navigation, state, and deep-link contract

### 13.1 Standardize destinations, adapt the shell

Example shared product destinations:

```text
Home
Search
Saved
Workspace / Projects
Account / Settings
```

Map them differently:

- **iPhone:** Top-level tab bar; push into details; contextual sheet for temporary tasks.
- **iPad:** Sidebar and persistent detail; compact layout uses a more mobile-like navigation model.
- **Mac:** Sidebar, command-capable toolbar, optional inspector; native menu bar mirrors frequent commands.
- **Android phone:** Material navigation bar, top app bar, system Back semantics.
- **Android tablet:** Navigation rail/drawer plus list-detail.
- **Web:** URL-aware top nav/sidebar and browser-history-compatible routes.

### 13.2 Keep route identity stable

A domain route such as `/projects/123` should identify the same project across platforms even when its display is:

- A full-screen pushed detail on iPhone.
- The right pane beside a project list on iPad.
- A selected desktop detail within a macOS multi-pane window.
- A browser-accessible URL with functional Back/Forward.

**Invariant:** Route and task state belong to the product; shell placement belongs to the platform.

### 13.3 Back/dismiss rules

- **iOS:** Back goes to the previous hierarchy level; sheets dismiss according to the modal contract; edge swipe should be preserved where appropriate.
- **Android:** System Back first resolves topmost transient UI and correct navigation history; predictive Back should show the appropriate destination when supported.
- **macOS:** Escape dismisses compatible transient elements; `⌘W` closes the appropriate window/document; navigation commands are explicit.
- **Web:** Browser Back/Forward are authoritative for browser history; closing a dialog may or may not modify history depending on the design, but must be consistent.

---

## 14. Crisp, premium visual finish: the pixel-level checklist

### 14.1 Sharp rendering

- Use high-resolution raster assets and properly scaled vector assets; verify at real device pixel ratios.
- Align hairlines to physical pixels when necessary; a 1-physical-pixel line can be calculated from device pixel ratio, but do not blindly force this on all controls.
- Audit clipping, corner masking, anti-aliasing, icon alignment, and blur around rounded containers.
- Avoid upscaling small screenshots, avatars, logos, or bitmaps.
- Check image cropping and focal points for compact, tablet, desktop, and web aspect ratios.
- Inspect shadows and translucency on OLED/dark backgrounds and high-density external displays.

### 14.2 Text and hierarchy

- Verify rendering at actual device scales, not only emulator screenshot scale.
- Check line heights, truncation, long languages, RTL, mixed scripts, numerals, and dense data labels.
- Avoid fonts that render beautifully in a static design but look soft or awkward in Flutter at small sizes.
- Use consistent numeral alignment for data tables and financial/statistical values where relevant.
- Apply an intentional minimum and maximum content width, especially on desktop and tablets.

### 14.3 Layout and micro-spacing

- Eliminate 1–2 px alignment errors at tab items, labels, icons, badges, and field suffix/prefix controls.
- Make all touch targets large enough without increasing visible chrome unnecessarily.
- Standardize empty, loading, error, and success compositions as carefully as populated screens.
- Avoid abrupt content flashes when switching Dark Mode, changing orientation, or opening a keyboard.
- Use skeleton states only when they improve comprehension and never flash them for extremely quick tasks.

### 14.4 Performance is visual design

- Use `const` constructors, efficient widget composition, and scoped state updates where useful.
- Prefer lazy lists/grids (`ListView.builder`, `GridView.builder`, slivers) over building very large widget trees at once.
- Profile raster/UI performance and expensive layers; minimize unnecessary saveLayer/opacity/blur work.
- Compress/resize images for actual display needs; cache intentionally and handle low-memory conditions.
- Avoid synchronous expensive work on the UI isolate; use appropriate async/background processing.
- Monitor scroll stutters, startup time, jank during route transitions, gesture lag, and form input latency.
- Test on **midrange Android hardware** and older supported Apple devices, not only flagship simulators.

---

## 15. Accessibility is a native-feel requirement

A premium app must work for people who use assistive technology, alternate input, larger text, and reduced motion.

**Always:**

- Provide meaningful semantic labels, state descriptions, roles, and action hints.
- Ensure all functions are keyboard reachable with visible focus order and focus indication.
- Support screen readers: VoiceOver on Apple, TalkBack on Android, and common browser/screen-reader combinations on web.
- Respect system text scaling and layout reflow; don't disable scaling to preserve a mockup.
- Use sufficient contrast and distinguish important states without color alone.
- Provide touch targets appropriate to platform guidance (often roughly **44 pt on Apple touch UIs** and **48 dp on Android** as design heuristics; verify current guidelines and exceptions).
- Respect reduced motion and avoid mandatory animation for completing tasks.
- Ensure dialogs trap/restore focus appropriately and announce their purpose.
- Make error messages specific, discoverable, and associated with the relevant form field.
- Test drag-and-drop alternatives, accessible menus, and selection actions without relying on gestures alone.
- Treat **WCAG 2.2 AA** as an appropriate baseline for web accessibility, while also validating platform-specific mobile guidance.

**Beware:** A Flutter screen can look visually perfect and still have incorrect semantic reading order, invisible focus, or web accessibility activation issues. Test behavior, not screenshots alone.

---

## 16. Platform services and OS integration checklist

| Service or concern | iOS/iPadOS | macOS | Android | Web |
|---|---|---|---|---|
| Login/auth | System sign-in and biometrics where suitable | Secure login + OS keychain patterns | Credential/biometric APIs | Browser redirects/passkeys where suitable |
| Sharing | System share sheet | Native sharing/clipboard | Android Sharesheet | Web Share API when supported + copy fallback |
| File input | Native document/photo pickers | Open/Save panels + Finder/drop | System pickers | Browser file picker / drag-drop |
| Deep links | Universal links | Registered links where appropriate | App Links | First-class browser routes |
| Notifications | Apple permissions, actions, badges | Native notifications | Channels, runtime permission, actions | Browser push only where justified/supported |
| Local data | Appropriate secure storage / app sandbox | App support directories, secure storage | Android scoped storage | Browser storage constraints and privacy |
| Background work | OS-limited, policy-compliant | Desktop lifecycle | Android lifecycle/background restrictions | Browser tab suspension limits |
| Windowing | Primarily phone screen | Multi-window/fullscreen | OS dependent | Browser windows/tabs |
| OS appearance | Dark Mode, text scale, accessibility | Appearance, accent, reduced motion | Dynamic color, contrast, font scale | Theme, browser/OS preferences |

**Implementation note:** Support depends on the Flutter/plugin version, host OS version, entitlements, browser capability, and store policy. Every integration needs a documented fallback and a real-device test.

---

## 17. Real device test matrix

Test **combinations**, not just one emulator per OS.

| Environment | Minimum representative tests |
|---|---|
| iPhone | Small and large supported displays; light/dark; normal/max supported text; gesture navigation; keyboard; VoiceOver |
| iPad | Portrait/landscape; narrow and wide multitasking windows; trackpad/keyboard; Pencil if applicable; VoiceOver |
| macOS | Laptop and external display sizes; narrow/large windows; menu bar; multiple windows; full-screen; keyboard only; VoiceOver |
| Android phone | Small/midrange and high-density device; gesture and 3-button navigation if supported; predictive Back; TalkBack; font scale |
| Android tablet/foldable | Narrow/wide window; rotation; fold/unfold; keyboard/mouse; split screen; hinge layout |
| Web desktop | Chrome, Safari, Firefox, Edge as supported; 100% and 200% zoom; keyboard-only; screen reader; slow network |
| Web mobile | Mobile Safari and Chrome; browser Back; virtual keyboard; rotation; tap, selection, and scroll |

### 17.1 A single golden user journey

Repeat the **same user goal** on every platform:

1. Launch the app and understand the home screen.
2. Navigate to a feature and open a detail item.
3. Create/edit something; intentionally enter invalid input once.
4. Recover from the error; save or submit successfully.
5. Navigate Back or dismiss an overlay.
6. Search, select, copy, and share an item where supported.
7. Switch Dark Mode or text scale and confirm state is preserved.
8. Background/resume or refresh/reopen the app and confirm continuity.
9. Perform the same flow using keyboard/screen reader when available.

Judge **equivalence of outcome** and **nativeness of interaction**, not identical tap counts.

### 17.2 Screenshot and behavioral regression strategy

- Capture platform-specific **golden screenshots** at representative widths/themes/text scales; do not compare iOS pixels directly to Android pixels.
- Maintain semantic/interaction tests for route state, Back/dismissal, focus, loading/error, and permission-denied behavior.
- Use performance benchmarks on representative hardware.
- Add manual platform-advocate review by people who regularly use each OS.
- Re-run the native-feel audit after major iOS, Android, macOS, Flutter, and browser changes.

---

## 18. Engineering quality gates and definition of done

### P0 — Release blockers

- Essential flow fails or loses user data on any supported platform.
- System Back/route history is broken; core controls are inaccessible; screen-reader traversal is unusable for essential tasks.
- Content is hidden under system bars/hinge/keyboard; a window resize corrupts UI state.
- App crashes, cannot launch, or has a platform-policy/security issue.

### P1 — Native-feel blockers

- iOS feels like Android or Android feels like iOS in primary navigation and core controls without product justification.
- macOS lacks essential keyboard/menu/window behavior.
- iPad/Android tablet is merely a stretched phone UI despite room for productive layout.
- Web breaks URLs, browser history, focus, normal browser interactions, or basic screen-reader operation.
- Major jank, unreadable Dark Mode, or severe layout clipping occurs in a key flow.

### P2 — Premium polish

- Typography/baseline spacing inconsistencies, mismatched icon weight, visual clipping, low-resolution assets.
- Small motion timing inconsistencies, placeholder flicker, missing hover refinement, overly heavy shadows.
- Inconsistent copy tone, empty-state composition, selection affordances, or scrollbar finish.

### 18.1 Pull request review checklist

- [ ] Product feature behavior matches the shared domain contract.
- [ ] Navigation, controls, and dismiss/back behavior match each affected platform.
- [ ] Window size is handled independently of OS/device category.
- [ ] Touch, pointer, keyboard, and accessibility states have been considered.
- [ ] Dark mode, text scaling, RTL/long text, and empty/error/loading states are verified.
- [ ] OS integrations use correct permission/lifecycle behavior and graceful fallbacks.
- [ ] Images, icons, text, separators, surfaces, and animations pass visual polish review.
- [ ] Performance does not regress on representative low/midrange devices.
- [ ] Platform-specific screenshots/tests were added or updated as appropriate.

---

## 19. Recommended implementation order

### Phase 1 — Set the product contract

- Identify all features, domain states, top-level destinations, and end-to-end user outcomes.
- Build semantic brand tokens and content guidelines.
- Decide which behaviors must be identical and which must be platform-specific.
- Define a capability matrix and supported OS/browser versions.

**Deliverable:** Shared product specification + platform adaptation decisions.

### Phase 2 — Prototype the six native shells

- iPhone: tabs, push, sheets, scrolling, system controls.
- iPad: sidebar, list-detail, multitasking resize.
- Mac: windows, menu bar, keyboard, toolbar, native file workflows.
- Android phone: Material nav, edge-to-edge, predictive Back.
- Android large screens: rail, supporting pane, fold/resize.
- Web: URLs, keyboard/focus, browser Back, responsive workspace.

**Deliverable:** One representative task flow, fully usable per target—not just static screenshots.

### Phase 3 — Build the adaptive design-system layer

- Create semantic tokens and platform-specific component mappings.
- Implement navigation-shell, menu, picker, sheet, dialog, control, and responsive pane adapters.
- Extract shared feature content and domain logic.
- Wire OS capability interfaces only where needed.

**Deliverable:** A reusable adaptive component catalogue with native behavior tests.

### Phase 4 — Implement features and integrations

- Build shared feature logic; attach platform-native presentations where justified.
- Add native share/file/notification/auth integration with permission/fallback handling.
- Add routing/deep linking, state restoration, and sync behavior.

**Deliverable:** Feature parity of core outcomes, with intentional OS-specific interaction differences.

### Phase 5 — Native-feel and performance audit

- Run real-device platform review with dedicated Apple, Android, Mac, and web advocates.
- Fix P0/P1 issues first; then optical polish, asset sharpness, haptic/motion refinement, and transition smoothness.
- Confirm accessibility, network failure, lifecycle, large text, and browser history.

**Deliverable:** Platform-specific release sign-off and regression suite.

---

## 20. Common mistakes to avoid

1. **One `MaterialApp` skin everywhere, called "native".** A shared root is fine; identical component behavior everywhere is not automatically native.
2. **One `CupertinoApp` everywhere, called "premium".** Apple-looking controls are inappropriate on many Android/web surfaces.
3. **Assuming a big screen means an iPad/tablet.** Window size, platform, and input capabilities are different axes.
4. **Using only breakpoints without interaction adaptation.** A three-column layout that cannot be keyboard-driven is not desktop-quality.
5. **Treating Mac as iPad with a pointer.** Mac needs menu bar, windowing, keyboard-first workflows, and different modal conventions.
6. **Treating web as another full-screen native app.** Browser history, URL semantics, focus, selection, accessibility, and loading are essential.
7. **Faking native effects.** A custom blur, status bar, swipe gesture, or context menu may be less native than using a proven platform implementation.
8. **Over-branding controls.** App identity should not interfere with system-recognizable interactions.
9. **Removing accessibility to preserve visual fidelity.** Do not clamp text scale or remove focus outlines without an accessible equivalent.
10. **Testing only simulators and flagship phones.** Real midrange hardware, wide windows, system settings, and screen readers expose the most serious gaps.
11. **Trying to achieve premium design using shadows, glass, and animations alone.** Precision, responsiveness, hierarchy, and correctness matter more.
12. **Creating six disconnected codebases.** Share the product domain and state; specialize presentation only where necessary.

---

## 21. Final design-review scorecard

Rate each dimension from **0 (missing)** to **5 (excellent)** for every supported platform. A combined average must not hide a serious failure in one platform.

| Dimension | What reviewers should ask |
|---|---|
| Product identity | Can a user instantly recognize this as the same product? |
| Platform familiarity | Would a regular user of this OS expect this control/navigation? |
| Interaction correctness | Do Back, scroll, select, edit, dismiss, and drag behave predictably? |
| Input adaptability | Does it work well with the inputs available on this device? |
| Responsive composition | Is the current window used intelligently without stretching or clipping? |
| OS integration | Do native features, permissions, and system UI behave correctly? |
| Crisp visual finish | Are icons, type, spacing, separators, surfaces, and assets precise? |
| Performance | Is interaction immediate and motion smooth on target hardware? |
| Accessibility | Can assistive technology and alternate input complete core tasks? |
| Reliability | Do state restoration, lifecycle changes, links, and failures behave safely? |

**Release rule:** No P0/P1 issues; core user journeys should meet an agreed minimum score on **each** target individually. Record justified deviations instead of disguising them with an average.

---

## 22. Copy-paste team directive / master implementation brief

> Build a premium Flutter application for iPhone/iOS, iPad/iPadOS, macOS, Android phones, Android tablets/foldables, and web from one coherent product architecture. Share brand identity, domain models, business logic, feature meaning, and content semantics. Do **not** force identical UI across platforms. Design each OS shell around its native information architecture, navigation, control vocabulary, input methods, gesture physics, windowing model, accessibility behavior, and system integrations. On iPhone prioritize elegant touch navigation, iOS-style sheets, edge-swipe Back, safe areas, Dynamic Type, and OS-consistent text and haptics. On iPad prioritize multitasking, sidebars, multi-pane workflows, keyboard/trackpad/Pencil support, and adaptive resize. On macOS deliver genuine desktop behaviors: native menu bar, title/toolbar integration, resizable windows, keyboard shortcuts, precise selection, context menus, and file workflows. On Android honor Material 3, edge-to-edge, state feedback, system/predictive Back, and native pickers. On Android tablets and foldables use window-aware navigation rails, list-detail panes, and hinge-safe layouts. On web honor URLs, browser navigation, keyboard focus, text selection, browser conventions, accessibility, and startup performance. Build a layered semantic design system with platform mappings and adaptive components; share the task, not necessarily the pixels. Every screen must pass real-device checks for native behavior, crisp typography, optical alignment, light/dark modes, text scaling, loading/error states, accessibility, performance, and responsive continuity. **The standard is: same product, genuinely native experience everywhere.**

---

## 23. Official references and further reading

These are primary-source reference starting points. Re-check them and package/platform documentation during implementation because OS design conventions and Flutter APIs evolve.

### Flutter

- [Adaptive and responsive design](https://docs.flutter.dev/ui/adaptive-responsive)
- [Automatic platform adaptations](https://docs.flutter.dev/ui/adaptive-responsive/platform-adaptations)
- [Platform idioms](https://docs.flutter.dev/ui/adaptive-responsive/idioms)
- [User input and accessibility](https://docs.flutter.dev/ui/adaptive-responsive/input)
- [Large-screen devices](https://docs.flutter.dev/ui/adaptive-responsive/large-screens)
- [Adaptive design best practices](https://docs.flutter.dev/ui/adaptive-responsive/best-practices)
- [Capabilities and policies](https://docs.flutter.dev/ui/adaptive-responsive/capabilities)
- [Platform integration](https://docs.flutter.dev/platform-integration)
- [Flutter web support](https://docs.flutter.dev/platform-integration/web)
- [Flutter web accessibility](https://docs.flutter.dev/ui/accessibility/web-accessibility)
- [Flutter performance best practices](https://docs.flutter.dev/perf/best-practices)
- [`PlatformMenuBar` API](https://api.flutter.dev/flutter/widgets/PlatformMenuBar-class.html)

### Apple

- [Apple Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/)
- [Designing for iOS](https://developer.apple.com/design/human-interface-guidelines/designing-for-ios)
- [Designing for iPadOS](https://developer.apple.com/design/human-interface-guidelines/designing-for-ipados)
- [Designing for macOS](https://developer.apple.com/design/human-interface-guidelines/designing-for-macos/)
- [Interface fundamentals](https://developer.apple.com/documentation/technologyoverviews/interface-fundamentals)
- [Layout](https://developer.apple.com/design/human-interface-guidelines/layout)
- [Design principles](https://developer.apple.com/design/human-interface-guidelines/design-principles/)

### Android

- [Android layout and navigation patterns](https://developer.android.com/design/ui/mobile/guides/layout-and-content/layout-and-nav-patterns)
- [Android large-screen design](https://developer.android.com/media/implement/surfaces/large_screens)

### Accessibility

- [WCAG 2.2](https://www.w3.org/TR/WCAG22/)

---

## Closing principle

**Native feel is achieved when nothing feels out of place.** The most premium cross-platform Flutter app is neither the most visually identical nor the most aggressively customized. It is the app that preserves one product identity while getting each platform's small expectations right—navigation, gestures, text, menus, focus, system bars, windowing, state, speed, and accessibility—on every real device that matters.
