# Internal QA and judging rubric

**Evidence class: internal self-review, not independent human judging.** This rubric was prepared by an AI collaborator from the supplied brief and inspected source. Scores reflect an initial design/readiness judgment only. Executed release evidence below is newer than the provisional score. They are not user-test results, organizer scores, a security audit or proof of release quality. The root build's executable verification report takes precedence over these provisional assessments.

## Provisional design assessment

| Dimension | Weight | Design score / 5 | Rationale and remaining evidence |
| --- | --- | --- | --- |
| Originality and premise | 20% | 4 | Haunted pharmacy and forgotten names form a clear hook; player response remains untested |
| Theme and narrative | 15% | 4 | Ten records build to a humane ethical choice; final pacing needs human playtesting |
| Gameplay progression | 20% | 4 | Ten modifier combinations exist in source; difficulty balance needs live play |
| Visual identity and UI | 15% | 4 | Original pixel palette, assets and planned full interface; inspect final screenshots and focus behavior |
| Completeness and robustness | 20% | 3 | Deterministic simulation and finite campaign; require final export, save and retry checks |
| Accessibility and localization | 5% | 3 | Bilingual content, high visibility, reduced effects and visual cues; no native Korean reviewer or assistive-tech certification |
| Commercial clarity | 5% | 4 | Finite premium-game hypothesis with free trial path; no verified demand or sales |

Weighted provisional design score: **3.75 / 5 (75 / 100)**. Do not use this as an independent endorsement. Improve the lowest dimensions through actual verification rather than increasing the claimed score.

## Executed release gates

Evidence: `TEST_REPORT.md` and `HEADLESS_TEST_LOG.txt` (native Godot 4.5, **4,945 assertions / 0 failures**); `BROWSER_QA.md` (real Chrome Web export at localhost); `INDEPENDENT_REVIEW.md` (separate AI-assisted review, approximately 8/10). This supersedes the earlier NOT RUN checklist. Native assertions and browser observations are deliberately distinguished.

| Check | Result | Evidence boundary |
| --- | --- | --- |
| Clean boot | PASS (Chrome); PASS (macOS smoke) | Real exported web menu; unsigned universal Mac headless startup exited 0 |
| Onboarding | PASS (native); PARTIAL (Chrome) | Native six-page construction/flow; browser first guide and skip, not every page |
| Campaign reachability | PASS (native); PARTIAL (Chrome) | All ten authored routes with enemies/hazards; Ward 1 completed in Chrome |
| Core controls | PASS (native); PARTIAL (Chrome) | Native movement/sneak/pulse/hiding checks; physical browser movement, SPACE reveal and E collection/hatch observed |
| Resource tradeoffs | PASS (native) | Charge costs, reveal/stun, pickup, station refill/cooldown and attraction verified |
| Modifier progression | PASS (native) | Per-ward simulation checks; not a human balance assessment |
| Damage/retry | PASS (native state checks) | Contact, grace interval, failure and restart state tested; no full browser defeat/retry claim |
| Pause | PASS (native); PASS (Chrome) | Native state frozen with settings and language; browser pause/settings observed |
| Persistence | PASS (native); PARTIAL (Chrome) | Native fields, endings, demo isolation; browser profile/Continue survives same-origin reload |
| Final choice | PASS (native UI/state) | Both endings construct and persist; not reached through Chrome in this session |
| Bilingual interface | PASS (native layout); PARTIAL (Chrome) | Both-language screen/label bounds tested; selected Korean labels visibly readable in browser |
| Storage failures | PASS (native bounded values); PARTIAL | Invalid values sanitized; forced crash/storage eviction not tested |
| Focus and viewport | PARTIAL (Chrome) | Physical input captured; broad resizing/fullscreen/multi-browser coverage not established |
| Audio | PARTIAL | Original-audio gameplay video exists; suite disables ambience fixture, no human mix review |
| Packaging | PASS (Chrome/local HTTP); PARTIAL (native platforms) | Web ran; Mac startup smoke passed; Windows/Linux generated, not executed |
| Public deployment | PARTIAL | Initial GitHub Pages CI succeeded; subsequent final-patch deployment pending at record time |
| Human playtest | NOT RUN | No first-player study or native Korean-language review claimed |

The automated browser profile was `Q` after a typing automation issue. Short-name flow works; Korean IME and complex name entry were not tested. The macOS startup check is not notarization or a GUI playthrough. See the source reports for reproduction and cleanup details.

## Risk priorities

1. Verify progression and save isolation before adding more content.
2. Test real exported web input, not just editor execution.
3. Observe whether recharge noise is understandable rather than unfair.
4. Check Korean glyph rendering and long text at the smallest supported viewport.
5. Preserve honest release notes: no cloud login, untested mobile support, market validation or independent judge claims.
