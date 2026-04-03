---
title: "Apple Audio Frameworks: A Complete Guide to iOS and macOS Audio"
date: 2026-04-02 12:00:00
categories:
- iOS
tags:
- audio
- AVFoundation
- CoreAudio
- AudioToolbox
- AudioUnit
- SoundAnalysis
- Swift
- AVAudioEngine
---

Apple provides six layers of audio frameworks -- from raw hardware access to one-line playback. This guide covers every layer, what it does, when to use it, and how the pieces fit together.

<!-- more -->

## The Audio Stack

Apple's audio architecture is a layered system. Each layer adds convenience at the cost of control:

```
┌──────────────────────────────────────────────────┐
│  AVFoundation                                    │  Highest level
│  (AVPlayer, AVAssetReader, AVMutableComposition) │  Media playback, editing, export
├──────────────────────────────────────────────────┤
│  AVFAudio                                        │  Audio-specific
│  (AVAudioEngine, AVAudioSession, AVAudioPlayer,  │  Engine graph, session config,
│   AVAudioRecorder, AVAudioFile)                  │  recording, file I/O
├──────────────────────────────────────────────────┤
│  AudioToolbox                                    │  C API
│  (Audio Queue, Audio File, Audio Converter,      │  Queues, files, codecs,
│   Extended Audio File, Music Sequence)           │  stream parsing, MIDI
├──────────────────────────────────────────────────┤
│  Audio Units                                     │  Plug-in layer
│  (AUAudioUnit, built-in effects, AUv3 extensions)│  Real-time DSP, effects, instruments
├──────────────────────────────────────────────────┤
│  Core Audio / CoreAudioTypes                     │  Foundation types
│  (ASBD, AudioBuffer, AudioTimeStamp,             │  Format descriptors, buffers,
│   AudioChannelLayout)                            │  timing, channel layouts
├──────────────────────────────────────────────────┤
│  Audio HAL (macOS only)                          │  Hardware access
│  (AudioObject, AudioDevice, AudioStream)         │  Device enumeration, I/O
└──────────────────────────────────────────────────┘
```

The sections below are ordered bottom-up -- starting from the lowest-level foundation types and working up to the highest-level APIs.

**Rule of thumb**: Start at the highest level that meets your needs. Drop down only when you need more control.

| Need | Start here |
|------|-----------|
| Play a URL or stream | AVPlayer (AVFoundation) |
| Play a local file | AVAudioPlayer (AVFAudio) |
| Real-time effects or mixing | AVAudioEngine (AVFAudio) |
| Custom audio processing | Audio Units |
| Format conversion, stream parsing | AudioToolbox |
| Sound classification (ML) | Sound Analysis |
| Raw hardware access (macOS) | Core Audio HAL |

---

## Core Audio (CoreAudioTypes)

Core Audio is the foundation. Every other audio framework on Apple platforms is built on these C types.

### AudioStreamBasicDescription (ASBD)

The most important type in all of Apple audio. It describes any audio format:

```c
struct AudioStreamBasicDescription {
    Float64 mSampleRate;        // 44100.0, 48000.0, etc.
    UInt32  mFormatID;          // kAudioFormatLinearPCM, kAudioFormatMPEG4AAC, etc.
    UInt32  mFormatFlags;       // Float, BigEndian, Packed, NonInterleaved, etc.
    UInt32  mBytesPerPacket;
    UInt32  mFramesPerPacket;   // 1 for PCM, 1024 for AAC
    UInt32  mBytesPerFrame;
    UInt32  mChannelsPerFrame;  // 1 = mono, 2 = stereo
    UInt32  mBitsPerChannel;    // 16, 24, 32
    UInt32  mReserved;
};
```

**Format IDs** (the codecs Apple supports natively):

| Constant | Format | Notes |
|----------|--------|-------|
| `kAudioFormatLinearPCM` | Uncompressed PCM | The raw format -- all processing happens in PCM |
| `kAudioFormatMPEG4AAC` | AAC | Default for Apple devices, excellent quality/size |
| `kAudioFormatMPEGLayer3` | MP3 | Decode only on iOS (no encode) |
| `kAudioFormatAppleLossless` | ALAC | Lossless, Apple's alternative to FLAC |
| `kAudioFormatFLAC` | FLAC | Free Lossless Audio Codec |
| `kAudioFormatOpus` | Opus | Low-latency, used in WebRTC |
| `kAudioFormatAppleIMA4` | IMA 4:1 ADPCM | Compressed, low CPU decode |
| `kAudioFormatAMR` | AMR Narrowband | Voice calls |
| `kAudioFormatAMR_WB` | AMR Wideband | HD voice |
| `kAudioFormatAudible` | Audible AA/AAX | Audiobook DRM format |
| `kAudioFormatMPEG4AAC_HE` | HE-AAC | Low bitrate streaming |
| `kAudioFormatMPEG4AAC_HE_V2` | HE-AAC v2 | Even lower bitrate |
| `kAudioFormatMPEG4AAC_ELD` | AAC-ELD | Ultra-low latency for FaceTime |

**Format flags** for PCM:

| Flag | Meaning |
|------|---------|
| `kAudioFormatFlagIsFloat` | 32-bit float samples (vs integer) |
| `kAudioFormatFlagIsBigEndian` | Big-endian byte order |
| `kAudioFormatFlagIsSignedInteger` | Signed integer samples |
| `kAudioFormatFlagIsPacked` | No padding between samples |
| `kAudioFormatFlagIsNonInterleaved` | Separate buffer per channel |

### Canonical Formats

AVAudioEngine uses **non-interleaved 32-bit float** internally:

```
Non-interleaved (AVAudioEngine default):
  Buffer 0: [L0, L1, L2, L3, ...]  (left channel)
  Buffer 1: [R0, R1, R2, R3, ...]  (right channel)

Interleaved (common in files):
  Buffer 0: [L0, R0, L1, R1, L2, R2, ...]
```

In Swift, `AVAudioFormat` wraps ASBD:

```swift
// Standard non-interleaved float format (what AVAudioEngine uses)
let format = AVAudioFormat(standardFormatWithSampleRate: 44100, channels: 2)!

// From an ASBD
var asbd = AudioStreamBasicDescription(...)
let format = AVAudioFormat(streamDescription: &asbd)
```

### AudioBuffer and AudioBufferList

The raw sample containers:

```c
struct AudioBuffer {
    UInt32 mNumberChannels;     // Channels in this buffer
    UInt32 mDataByteSize;       // Size of mData
    void*  mData;               // The samples
};

struct AudioBufferList {
    UInt32      mNumberBuffers;  // 1 for interleaved, N for non-interleaved
    AudioBuffer mBuffers[1];     // Variable-length array
};
```

In Swift, `AVAudioPCMBuffer` provides safe access:

```swift
let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: 4096)!
// Float channel data (non-interleaved)
let leftChannel = buffer.floatChannelData![0]   // UnsafeMutablePointer<Float>
let rightChannel = buffer.floatChannelData![1]
```

### AudioTimeStamp

Timing information with multiple representations:

```c
struct AudioTimeStamp {
    Float64        mSampleTime;   // Sample frame position
    UInt64         mHostTime;     // Mach absolute time (nanoseconds)
    Float64        mRateScalar;   // Rate relative to host clock
    UInt64         mWordClockTime;
    SMPTETime      mSMPTETime;
    AudioTimeStampFlags mFlags;   // Which fields are valid
};
```

