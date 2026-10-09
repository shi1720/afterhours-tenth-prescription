# Reproducible gameplay montage

`tests/record_trailer.gd` captures an approximately 120-second montage at 1280×720 and 30 fps. It uses normal gameplay processing: actual path movement, active enemies/hazards, battery expenditure, light revelation, E interactions and successful ward completion. It does not teleport the player during gameplay.

The sequence selects Wards 1, 3 and 8 directly. The final choice and ending are an editorial preview. Describe the result as a gameplay montage, not an uninterrupted recording of completing all ten wards. The archive shows only the three records earned in this take.

User saves are protected by a recording-only application subclass overriding `save()` to do nothing. The fixture reads startup state but then sets its own in-memory profile and preferences. It never alters campaign progress on disk. Headless dry-run disables audio playback; the real rendered movie keeps sound.

From the project root, substituting the installed Godot executable:

```sh
Godot --path . --script tests/record_trailer.gd --fixed-fps 30 --disable-vsync --write-movie /absolute/path/afterhours-trailer.avi
ffmpeg -y -i /absolute/path/afterhours-trailer.avi -c:v libx264 -preset medium -crf 19 -pix_fmt yuv420p -c:a aac -b:a 192k -movflags +faststart /absolute/path/AFTERHOURS_GAMEPLAY.mp4
```

Do not use `--headless` for the actual movie; it disables rendering. For a fast control-flow check only, use `--headless --fixed-fps 30` and omit `--write-movie`. Movie writing can run faster or slower than the footage duration; its fixed simulation rate preserves real-time gameplay when played back at 30fps.

## Dry-run shot timings

| Time | Shot |
|---|---|
| 00:00–00:06 | Title |
| 00:06–00:12 | Light-pulse field guide |
| 00:12–00:17 | Ward 1 briefing |
| 00:17–00:33.67 | Ward 1 actual gameplay |
| 00:33.67–00:39.67 | Earned memory |
| 00:39.67–00:44.67 | Ward 3 briefing |
| 00:44.67–01:00.87 | Ward 3 actual alarm gameplay |
| 01:00.87–01:06.87 | Earned memory |
| 01:06.87–01:11.87 | Korean Ward 8 briefing |
| 01:11.87–01:26.60 | Korean Ward 8 actual gameplay |
| 01:26.60–01:32.60 | Earned memory |
| 01:32.60–01:37.60 | Archive |
| 01:37.60–01:42.60 | Editorial preview of final choice |
| 01:42.60–01:52.60 | Editorial preview of remember ending |
| 01:52.60–01:59.60 | Closing title |

The log prints actual shot markers and rejects a failed gameplay take with nonzero exit status. Review the rendered output and audio before publishing. A clean headless control-flow run is not visual/audio verification of the resulting video.
