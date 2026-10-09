# Browser player and deployment

The responsive HTML shell introduces the story, launches the Godot player after a user gesture and provides help and player controls. Keyboard users play with WASD/arrows, Shift, Space, E and Escape. Landscape touch places the direction pad and action controls over the lower corners of the player, preserving the canvas height instead of reserving a separate bottom strip. Portrait guidance asks players to turn the device.

The game uses a single-threaded Web export. Static hosting must keep the exported HTML, JavaScript, WASM and PCK together. The title illustration is also required as an ordinary file at `assets/title_art.png`; the build and deployment scripts copy it from the source assets.

## Firebase

The public address is https://afterhours-prescription.web.app . A dedicated secondary Hosting site named `afterhours-prescription` lives inside `unpause-studio`. `.firebaserc` maps only the local `afterhours` deploy target to that site. `tools/deploy_firebase.sh` deploys only `hosting:afterhours` with an explicit project. Existing project sites and backend services are outside that deployment.

`firebase.json` serves WASM as `application/wasm`, PCK as `application/octet-stream` and JavaScript as `application/javascript`. HTML uses `no-store`; other assets revalidate so a new PCK does not silently mix with stale loader files. Authentication belongs to the developer's Firebase CLI, not the game. Never include CLI tokens in source.

## Storage

Godot browser progress belongs to the current origin. Firebase and the prior Pages hostname have separate local storage. The shell must not promise automatic transfer. No password, cloud profile or server synchronization is implemented.

## Verification

Use the current release checklist. Responsive CSS and touch controls do not themselves prove usability on every device. Record tested viewport sizes, pointer behavior, keyboard focus, reload persistence and audio activation separately.