### AudioChannelLayout

Maps channels to speaker positions:

| Layout Tag | Channels | Description |
|-----------|----------|-------------|
| `kAudioChannelLayoutTag_Mono` | 1 | Single center |
| `kAudioChannelLayoutTag_Stereo` | 2 | Left + Right |
| `kAudioChannelLayoutTag_MPEG_5_1_A` | 6 | 5.1 surround |
| `kAudioChannelLayoutTag_MPEG_7_1_A` | 8 | 7.1 surround |
| `kAudioChannelLayoutTag_Atmos_5_1_4` | 10 | Dolby Atmos 5.1.4 |

### Real-Time Programming Rules

Audio render callbacks run on a **real-time priority thread**. Violating these rules causes audio glitches (clicks, pops, dropouts):

| Rule | Reason |
|------|--------|
| No `malloc` / `free` | Memory allocator uses locks |
| No Objective-C messaging (`objc_msgSend`) | May trigger autorelease pools or locks |
| No locks (`pthread_mutex_lock`) | Priority inversion with lower-priority threads |
| No file I/O | Disk access is unbounded latency |
| No Swift ARC (`retain` / `release`) | Atomic reference counting uses locks |
| No `NSLog` / `print` / `os_log` | I/O operations |
| No `dispatch_sync` to another queue | Can cause deadlock or priority inversion |

**Safe on the render thread**: Plain C/C++ math, pre-allocated buffer access, atomic operations, block/closure calls (if the block itself follows these rules), `Accelerate.framework` vDSP functions.

### Swift Interop Challenges

Core Audio's C APIs require careful handling in Swift:

```swift
// C callback functions can't capture context -- use UnsafeMutableRawPointer
let renderCallback: AURenderCallback = { (
    inRefCon: UnsafeMutableRawPointer,
    ioActionFlags: UnsafeMutablePointer<AudioUnitRenderActionFlags>,
    inTimeStamp: UnsafePointer<AudioTimeStamp>,
    inBusNumber: UInt32,
    inNumberFrames: UInt32,
    ioData: UnsafeMutablePointer<AudioBufferList>?
) -> OSStatus in
    // Process audio here
    return noErr
}

// AudioBufferList manipulation
let ablPointer = UnsafeMutableAudioBufferListPointer(ioData!)
for buffer in ablPointer {
    let samples = UnsafeMutableBufferPointer<Float>(buffer)
    for i in 0..<Int(inNumberFrames) {
        samples[i] *= 0.5  // halve volume
    }
}
```

---

## Audio Units

Audio Units are Apple's real-time audio plug-in architecture. Every node in `AVAudioEngine` is an Audio Unit under the hood. Understanding Audio Units gives you access to the full power that AVAudioEngine abstracts.

### AUAudioUnit (v3 API)

The modern Objective-C/Swift class (iOS 9+) for building and hosting audio plug-ins:

```swift
// Create an Audio Unit by description
let description = AudioComponentDescription(
    componentType: kAudioUnitType_Effect,
    componentSubType: kAudioUnitSubType_NBandEQ,
    componentManufacturer: kAudioUnitManufacturer_Apple,
    componentFlags: 0,
    componentFlagsMask: 0
)

AUAudioUnit.instantiate(with: description) { audioUnit, error in
    guard let au = audioUnit else { return }
    // Configure parameters via au.parameterTree
    // Connect to engine via AVAudioUnit(audioUnit: au)
}
```

**Key concepts**:
- **Component Description**: Type + subtype + manufacturer identifies the AU
- **Parameter Tree**: `AUParameterTree` containing `AUParameterGroup`s and `AUParameter` leaves. Each parameter has address, value, range, unit, and name
- **Render Block**: `AURenderBlock` / `AUInternalRenderBlock` -- the function called on the real-time thread to process audio
- **Buses**: Input and output `AUAudioUnitBus` arrays with format negotiation
- **Presets**: Factory (read-only, index >= 0) and user (saved, index < 0, iOS 13+)
- **Latency / Tail Time**: AU reports its processing delay and how long output continues after input stops

### Built-in Audio Unit Types

Apple provides dozens of built-in Audio Units. Here is the complete enumeration by category:

#### Output Units

| Subtype | Constant | Platform | Purpose |
|---------|----------|----------|---------|
| Remote I/O | `kAudioUnitSubType_RemoteIO` | iOS | Hardware I/O (microphone + speaker) |
| Voice Processing I/O | `kAudioUnitSubType_VoiceProcessingIO` | All | Echo cancellation + noise suppression |
| Generic Output | `kAudioUnitSubType_GenericOutput` | All | Offline rendering (no hardware) |
| HAL Output | `kAudioUnitSubType_HALOutput` | macOS | Direct hardware access |
| Default Output | `kAudioUnitSubType_DefaultOutput` | macOS | System default device |
| System Output | `kAudioUnitSubType_SystemOutput` | macOS | System alert device |

#### Effects (Cross-Platform)

| Subtype | Constant | What it does |
|---------|----------|-------------|
| N-Band EQ | `kAudioUnitSubType_NBandEQ` | Multi-band parametric equalizer |
| Dynamics Processor | `kAudioUnitSubType_DynamicsProcessor` | Compressor + expander + limiter |
| Peak Limiter | `kAudioUnitSubType_PeakLimiter` | Brickwall peak limiter |
| Distortion | `kAudioUnitSubType_Distortion` | 25+ distortion presets |
| Delay | `kAudioUnitSubType_Delay` | Time-domain delay |
| Reverb 2 | `kAudioUnitSubType_Reverb2` | Algorithmic reverb |
| Low Pass Filter | `kAudioUnitSubType_LowPassFilter` | Butterworth low pass |
| High Pass Filter | `kAudioUnitSubType_HighPassFilter` | Butterworth high pass |
| Band Pass Filter | `kAudioUnitSubType_BandPassFilter` | Band pass filter |
| High Shelf Filter | `kAudioUnitSubType_HighShelfFilter` | High shelf EQ |
| Low Shelf Filter | `kAudioUnitSubType_LowShelfFilter` | Low shelf EQ |
| Parametric EQ | `kAudioUnitSubType_ParametricEQ` | Single-band parametric EQ |

#### macOS-Only Effects

| Subtype | Constant |
|---------|----------|
| Sample Delay | `kAudioUnitSubType_SampleDelay` |
| Graphic EQ | `kAudioUnitSubType_GraphicEQ` |
| Multi-Band Compressor | `kAudioUnitSubType_MultiBandCompressor` |
| Matrix Reverb | `kAudioUnitSubType_MatrixReverb` |
| Pitch | `kAudioUnitSubType_Pitch` |
| Filter | `kAudioUnitSubType_AUFilter` |
| Net Send / Net Receive | `kAudioUnitSubType_NetSend` / `NetReceive` |
| Roger Beep | `kAudioUnitSubType_RogerBeep` |

#### Format Converters

| Subtype | Constant | Purpose |
|---------|----------|---------|
| Converter | `kAudioUnitSubType_AUConverter` | Sample rate, bit depth, channel conversion |
| New Time Pitch | `kAudioUnitSubType_NewTimePitch` | Independent rate + pitch shift |
| Time Pitch (legacy) | `kAudioUnitSubType_TimePitch` | Older time-pitch |
| Varispeed | `kAudioUnitSubType_Varispeed` | Rate change (pitch follows) |
| Splitter | `kAudioUnitSubType_Splitter` | One input to N outputs |
| Merger | `kAudioUnitSubType_Merger` | N inputs to one output |
| Deferred Renderer | `kAudioUnitSubType_DeferredRenderer` | Pull from non-real-time thread |

