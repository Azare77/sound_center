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

| ![Screenshot 1](https://github.com/user-attachments/assets/01ac412d-c29d-4828-801b-e7d62646e9e7) | ![Screenshot 2](https://github.com/user-attachments/assets/84d1368d-340d-458c-9d31-6c3a4bc2a79b) | ![Screenshot 3](https://github.com/user-attachments/assets/3a7fd777-a20a-4802-a439-11e5cbcebb25) | ![Screenshot 4](https://github.com/user-attachments/assets/9f3d2559-691c-4d8d-9f1c-77a10863faa1) |
|--------------------------------------------------------------------------------------------------|--------------------------------------------------------------------------------------------------|--------------------------------------------------------------------------------------------------|--------------------------------------------------------------------------------------------------|
| ![Screenshot 5](https://github.com/user-attachments/assets/295464ca-a0dd-4d15-afc9-eaaacfd43002) | ![Screenshot 6](https://github.com/user-attachments/assets/beb8e7aa-68b9-4dba-b718-011f81443bfa) | ![Screenshot 7](https://github.com/user-attachments/assets/81a8e723-87fd-4a75-b919-00c30e69a478) | ![Screenshot 8](https://github.com/user-attachments/assets/0e1ee8d7-ffb6-4258-8a69-1f44b2007f2b) |

## Feedback & Support

Found a bug? Have a feature request?  
Please open an [Issue](https://github.com/azare77/sound_center/issues) or join the discussion!

### Short notes

- Architecture: modular features with BLoC for state management and a central `audio_handler` for
  playback orchestration.
- Permissions: the app requests storage/media permissions on first run to allow local scanning (
  `permission_handler`).
