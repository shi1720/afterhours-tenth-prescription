# Release candidate scope and player notes

## Included scope

Ten sequential wards, three sealed records per ward and thirty fictional names across ten authored layouts, a dispensing hatch objective, defensive light pulse, hiding cabinets, charging stations, escalating threats and a final story choice. The interface includes English/Korean selection, local profiles, tutorial, campaign, separate demo, pause, retry and settings. Read `QA_SELF_REVIEW.md`, `TEST_REPORT.md` and `BROWSER_QA.md` for executed evidence and exact limits.

## Controls

WASD/arrows move. Hold Shift to sneak. Press E near a record, cabinet, charger or hatch. Press E again to leave hiding. Space emits a pulse when sufficient battery is available. Pulse within 165 pixels of a sealed record to reveal it, then E nearby to collect it. The same 18-charge pulse stuns nearby shadows for 4.5 seconds; each recovered name returns 8 charge. Escape pauses. Click the browser game first if keyboard input does not respond.

A charge restores battery and some composure; it also attracts shadows. Stations have a short reuse delay. Collect all three records before using the hatch. If caught, retry the current ward. Preserve browser data to keep local progress.

## Accessibility and content

Headphones are optional; objectives and resource information are visual. The horror uses low light, chasing spectral figures, alarm color and defensive pulse effects. This release does not claim full screen-reader support, complete keyboard remapping, controller support, mobile controls, certified photosensitivity safety or compliance with an accessibility standard. Settings offer master volume, a gentler mode, high visibility and atmospheric animation controls. Gentler mode reduces pursuer speed and damage; high visibility brightens darkness, and the atmospheric animation toggle disables pulse rings, title scanlines and filament flicker. It does not remove all hazard or alarm indicators. If light effects are uncomfortable, stop playing; no game can guarantee a universally safe visual experience.

## Storage and account boundaries

A profile is a local name and save slot, not an authenticated online identity. There are no passwords, cloud saves or cross-device synchronization. Browser private mode, cleared site data, storage eviction or a different origin can reset progress. Desktop persistence uses the application's Godot user-data directory. Never use the profile name to store sensitive information.

## Executed release evidence

- Godot 4.5 native headless suite: 4,945 assertions, 0 failures, clean exit, including all ten active-enemy objective routes.
- Real Chrome Web export at localhost: clean load, local profile and reload persistence, guide/skip, physical movement, all three Ward 1 reveal/collect actions and hatch completion, pause/settings, Korean switch and high visibility.
- Universal unsigned macOS export: headless startup smoke check exited 0 without errors. Windows/Linux exports were generated but not executed on this host.
- Actual two-minute gameplay video: `AFTERHOURS_GAMEPLAY.mp4`, with original audio. It has no spoken human narration.

Both public Pages deployments succeeded. The refined public title/menu was visually verified in Chrome; the localhost playthrough also verified Ward 2 checkpoint continuation after reload. The final packaged macOS startup smoke check passed again after the label patch. macOS signing/notarization, Windows/Linux execution, broad browser coverage, native Korean review and first-player balance remain outside the established evidence.

## Verification boundaries

This is a jam release candidate. Automated tests can check campaign reachability, state transitions and build validity; they cannot establish subjective enjoyment, human localization quality, broad hardware performance or commercial demand. Record the actual tested browser and build in the final QA report. Current limitations are finite scope choices, not hidden promises of future services.