#### Mixers

| Subtype | Constant | Notes |
|---------|----------|-------|
| Multi-Channel Mixer | `kAudioUnitSubType_MultiChannelMixer` | Most common -- N inputs, 1 output |
| Stereo Mixer | `kAudioUnitSubType_StereoMixer` | Simplified stereo |
| 3D Mixer | `kAudioUnitSubType_3DMixer` | Spatial audio (deprecated, use `AVAudioEnvironmentNode`) |
| Matrix Mixer | `kAudioUnitSubType_MatrixMixer` | Arbitrary NxM routing |

#### Generators

| Subtype | Constant | Notes |
|---------|----------|-------|
| Scheduled Sound Player | `kAudioUnitSubType_ScheduledSoundPlayer` | Schedule audio buffers at specific times |
| Audio File Player | `kAudioUnitSubType_AudioFilePlayer` | Play regions of audio files |
| Speech Synthesis | `kAudioUnitSubType_SpeechSynthesis` | macOS text-to-speech |

#### Music Devices / Instruments

| Subtype | Constant | Notes |
|---------|----------|-------|
| DLS Synth | `kAudioUnitSubType_DLSSynth` | macOS DLS/SoundFont player |
| MIDI Synth | `kAudioUnitSubType_MIDISynth` | General MIDI synth |
| Sampler | `kAudioUnitSubType_Sampler` | SoundFont/DLS/EXS24/Aupreset player |

### AVAudioEngine Node to Audio Unit Mapping

Every `AVAudioUnit*` convenience class wraps a specific Audio Unit subtype:

| AVAudioEngine Class | Audio Unit Subtype | Category |
|--------------------|--------------------|----------|
| `AVAudioUnitEQ` | `kAudioUnitSubType_NBandEQ` | Effect |
| `AVAudioUnitReverb` | `kAudioUnitSubType_Reverb2` | Effect |
| `AVAudioUnitDelay` | `kAudioUnitSubType_Delay` | Effect |
| `AVAudioUnitDistortion` | `kAudioUnitSubType_Distortion` | Effect |
| `AVAudioUnitTimePitch` | `kAudioUnitSubType_NewTimePitch` | Converter |
| `AVAudioUnitVarispeed` | `kAudioUnitSubType_Varispeed` | Converter |
| `AVAudioUnitSampler` | `kAudioUnitSubType_Sampler` | Instrument |
| `AVAudioPlayerNode` | `kAudioUnitSubType_ScheduledSoundPlayer` | Generator |
| `AVAudioMixerNode` | `kAudioUnitSubType_MultiChannelMixer` | Mixer |
| `AVAudioEnvironmentNode` | `kAudioUnitSubType_SpatialMixer` | Mixer |
| `AVAudioInputNode` | `kAudioUnitSubType_RemoteIO` (iOS) | I/O |
| `AVAudioOutputNode` | `kAudioUnitSubType_RemoteIO` (iOS) | I/O |

### AUv3 Extensions

AUv3 (Audio Unit version 3) is the modern plug-in format. Audio Units can be distributed as App Extensions, allowing third-party effects and instruments to be used inside any host app (like GarageBand):

```swift
// Discover third-party AUv3 extensions
let description = AudioComponentDescription(
    componentType: kAudioUnitType_Effect,
    componentSubType: 0, componentManufacturer: 0,
    componentFlags: 0, componentFlagsMask: 0
)
AVAudioUnitComponentManager.shared().components(matching: description)

// Instantiate and host a third-party AU
AVAudioUnit.instantiate(with: componentDescription) { avAudioUnit, error in
    engine.attach(avAudioUnit!)
    engine.connect(playerNode, to: avAudioUnit!, format: format)
    engine.connect(avAudioUnit!, to: engine.mainMixerNode, format: format)
}
```

**AUv3 vs AUv2 comparison**:

| Aspect | AUv2 (Legacy) | AUv3 (Modern) |
|--------|---------------|---------------|
| API | C functions + property listeners | ObjC/Swift class (`AUAudioUnit`) |
| Distribution | Component bundles (macOS) | App Extensions (all platforms) |
| Sandboxing | None | App sandbox (secure) |
| UI | Carbon/Cocoa views | UIKit/SwiftUI views |
| iOS support | Built-in only (no third-party plug-in distribution) | Full (including third-party App Extensions) |
| Inter-process | In-process only | In-process or out-of-process |

---

## AudioToolbox

AudioToolbox is Apple's mid-level C framework for audio file I/O, format conversion, stream parsing, queue-based playback/recording, and MIDI. It builds on Audio Units and Core Audio types, providing higher-level services below AVFAudio.

### Audio Queue Services

Buffer-callback model for playback and recording. You allocate buffers, fill them with audio data, and enqueue them. The system calls you back when it needs more data (playback) or has captured data (recording).

```c
// Create output queue for playback
AudioQueueNewOutput(
    &dataFormat,          // AudioStreamBasicDescription
    outputCallback,       // Called when buffer needs refilling
    userData,             // Context pointer
    NULL, NULL, 0,
    &audioQueue           // Output: the queue
);

// Allocate and enqueue buffers
for (int i = 0; i < 3; i++) {
    AudioQueueAllocateBuffer(audioQueue, bufferSize, &buffers[i]);
    outputCallback(userData, audioQueue, buffers[i]);  // Pre-fill
}

AudioQueueStart(audioQueue, NULL);  // Begin playback
```

**Key properties**:
- `kAudioQueueParam_Volume` -- 0.0 to 1.0
- `kAudioQueueParam_PlayRate` -- playback speed (macOS only)
- `kAudioQueueProperty_EnableLevelMetering` -- audio level metering

**When to use**: When you need low-level control over buffering but don't want to deal with Audio Units directly. Useful for custom streaming implementations where AVPlayer's buffering strategy doesn't fit.

### Audio File Services

Low-level file reading and writing:

```c
AudioFileOpenURL(fileURL, kAudioFileReadPermission, 0, &audioFile);
AudioFileReadPacketData(audioFile, false, &numBytes, NULL, startPacket, &numPackets, buffer);
AudioFileClose(audioFile);
```

**Supported file types**:

| Constant | Format |
|----------|--------|
| `kAudioFileAIFFType` | AIFF |
| `kAudioFileWAVEType` | WAV |
| `kAudioFileCAFType` | Core Audio Format |
| `kAudioFileMP3Type` | MP3 |
| `kAudioFileM4AType` | M4A (AAC) |
| `kAudioFileFLACType` | FLAC |
| `kAudioFileAAC_ADTSType` | AAC ADTS (raw AAC stream) |

### Extended Audio File Services

Higher-level file API that handles format conversion automatically:

```c
// Open any audio file
ExtAudioFileOpenURL(fileURL, &extAudioFile);

// Set output format to PCM (auto-converts from MP3/AAC/FLAC/etc.)
ExtAudioFileSetProperty(
    extAudioFile,
    kExtAudioFileProperty_ClientDataFormat,
    sizeof(pcmFormat),
    &pcmFormat
);

// Read PCM samples (auto-decoded from source format)
ExtAudioFileRead(extAudioFile, &frameCount, &bufferList);
```

