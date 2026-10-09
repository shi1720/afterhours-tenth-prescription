# Current release verification

This checklist applies to the revised English-only product. Native results and browser observations establish different things. Device emulation is not a physical-device test. No first-player study or broad compatibility certification is claimed.

**Verification date:** 9 October 2026.

**Build identifier:** record the final committed/deployed revision before packaging.

## Native and content checks

| Check | Status | Evidence |
| --- | --- | --- |
| Error-free native suite and cleanup | Pass | Godot 4.5, macOS headless, 9,043 assertions, zero failures, clean exit |
| All ten actual normal-mode routes | Pass | Active threats, real charge, cooldowns and stationary recovery; see TEST_REPORT.md |
| Pulse costs and timing | Pass | 24 charge, normal 2.6-second stun, 4.2-second cooldown; gentle timing separately tested |
| Stationary recovery and cancellation | Pass | Channel completes while still and cancels on movement |
| Hearing, sight, pursuit and hiding | Pass | Native regressions include wall obstruction, quiet movement, late pressure and shelter |
| Alarms, spills and resource pressure | Pass | Native executed assertions and route observations |
| Saves, bounded input and endings | Pass | Native reload fixtures restore the original user save after normal completion |
| English copy and fixed viewport labels | Pass | Native screen construction and bounds checks; visual aesthetics remain a separate judgment |
| Compact HUD and focus-loss bridge | Pass in native handler tests | Does not prove every real browser delivers events identically |

## Public browser and touch checks

| Check | Status | Evidence or boundary |
| --- | --- | --- |
| Firebase site reachable | Pass | Public HTTPS load at afterhours-prescription.web.app |
| HTTP delivery | Pass | Root returned 200, text/html and no-store; index.wasm returned 200 and application/wasm on 9 October |
| Desktop first room | Pass in Chrome | Ordinary keyboard play completed Ward 1 in about 33 seconds |
| Browser interactions, pause and retry | Pass in Chrome | Interactions, pause, defeat and retry observed on the public release |
| Checkpoint and reload | Pass in Chrome | Completed checkpoint survived reload and continued to Ward 2 |
| Landscape emulation | Partial | Chrome 844 by 390 rendered menu and continued to Ward 2 |
| Final touch movement and Pulse | Verified in Chrome emulation | 844 x 390, held direction moved player, Pulse reduced charge and drew ring; Use bridge has native regression coverage |
| Touch release and rotation | Verified in Chrome emulation | Direction released after held click; portrait 390 x 844 shows rotation guidance with no horizontal overflow; hardware cancellation remains untested |
| Physical phones/tablets | Not tested | Emulation does not establish real hardware support |
| Other browsers | Not tested | Do not generalize Chrome evidence to Safari, Firefox or Edge |
| Browser audio quality and long sessions | Partial | Video contains game audio, but this is not a browser mix or stability study |
| Browser final choice and both endings | Pending | Native state tests pass; full browser ending verification remains separate |

## Media and product checks

| Check | Status | Evidence or boundary |
| --- | --- | --- |
| Current official video | Complete | 67 seconds, 1280 by 720, 30 fps, H.264/AAC; real first-three-ward montage |
| Voice disclosure | Complete | Generic AndrewNeural synthesis, 66.888 seconds; not Shivam Gupta's voice |
| Current script and captions | Complete | Exact NARRATION.txt and copied timed caption file |
| Final-choice footage claims | Accurate | Final video contains no editorial ending or final-choice shots |
| YouTube publication | Verified public | Watch page played to 0:29, https://youtu.be/L6kt6Z9vEp4 |
| Current press kit and pitch deck | Pending review/replacement | Older media contains superseded mechanics and framing |
| Human comprehension, fairness and horror | Not tested | Automated pilots do not establish subjective experience |
| Creator and assistance attribution | Documented | Shivam Gupta creator/product direction, with honest AI assistance credit |

Deployment target: `hosting:afterhours`, project `unpause-studio`, secondary site `afterhours-prescription`. Existing default-site and backend services are outside the deployment.
