> Historical evidence from the earlier release. These observations do not certify the revised English-only mechanics, touch player or current Firebase build. Use RELEASE_CHECKLIST.md for current verification.

# Exported-browser acceptance record

**Date:** 9 October 2026. **Browser:** real Google Chrome, operated through computer-use automation. **Build:** exported Godot Web build served at `http://localhost:8732`. This record summarizes observations reported by the build lead; it is separate from the native headless suite. It is not a human playtest or cross-browser certification.

## Observed passes

- Exported game loaded cleanly and rendered the title/menu.
- Local profile creation and the first-time guide worked; guide skip entered the game flow.
- The profile and Continue flow persisted after a real browser reload on the same origin.
- Physical Right, Down and Left keys moved the player in the exported build.
- SPACE revealed a sealed record and E recovered it. All three records in Ward 1 were recovered through actual browser input.
- Using the hatch completed Ward 1 and displayed its memory/checkpoint transition.
- Pause and settings worked while the ward remained paused.
- Switching to Korean and enabling high visibility worked. Inspected labels were readable in that state.

## Exact boundaries

The recorded automated profile ended up as `Q` because of a text-entry automation issue. A short profile and normal profile flow were verified; rich text input, long Korean names and Korean IME composition were not established by this observation.

Only Ward 1 was fully completed in Chrome. The ten-ward full-route evidence comes from the separate native simulation suite. This browser session did not establish all browser endings, all guide pages, browser save-corruption recovery, every settings combination, fullscreen/resize behavior, other browsers, mobile devices, long-session stability, subjective audio quality or native Korean translation fluency.

Both public GitHub Pages builds and deployments succeeded. The refined build at commit 6eb70ed was opened in real Chrome at https://shi1720.github.io/afterhours-tenth-prescription/ and its title/menu rendered correctly. The localhost browser session also reloaded after Ward 1 completion and Continue opened the Ward 2 briefing, confirming the actual ward checkpoint persisted. Future hosted revisions need their own acceptance checks.

## Other artifact smoke checks

An unsigned universal macOS export was launched headlessly with `--quit-after 30`; it exited 0 without engine errors. This checks startup, not a human GUI playthrough or macOS signing/notarization. Windows and Linux exports were generated but were not run on this host. The final packaged macOS build was unzipped and rerun after the label patch; startup again exited 0 without errors.

## Video artifact

`AFTERHOURS_GAMEPLAY.mp4` is an actual generated gameplay recording with original game audio: 1280×720, 30 fps, approximately 119.83 seconds, approximately 6.2 MB. It is not a fabricated UI mockup and is not evidence of human input or a spoken presentation. The separate verbatim narration remains available for Shivam's optional voice recording.

## Media verification

The final MP4 was decoded with ffmpeg; sampled gameplay frames were visually inspected. Its audio stream has a measured mean of -29.7 dB and peak of -17.4 dB, without clipping. This verifies media structure and signal level, not subjective listening quality.