This is the workhorse for format conversion -- open any supported format, set a PCM client format, and read decoded samples. In Swift, `AVAudioFile` provides the same functionality with a nicer API.

### Audio Converter Services

Direct codec conversion:

```c
// Create converter (e.g., PCM to AAC)
AudioConverterNew(&sourceFormat, &destinationFormat, &converter);

// Convert with callback
AudioConverterFillComplexBuffer(
    converter,
    inputDataProc,     // Called to supply input data
    userData,
    &outputFrameCount,
    &outputBufferList,
    outputPacketDescriptions
);
```

**Key capabilities**:
- Sample rate conversion (e.g., 44100 Hz to 48000 Hz)
- Bit depth conversion (16-bit to 32-bit float)
- Channel count conversion (mono to stereo, downmix)
- Codec encode/decode (PCM to AAC, AAC to PCM)
- Hardware-accelerated encoding on devices with media engines

### Audio File Stream Services

Progressive parsing of streamed audio -- essential for building custom streaming players:

```c
// Open stream parser
AudioFileStreamOpen(
    userData,
    propertyListenerCallback,   // Called when stream properties are discovered
    packetsCallback,            // Called when audio packets are parsed
    kAudioFileMP3Type,          // Hint for file type
    &streamID
);

// Feed data as it arrives from the network
AudioFileStreamParseBytes(streamID, dataLength, data, 0);
```

The parser discovers format info (sample rate, channels, codec) from the stream header, then delivers decoded packets as they're parsed. This is what powers custom audio streaming implementations that go beyond what AVPlayer provides.

### System Sound Services

Short sounds, alerts, and haptics:

```swift
// Play system sound (< 30 seconds, no volume control)
var soundID: SystemSoundID = 0
AudioServicesCreateSystemSoundID(soundURL as CFURL, &soundID)
AudioServicesPlaySystemSound(soundID)

// Play alert sound (respects silent switch, may vibrate)
AudioServicesPlayAlertSound(soundID)

// Vibrate
AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
```

Best for UI feedback sounds. For anything more complex (volume control, effects, long audio), use AVAudioPlayer or AVAudioEngine instead.

### Music Player / Music Sequence (MIDI)

Programmatic MIDI playback:

```c
NewMusicSequence(&sequence);
MusicSequenceFileLoad(sequence, midiFileURL, kMusicSequenceFile_MIDIType, 0);

NewMusicPlayer(&player);
MusicPlayerSetSequence(player, sequence);
MusicPlayerStart(player);

// Tempo track
MusicSequenceGetTempoTrack(sequence, &tempoTrack);
MusicTrackNewExtendedTempoEvent(tempoTrack, 0, 120.0);  // 120 BPM

// Iterate events
MusicEventIteratorNextEvent(iterator);
MusicEventIteratorGetEventInfo(iterator, &timeStamp, &eventType, &eventData, &eventDataSize);
```

### MTAudioProcessingTap

Tap into the AVPlayer audio pipeline for real-time sample access:

```swift
// Create processing tap
var callbacks = MTAudioProcessingTapCallbacks(
    version: kMTAudioProcessingTapCallbacksVersion_0,
    clientInfo: UnsafeMutableRawPointer(Unmanaged.passRetained(self).toOpaque()),
    init: tapInit,
    finalize: tapFinalize,
    prepare: tapPrepare,
    unprepare: tapUnprepare,
    process: tapProcess  // This is where you access/modify audio samples
)
MTAudioProcessingTapCreate(kCFAllocatorDefault, &callbacks, kMTAudioProcessingTapCreationFlag_PostEffects, &tap)

// Attach to AVPlayerItem
let params = AVMutableAudioMixInputParameters(track: audioTrack)
params.audioTapProcessor = tap
let audioMix = AVMutableAudioMix()
audioMix.inputParameters = [params]
playerItem.audioMix = audioMix
```

The `process` callback receives `AudioBufferList` data on the render thread -- same real-time rules apply. This is the **only way** to access AVPlayer's audio samples in real-time (AVAudioEngine cannot route AVPlayer audio through its graph).

### Core Audio Format (CAF)

Apple's container format that supports every codec and has no size limits:

| Feature | CAF | WAV | AIFF |
|---------|-----|-----|------|
| Max file size | Unlimited | 4 GB | 4 GB |
| Codec support | All Apple codecs | PCM, ADPCM | PCM |
| Metadata | Rich | RIFF chunks | Limited |
| Markers/regions | Yes | No | No |

CAF is ideal for intermediate audio processing where you need a container that won't limit you.

---

## AVFAudio

AVFAudio is the modern Swift/Objective-C framework for audio engine, session management, playback, recording, and file I/O.

### AVAudioEngine

A node-based audio processing graph that wraps Audio Units in a Swift-friendly API:

```swift
let engine = AVAudioEngine()
let player = AVAudioPlayerNode()
let eq = AVAudioUnitEQ(numberOfBands: 3)
let reverb = AVAudioUnitReverb()

// Build graph: player → EQ → reverb → output
engine.attach(player)
engine.attach(eq)
engine.attach(reverb)
engine.connect(player, to: eq, format: format)
engine.connect(eq, to: reverb, format: format)
engine.connect(reverb, to: engine.mainMixerNode, format: format)

try engine.start()

// Schedule and play audio
let file = try AVAudioFile(forReading: audioURL)
player.scheduleFile(file, at: nil)
player.play()
```

**Singleton nodes** (always exist):
- `engine.inputNode` -- microphone
- `engine.outputNode` -- speaker
- `engine.mainMixerNode` -- main mixer (auto-created when first accessed)

**Key operations**:

| Method | Purpose |
|--------|---------|
| `attach(_:)` | Add node to engine |
| `connect(_:to:format:)` | Wire nodes together |
| `start()` | Begin processing |
| `pause()` | Pause (keep resources) |
| `stop()` | Stop (release resources) |
| `reset()` | Reset all nodes |

**Manual (offline) rendering**:

```swift
try engine.enableManualRenderingMode(.offline, format: format, maximumFrameCount: 4096)
try engine.start()

let outputBuffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: 4096)!
while player.isPlaying {
    let status = try engine.renderOffline(4096, to: outputBuffer)
    // Write outputBuffer to file
}
```

This enables processing audio without real-time constraints -- perfect for batch effects, format conversion, or analysis.

**Installing taps** for analysis:

```swift
let bus = 0
let bufferSize: AVAudioFrameCount = 1024
engine.mainMixerNode.installTap(onBus: bus, bufferSize: bufferSize, format: format) { buffer, time in
    // Analyze buffer.floatChannelData for visualization, level metering, etc.
}
```

### Built-in Effect Nodes

| Class | Properties | Use case |
|-------|-----------|----------|
| `AVAudioUnitEQ` | `bands[]: {frequency, bandwidth, gain, filterType, bypass}`, `globalGain` | Multi-band parametric equalizer |
| `AVAudioUnitTimePitch` | `pitch` (-2400 to +2400 cents), `rate` (0.03 to 32x), `overlap` | Independent pitch shift + tempo change |
| `AVAudioUnitVarispeed` | `rate` | Speed change (pitch follows, like a turntable) |
| `AVAudioUnitReverb` | `wetDryMix` (0-100), 13 factory presets | Room/hall/chamber/plate/cathedral reverb |
| `AVAudioUnitDelay` | `delayTime`, `feedback`, `lowPassCutoff`, `wetDryMix` | Echo/delay effect |
| `AVAudioUnitDistortion` | 25+ presets, `wetDryMix`, `preGain` | Overdrive, fuzz, decimation, etc. |

