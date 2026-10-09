# Independent judge review

This review evaluates the current English-only build using direct source inspection, **9,043 passing native integration assertions**, ten normal-mode objective playthroughs and fresh rendered native screenshots. The criteria below are inferred from the requested product goals. They are not an official judging rubric, external competition score or prediction of winning.

## Assessment

| Criterion | Score / 10 | Judgment and evidence |
|---|---:|---|
| Immersion and level variety | 7.5 | The abandoned pharmacy and forgotten-name story are understandable and thematically consistent. Ten ward layouts, distinct props, arrival text/cues, cold storage, hazard timing, darkness, resource pressure and alarm behavior differentiate the descent. The recovery channel now creates a vulnerable moment that fits the story. Most wards still share one compact collection-and-escape loop, so the visual themes exceed the breadth of their underlying decisions. Scare response and audio quality have not been independently listened to in this review. |
| UI and UX | 8.5 | The new Space Grotesk typography is substantially clearer than the earlier thin text. Title composition, mint/coral hierarchy, six-page skippable guide, contextual prompts, visible resource bars and explicit pause/settings screens form a coherent product. Fresh screenshots show clean desktop layouts. Compact mode enlarges the playfield and follows the player; a clipped-bar defect found in its screenshot was repaired and recaptured. Real phone readability and touch ergonomics require the separate browser/device acceptance pass. |
| Functionality and robustness | 8.5 | All ten wards complete under actual movement with enemies and hazards enabled, real pulse costs/cooldowns, stationary recovery and no health resets or gameplay teleports. Tests cover geometry, pursuit, wall clearance, death, hiding, resource management, profile saves, endings and browser-command handlers. Late wards produce material damage and charge pressure. This is strong native release-candidate evidence, not certification of every browser, hosting configuration or long-session audio behavior. |
| Originality | 7.5 | The pharmacist who restores forgotten names offers a distinctive emotional hook. Spending the same light charge to reveal a person and protect yourself is a clear, relevant tradeoff. Recovering the final record attracts pursuit. Collection, light stuns, cabinets and patrol enemies are familiar mechanics, and the compact room structure does not yet create a new genre or a deep systemic simulation. |
| Commercial viability | 6.5 | A browser-playable short horror story is an intelligible indie product with a low-friction discovery route. Local profiles avoid unnecessary account infrastructure. However, no willingness-to-pay, retention, audience acquisition or price evidence has been collected. Current content depth supports a polished jam short more strongly than a substantial paid campaign. A business claim should remain a hypothesis until real players finish the game and express interest in more. |
| Accessibility | 7.5 | Gentle mode, high visibility, reduced atmospheric motion, volume control, visible alarm/pulse status, keyboard controls and a touch bridge are valuable. Focus loss clears movement and pauses the game. Instructions identify objects with words as well as colors. Control remapping, controller access, screen-reader navigation and disability-user validation are not established. Compact screenshots are readable at native resolution; that does not prove readability after phone scaling. |

**Overall judgment: approximately 7.7 / 10 as a polished compact game-jam release candidate.** Presentation and functional completeness are strengths. Horror impact, human difficulty and commercial demand remain the principal uncertainties.

## What improved in this iteration

The mechanics now require more than a fast collection route. A pulse costs 24 charge, stuns briefly in normal mode and cannot be chained continuously. It also tells distant shadows where you were. Recovering a name takes stationary exposure. Later pursuers close distance on noisy movement, and walls break sight. Exposed camping demonstrably fails; hiding remains protective. These are meaningful interactions rather than additional menu features.

Normal automated routes finished with 32 to 100 resolve and 4.7 to 39.9 charge. An exact-map pilot still completes a ward in roughly 17 to 24 seconds. That is evidence of a compact design and skilled routing, not an estimate of a new player's playtime. Do not advertise an unmeasured duration or imply the automated pilot represents typical players.

The native screenshots show distinct room silhouettes and environmental storytelling. Ward 4's broken-seal layout and Ward 9's sorting shelves differ visually and spatially. The repeated tiled single-room framing is still apparent. The next content expansion should add a different kind of decision or a persistent consequence, rather than merely recolor another floor.

## Highest-impact remaining work

**Observe one person playing the first two wards without coaching.** The most useful unanswered question is whether the player understands "pulse to reveal, E to begin recovery, stay still, then escape" under actual pressure. Record where they hesitate, whether they notice the recovery progress, whether the pulse's noise consequence feels fair, and whether they voluntarily use shelter or a charger. This review has not conducted that human study.

If the player misses the channel, strengthen its immediate visual/audio feedback. If the player understands it but never makes a meaningful survival decision, add one carefully telegraphed spatial or threat choice in the middle wards. Avoid adding administrative screens or forced waiting to manufacture depth.

Before public distribution, the separate browser pass should verify loading, focus/audio activation, actual touch delivery, persistent saves, fullscreen and readable phone presentation. Those are acceptance conditions, not evidence supplied by headless bridge tests.

## Screens inspected directly

- `screenshots/01-title.png`: title composition, primary action, product identity.
- `screenshots/03-guide.png`: accurate current pulse rule and tutorial hierarchy.
- `screenshots/05-gameplay.png`: normal HUD, resource bars, map and arrival narrative.
- `screenshots/08-settings.png`: volume, gentle mode, animation and visibility controls.
- `screenshots/09-compact.png`: enlarged map, compact sidebar and corrected resource-bar bounds.
- `screenshots/ward-04.png` and `screenshots/ward-09.png`: layout and environmental variety.

The capture fixture uses an in-memory profile and a no-op save override. It does not overwrite the user's campaign. Screens are rendered by the native engine; they are not generated mockups or proof of browser behavior.
