---
title: "Tethersnap: Switch 2 captures on a Mac over plain PTP"
date: 2026-09-04 12:00:00
categories:
- Mac
tags:
- Tethersnap
- PTP
- MTP
- IOUSBHost
- IOKit
- USB
- Swift
- SwiftUI
- libmtp
- OpenMTP
- Nintendo Switch 2
---

The Switch 2 has a ["Copy to PC via USB"](https://en-americas-support.nintendo.com/app/answers/detail/a_id/68343) screen for getting screenshots and clips onto a computer. From a Mac, nothing shows up. macOS has never shipped an MTP stack, and the bridges Mac users leaned on with the original Switch ([OpenMTP](https://github.com/ganeshrvel/openmtp), [MacDroid](https://www.macdroid.app/), [Android File Transfer](https://9to5google.com/2024/02/16/android-file-transfer-mac-hidden/)) all fail against the new console. This post is about why they fail, which comes down to the console speaking plain [PTP](https://en.wikipedia.org/wiki/Picture_Transfer_Protocol) rather than the [MTP](https://en.wikipedia.org/wiki/Media_Transfer_Protocol) those tools expect, and about [Tethersnap](https://github.com/Luminoid/Tethersnap), a Mac app and CLI that talks to the console directly over [IOUSBHost](https://developer.apple.com/documentation/iousbhost). Most of it covers the four ways the real hardware diverged from the standard, and it ends with what is still rough.

<!-- more -->

## Terms

| Term | Meaning |
|------|---------|
| **Initiator, responder** | PTP's names for the host (the Mac) and the device (the console) |
| **Session** | The open conversation between them; the responder keeps one transaction counter per session |
| **Transaction** | One request: a command, an optional data phase in one direction, then a response |
| **Container** | The unit on the wire: a 12-byte header plus payload, typed command, data, response, or event |
| **Dataset** | A fixed-layout record the responder returns: DeviceInfo, StorageInfo, ObjectInfo |
| **Object handle** | A 32-bit ID for one file or folder, valid within a session |
| **Association** | PTP's word for a folder (object format 0x3001) |
| **Storage ID** | A 32-bit ID for one store on the device, such as the console's "Album" |

## What the Mac sees

Put the console on System Settings → Data Management → Manage Screenshots and Videos → Copy to PC via USB, plug a data cable into the bottom USB-C port rather than the dock, and it enumerates as USB device `057e:2061` with one interface: class 0x06, subclass 0x01, protocol 0x01, a bulk-in endpoint at 0x81, a bulk-out at 0x01, and an interrupt-in for events. That class triple is the USB [still image capture class](https://www.usb.org/document-library/still-image-capture-device-definition-10-and-errata-16-mar-2007) digital cameras use, and the protocol riding on it is PTP.

PTP and MTP get used interchangeably, and the difference is the whole story here. PTP (Picture Transfer Protocol) started as PIMA 15740 in 2000 and was later folded into [ISO 15740](https://www.iso.org/standard/63602.html): sessions, transactions, datasets, handles, associations. MTP (Media Transfer Protocol) is the extension Microsoft layered on top around 2004 for media players, which the USB-IF standardized as a device class in 2008. An MTP device is a PTP device whose DeviceInfo carries vendor extension ID 6, the description `microsoft.com: 1.0`, and a large block of [extension operations](https://learn.microsoft.com/en-us/previous-versions/windows/desktop/wmp/mtp-device-extensions-for-metadata-transfer). The one that matters is [GetObjectPropList](https://github.com/gphoto/libgphoto2/blob/master/camlibs/ptp2/ptp.h) (0x9805), which returns the metadata for a whole folder in one round trip. Every Android phone is an MTP device, so every client written against Android phones leans on it, because one GetObjectInfo per object crawls on a phone holding ten thousand files.

Here is the Switch 2's DeviceInfo as `tethersnap probe` prints it, serial redacted:

```text
DeviceInfo
  Manufacturer:     Nintendo
  Model:            Nintendo Switch 2
  Version:          22.5.0
  PTP version:      1.00
  Vendor extension: 0xFFFFFFFF "nintendo.com: 1.0; "
  Operations:       0x1001 0x1002 0x1003 0x1004 0x1005 0x1006 0x1007 0x1008 0x1009 0x100A
```

Ten operations, the first ten codes of the PTP baseline in order: GetDeviceInfo, OpenSession, CloseSession, GetStorageIDs, GetStorageInfo, GetNumObjects, GetObjectHandles, GetObjectInfo, GetObject, GetThumb. The vendor extension of 0xFFFFFFFF means the console has none. There is no GetObjectPropList, and no GetPartialObject (0x101B) either, even though that one is baseline PTP that every camera of the last twenty years implements. The advertised formats are 0x3801 (EXIF/JPEG) for screenshots and 0xB982 (MP4) for clips; that MP4 code comes from MTP's format range and is the only trace of MTP anywhere in the profile.

That profile explains the failures. A client that assumes GetObjectPropList is there gets OperationNotSupported back and, depending on how it handles that, gives up or surfaces a read error. I have not stepped through OpenMTP's source, so this is read off the profile rather than traced, but the symptoms in [OpenMTP issue #460](https://github.com/ganeshrvel/openmtp/issues/460) (open since May 2026, still without a maintainer reply) fit: Kalam mode disconnects with "An error occurred while reading the MTP file object", and Legacy mode connects but lists nothing. Nintendo's own support page asks for an operating system with MTP support and points everyone else at third-party MTP software, at their own risk.

Linux met the same device and had no trouble. [libmtp bug #1953](https://sourceforge.net/p/libmtp/bugs/1953/), filed in June 2025 and closed in February 2026, shows `mtp-detect` warning that the device looks like a camera and then getting clean results from GetDeviceInfo, OpenSession, and GetObjectHandles. [libmtp](https://github.com/libmtp/libmtp) 1.1.23 added the console to its [device table](https://github.com/libmtp/libmtp/blob/master/src/music-players.h) as `{ "Nintendo", 0x057e, "Switch 2", 0x2061, DEVICE_FLAG_NONE }`, no quirk flags, the same treatment the original Switch (0x201d) got under [bug #1893](https://sourceforge.net/p/libmtp/bugs/1893/). That suggested the approach for a Mac client: use only the ten operations the console admits to. Tethersnap was built to see whether that was enough, and it was.

Why not just use libmtp on the Mac, then? [Homebrew carries 1.1.23](https://formulae.brew.sh/formula/libmtp), and `mtp-detect` is a useful independent cross-check on the transport. As a shipping dependency it is an LGPL dylib plus libusb, both of which a user would have to install, in exchange for a protocol subset that fits in a few hundred lines of Swift. Writing the transport by hand also keeps every byte on the wire visible, which is what you want the moment a device misbehaves. And macOS makes the direct route cheap: with no MTP kernel driver, the console's IOService sits unclaimed, and a user-space process can take exclusive ownership through IOUSBHost with no entitlement, provided it is not sandboxed. (A sandboxed app would need [`com.apple.security.device.usb`](https://developer.apple.com/documentation/bundleresources/entitlements/com.apple.security.device.usb).)

## Driving USB from Swift through IOUSBHost

IOUSBHost is the user-space USB API Apple shipped in macOS 10.15 to replace the old COM-style IOUSBLib interfaces. Three Objective-C classes carry the weight: [`IOUSBHostDevice`](https://developer.apple.com/documentation/iousbhost/iousbhostdevice), [`IOUSBHostInterface`](https://developer.apple.com/documentation/iousbhost/iousbhostinterface), [`IOUSBHostPipe`](https://developer.apple.com/documentation/iousbhost/iousbhostpipe). Several methods you need are marked [`NS_REFINED_FOR_SWIFT`](https://developer.apple.com/documentation/swift/improving-objective-c-api-declarations-for-swift), which hides them behind a double-underscore prefix on the theory that a Swift overlay provides something nicer. No overlay exists, so the code calls the underscored names:

```swift
// Find the console: an IOUSBHost matching dictionary, then an IOKit lookup
let matching = IOUSBHostDevice.__createMatchingDictionary(
    withVendorID: NSNumber(value: 0x057E), productID: NSNumber(value: 0x2061),
    bcdDevice: nil, deviceClass: nil, deviceSubclass: nil,
    deviceProtocol: nil, speed: nil, productIDArray: nil
)
// IOServiceGetMatchingService consumes the dictionary's +1 reference.
let service = IOServiceGetMatchingService(kIOMainPortDefault, matching.takeUnretainedValue())
let device = try IOUSBHostDevice(__ioService: service, options: [], queue: nil, interestHandler: nil)
```

The same goes for `__configure(withValue:matchInterfaces:)`, `__sendIORequest(with:bytesTransferred:completionTimeout:)` on bulk transfers, and `IOUSBHostInterface.__send(_:data:bytesTransferred:completionTimeout:)` on control requests. It reads badly but it is stable, and it compiles against the current SDK at a macOS 15 deployment target.

From there the claim sequence is: select the configuration if none is active, walk the configuration descriptor for an interface with both a bulk-in and a bulk-out endpoint (preferring class 0x06 or vendor-specific 0xFF), claim it, and copy out the two pipes. Interfaces register with IOKit asynchronously after configuration, so the claim polls for up to five seconds rather than giving up on the first miss. Transfers are synchronous calls with a completion timeout, five seconds for a command and thirty for a data phase, and the transport runs on one thread by design.

The descriptor walk held the first real-hardware bug, one the mock-transport tests could not have caught. Against the real console this never returned:

```swift
// Wrong: when the iterator is exhausted, flatMap yields nil and ?? restarts from the first interface
current = current.flatMap { IOUSBGetNextInterfaceDescriptor(configuration, $0) }
    ?? IOUSBGetNextInterfaceDescriptor(configuration, nil)
```

Once the iterator runs out, `flatMap` produces nil, the `??` branch fetches the first interface again, and the walk starts over forever. The app sat on "Connecting…", and since quitting waited on a disconnect that ran on the same actor that was spinning, it could not be quit through the normal path. The fix is the plain version: seed before the loop, advance at the end, stop on nil.

```swift
// Right: no restart path
var interfacePointer = IOUSBGetNextInterfaceDescriptor(configuration, nil)
while let interfaceDescriptor = interfacePointer {
    // ...collect this interface's endpoints...
    interfacePointer = interfaceDescriptor.withMemoryRebound(to: IOUSBDescriptorHeader.self, capacity: 1) {
        IOUSBGetNextInterfaceDescriptor(configuration, $0)
    }
}
```

Two lessons from that: a mock transport cannot exercise the layer underneath the mock, and the quit path must never block on the device thread. App termination now does a bounded wait on a detached disconnect and then exits whether or not it finished.

Bulk-in requests must be whole multiples of the endpoint's packet size or they fail outright, so the reader rounds every request up to 1024 bytes, which 64, 512, and 1024 all divide. And a failed transfer should only clear the endpoint when the failure really is a stall, since clearing a healthy pipe resets its data toggle and scrambles everything after it. IOUSBHost reports a STALL handshake as `kUSBHostReturnPipeStalled`, 0xe0005000 in `IOUSBHostFamilyDefinitions.h`; the 0xe0004xxx codes in older USB material (0xe000404f `kIOUSBPipeStalled`, 0xe0004007 `kIOUSBWrongPIDErr`) belong to the legacy IOUSBFamily. The first release of Tethersnap matched 0xe0004007, so its stall recovery could never have fired. It now matches the usbhost code first and the legacy pair as a fallback, sign-extended forms included, because the macros do not import into Swift and the value arrives as a plain `NSError` code.

## Containers, transactions, and what happens when one fails

Every PTP-over-USB container opens with the same 12 bytes (the framing comes from the USB still image class, not PIMA 15740 itself):

| Offset | Size | Field |
|-------:|-----:|-------|
| 0 | 4 | Total length, header included |
| 4 | 2 | Type: 1 command, 2 data, 3 response, 4 event |
| 6 | 2 | Operation code, or response code for type 3 |
| 8 | 4 | Transaction ID |

Here is a real GetDeviceInfo from the app's debug log, which records every transfer on the wire:

```text
→ GetDeviceInfo(0x1001) tx 0
bulk-out 0c 00 00 00 01 00 01 10 00 00 00 00                  command, 12 bytes, no parameters
bulk-in  d9 00 00 00 02 00 01 10 00 00 00 00                  data header: 217 bytes total
bulk-in  64 00 ff ff ff ff 6e 00 14 6e 00 69 00 6e 00 74 …     205 payload bytes
bulk-in  0c 00 00 00 03 00 01 20 00 00 00 00                  response OK (0x2001)
← OK (0x2001) tx 0, 205 data bytes
```

The payload opens with `64 00` (standard version 100, meaning 1.00), `ff ff ff ff` for no vendor extension, `6e 00` for extension version 110, then a 20-character UCS-2 string starting `n i n t`. Notice that the console sends the data header as its own 12-byte transfer and the payload in a second one. Other responders pack header and payload together, or fuse the data container and the response into one transfer, or split a header across two, and a large part of libmtp's USB layer is case analysis over exactly these variations. Tethersnap's container reader keeps a leftover buffer and copes with all of them, plus stray zero-length packets (two in a row are tolerated, a third means the device stopped talking). Each case is a scripted mock-transport test, since none of them can be reproduced on demand against a real console.

Transaction IDs: OpenSession always uses 0, a GetDeviceInfo issued outside a session also uses 0, and everything else counts up from 1. Data sizes: a GetObject data phase can run to tens of megabytes (the validation run pulled a 34.8 MB video), so data phases stream to a sink in 512 KB reads, while the buffered path used for responses refuses anything over 64 MB so a corrupt length field cannot turn into a multi-gigabyte allocation.

Any transaction that ends with something other than a proper response, whether a transport error or a data phase the user abandoned by cancelling an export mid-video, leaves the responder stuck in the middle of a conversation, and its next bulk-in transfer is the rest of the video you stopped reading. Recovering in place would mean draining an unknown quantity of data and guessing at the responder's state, so Tethersnap does not attempt it. `MTPSession` marks itself invalid the moment a transaction ends in anything but a clean response, every later call throws `sessionInvalidated`, and the consumers above it (export, thumbnail loading) drop the connection and reconnect. If the console still thinks the previous session is open when the new connection arrives, the reconnect runs the stale-session ladder below.

## Four things the console did that the spec did not mention

### The flat listing is rejected

GetObjectHandles with a storage ID, format 0, and parent 0 means "every object in this store", the standard's one-shot listing. The console answers InvalidObjectHandle (0x2009) with a four-byte empty data phase. The recursive walk does work: ask for parent 0xFFFFFFFF at the root, then descend into each association.

```text
→ GetObjectHandles tx 2 [0x00260001 0x00000000 0x00000000]
← InvalidObjectHandle (0x2009) tx 2, 4 data bytes
→ GetObjectHandles tx 3 [0x00260001 0x00000000 0xFFFFFFFF]
← OK tx 3, 8 data bytes                       one root handle: 0x0000088D
→ GetObjectInfo tx 4 [0x0000088D]
← OK tx 4, 88 data bytes                      association, one folder per game
→ GetObjectHandles tx 5 [0x00260001 0x00000000 0x0000088D]
← OK tx 5, 16 data bytes                      three captures
```

At the root there is one folder per game, not the `Album/YYYY/MM/DD` date tree older reports describe for the original Switch. That is where the app's "by game" grouping comes from, with no extra metadata call: the folder name is already in the parent association's ObjectInfo, and the walk carries it down to each capture.

The cost is one GetObjectInfo round trip per object, two or three milliseconds apiece on this console. Seventy captures list in well under a second; a library of a few thousand would take around ten seconds on every connect, with no GetObjectPropList to batch it and, because of the next finding, nothing safe to cache between sessions.

### Storage IDs change between sessions

The console's single storage, named "Album", reported ID 0x000F0001 in one session, 0x00140001 in the next, and 0x00260001 in the trace above. Nothing in the standard promises a storage ID outlives a session. The upper half climbs like a counter of something, possibly entries into transfer mode, though that is a guess from three samples. Tethersnap persists nothing that includes a storage ID. StorageInfo is no help for capacity either: MaxCapacity and FreeSpaceInBytes both come back as all-ones, so `probe` prints "unknown" instead of the sixteen exabytes those values decode to.

### The spec's handshake works exactly once

The standard's connect sequence is a sessionless GetDeviceInfo on transaction 0, then OpenSession. That worked on the first entry into transfer mode. Leave the Copy to PC screen and come back, and the console answers transaction 0 with an empty data phase and InvalidTransactionID (0x2004). The fallback opens the session first and fetches DeviceInfo inside it with an ordinary transaction ID. Both paths stay in the code, since on a fresh entry the spec-compliant one works and there is no way to tell the two states apart without trying.

### The stale session, and the reset the console refuses

The symptom was OpenSession coming back with SessionAlreadyOpen (0x201E). The tempting reading, and the one Tethersnap first shipped with, is that the session is already open, so carry on. Then every request returns InvalidTransactionID, because the stale session's transaction counter belongs to whatever process opened it and no operation will tell you its value. The session was useless, and so was every reconnect after it, until the cable came out.

Who opened it? Android File Transfer Agent, the login item that Google's discontinued app leaves behind on any Mac that ever had it installed. It opens a PTP session on every console attach and abandons it, and it will do the same to any PTP device you plug in. macOS's own `ptpcamerad`, which backs Image Capture, could in principle do the same to a still-image-class device, though it did not here.

The recovery ladder, in the order the code walks it:

{% mermaid %}
flowchart TD
    A["OpenSession"]:::outline --> B{"Response"}
    B -- OK --> OK["Session open"]:::accent
    B -- SessionAlreadyOpen --> C["CloseSession the stale session"]
    C -- OK --> A2["OpenSession again"] --> OK
    C -- rejected, needs the stale counter --> D["Still-image class Device Reset<br>bRequest 0x66 on the control pipe"]
    D -- accepted --> A2
    D -- STALL on firmware 22.5.0 --> E["USB device reset<br>IOUSBHostDevice.reset, a software replug"]:::muted
    E --> F["Wait for re-enumeration,<br>reconnect once"]:::outline --> A
{% endmermaid %}

CloseSession fails for the same reason as everything else, since it also needs a valid transaction ID. The USB still image class provides a class-specific Device Reset request (bRequest 0x66 on the control pipe) for precisely this situation, meant to cancel any open session and return the responder to idle, and the Switch 2 STALLs that request too. So the last rung is `IOUSBHostDevice.reset()`, which tears the device down kernel-side and re-enumerates it, the software equivalent of pulling the cable. The transport is dead after that, the console re-attaches a few seconds later, the IOKit matching notification fires, and the app connects fresh. It is heavy-handed, and it was also the only thing that reliably cleared a stuck session.

## The app around it

The app is a thin SwiftUI shell over the same kit the CLI uses: a thumbnail grid, multi-select, export to a folder, drag-out to Finder. The console generates its own thumbnails, 20 to 30 KB JPEGs for screenshots and clips alike, so one GetThumb per item is all the grid needs, and seventy of them arrive in well under a second. The kit keeps a GetPartialObject fallback for responders without GetThumb, though on the Switch 2 it never runs.

{% asset_img app-grid.png "Tethersnap connected to a Nintendo Switch 2, showing the capture grid with thumbnails, a selection, and the export controls" %}

Concurrency is the one design choice that cuts against the grain of [Swift 6](https://www.swift.org/migration/documentation/migrationguide/). The whole USB and PTP stack is synchronous and non-Sendable on purpose. A PTP session is one strictly ordered conversation, so making it internally async buys nothing, and marking it [Sendable](https://developer.apple.com/documentation/swift/sendable) would be untrue. The app confines it to one actor and gives that actor its own [serial executor](https://github.com/swiftlang/swift-evolution/blob/main/proposals/0392-custom-actor-executors.md):

```swift
actor DeviceService {
    private var connection: TethersnapConnection?
    private nonisolated let executorQueue = DispatchSerialQueue(label: "dev.luminoid.Tethersnap.DeviceService")

    nonisolated var unownedExecutor: UnownedSerialExecutor {
        executorQueue.asUnownedSerialExecutor()
    }

    // Every MTP call is an actor method: serialized, blocking, and off the cooperative pool.
}
```

A 35 MB GetObject is a blocking call that runs for several seconds. On the default executor it would tie up a thread from the [cooperative pool](https://developer.apple.com/videos/play/wwdc2021/10254/), which holds about one thread per core, and blocking enough of them stalls unrelated async work across the app. On a dedicated [serial dispatch queue](https://developer.apple.com/documentation/dispatch/dispatchserialqueue) the blocking sits where it belongs, and thumbnail requests and an export queue up behind one another in arrival order, which is what a single-conversation protocol wants anyway.

## What is still rough

**Most of the constraints come from the console.** Bottom port only, undocked, the Copy to PC screen has to stay up, and leaving it kills the session mid-transfer. A charge-only cable produces no enumeration at all on the Mac side, which looks exactly like "the app is broken" until you run `probe` and see zero devices in the IO registry.

**Enumeration does not scale.** Every connect walks every object at a few milliseconds each, and since storage IDs move between sessions there is nothing safe to remember. Fine for a few hundred captures, a visible wait for a few thousand, and the console offers no faster path.

**Recovery ends in a USB reset**, and any other PTP client on the Mac, a second copy of Tethersnap included, competes for the same exclusive interface claim. The loser gets a claim error, which is correct, but it is something the user has to understand rather than something the app can hide.

**No sandbox, so no App Store**, and [Guideline 5.2](https://developer.apple.com/app-store/review/guidelines/#intellectual-property) would rule it out anyway for a product whose entire description is another company's trademark. Tethersnap ships as a [notarized](https://developer.apple.com/documentation/security/notarizing-macos-software-before-distribution) DMG on GitHub, which suits a tool for people who own a Switch 2 and take screenshots on a Mac and would be a problem for anything broader.

**Only the Switch 2 is validated.** The original Switch (057e:201d) is recognized by USB ID and libmtp treats the two identically, but I have not run one through Tethersnap.

The gap is structural: MTP has existed for two decades and Apple has never shipped it; the still-image stack macOS does ship, Image Capture and [ImageCaptureCore](https://developer.apple.com/documentation/imagecapturecore), is built for cameras. Mac users with Android phones have depended on third-party bridges since 2011, most of those are now abandoned, Google discontinued its own, and OpenMTP's maintainer has not answered a four-month-old report. A device speaking the older and simpler of the two protocols should have been the easy case, and instead it is the one nothing on the platform handles. That is a hole in macOS rather than anything Nintendo did wrong.

If you have a PTP device of your own that macOS ignores, the quickest way to learn what it actually implements is that ten-line DeviceInfo dump, and these two commands produce it from two independent stacks:

```bash
brew install libmtp && mtp-detect            # libmtp's view, proven on Linux
swift run tethersnap probe --verbose         # Tethersnap's view, every container on the wire
```

*Tethersnap is an independent open-source project, not affiliated with or endorsed by Nintendo. Nintendo Switch and Nintendo Switch 2 are trademarks of Nintendo, used here to describe compatibility.*