**EQ filter types**: `parametric`, `lowPass`, `highPass`, `resonantLowPass`, `resonantHighPass`, `bandPass`, `bandStop`, `lowShelf`, `highShelf`, `resonantLowShelf`, `resonantHighShelf`

**Reverb presets**: `smallRoom`, `mediumRoom`, `largeRoom`, `largeRoom2`, `mediumHall`, `mediumHall2`, `mediumHall3`, `largeHall`, `largeHall2`, `mediumChamber`, `largeChamber`, `cathedral`, `plate`

### AVAudioSession

Configures how your app interacts with the system audio:

```swift
let session = AVAudioSession.sharedInstance()
try session.setCategory(.playback, mode: .spokenAudio, options: [.allowBluetooth])
try session.setActive(true)
```

**Categories** (what your app does with audio):

| Category | Behavior |
|----------|----------|
| `.ambient` | Mixes with other apps, silenced by switch |
| `.soloAmbient` | Default. Silences other apps, silenced by switch |
| `.playback` | Silences other apps, ignores silent switch |
| `.record` | Recording only |
| `.playAndRecord` | Simultaneous playback + recording |
| `.multiRoute` | Route to multiple outputs simultaneously |

**Modes** (optimize for content type):

| Mode | Optimization |
|------|-------------|
| `.default` | No optimization |
| `.voiceChat` | Echo cancellation, AGC |
| `.gameChat` | Gaming voice chat |
| `.videoRecording` | Video recording |
| `.measurement` | Minimal signal processing |
| `.moviePlayback` | Enhanced movie audio |
| `.spokenAudio` | Podcasts, audiobooks (ducks properly) |
| `.voicePrompt` | Short voice prompts (e.g., navigation) |

**Options**: `.mixWithOthers`, `.duckOthers`, `.allowBluetooth`, `.allowBluetoothA2DP`, `.allowAirPlay`, `.defaultToSpeaker`

**Interruption handling**:

```swift
NotificationCenter.default.addObserver(
    forName: AVAudioSession.interruptionNotification,
    object: nil, queue: .main
) { notification in
    guard let info = notification.userInfo,
          let typeValue = info[AVAudioSessionInterruptionTypeKey] as? UInt,
          let type = AVAudioSession.InterruptionType(rawValue: typeValue) else { return }

    switch type {
    case .began:
        // Pause playback
    case .ended:
        let options = info[AVAudioSessionInterruptionOptionKey] as? UInt ?? 0
        if AVAudioSession.InterruptionOptions(rawValue: options).contains(.shouldResume) {
            // Resume playback
        }
    }
}
```

### AVAudioPlayer

Simple local file playback with no streaming support:

```swift
let player = try AVAudioPlayer(contentsOf: fileURL)
player.enableRate = true         // Must set before play
player.rate = 1.5                // 0.5x to 2.0x
player.volume = 0.8              // 0.0 to 1.0
player.numberOfLoops = -1        // -1 = infinite, 0 = play once, N = play N+1 times
player.pan = 0.0                 // -1.0 (left) to 1.0 (right)

player.prepareToPlay()           // Pre-buffer for low-latency start
player.play()

// Volume fade
player.setVolume(0.0, fadeDuration: 2.0)

// Metering
player.isMeteringEnabled = true
player.updateMeters()
let avgPower = player.averagePower(forChannel: 0)  // dBFS
let peakPower = player.peakPower(forChannel: 0)

// Seek
player.currentTime = 30.0       // Jump to 30 seconds
```

**Supported formats**: AAC, ALAC, HE-AAC, MP3, AIFF, WAV, CAF, and anything Core Audio can decode.

**Limitations**: Local files or in-memory `Data` only. No network streaming, no real-time effects, no time observation callbacks.

### AVAudioRecorder

Record audio to a file:

```swift
let settings: [String: Any] = [
    AVFormatIDKey: kAudioFormatMPEG4AAC,
    AVSampleRateKey: 44100.0,
    AVNumberOfChannelsKey: 2,
    AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue,
]

let recorder = try AVAudioRecorder(url: outputURL, settings: settings)
recorder.isMeteringEnabled = true
recorder.prepareToRecord()
recorder.record()

// During recording
recorder.updateMeters()
let level = recorder.averagePower(forChannel: 0)

recorder.stop()
```

### AVAudioFile and AVAudioPCMBuffer

Read and write audio files with automatic format conversion:

```swift
// Read any audio file into PCM buffers
let file = try AVAudioFile(forReading: url)
let format = file.processingFormat        // In-memory PCM format
let length = AVAudioFrameCount(file.length)
let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: length)!
try file.read(into: buffer)

// Access raw samples
let samples = buffer.floatChannelData![0]  // Left channel
for i in 0..<Int(buffer.frameLength) {
    let sample = samples[i]  // Float, -1.0 to 1.0
}

// Write PCM to file
let outputFile = try AVAudioFile(
    forWriting: outputURL,
    settings: [
        AVFormatIDKey: kAudioFormatMPEG4AAC,
        AVSampleRateKey: 44100.0,
        AVNumberOfChannelsKey: 2,
    ]
)
try outputFile.write(from: buffer)

// Random access
file.framePosition = 44100 * 10  // Seek to 10 seconds
try file.read(into: buffer, frameCount: 44100)  // Read 1 second
```

---

## AVFoundation (Audio)

AVFoundation's audio capabilities focus on media playback, editing, and export.

### AVPlayer

The primary player for URL-based audio and video:

```swift
let player = AVPlayer(url: streamURL)
player.play()

// Rate control
player.rate = 1.5                  // Any rate (0.0 = paused)
player.defaultRate = 1.0           // Rate used by play()

// Volume
player.volume = 0.8
player.isMuted = false

// Seeking
player.seek(to: CMTime(seconds: 30, preferredTimescale: 600))
player.seek(to: time, toleranceBefore: .zero, toleranceAfter: .zero)  // Exact seek

// Buffer control
player.automaticallyWaitsToMinimizeStalling = true  // Default
```

**Time observation**:

```swift
// Periodic -- fires at regular intervals
let observer = player.addPeriodicTimeObserver(
    forInterval: CMTime(seconds: 0.5, preferredTimescale: 600),
    queue: .main
) { time in
    let seconds = CMTimeGetSeconds(time)
    // Update progress UI
}

// Boundary -- fires when specific times are crossed
let times = [CMTime(seconds: 30, preferredTimescale: 600)]
let observer = player.addBoundaryTimeObserver(forTimes: times.map { NSValue(time: $0) }, queue: .main) {
    // Reached the 30-second mark
}

// Remove when done
player.removeTimeObserver(observer)
```

**Buffer monitoring** (via `AVPlayerItem`):

```swift
let item = player.currentItem!
item.loadedTimeRanges          // [NSValue(CMTimeRange)] -- what's buffered
item.isPlaybackBufferEmpty     // Buffer ran out
item.isPlaybackLikelyToKeepUp // Enough buffer to play smoothly
```

**Status observation** (KVO):

