<div align="center">

# Sound Center 🎵

![Flutter](https://img.shields.io/badge/Flutter-3.x-blue)
![Platform](https://img.shields.io/badge/platform-Android%20|%20Linux-green)
[![GitHub release](https://img.shields.io/github/v/release/azare77/sound_center?color=D3BEAB)](https://github.com/azare77/sound_center/releases)
[![License](https://img.shields.io/github/license/azare77/sound_center?color=D3BEAB)](LICENSE)

---
</div>

**A simple and practical audio player built with Flutter**  
This app provides playback of local music, podcast search and streaming, offline downloads,
background playback, along with customization features.  
Currently available on Android and Linux desktop, with support for English and Farsi languages.

## Features

<div align="center">

| Feature                                    | Status / Notes                             |
|--------------------------------------------|--------------------------------------------|
| **Local audio scanning & playback**        | ✔ Playlists, queue, seek, shuffle          |
| **Podcast search, streaming & downloads**  | ✔ Search, stream, offline resume           |
| **Background playback & system controls**  | ✔ `audio_service`, MPRIS on desktop        |
| **Downloads manager**                      | ✔ Background using `background_downloader` |
| **Localization**                           | ✔ English & Farsi (`intl`)                 |
| **Custom Themes**                          | ✔ Create Custom Themes and share them      |
| **Third-party sources (SoundCloud, etc.)** | 🔧 Planned — adapter-based architecture    |
| **Live audio streams (internet radio)**    | 🔧 Supported at player level, UI pending   |

</div>

## Screenshots

| ![Screenshot 1](info/screenshots/1.jpeg) | ![Screenshot 2](info/screenshots/2.jpeg) | ![Screenshot 3](info/screenshots/3.jpeg) | ![Screenshot 4](info/screenshots/4.jpeg) |
|------------------------------------------|------------------------------------------|------------------------------------------|------------------------------------------|
| ![Screenshot 5](info/screenshots/5.jpeg) | ![Screenshot 6](info/screenshots/6.jpeg) | ![Screenshot 7](info/screenshots/7.jpeg) | ![Screenshot 8](info/screenshots/8.jpeg) |

## Feedback & Support

Found a bug? Have a feature request?  
Please open an [Issue](https://github.com/azare77/sound_center/issues) or join the discussion!

### Short notes

- Architecture: modular features with BLoC for state management and a central `audio_handler` for
  playback orchestration.
- Permissions: the app requests storage/media permissions on first run to allow local scanning (
  `permission_handler`).

## License

Sound Center - A music and podcast player bringing multiple playback modes into one app.
Copyright (C) 2026 Ali Zare

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program. If not, see <https://www.gnu.org/licenses/>.