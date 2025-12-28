<div align="center">

# Sound Center 🎵

![Flutter](https://img.shields.io/badge/Flutter-3.x-blue)
![Platform](https://img.shields.io/badge/platform-Android%20|%20Linux-green)
[![GitHub release](https://img.shields.io/github/v/release/azare77/sound_center?color=D3BEAB)](https://github.com/azare77/sound_center/releases)
[![License](https://img.shields.io/github/license/azare77/sound_center?color=D3BEAB)](LICENSE)

---
</div>

| Feature                                    | Status / Notes                             |
|--------------------------------------------|--------------------------------------------|
| **Local audio scanning & playback**        | ✔ Playlists, queue, seek, shuffle          |
| **Podcast search, streaming & downloads**  | ✔ Search, stream, offline resume           |
| **Background playback & system controls**  | ✔ `audio_service`, MPRIS on desktop        |
| **Downloads manager**                      | ✔ Background using `background_downloader` |
| **Localization**                           | ✔ English & Farsi (`intl`)                 |
| **Third-party sources (SoundCloud, etc.)** | 🔧 Planned — adapter-based architecture    |
| **Live audio streams (internet radio)**    | 🔧 Supported at player level, UI pending   |

## Feedback & Support

Found a bug? Have a feature request?  
Please open an [Issue](https://github.com/azare77/sound_center/issues) or join the discussion!

### Short notes

- Architecture: modular features with BLoC for state management and a central `audio_handler` for
  playback orchestration.
- Permissions: the app requests storage/media permissions on first run to allow local scanning (
  `permission_handler`).