```swift
player.currentItem?.observe(\.status) { item, _ in
    switch item.status {
    case .readyToPlay: // Ready
    case .failed:      // Check item.error
    case .unknown:     // Loading
    }
}
```

### AVQueuePlayer

Sequential playback of multiple items:

```swift
let items = urls.map { AVPlayerItem(url: $0) }
let queuePlayer = AVQueuePlayer(items: items)
queuePlayer.play()
queuePlayer.advanceToNextItem()

// Add more items
queuePlayer.insert(newItem, after: currentItem)
queuePlayer.remove(item)
```

### Audio Editing with AVMutableComposition

Non-destructive editing -- trim, split, merge without re-encoding:

```swift
// Trim
let asset = AVURLAsset(url: audioURL)
let composition = AVMutableComposition()
let track = composition.addMutableTrack(withMediaType: .audio, preferredTrackID: kCMPersistentTrackID_Invalid)!
let sourceTrack = try await asset.loadTracks(withMediaType: .audio).first!

let startTime = CMTime(seconds: 10, preferredTimescale: 600)
let duration = CMTime(seconds: 30, preferredTimescale: 600)
let range = CMTimeRange(start: startTime, duration: duration)
try track.insertTimeRange(range, of: sourceTrack, at: .zero)

// Merge multiple files
for (index, url) in urls.enumerated() {
    let asset = AVURLAsset(url: url)
    let sourceTrack = try await asset.loadTracks(withMediaType: .audio).first!
    let duration = try await asset.load(.duration)
    try track.insertTimeRange(CMTimeRange(start: .zero, duration: duration), of: sourceTrack, at: currentTime)
    currentTime = CMTimeAdd(currentTime, duration)
}

// Export
let exporter = AVAssetExportSession(asset: composition, presetName: AVAssetExportPresetAppleM4A)!
exporter.outputURL = outputURL
exporter.outputFileType = .m4a
exporter.timeRange = range  // Optional: trim during export
await exporter.export()
```

### AVAudioMix

Apply volume changes and processing during AVPlayer playback or export:

```swift
let params = AVMutableAudioMixInputParameters(track: audioTrack)

// Volume ramp
params.setVolumeRamp(fromStartVolume: 1.0, toEndVolume: 0.0,
    timeRange: CMTimeRange(start: fadeStart, duration: fadeDuration))

// Set volume at a point
params.setVolume(0.5, at: CMTime(seconds: 30, preferredTimescale: 600))

// Time pitch algorithm
params.audioTimePitchAlgorithm = .spectral  // .timeDomain, .spectral, .varispeed (.lowQualityZeroLatency deprecated)

let audioMix = AVMutableAudioMix()
audioMix.inputParameters = [params]

// Apply to player or exporter
playerItem.audioMix = audioMix
exportSession.audioMix = audioMix
```

### MPNowPlayingInfoCenter

Display metadata on Lock Screen, Control Center, and CarPlay:

```swift
var info = [String: Any]()
info[MPMediaItemPropertyTitle] = "Episode 42"
info[MPMediaItemPropertyArtist] = "My Podcast"
info[MPMediaItemPropertyPlaybackDuration] = 3600.0
info[MPNowPlayingInfoPropertyElapsedPlaybackTime] = 120.0
info[MPNowPlayingInfoPropertyPlaybackRate] = 1.0
info[MPMediaItemPropertyArtwork] = MPMediaItemArtwork(boundsSize: image.size) { _ in image }
info[MPNowPlayingInfoPropertyIsLiveStream] = false

MPNowPlayingInfoCenter.default().nowPlayingInfo = info
```

### MPRemoteCommandCenter

Handle external controls (Lock Screen, headphones, CarPlay, Siri):

```swift
let center = MPRemoteCommandCenter.shared()

center.playCommand.addTarget { _ in
    player.play()
    return .success
}

center.pauseCommand.addTarget { _ in
    player.pause()
    return .success
}

// Skip forward/back (podcast style)
center.skipForwardCommand.preferredIntervals = [15]
center.skipForwardCommand.addTarget { event in
    let seconds = (event as! MPSkipIntervalCommandEvent).interval
    let newTime = player.currentTime + seconds
    player.seek(to: CMTime(seconds: newTime, preferredTimescale: 600))
    return .success
}

// Playback position (scrubber)
center.changePlaybackPositionCommand.addTarget { event in
    let position = (event as! MPChangePlaybackPositionCommandEvent).positionTime
    player.seek(to: CMTime(seconds: position, preferredTimescale: 600))
    return .success
}

// Playback rate
center.changePlaybackRateCommand.supportedPlaybackRates = [0.5, 1.0, 1.25, 1.5, 2.0]
center.changePlaybackRateCommand.addTarget { event in
    player.rate = (event as! MPChangePlaybackRateCommandEvent).playbackRate
    return .success
}
```

---

## Sound Analysis

Sound Analysis is Apple's on-device ML framework for classifying audio. Introduced at WWDC 2019 (iOS 13), with a built-in classifier added at WWDC 2021 (iOS 15+).

### Overview

The framework answers **"what kind of sound is this?"** using neural networks that run entirely on-device. It supports both Apple's built-in classifier (303 sound categories) and custom Core ML models trained with Create ML.

### Real-Time Classification

Feed audio buffers from `AVAudioEngine` into `SNAudioStreamAnalyzer`:

```swift
import SoundAnalysis

let analyzer = SNAudioStreamAnalyzer(format: engine.mainMixerNode.outputFormat(forBus: 0))
let request = try SNClassifySoundRequest(classifierIdentifier: .version1)
request.windowDuration = CMTime(seconds: 1.5, preferredTimescale: 1)
request.overlapFactor = 0.5

try analyzer.add(request, withObserver: self)

// Feed audio from engine tap
engine.mainMixerNode.installTap(onBus: 0, bufferSize: 8192, format: format) { buffer, time in
    analysisQueue.async {
        analyzer.analyze(buffer, atAudioFramePosition: time.sampleTime)
    }
}
```

### File Analysis

Classify a recorded audio file (runs faster than real-time):

```swift
let fileAnalyzer = try SNAudioFileAnalyzer(url: audioFileURL)
let request = try SNClassifySoundRequest(classifierIdentifier: .version1)
try fileAnalyzer.add(request, withObserver: self)
fileAnalyzer.analyze()  // Synchronous
// or
fileAnalyzer.analyze { didReachEnd in
    // Async completion
}
```

### Results Observer

```swift
extension MyAnalyzer: SNResultsObserving {
    func request(_ request: SNRequest, didProduce result: SNResult) {
        guard let classification = result as? SNClassificationResult else { return }

        // Top classification
        let top = classification.classifications.first!
        print("\(top.identifier): \(top.confidence)")  // "speech: 0.95"

        // Check specific sound
        if let speech = classification.classification(forIdentifier: "speech") {
            if speech.confidence > 0.7 {
                // Speech detected
            }
        }

        // Time range
        let range = classification.timeRange  // CMTimeRange
    }

    func request(_ request: SNRequest, didFailWithError error: Error) { }
    func requestDidComplete(_ request: SNRequest) { }
}
```

### Configuration

| Property | Default | Range | Impact |
|----------|---------|-------|--------|
| `windowDuration` | ~1.0s | Model-dependent (check `windowDurationConstraint`) | Larger = more accurate, less time-precise |
| `overlapFactor` | 0.5 | 0.0 - 1.0 | Higher = more frequent results, more CPU |

