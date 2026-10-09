# AFTERHOURS: The Tenth Prescription
### 심야약국: 열 번째 처방전

**Ten wards. Three records in each. One light left on.**

A complete ten-ward pixel horror campaign built in Godot. You return to a pharmacy that closed ten years ago, recover prescriptions carrying forgotten names, and decide what the building will remember. The shadows are supernatural grief, not a portrayal of mental illness.

![AFTERHOURS title illustration](assets/title_art.png)

## Play

Open the hosted web build in a desktop browser, click inside the game, and create a local profile. Choose **Begin the night** (or **Continue shift** with an existing profile) for the ten-ward campaign, or the separate demo for a short introduction. Follow the first-launch tutorial; it can be skipped and replayed. English and Korean are available in the interface.

| Key | Action |
| --- | --- |
| WASD / arrow keys | Move |
| Shift | Sneak: slower movement, quieter footsteps |
| E | Collect a nearby record, hide/leave a cabinet, recharge, or use the hatch |
| Space | Reveal nearby sealed records and stun shadows; consumes battery |
| Escape | Pause / return |

Records begin sealed. Press Space nearby to reveal a name, then E to collect it. The same pulse stuns nearby shadows for 4.5 seconds and costs 18 charge; each recovered record returns 8 charge. Recover all three records, then press E at the dispensing hatch. The teal charging station restores battery and some composure, but its noise draws shadows. Hiding breaks pursuit. A pulse stuns nearby shadows, buying time to escape. Ten authored layouts introduce timed low-visibility periods, alarms with a visible countdown, hazardous residue, faster shadows and multiple pursuers. Thirty fictional names are recovered across the campaign. There are two final story choices.

**Headphones are optional.** Visual cues show objectives, warnings and resources. Horror includes pursuit, darkness, spectral figures, pulse effects and peril; it contains no medical advice. Settings include a gentler mode, high visibility, master volume and atmospheric animation controls.

Source repository: [shi1720/afterhours-tenth-prescription](https://github.com/shi1720/afterhours-tenth-prescription).

## Run from source

1. Install Godot 4.5 or later in the Godot 4.x series, with export templates matching the editor version.
2. Import `project.godot` and run the main scene with F6, or the project with F5.
3. The project uses the Compatibility renderer. No API keys, paid services, account backend or external package installation is required for gameplay.

Command line, with `godot` on PATH:

```sh
godot --path . --editor
godot --path .
```

For web, export the project with the Web preset to `export/web/index.html`. Serve the generated directory over HTTP; opening the HTML directly as a file is unsupported.

```sh
python3 -m http.server 8080 --directory export/web
```

Open `http://localhost:8080`. Keep all generated `.wasm`, `.pck`, JavaScript and HTML files together. If a threaded Web export is used, the host must supply the required cross-origin isolation headers; the release should prefer a non-threaded build for simple static hosting. Refer to the exact checked-in export preset when rebuilding.

## Saves and privacy

The profile is a name attached to a local campaign save. **They are not secure online accounts or cloud authentication.** The game does not ask for a password. Desktop saves use Godot's application data directory; web saves use browser storage for the current origin. Changing browser or hostname, private browsing, clearing site data, or storage eviction can lose progress. There is no cloud synchronization. Use the same browser and origin to continue a shift.

## Project map

- `scripts/`: game simulation, interface and bilingual ward content.
- `assets/`: original procedural pixel art and synthesized audio; bundled font licenses are in `assets/fonts/`.
- `docs/`: submission copy, narration, commercial plan, release limits and self-review rubric.
- `project.godot` / `main.tscn`: entry point and project configuration.

Read [the documentation index](docs/README.md) for the submission kit. The jam build grants access to all ten wards; future pricing discussed in the commercial plan is a hypothesis for an expanded release, not a paywall in this build.

## Credits and status

Created and directed by **Shivam Gupta**, with AI-assisted implementation, writing, procedural art and sound production. Attribution does not claim specific manual programming work. Disclose assistance wherever the jam's rules require it; this repository does not establish eligibility under rules that were not supplied.

This is a release candidate for a game jam, with an explicit finite scope. Source inspection and automated checks do not certify production readiness on every device. See [release notes](docs/RELEASE_NOTES.md) and [QA self-review](docs/QA_SELF_REVIEW.md) for limitations and verification boundaries.

Godot and bundled fonts retain their respective licenses. Project code/art are copyright 2026 Shivam Gupta unless a file states otherwise; no open-source license is implied.
