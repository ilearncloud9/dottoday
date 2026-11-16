# Concept E reference renders

Pictures of the approved Concept E boards, cut from the Design canvas. Each app screen built for
Concept E must match its frame here (CLAUDE.md §11; plan M18–M22). Where a frame and the decision
log disagree, the decision log wins (ED-314).

- **Source:** Design canvas https://claude.ai/artifact/FmSwyPQt7FrCh3fXPkkXX9, version `1794787239-a691`.
- **Extracted:** 2026-11-16, by rendering each board file at its own size (headless Chromium) and
  cutting out every screen frame at its exact size.
- **Layout:** one folder per board (`e-phones/`, `e-phones-dark/`, …):
  - `_board.png` is the whole board, so a frame the finder could not cut out is still covered;
  - `frame-NN-WxH.png` is one screen frame. Common sizes: iPhone 390 × 844, Android 412 × 892, Mac
    and web windows 1280 × 800, tablets and scaled frames as drawn.
- **`index.json`** lists every board and frame with its position on the board, size, the board's
  label and caption text, and the decisions (ED-nnn) named on it.

## What is here

All 120 approved, active and reference board images (light and dark), with 976 screen frames:
- **Active product boards:** E-Phones, E-Phones-2, E-Phones-3, E-PhonesMinimal, E-Minimal, E-FullA-v2, E-Earlier, E-Responsive, E-MobileWeb, E-G4-3-Narrow.
- **Round 2:** E-R2-1 to E-R2-42, with option B of R2-19 (E-R2-19-B, E-R2-19-B-2). The option A board and the static R2-16 are history and are not here: onboarding's reference is the approved interactive prototype, https://claude.ai/artifact/3dgrJiQ8GGEdxgnD9PCvjL (ED-305, ED-351).
- **Approved reference boards:** E-G4-7-States, E-G4-7-Q4-KeepBoth, E-DF2, E-DF3, E-G4-6-Dark-Tokens, E-G2-5-OptionD-RefinedEditor, E-G2-11, E-G3-6-Decision, E-G3-6-Remaining, E-G3-6-Compat, E-G3-9b-Screens, E-WakeWindDown-Settings-Candidate, E-T1 to E-T4.

Six spec boards have no device frame (E-Responsive and its dark board, E-G4-6-Dark-Tokens, E-G2-11, E-G3-6-Remaining, E-G3-6-Compat); their `_board.png` is the reference.

## Notes

- Fonts and glass are the board's drawing: Manrope is loaded from Google Fonts; SF Pro and Roboto
  appear as each browser's system face; blur and vibrancy are approximations of the native materials.
- Option frames on history boards are not here; only approved, active and reference boards are.
- To refresh after a board changes: re-render that board from the canvas at the new version and
  replace its folder and its `index.json` entry.
