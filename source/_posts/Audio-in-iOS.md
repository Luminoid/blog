---
title: Audio in iOS
date: 2020-03-23 00:28:25
updated:
categories: iOS
tags:
- Audio
keywords:
- iOS
- Audio
---

## Basic
### Sampling
> 44,100 Hz: The `Nyquist–Shannon sampling theorem` says the sampling frequency must be greater than twice the maximum frequency one wishes to reproduce. Since human hearing range is roughly 20 Hz to 20,000 Hz, the sampling rate had to be greater than 40 kHz.

### Pulse-code modulation (PCM)
> Pulse-code modulation (PCM) is a method used to digitally represent sampled analog signals. A PCM stream has two basic properties that determine the stream's fidelity to the original analog signal: the sampling rate, which is the number of times per second that samples are taken; and the bit depth, which determines the number of possible digital values that can be used to represent each sample.

Filename extension: `.L16, .WAV, .AIFF, .AU, .PCM`

Example: A 3-minute song of 16 bit depth, two-channel is about 30MB. (44100 * 2 * 16 * 180 / 1024 / 1024 / 8)

### Codec
> A codec is a device or computer program which encodes or decodes a digital data stream or signal. Codec is a portmanteau of coder-decoder.

## Audio Session
### [AVAudioSession](https://developer.apple.com/documentation/avfoundation/avaudiosession)
> An audio session acts as an intermediary between your app and the operating system—and, in turn, the underlying audio hardware. You use an audio session to communicate to the operating system the general nature of your app’s audio without detailing the specific behavior or required interactions with the audio hardware.

### Audio Session Category
> An audio session category defines a set of audio behaviors. The operating system sets the precise behaviors associated with each category, and Apple may refine category behavior in future versions of the operating system.

| Category                                       | Silenced by the Ring/Silent switch and by screen locking | Interrupts nonmixable app’s audio           | Allows audio input (recording) and output (playback) | AirPlay                  |
|------------------------------------------------|----------------------------------------------------------|---------------------------------------------|------------------------------------------------------|--------------------------|
| `AVAudioSession.Category.ambient`              | Yes                                                      | No                                          | Output only                                          | mirrored and nonmirrored |
| `AVAudioSession.Category.soloAmbient`(Default) | Yes                                                      | Yes                                         | Output only                                          | mirrored and nonmirrored |
| `AVAudioSession.Category.playback`             | No                                                       | Yes by default; no by using override switch | Output only                                          | mirrored and nonmirrored |
| `AVAudioSession.Category.record`               | No                                                       | Yes                                         | Input only                                           | /                        |
| `AVAudioSession.Category.playAndRecord`        | No                                                       | Yes by default; no by using override switch | Input and output                                     | mirrored                 |
| `AVAudioSession.Category.multiRoute`           | No                                                       | Yes                                         | Input and output                                     | /                        |

### Audio Session Mode
> The audio session mode, together with the audio session category, indicates to the system how you intend to use audio in your app. You can use a mode to configure the audio system for specific use cases such as video recording, voice or video chat, or audio analysis.

- `default`
- `gameChat`
- `measurement`
- `moviePlayback`
- `spokenAudio`: A mode used for continuous spoken audio to pause the audio when another app plays a short audio prompt.
- `videoChat`
- `videoRecording`
- `voiceChat`
- `voicePrompt`

### Audio Session RouteSharingPolicy
> A route-sharing policy allows you to specify that an audio session should route its output to somewhere other than the default system output when alternative routes are available.

- `default`
- `longFormAudio`
- `longFormVideo`
- `independent`

### Audio Session CategoryOptions
- `mixWithOthers`
- `duckOthers`
- `interruptSpokenAudioAndMixWithOthers`
- `allowBluetooth`
- `allowBluetoothA2DP`
- `allowAirPlay`
- `defaultToSpeaker`

### API
`func setCategory(AVAudioSession.Category, mode: AVAudioSession.Mode, policy: AVAudioSession.RouteSharingPolicy, options: AVAudioSession.CategoryOptions)`: Sets the session category, mode, route-sharing policy, and options.

## System Sounds
### [System Sound Services](https://developer.apple.com/documentation/audiotoolbox/audio_services)
> You can use System Sound Services to play short (30 seconds or shorter) sounds. The interface does not provide level, positioning, looping, or timing control, and does not support simultaneous playback: You can play only one sound at a time. You can use System Sound Services to provide audible alerts. On some iOS devices, alerts can include vibration.

### API
`func AudioServicesPlayAlertSoundWithCompletion(SystemSoundID, (() -> Void)?)`: Plays a system sound as an alert.

`func AudioServicesPlaySystemSoundWithCompletion(SystemSoundID, (() -> Void)?)`: Plays a system sound object.

### Usage
#### Play System Sound
``` Swift
import AudioToolbox
let systemSoundId: SystemSoundID = 1000 // new-mail.caf
AudioServicesPlaySystemSound(systemSoundId)
```

#### System Sounds and Ringtones
Directories
`/Library/Ringtones` and `/System/Library/Audio/UISounds`

`.m4r` 
> The Apple iPhone uses MPEG-4 audio for its ringtones but uses the .m4r extension rather than the .m4a extension.

`.caf`
Core Audio Format

### Ref
- https://github.com/TUNER88/iOSSystemSoundsLibrary
- https://github.com/CQH/iOS-Sounds-and-Ringtones
- http://iphonedevwiki.net/index.php/AudioServices

## Reference
### Apple Doc
- [Media Playback Programming Guide](https://developer.apple.com/library/archive/documentation/AudioVideo/Conceptual/MediaPlaybackGuide/Contents/Resources/en.lproj/Introduction/Introduction.html)
- [Multimedia Programming Guide](https://developer.apple.com/library/archive/documentation/AudioVideo/Conceptual/MultimediaPG/Introduction/Introduction.html)
- [Audio Session Programming Guide](https://developer.apple.com/library/archive/documentation/Audio/Conceptual/AudioSessionProgrammingGuide/Introduction/Introduction.html)
- [AVFoundation Programming Guide](https://developer.apple.com/library/archive/documentation/AudioVideo/Conceptual/AVFoundationPG/Articles/00_Introduction.html)
- [HTTP Live Streaming Overview](https://developer.apple.com/library/archive/documentation/NetworkingInternet/Conceptual/StreamingMediaGuide/Introduction/Introduction.html)

### Other
- [KKBOX](https://zonble.gitbooks.io/kkbox-ios-dev/audio_apis/)