### Built-in Sound Categories (303 total)

The built-in classifier recognizes 303 sounds. Here are the categories organized by group:

**Human - Speech & Vocalization**: `speech`, `shout`, `yell`, `scream`, `laughter`, `babbling`, `crowd`, `conversation`, `narration`, `singing`, `whispering`, `battle_cry`, `humming`, `whistling`, `chatter`, `whimper`

**Human - Respiratory**: `breathing`, `cough`, `sneeze`, `snoring`, `gasp`, `sigh`, `throat_clearing`, `gargling`, `hiccup`

**Human - Activity**: `clapping`, `finger_snapping`, `typing`, `writing`, `walking`, `running`, `tapping`, `shuffling`, `stomping`, `chewing`, `drinking_sipping`, `burping`

**Animals**: `dog_bark`, `dog_bow_wow`, `dog_growl`, `dog_whimper`, `cat_meow`, `cat_purr`, `cat_hiss`, `bird_chirp`, `bird_squawk`, `bird_call`, `crow_caw`, `owl_hoot`, `rooster_crow`, `duck_quack`, `goose_honk`, `turkey_gobble`, `livestock`, `horse_clip_clop`, `horse_neigh`, `cow_moo`, `pig_oink`, `sheep_bleat`, `goat_bleat`, `frog_croak`, `cricket`, `insect_buzz`, `fly_buzz`, `bee_buzz`, `mosquito_buzz`, `snake_hiss`, `whale_vocalization`, `monkey`, `elephant`, `lion_roar`, `bear_growl`

**Musical Instruments**: `piano`, `guitar`, `electric_guitar`, `bass_guitar`, `ukulele`, `banjo`, `mandolin`, `harp`, `violin_fiddle`, `cello`, `double_bass`, `drum_kit`, `snare_drum`, `bass_drum`, `cymbal`, `hi_hat`, `tambourine`, `bongo`, `conga`, `steel_drum`, `marimba`, `xylophone`, `vibraphone`, `glockenspiel`, `trumpet`, `trombone`, `french_horn`, `tuba`, `saxophone`, `clarinet`, `flute`, `oboe`, `harmonica`, `accordion`, `bagpipe`, `organ`, `synthesizer`, `sitar`, `tabla`, `didgeridoo`

**Music**: `music`, `theme_music`, `jingle`, `soundtrack_music`

Note: The classifier recognizes music as a general category and distinguishes individual instruments (listed above), but does not classify music by genre.

**Environmental - Weather**: `rain`, `raindrop`, `heavy_rain`, `thunder`, `thunderstorm`, `wind`, `hail`

**Environmental - Water**: `water`, `stream`, `waterfall`, `ocean`, `waves`, `boiling`, `water_drip`, `splash`, `water_pour`

**Environmental - Nature**: `fire_crackle`, `rustling_leaves`, `branch_snap`, `avalanche`, `earthquake`, `volcano`, `landslide`

**Vehicles**: `car`, `car_horn`, `car_engine_starting`, `car_engine_idling`, `car_passing`, `tire_screech`, `truck`, `bus`, `motorcycle`, `train`, `train_horn`, `train_wheels`, `subway`, `aircraft`, `helicopter`, `propeller`, `jet_engine`, `boat`, `speedboat`, `bicycle_bell`, `skateboard`, `siren`, `ambulance_siren`, `police_siren`, `fire_engine_siren`

**Household**: `door_knock`, `door_slam`, `door_open_close`, `doorbell`, `key_jingle`, `lock_click`, `window`, `drawer`, `cupboard`, `toilet_flush`, `sink_filling`, `faucet`, `shower`, `bathtub`, `vacuum_cleaner`, `hair_dryer`, `blender`, `microwave`, `dishwasher`, `washing_machine`, `refrigerator`, `air_conditioner`, `fan`, `clock_tick`, `clock_alarm`, `telephone_ring`, `cellphone_ring`, `television`, `static_noise`, `printer`, `computer_keyboard`, `mouse_click`, `zipper`

**Alarms & Signals**: `alarm`, `alarm_clock`, `smoke_detector`, `fire_alarm`, `car_alarm`, `security_alarm`, `beep`, `buzzer`, `bell`, `church_bell`, `school_bell`, `whistle`, `horn`, `foghorn`, `air_horn`

**Food & Kitchen**: `chopping`, `sizzle`, `frying`, `stirring`, `pouring`, `cork_pop`, `can_opening`, `bottle_opening`, `glass_clink`, `cutlery`, `plate_clink`, `ice_cube`

**Tools & Machinery**: `hammer`, `saw`, `drill`, `power_tool`, `jackhammer`, `nail_gun`, `sanding`, `welding`, `chainsaw`, `lawnmower`, `engine`, `compressor`, `pump`, `machinery`

**Other**: `explosion`, `gunshot`, `fireworks`, `glass_breaking`, `wood_breaking`, `metal_clang`, `paper_rustling`, `plastic_bag`, `cardboard`, `bubble_wrap`, `tape`, `coin_drop`, `cash_register`, `slot_machine`, `pinball`, `bowling`, `basketball_bounce`, `golf_swing`, `tennis_hit`, `crowd_cheer`, `crowd_boo`, `applause`, `baby_crying`, `baby_laughter`, `child_speech`, `silence`, `noise`, `white_noise`, `pink_noise`, `static`

### Custom Models

Train your own sound classifier with Create ML:

1. Organize audio files into folders (one folder per category)
2. Open Create ML, create a Sound Classification project
3. It uses **Audio Feature Print** transfer learning from Apple's base model
4. Even small datasets (50-100 samples per class) produce good results
5. Export as `.mlmodel`, use with `SNClassifySoundRequest(mlModel:)`

```swift
let model = try MLModel(contentsOf: customModelURL)
let request = try SNClassifySoundRequest(mlModel: model)
```

**Audio requirements**: 16 kHz recommended, mono (first channel only), window duration 0.5-15s.

### Sound Analysis vs. Speech Framework

| Framework | Question it answers | Output |
|-----------|-------------------|--------|
| Sound Analysis | "What kind of sound?" | Category labels + confidence |
| Speech (`SFSpeechRecognizer`) | "What words are spoken?" | Transcribed text |

They complement each other: detect speech presence with Sound Analysis, then transcribe only when speech confidence is high.

---

## AudioKit (Open Source)

