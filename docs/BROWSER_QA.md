# Browser release verification

9 October 2026. Game build 5fe153f, Godot 4.5 stable, desktop Chrome.

Firebase release loaded from https://afterhours-prescription.web.app with no captured console errors. WASM returned application/wasm and HTML no-store. The full first ward was completed with ordinary keyboard input: movement, sealed reveal, stationary recovery, enemy damage, pause/resume, three names, hatch, memory screen and checkpoint. Defeat and retry were also exercised. Reload retained the checkpoint and Continue opened Ward 2.

At 844 x 390 with Chrome touch emulation, compact menus and the 1.6x follow camera rendered correctly. Two simultaneous touch contacts held Right and Sneak. Touch release cleared both. Use displayed its proximity feedback. Pulse reduced charge and drew its ring. Pause worked. At 390 x 844, rotation guidance appeared without horizontal overflow. Final touch controls overlay the lower corners, preserving the full game area. Temporary viewport and touch overrides were removed after testing.

Evidence: outputs/firebase-ward-complete.jpg and outputs/firebase-mobile.jpg in the task deliverables. Native integration and Linux CI each passed 9,043 assertions. Physical phone hardware and browsers other than Chrome were not exercised. Native tests cover both endings; the full ten-ward campaign was not manually repeated in the browser.
