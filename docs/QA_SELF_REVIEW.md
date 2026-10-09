# Internal QA and judging rubric

**Evidence class: internal self-review, not independent human judging.** This rubric was prepared by an AI collaborator from the supplied brief and inspected source. Scores reflect design/readiness judgment only. They are not user-test results, organizer scores, a security audit or proof of release quality. The root build's executable verification report takes precedence over these provisional assessments.

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

## Release gates to execute

Mark each item only after observing it in the exact release build. Use PASS / FAIL / NOT RUN, with a test command, screenshot or recording reference. A source implementation alone is not a pass.

| Check | Required observation | Initial status |
| --- | --- | --- |
| Clean boot | Main menu renders without missing resources or console errors | NOT RUN |
| Onboarding | Fresh profile sees tutorial; skip and replay work | NOT RUN |
| Campaign reachability | All three records and hatch reachable on each of ten maps | NOT RUN |
| Core controls | Move, sneak, reveal sealed names, collect, interact, pulse and hide work in exported browser build | NOT RUN |
| Resource tradeoffs | Pulse costs 18 charge and reveals/stuns; pickup restores 8; station restores resources and alerts shadows | NOT RUN |
| Modifier progression | Timed low visibility, alarms/countdown, residue and multiple pursuers match displayed rule | NOT RUN |
| Damage/retry | Damage has feedback; defeat and retry restore playable state | NOT RUN |
| Pause | Movement, AI and resource timers stop while paused | NOT RUN |
| Persistence | Continue works after reload on the same origin; demo does not overwrite campaign | NOT RUN |
| Final choice | Both endings are reachable and return to a usable menu | NOT RUN |
| Bilingual interface | Every screen, objective, settings label and ending changes language | NOT RUN |
| Storage failures | Invalid or missing saves fail gracefully | NOT RUN |
| Focus and viewport | Browser click/focus and resizing preserve input and readable UI | NOT RUN |
| Audio | Assets load, volumes behave, no critical warning depends on hearing alone | NOT RUN |
| Packaging | Export opens from HTTP with all required files present | NOT RUN |
| Human playtest | New English and Korean players can explain and complete onboarding | NOT RUN |

## Risk priorities

1. Verify progression and save isolation before adding more content.
2. Test real exported web input, not just editor execution.
3. Observe whether recharge noise is understandable rather than unfair.
4. Check Korean glyph rendering and long text at the smallest supported viewport.
5. Preserve honest release notes: no cloud login, untested mobile support, market validation or independent judge claims.