[AudioKit](https://github.com/AudioKit/AudioKit) is an 11,000+-star MIT-licensed audio platform built on AVAudioEngine. It provides vastly more DSP nodes, analysis tools, and UI components than Apple's built-in APIs.

### Architecture

AudioKit is split into ~15 SPM packages (plus documentation, CI, and example repos). The core is **pure Swift** (no C/C++). Heavy DSP lives in separate packages:

| Package | What it provides | Backend |
|---------|-----------------|---------|
| **AudioKit** (core) | AudioEngine, Node, Taps, MIDI, Sequencing | Pure Swift over AVAudioEngine |
| **AudioKitEX** | Fader, DryWetMixer, Parameter Automation, Sequencer | C |
| **SoundpipeAudioKit** | 54 DSP nodes (14 generators + 40 effects) | Soundpipe C + KissFFT |
| **DunneAudioKit** | Sampler (SFZ), Synth, Chorus, Flanger, StereoDelay | C++ |
| **STKAudioKit** | Physical instrument models (strings, brass, flutes) | Stanford STK C++ |
| **DevoloopAudioKit** | Guitar amp sim, tube compressor | C++ |
| **SporthAudioKit** | Functional DSL for audio programming | Sporth C |
| **AudioKitUI** | SwiftUI visualizations (FFT, spectrogram, waveform, meters) | Swift |
| **Controls** | SwiftUI knobs, sliders, XY pads, wheels | Swift |
| **Keyboard** | SwiftUI piano/guitar/isomorphic keyboard | Swift |
| **Tonic** | Music theory (notes, chords, scales, keys, intervals) | Swift |
| **Flow** | Node graph editor | Swift |

### What It Adds Over Apple's APIs

| Capability | Apple Built-in | AudioKit |
|-----------|---------------|----------|
| Effect nodes | ~12 | 80+ |
| Filters | 6 (LP, HP, BP, shelf, parametric) | 20+ (Moog, Korg, Roland TB-303, Diode Ladder, Modal Resonance, etc.) |
| Reverbs | 1 (Reverb2 with 13 presets) | 6 (Chowning, Costello, Convolution IR, Zita, Comb, Flat) |
| Distortion | 1 (25 presets) | 5+ (BitCrusher, Clipper, Tanh, Decimator, RingModulator) |
| Dynamics | 1 (DynamicsProcessor) | 5+ (Compressor, Expander, PeakLimiter, DynaRage, TransientShaper) |
| Modulation | None built-in | 8 (AutoPanner, AutoWah, Chorus, Ensemble, Flanger, Phaser, Tremolo, Vibrato) |
| Oscillators | None (generator AU only) | 7+ (Oscillator, FM, Morphing, PWM, Phase Distortion, Dynamic, etc.) |
| Physical models | None | 5+ (PluckedString, MetalBar, VocalTract, Drip, Shaker + STK instruments) |
| Analysis taps | Raw buffer only | Amplitude, FFT, Pitch detection |
| MIDI | C-level CoreMIDI | Full Swift MIDI stack with Bluetooth, file parsing, listeners |
| UI components | None | 30+ SwiftUI views (spectrogram, waveform, meters, knobs, keyboard) |
| Music theory | None | Tonic library (notes, chords, scales, keys) |

### Example Usage

```swift
import AudioKit
import SoundpipeAudioKit

let engine = AudioEngine()
let player = AudioPlayer()

// Build effect chain
let reverb = CostelloReverb(player)
reverb.feedback = 0.6
reverb.cutoffFrequency = 9900

let moogFilter = MoogLadder(reverb)
moogFilter.cutoffFrequency = 1000
moogFilter.resonance = 0.5

engine.output = moogFilter
try engine.start()

try player.load(url: audioURL)
player.play()
```

### Analysis

```swift
// Amplitude tracking
let tap = AmplitudeTap(player) { amplitude in
    print("Level: \(amplitude)")  // RMS amplitude
}
tap.start()

// FFT spectrum
let fftTap = FFTTap(player) { fftData in
    // fftData: [Float] -- magnitude spectrum
}
fftTap.start()

// Pitch detection (SoundpipeAudioKit)
let pitchTap = PitchTap(player) { pitch, amplitude in
    print("Pitch: \(pitch) Hz, Amplitude: \(amplitude)")
}
pitchTap.start()
```

### When to Use AudioKit

**Use AudioKit when**: Building a synthesizer, music production app, guitar effects processor, audio visualizer with complex DSP, or any app that needs filters/effects beyond Apple's built-in 12 Audio Units.

**Use Apple's APIs directly when**: Building a podcast player, audiobook player, music player, voice recorder, or any app where the primary need is playback/recording with basic effects (EQ, reverb, pitch/speed). Apple's built-in APIs cover these use cases without the overhead of AudioKit's C/C++ compilation and dependency graph.

### Trade-offs

| Pro | Con |
|-----|-----|
| 80+ DSP nodes | Each node = one AVAudioUnit (overhead for complex graphs) |
| Swift-native API | C/C++ compilation slows builds significantly |
| 12 years battle-tested | Still swift-tools-version 5.9 (no strict concurrency mode) |
| MIT license, 110+ Cookbook demos | Multi-repo ecosystem can be fragmented |
| Full MIDI stack | Single primary maintainer (bus factor risk) |

---

## Decision Matrix

| Use case | Framework | Key types |
|----------|-----------|-----------|
| Play a sound effect (< 30s) | AudioToolbox | `AudioServicesPlaySystemSound` |
| Play local audio file | AVFAudio | `AVAudioPlayer` |
| Stream audio from URL/HLS | AVFoundation | `AVPlayer`, `AVPlayerItem` |
| Queue multiple tracks | AVFoundation | `AVQueuePlayer` |
| Real-time EQ / reverb / effects | AVFAudio | `AVAudioEngine`, `AVAudioUnitEQ`, `AVAudioUnitReverb` |
| Change speed without pitch change | AVFAudio | `AVAudioUnitTimePitch` |
| Record audio | AVFAudio | `AVAudioRecorder` (simple), `AVAudioEngine` (with effects) |
| Trim / split / merge audio | AVFoundation | `AVMutableComposition`, `AVAssetExportSession` |
| Volume fades during playback | AVFoundation | `AVMutableAudioMix`, `AVMutableAudioMixInputParameters` |
| Access raw samples from AVPlayer | AudioToolbox | `MTAudioProcessingTap` |
| Parse streaming audio progressively | AudioToolbox | `AudioFileStreamOpen`, `AudioFileStreamParseBytes` |
| Convert audio formats | AudioToolbox | `AudioConverterNew`, `AudioConverterFillComplexBuffer` |
| Read any file format into PCM | AudioToolbox / AVFAudio | `ExtAudioFile` or `AVAudioFile` |
| Classify sounds (ML) | Sound Analysis | `SNAudioStreamAnalyzer`, `SNClassifySoundRequest` |
| Play MIDI files | AudioToolbox | `MusicSequence`, `MusicPlayer` |
| Lock Screen now playing info | MediaPlayer | `MPNowPlayingInfoCenter` |
| Handle remote commands | MediaPlayer | `MPRemoteCommandCenter` |
| Custom AUv3 audio plug-in | AudioUnit | `AUAudioUnit` subclass, App Extension |
| Host third-party audio plug-ins | AudioUnit | `AVAudioUnitComponentManager`, `AVAudioUnit.instantiate` |
| Synthesis / complex DSP / music apps | AudioKit | `AudioEngine`, SoundpipeAudioKit nodes |
| Background audio playback | AVFAudio + UIKit | `AVAudioSession.setCategory(.playback)` + `UIBackgroundModes: audio` |
| Spatial / 3D audio | AVFAudio | `AVAudioEnvironmentNode` |
| Offline audio rendering | AVFAudio | `AVAudioEngine.enableManualRenderingMode` |
| Low-level hardware access (macOS) | Core Audio | `AudioHardware`, `AudioDevice` |

---

## Summary

Apple's audio stack is deep. Most apps only need AVFoundation (AVPlayer) or AVFAudio (AVAudioEngine). Drop to AudioToolbox for format conversion, stream parsing, or MTAudioProcessingTap. Use Audio Units for custom real-time DSP or hosting third-party plug-ins. Sound Analysis adds ML-powered sound classification. And AudioKit fills the gaps with 80+ DSP nodes when Apple's built-in effects aren't enough.

Start at the highest level. Drop down only when you need more control.
