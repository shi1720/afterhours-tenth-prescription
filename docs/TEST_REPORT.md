# AFTERHOURS integration test report

**Final result: 9,043 assertions, 0 failures, exit code 0.** Engine: Godot 4.5 stable, macOS native headless. The final log contains no script errors or resource-leak warnings. This report describes the current English-only game.

Run from the project directory after importing assets:

```sh
Godot --headless --path . --script tests/test_game.gd
```

The executable may require its full installed path. Complete captured evidence is in `HEADLESS_TEST_LOG.txt`. The suite backs up `user://afterhours.cfg` byte-for-byte and restores it after normal completion. Do not force-kill the suite or run it concurrently with a save-writing game session.

## Executed coverage

| Area | Evidence |
|---|---|
| Campaign geometry | Ten authored wards. Every floor tile reachable from spawn. Records, cabinets, charger, hatch and enemy spawns have physical clearance. Real 60Hz movement traverses every ward's exit route. Shelving and outer walls block player movement. |
| Full gameplay | All ten wards completed in normal mode with active enemies/hazards, real charge consumption and cooldowns, pulse revelation, stationary recovery and hatch interaction. No health/charge resets, teleporting, enemy removal or invulnerability overrides occur within these full routes. |
| Pulse tradeoff | Costs 24 charge, normal stun 2.6 seconds, gentle stun 4.5 seconds, cooldown 4.2 seconds. Insufficient charge, hiding and cooldown reject activation. Noise alerts distant enemies to the pulse location. |
| Recovery | Sealed records reject E. Pulse reveals them. E starts recovery rather than instant collection. Standing still completes the channel; movement cancels it. Restarting recovers one name. Three names gate the hatch. Completion emits once. |
| Enemy pressure | Patrol advances over 1,200 steps. Enemy centers and bodies stay clear of solid walls. Pursuit replans, follows within a cell and closes distance on noisy running in the final ward. Walls block sight; quiet movement behind a shelf stays outside hearing range; louder movement alerts enemies. Alarm attracts enemies across the ward. |
| Meaningful shelter | Exposed camping near a pursuer eventually fails. Cabinet hiding survives an equivalent 15-second exposure window without damage. Hiding also freezes player movement. |
| Survival resources | Damage grace interval, lethal failure signal, no duplicate stopped-simulation failure, hazard phases and gentle damage scaling, increased Filament battery drain, charger refill/healing and charger cooldown. |
| First-run UX | Local profile gate, ward-selection profile gate, six guide pages, briefing, campaign continuation, replay selection and both endings. |
| English presentation | All six guide pages, ten ward briefings and application screens construct. Visible labels/buttons use English and avoid em dashes. Fixed labels and compact resource bars stay within the viewport; shaped lines fit label heights. Scrollable archive content is excluded from fixed viewport bounds. |
| Desktop/mobile bridge | Normalized/clamped movement, quiet mode, pause/resume, mute/unmute, reset confirmation, compact HUD preserving ward position, resource bars reflecting actual values, and focus loss pausing and clearing touch controls. These are bridge-handler tests, not real browser input tests. |
| Persistence | Name, checkpoint, unlocks, archive, gentle mode, volume, motion, high visibility and final ending reload. Bad profile lengths, indices, volume and archive entries are bounded/sanitized. Original user save restored. |

## Actual normal-mode route observations

The pilot knows the map, takes short routes, pulses when an enemy is close, and waits for real recovery. These times are not estimates of a new player's experience. Normal-mode wins demonstrate completable routes; they do not prove difficulty balance or horror impact.

| Ward | Seconds | Resolve at exit | Charge at exit |
|---|---:|---:|---:|
| 01 | 19.52 | 66.0 | 38.3 |
| 02 | 20.73 | 100.0 | 13.5 |
| 03 | 20.02 | 100.0 | 14.0 |
| 04 | 20.90 | 95.2 | 13.4 |
| 05 | 22.47 | 66.0 | 12.3 |
| 06 | 20.85 | 100.0 | 4.7 |
| 07 | 18.68 | 32.0 | 14.9 |
| 08 | 17.25 | 85.9 | 39.9 |
| 09 | 23.77 | 66.0 | 11.4 |
| 10 | 21.60 | 55.8 | 12.9 |

Earlier, simpler mechanics yielded mostly damage-free runs. The new chase speed, exposure channel, pulse noise and longer cooldown create observable damage and charge pressure. A reckless stationary player loses, while shelter remains effective. This is a stronger mechanical foundation, although only human playtesting can judge whether it feels fair and frightening.

## Defects caught and corrected

- Disconnected floor pockets in earlier layouts.
- Oversized cached Label minimum heights caused by assigning text before initial width.
- Enemy body clipping at path corners despite the center remaining in a floor cell. The corrected route centering and collision check pass the body-clearance regression.
- Compact progress bars extending outside their sidebar. The corrected size/style setup passes viewport bounds checks.
- Earlier language-switch pause-context regression, superseded by the current English-only interface.

Fixture cleanup stops and clears audio streams before freeing application nodes and waits for deferred disposal. This resolves rapid-headless-shutdown warnings in the final run. It is not a production audio-quality test and does not mute or modify the shipping engine.

## Honest limits

- This suite does not launch a browser. WebAssembly loading, Firebase headers, actual touch/keyboard delivery, browser audio activation, storage persistence, fullscreen, responsive CSS and real-device compatibility require separate acceptance evidence.
- Native screenshots were captured and visually inspected for the independent judge review. Automated label bounds cannot establish contrast, mobile readability or aesthetic quality.
- Automated audio listening, human first-player comprehension, scare response, accessibility user testing, commercial demand and unmeasured playtime claims are outside this suite.
- Save restoration is verified on normal completion, not forced termination during fixture writes.
- The current product uses a local profile. It does not implement cloud accounts, cloud sync or multiplayer.

Read `JUDGE_REVIEW.md` for independent qualitative judgment and remaining priorities.
