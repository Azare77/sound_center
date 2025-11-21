# sound_center 🎵

![Flutter](https://img.shields.io/badge/Flutter-3.x-blue)
![Platform](https://img.shields.io/badge/platform-Android%20|%20Linux-blueviolet)

sound_center — a concise, cross-platform music & podcast player built with Flutter.

Local music and podcast playback are implemented. The app also targets playing from third‑party
sources (e.g., SoundCloud) and live audio streams (internet radio).

| Feature                                    | Status / Notes                             |
|--------------------------------------------|--------------------------------------------|
| **Local audio scanning & playback**        | ✔ Playlists, queue, seek, shuffle          |
| **Podcast search, streaming & downloads**  | ✔ Search, stream, offline resume           |
| **Background playback & system controls**  | ✔ `audio_service`, MPRIS on desktop        |
| **Downloads manager**                      | ✔ Background using `background_downloader` |
| **Localization**                           | ✔ English & Farsi (`intl`)                 |
| **Third-party sources (SoundCloud, etc.)** | 🔧 Planned — adapter-based architecture    |
| **Live audio streams (internet radio)**    | 🔧 Supported at player level, UI pending   |

### Short notes

- Architecture: modular features with BLoC for state management and a central `audio_handler` for
  playback orchestration.
- Permissions: the app requests storage/media permissions on first run to allow local scanning (
  `permission_handler`).
