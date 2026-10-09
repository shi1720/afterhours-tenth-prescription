# AFTERHOURS — independent integration QA

**Run date:** 9 October 2026. **Engine:** Godot 4.5 stable (`876b29033`). **Platform:** macOS, headless native engine. **Result:** **4,545 assertions, 0 failures, exit code 0.** The final run produced no engine error or leak warnings.

The reproducible suite is `tests/test_game.gd`; complete captured output is `docs/HEADLESS_TEST_LOG.txt`.

```sh
Godot --headless --path . --script tests/test_game.gd
```

Use the installed Godot executable in place of `Godot`. Run from the project directory. Assets must first have been imported by Godot. The suite backs up `user://afterhours.cfg` byte-for-byte, uses fixture saves, and restores the original file on normal completion; if there was no prior save, it removes its fixture. Do not run it concurrently with a session writing progress. Do not force-kill the process during save tests.

## Verified behavior

| Area | Executed evidence |
|---|---|
| Ten wards | All ten authored ward definitions load; both languages have title, rule, patient and memory content. Each ward resets resources, objectives and revelation state. |
| Geometry | Every walkable tile is reachable from spawn. All record, cabinet, charger, hatch and enemy spawn positions have physical clearance and connected routes. Hazard tiles are walkable. |
| Player collision | Every ward traverses its actual exit path with 60Hz movement steps. Continuous attempted motion cannot cross shelving or boundary walls. |
| Objectives | An unrevealed record rejects E. A nearby SPACE pulse reveals it; E recovers it once. All three records gate the hatch. A finished ward stops and emits one completion signal. |
| Full gameplay routes | All ten wards complete with active enemies and hazards in normal mode, using 60Hz movement, real charge expenditure, real cooldowns, record revelation and hatch interaction. No teleporting or invulnerability overrides in this route test. |
| Enemy behavior | 1,200 simulation steps on the final ward keep every enemy on walkable cells. Patrol advances; nearby player triggers pursuit; a moved player causes a replanned route; pursuit advances within one grid cell. Alarm attracts enemies across the ward. |
| Pulse | Costs 18 charge; nearby enemies are stunned for 4.5 seconds. Stunned enemies remain still. Cooldown rejects repeated activation; insufficient charge and hiding reject pulses. |
| Hiding and damage | Cabinet interaction enters/exits hiding. Hiding prevents movement and contact damage. Contact deals damage outside hiding and grants a grace interval. Lethal contact emits failure once and stops simulation. |
| Hazards and resource management | Active/inactive hazard phases and gentle damage scaling verified. Filament ward drains 1.25 charge/second. Charging restores charge and 25 resolve; station cooldown prevents repeated refill. |
| First run and tutorial | First campaign and ward selection both require local profile. Named first-time player sees the six-page guide. All six pages construct; completing the guide enters briefing. |
| Application flow | English and Korean title, profile, guide, ward select, archive, settings, credits, failure, demo end, choice and both endings construct. This checks UI construction, not visual quality. |
| Pause | Physical ESC key pauses; player position and resources remain frozen. Pause settings remain frozen. Switching language preserves the return-to-pause route. ESC resumes the existing ward state. |
| Demo isolation | Demo begins at Ward 1. Completing its three wards preserves campaign checkpoint, unlocks, memories and the save file byte-for-byte. Returning to the campaign restores its prior checkpoint. |
| Persistence | Profile, checkpoint, archive, language, gentle mode, volume, motion, high visibility and ending reload. Completed campaign offers ward replay. Invalid profile length, indices, language, volume and archive entries are bounded/sanitized. |
| Accessibility settings | Ward entry applies high visibility, motion and gentle preferences. |

## Deterministic route observations

This is an efficient automated pilot with exact map knowledge, shortest record routing, and emergency pulses near enemies. These times are **not human completion-time estimates**, and this test does not prove the game is difficult, frightening or enjoyable.

| Ward | Simulation seconds | Resolve at exit | Charge at exit |
|---|---:|---:|---:|
| 01 | 13.97 | 100.0 | 24.2 |
| 02 | 14.53 | 100.0 | 59.8 |
| 03 | 13.83 | 100.0 | 60.3 |
| 04 | 15.15 | 100.0 | 59.4 |
| 05 | 16.35 | 100.0 | 58.6 |
| 06 | 13.95 | 100.0 | 52.6 |
| 07 | 13.32 | 100.0 | 60.7 |
| 08 | 12.15 | 100.0 | 61.5 |
| 09 | 16.33 | 100.0 | 40.6 |
| 10 | 15.73 | 92.4 | 41.0 |

## Defects caught and retested

The review identified disconnected floor pockets in the earlier Ward 4/8 geometry, a pause-settings language-switch return-context regression, and a tutorial implementation-variable leak. Final geometry connectivity and pause-settings regression checks pass. The tutorial wording was corrected in implementation. Enemy chase replanning and same-cell pursuit received explicit regression tests after their corrections. The suite was updated when the pulse-to-reveal mechanic was added; its initial failures correctly caught obsolete direct-pickup assumptions.

An earlier fast headless shutdown produced an ambience playback/resource warning. This test disables ambience playback in its application fixture and explicitly stops other audio players before cleanup. The clean final run therefore does **not** establish production audio shutdown behavior.

## Remaining release checks and honest limits

- This suite did **not** launch a real web browser or exercise the exported WebAssembly build. Browser input capture, audio-unlock gestures, IndexedDB persistence, resize/fullscreen behavior and multiple-browser compatibility require separate browser verification.
- Ambience playback is disabled in the application fixture. Listening quality, mix, browser audio activation and long-session playback require a human/audio-capable run.
- Native input events are invoked through the application's handler; OS-level keyboard focus, controller support and mobile/touch behavior are not tested here.
- The UI is constructed in both languages, but headless assertions cannot judge clipping, font rendering, contrast or aesthetics. Visual screenshot inspection is a separate QA activity.
- The test pilot has perfect knowledge. It does not establish first-player comprehension, Korean translation fluency, horror impact, human difficulty balance or commercial demand. Native Korean review and human playtesting remain valuable.
- Save restoration is tested after normal completion. Crash/forced termination during the fixture-save window is not covered. Cloud sync and authentication are outside this local-profile game's implemented scope.

## Independent readiness judgment

The mechanics and application state are coherent and testable; the authored ten-ward campaign, pulse-to-reveal decision, local progression, isolated demo and bilingual UI form a complete compact game-jam build. The evidence supports a release candidate for the verified native simulation, rather than a claim of exhaustive production certification. Final browser verification, visual review and player feedback remain necessary before broad commercial release.
