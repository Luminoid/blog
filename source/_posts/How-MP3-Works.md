---
title: "How MP3 works: compressing music by deleting what you can't hear"
date: 2026-07-22 12:00:00
categories:
- Audio
tags:
- MP3
- psychoacoustics
- masking
- MDCT
- Huffman-coding
- ID3
- LAME
- AAC
- Opus
- FaceTime
- Siri
---

MP3 gets 11:1 compression on CD audio, and almost none of it comes from clever bit-packing. It comes from a model of your ear: which frequencies you can hear at all, how loud each has to be before you notice, and when one sound hides another outright. This post walks through the pipeline (psychoacoustics, the hybrid filter bank, the quantizer where the loss happens, the Huffman coder that packs what survives), then the file format around it, ten songs that make encoders fail audibly, and how to run that test without fooling yourself. It ends by following the same idea, model the listener and discard what they won't notice, into four other places: a FaceTime call, a cat hearing its owner's voice through a phone, the trick Apple used to keep "Siri" from waking HomePods during the WWDC keynote, and the "enhance" button in podcast editors.

<!-- more -->

## Terms

A dozen words the rest of the post leans on.

| Term | Meaning |
|------|---------|
| **PCM** | Raw sample values, what a CD or WAV file holds |
| **kbps** | Kilobits per second of audio; CD is 1411, MP3 typically 128 to 320 |
| **dB SPL** | Sound pressure level in decibels, absolute loudness in air |
| **Frame, granule** | MP3 codes 1152 samples per frame (26 ms at 44.1 kHz) as two 576-sample granules |
| **MDCT** | Modified discrete cosine transform, the step that turns samples into spectral lines |
| **Critical band, Bark** | The ear's own frequency bins, about 24 of them; one Bark is one band, and the scale runs 0 to 24 |
| **Masking** | A loud sound hiding a quieter one nearby in frequency or time |
| **SMR** | Signal-to-mask ratio: how far a band's signal stands above what masking hides |
| **Scalefactor band** | A group of spectral lines that share one quantizer setting |
| **CBR, VBR** | Constant or variable bitrate |
| **ABX** | Blind listening test: identify an unknown X as A or B, over many trials |
| **LUFS** | Loudness units relative to full scale, the broadcast and podcast loudness measure |

## Two compressors in series

CD audio is 1411 kbps: 44,100 samples per second, 16 bits each, two channels. A 128 kbps MP3 keeps roughly a bit per eleven. No lossless codec gets anywhere near that on music; FLAC manages about 2:1. So MP3 is two compressors, chained:

1. **A lossy stage that models the ear.** A psychoacoustic model estimates, moment by moment and frequency by frequency, how much quantization noise it can inject before a human notices, then quantizes right up to that limit. This stage is where the 11:1 comes from, and it throws information away permanently.
2. **A lossless stage that models statistics.** The quantized values are mostly small integers and runs of zeros. Huffman coding exploits that skew for a further saving whose size depends on the material. This stage is exact: decode it and the quantized values come back bit-perfect.

Everything interesting lives in stage one, and stage one is only possible because human hearing is measurably, exploitably imperfect.

The format itself is a child of the late 1980s. Karlheinz Brandenburg built the perceptual core in his doctoral work at Erlangen (the OCF coder), refined it with James Johnston at AT&T Bell Labs into the ASPEC proposal, alongside Thomson and CNET, and carried it to Fraunhofer IIS. MPEG standardized the result as MPEG-1 Audio Layer III in [ISO/IEC 11172-3](https://www.iso.org/standard/22412.html), approved in November 1992 and published in 1993.

The name arrived by lower-tech means: an [internal Fraunhofer email poll](https://www.iis.fraunhofer.de/en/magazin/panorama/2025/30-years-of-mp3.html) picked the `.mp3` extension over `.bit` on July 14, 1995. The last core US patent, [US 6,009,399](https://patents.google.com/patent/US6009399A/en), expired on April 16, 2017, and Technicolor, which ran the joint licensing program with Fraunhofer, closed it a week later. Since then MP3 has been an essentially free format that virtually every device can decode.

## The ear, measured

The codec's noise budget starts from three empirical facts.

**The range is 20 Hz to 20 kHz, and most adults never hear the top of it.** Children hear to about 20 kHz; by your thirties or forties presbycusis has usually pulled the ceiling down to 15 or 16 kHz. So a 128 kbps encoder that low-passes everything above 16 to 17 kHz is discarding a band most of its audience cannot detect. Musical fundamentals sit far lower anyway, from 27.5 Hz (the lowest piano key; a kick drum's fundamental sits around 40 to 60 Hz) to about 4.2 kHz (the top of a piccolo); everything above is harmonics and noise-like content such as cymbals and sibilance.

**Sensitivity is wildly uneven across that range.** This is the equal-loudness contour result, first measured by Fletcher and Munson at Bell Labs in 1933 and standardized today as [ISO 226](https://www.iso.org/standard/83117.html) (last revised in 2023, by at most 0.6 dB from the 2003 curves). Play a 1 kHz tone at 40 dB SPL, ask a listener to match a 100 Hz tone to it, and they'll push the low tone about 24 dB louder: the 40-phon contour puts 100 Hz at 64 dB SPL. (The curves define the **phon**: 40 phons means "as loud as 1 kHz at 40 dB SPL".)

Two properties matter here. The ear is most sensitive between about 2 and 5 kHz, a peak created by the ear canal's resonance and the middle ear's transfer function, conveniently centered where speech consonants live. And the contours flatten as level rises (that 100 Hz penalty shrinks from 24 dB at 40 phons to 12 dB at 80 phons), which is why music sounds thin at low volume and why amplifiers grew "loudness" buttons.

**Below a floor, you hear nothing at all.** The quietest detectable level at each frequency is the absolute threshold of hearing: a U-shaped curve, steep at the extremes (a 30 Hz tone needs some 60 dB SPL to register at all), dipping to its minimum in that same 2 to 5 kHz region. The whole curve fits in one line; Terhardt's 1979 approximation (as given in [Painter and Spanias](https://www.cns.nyu.edu/~david/courses/perceptionGrad/Readings/PainterSpanias-ProcIEEE2000.pdf), the standard survey of perceptual coding) is the ancestor of most encoders' versions, LAME's included, and the figure below is plotted straight from it:

```python
# Terhardt's threshold-in-quiet approximation (f in kHz, result in dB SPL)
def ath_db(f):
    return 3.64 * f**-0.8 - 6.5 * math.exp(-0.6 * (f - 3.3)**2) + 1e-3 * f**4
```

{% asset_img ath-curve.png "Absolute threshold of hearing (Terhardt approximation): a U-shaped curve from 20 Hz to 20 kHz, minimum near 3 kHz, with the region below the curve marked inaudible" %}

The curve dips below zero because 0 dB SPL is not silence: it is a reference pressure of 20 µPa, set near the 1 kHz threshold in the 1930s, and the ear's most sensitive region hears about 5 dB below it (ISO 226 puts the 3150 Hz threshold at -6 dB SPL).

The codec treats everything under this curve as free space. Quantization noise that lands under the absolute threshold costs nothing, ever. Noise near 3 kHz is the most exposed; the same energy at 15 kHz may be inaudible for free. That asymmetry alone buys real compression. Masking buys far more.

## Masking: where the bits actually come from

The cochlea is not a microphone. The basilar membrane behaves like a bank of roughly 24 overlapping bandpass filters (the **critical bands**), each about 100 Hz wide below 500 Hz and widening to roughly 20 percent of center frequency above. Loudness, pitch, and masking all operate in this domain, and MP3's psychoacoustic model does its accounting in it.

The **Bark scale** simply numbers those bands: one Bark is one critical band, and 0 to 24 Bark covers 20 Hz to 15.5 kHz. It is close to linear in Hz below 500 Hz and logarithmic above, so 100 to 200 Hz is one Bark and so is 8 to 10 kHz; 1 kHz sits at 8.5 Bark, 4 kHz at 17.3. The point of the scale is that masking is uniform on it: a masker hides sounds within about the same number of Bark on either side wherever it sits in the spectrum. That is why the spreading function below takes its distance in Bark rather than Hz, and why the codec's scalefactor bands are laid out to track Bark bands rather than equal slices of Hz.

**Simultaneous masking**: a loud sound raises the threshold of hearing for everything nearby in frequency, within its critical band and spreading into neighbors. The spread is asymmetric: toward lower frequencies the masking skirt falls off steeply, tens of dB per Bark; toward higher frequencies only around 10 dB per Bark, flattening further as the masker gets louder. Loud sounds hide things above them much better than things below them.

The character of the masker matters as much as its level. Noise is a strong masker: a tone a few dB below band-limited noise vanishes. Tones are weak maskers: to hide noise in its band, a pure tone must stand roughly 20 to 30 dB above it. So the model also estimates *tonality* per band (the reference model checks how predictable each spectral line is from frame to frame), because a flute solo can conceal far less quantization noise than a distorted guitar at the same level. This is also the intuition for which music breaks the codec: dense loud mixes mask their own encoding noise, sparse tonal recordings expose it.

Both ingredients have standard closed forms, Zwicker's Hz-to-Bark mapping for the band scale and the Schroeder spreading function for the skirts:

```python
def bark(f_hz):    # Zwicker: Hz to critical-band rate
    return 13 * math.atan(0.00076 * f_hz) + 3.5 * math.atan((f_hz / 7500) ** 2)

def spread_db(dz):  # Schroeder skirt: dB relative to masker level, dz in Bark
    d = dz + 0.474
    return 15.81 + 7.5 * d - 17.5 * math.sqrt(1 + d * d)
```

Plot those two functions with a simplified flat 15 dB offset below the masker's level, and you can watch a 70 dB tone at 1 kHz swallow a 30 dB tone at 1.5 kHz that would be plainly audible on its own:

{% asset_img masking-demo.png "Simultaneous masking: a 70 dB tone at 1 kHz raises the threshold in a bump around it, hiding a 30 dB tone at 1.5 kHz that sits far above the threshold in quiet" %}

Everything inside that shaded bump is inaudible while the masker plays. The encoder's job is to steer its quantization noise into bumps like this, which the music itself keeps generating, everywhere, all the time.

**Temporal masking**: the hiding extends in time. After a loud event the threshold stays elevated for 100 to 200 ms (post-masking); before it there are only a few milliseconds of pre-masking (the usual explanation is that loud sounds are processed faster than quiet ones). That asymmetry, generous after, nearly nothing before, is the direct cause of MP3's most famous artifact, described below.

The model's output is one number per band: the **signal-to-mask ratio**, how far the signal stands above whatever the combined maskers and the absolute threshold will hide. High SMR needs fine quantization; low SMR tolerates coarse; bands entirely under the mask can be zeroed.

## The signal path

To spend that budget per-frequency, the encoder needs the signal in the frequency domain. MP3 gets there in two stages, and the two-stage design is a fossil worth understanding. In the diagram, the solid blue path is the audio and the dark box is the one step that loses information; the dotted grey path is the psychoacoustic model looking at the same samples and telling two later stages what they are allowed to do.

{% mermaid %}
flowchart TB
    PCM(["PCM in<br>1152 samples per frame, 26 ms"]):::outline
    PFB["Polyphase filter bank<br>32 equal subbands, 689 Hz each"]
    MDCT["MDCT + aliasing reduction<br>18 lines per subband"]
    Q["Quantization<br>two nested loops: the only lossy step"]:::accent
    H["Huffman coding + bit reservoir<br>lossless"]
    OUT(["MP3 bitstream"]):::outline
    PM["Psychoacoustic model<br>side-chain FFT: masking thresholds,<br>tonality, SMR per band"]:::muted
    PCM --> PFB
    PFB -->|"32 streams × 36 samples"| MDCT
    MDCT -->|"2 granules × 576 spectral lines"| Q
    Q -->|"576 small integers per granule, mostly zeros"| H
    H -->|"about 3000 bits per frame at 128 kbps"| OUT
    PCM -.-> PM
    PM -.->|"window type: long or short"| MDCT
    PM -.->|"allowed noise per band"| Q
    linkStyle 0,1,2,3,4 stroke:#2E6FD6,stroke-width:2.5px
    linkStyle 5,6,7 stroke:#777777,stroke-width:1.5px
{% endmermaid %}

Following one stereo frame through at 128 kbps makes the shapes concrete:

| Point in the pipeline | What exists at this point | Size |
|-----------------------|---------------------------|------|
| PCM in | 1152 samples × 2 channels × 16 bits | 36,864 bits |
| After the polyphase bank | 32 subbands × 36 samples × 2 channels, still real numbers | same information, rearranged |
| After the MDCT | 2 granules × 576 lines × 2 channels = 2304 real-valued lines | same information, now per frequency |
| After quantization | 2304 small integers, most of them zero | the loss happens here |
| After Huffman coding | scalefactors and codewords, the frame's main data | 3048 bits (381 bytes) |
| Header and side info | 4 + 32 bytes, no CRC | 288 bits |
| Frame out | 417 bytes (the next frame gets 418; they alternate to average 417.96) | 3336 bits, 11.05:1 |

Per granule and channel, that is 762 bits to describe 576 spectral lines, about 1.3 bits per line before the bit reservoir lends or borrows. Against the 9216 bits of PCM those 576 samples arrived as, the ratio is 12:1; header and side info eat the difference down to 11:1.

Stage one is a **polyphase filter bank**: 32 bandpass filters (one 512-tap prototype low-pass, modulated up to 32 center frequencies) that split the spectrum into 32 equal slices. Picture a 32-way splitter: 1152 samples go in, and out come 32 parallel streams of 36 samples, each carrying only the energy in its own 689 Hz slice. There's a pleasing symmetry here, the codec's front end crudely mirroring the cochlea's own filter bank, but the mirror is warped: the ear's bands are logarithmic, these are equal-width. Useless for psychoacoustics on its own.

Stage two fixes that: an **MDCT** takes each stream's 18 new samples per granule (windowed together with the previous 18, hence the 50 percent overlap) and turns them into 18 spectral lines. Each line is one number saying how much energy sits in a 38 Hz sliver of that subband, so a granule ends up as 32 × 18 = 576 lines covering the whole spectrum. The aliasing between adjacent polyphase subbands gets partially cancelled by a set of butterfly operations.

The arithmetic is short. At 44.1 kHz the usable spectrum runs to 22,050 Hz. Divided 32 ways, each subband is 689 Hz wide; divided 18 more ways, each line covers 38 Hz. Line those slices up against the ear's critical bands and the reason for stage two becomes obvious:

```python
fs = 44_100
subband_hz = fs / 2 / 32     # 689 Hz per polyphase subband
line_hz = subband_hz / 18    # 38 Hz per MDCT line, 32 * 18 = 576 lines

# Zwicker's critical-band edges in Hz
bark_edges = [0, 100, 200, 300, 400, 510, 630, 770, 920, 1080, 1270, 1480,
              1720, 2000, 2320, 2700, 3150, 3700, 4400, 5300, 6400, 7700,
              9500, 12000, 15500]

for k in (0, 1, 2, 3, 8, 20):
    lo, hi = k * subband_hz, (k + 1) * subband_hz
    inside = sum(lo < e < hi for e in bark_edges)
    print(f"subband {k:2d}: {lo:6.0f} to {hi:6.0f} Hz, {inside} critical-band edges inside")
```

```text
subband  0:      0 to    689 Hz, 6 critical-band edges inside
subband  1:    689 to   1378 Hz, 4 critical-band edges inside
subband  2:   1378 to   2067 Hz, 3 critical-band edges inside
subband  3:   2067 to   2756 Hz, 2 critical-band edges inside
subband  8:   5512 to   6202 Hz, 0 critical-band edges inside
subband 20:  13781 to  14470 Hz, 0 critical-band edges inside
```

The first subband alone cuts across seven critical bands, in the region where the ear separates 100 Hz from 200 Hz with ease. Above 5 kHz the relationship flips and one critical band swallows several subbands. The 38 Hz lines are what make the fix possible: the encoder regroups them into **scalefactor bands** that track the Bark scale, four lines wide at the bottom and 76 lines wide near the top, and does its noise accounting in those. The figure puts the three rulers side by side and opens up the first subband.

{% asset_img filter-bank.png "Three rulers over the 0 to 22 kHz spectrum on a linear axis: the ear's 24 Bark critical bands, narrow at the bottom and wide at the top; the 32 equal 689 Hz polyphase subbands; and the 21 scalefactor bands plus sfb21 built from MDCT lines, which track the Bark scale again. A second panel zooms into subband 0, 0 to 689 Hz, showing its 18 MDCT lines of 38 Hz, the six critical-band edges that fall inside it, and scalefactor bands 0 to 3 of four lines each" %}

Why two stages instead of one clean transform? Politics. In the MPEG-1 contest, the MUSICAM proposal (Philips, IRT, CCETT, Matsushita) became Layers I and II, built on the polyphase bank. The ASPEC design (AT&T Bell Labs, Fraunhofer, Thomson, CNET) became Layer III, but had to sit on top of the Layer I/II filter bank for structural compatibility. So MP3 carries a hybrid filter bank neither team would have designed from scratch: extra latency, residual aliasing the butterflies only partly remove, and complexity that bought nothing perceptual.

AAC, standardized about five years later by largely the same labs, wore its freedom from that mandate in its formal name, MPEG-2 NBC, for Non-Backward Compatible, and threw the polyphase bank away for a single 1024-line MDCT. When people say AAC is "MP3 done right," this is the first thing they mean.

**Windows, and the pre-echo problem.** Fine frequency resolution costs time resolution: those 576 lines describe a 26 ms stretch as one spectrum, and quantization noise added to that spectrum smears across the entire window on decode. Recall that pre-masking covers only a few milliseconds. Hit a castanet click late in a window and the noise can start a full window, up to ~26 ms, *before* the click, in silence, hidden by nothing. That's **pre-echo**: a soft "fft" shadow announcing every sharp transient.

MP3's defense is window switching: when the model detects an attack, the encoder swaps in three short windows (6 lines per subband instead of 18), trading frequency resolution for time resolution for that granule. It helps. It doesn't fully work. The switch must be decided a granule (13 ms) ahead, because the preceding granule has to carry the transitional window. The short windows still aren't that short: [Brandenburg](https://www.iis.fraunhofer.de/content/dam/iis/de/doc/ame/conference/AES-17-Conference_mp3-and-AAC-explained_AES17.pdf) puts Layer III's short-block impulse response at 18.6 ms against 5.3 ms for AAC. And pre-echo remains the signature MP3 artifact on percussive material.

## Quantization: the actual loss

Each granule's 576 lines get grouped into **scalefactor bands** (21 for long blocks, 12 for short ones, laid out to approximate critical bands), and the encoder runs two nested loops, described step by step in [Brandenburg and Popp's EBU introduction](https://tech.ebu.ch/docs/techreview/trev_283-popp.pdf):

- The **inner loop** picks a global quantizer step, quantizes every line (values are raised to the power 0.75 before rounding, so error scales with amplitude), Huffman-codes the result, and checks the frame's bit budget. Too big: coarsen the step, retry.
- The **outer loop** measures the resulting noise per scalefactor band against the model's threshold. Any band where noise pokes above the mask gets its scalefactor amplified (finer effective quantization there), and the inner loop reruns. It terminates when every band is under the mask, or, at low bitrates, when the encoder gives up and ships the least-bad compromise.

That last clause is where "128 kbps sounds fine" quietly becomes false: on demanding frames the loops exit with noise above the mask, and you hear it.

Two mechanisms stretch the budget. The **bit reservoir** lets an easy frame donate unused bits to a later hard frame, a rolling reserve that mostly gets spent on transients. And **joint stereo** exploits inter-channel redundancy: mid/side coding stores L+R and L-R (cheap when the channels are similar, lossless in principle), while intensity stereo, the aggressive variant, replaces both channels' high end with one signal plus pan positions. Early encoders were clumsy with both; collapsed width and wandering reverb gave "joint stereo" a bad reputation it has never quite lost, though it was an encoder-quality problem and modern encoders handle both well.

One genuine flaw in the format: the region above 16 kHz shares no dedicated scalefactor (the [sfb21 problem](https://wiki.hydrogenaudio.org/index.php?title=LAME_Y_switch)), so preserving content up there is disproportionately expensive. Encoders mostly give up on that band and low-pass instead, which is why 128 kbps MP3s reliably cut off around 16 to 17 kHz (LAME's default at that bitrate is 17 kHz).

## Huffman coding: the honest half

After quantization, a granule is 576 small integers with an extremely skewed distribution: high-frequency lines mostly zero, mid ones mostly -1, 0, or 1, big values only at the low end. Fixed-width storage would pay full price to say "zero" hundreds of times.

Huffman coding is the textbook answer: a prefix-free variable-length code, short codewords for frequent symbols, no codeword a prefix of another, so the decoder needs no separators. The construction is a 20-line function: put every symbol in a min-heap by count, repeatedly merge the two rarest nodes until one tree remains.

```python
import heapq
from collections import Counter

def huffman_code(counts):
    heap = [(n, i, sym) for i, (sym, n) in enumerate(counts.items())]
    heapq.heapify(heap)
    tie = len(heap)
    while len(heap) > 1:
        n1, _, a = heapq.heappop(heap)
        n2, _, b = heapq.heappop(heap)
        heapq.heappush(heap, (n1 + n2, tie, (a, b)))
        tie += 1
    code = {}
    def walk(node, prefix):
        if isinstance(node, tuple):
            walk(node[0], prefix + "0")
            walk(node[1], prefix + "1")
        else:
            code[node] = prefix or "0"
    walk(heap[0][2], "")
    return code

# quantized spectral lines of one granule (576 values), skewed hard toward zero
counts = Counter({0: 310, 1: 88, -1: 84, 2: 30, -2: 28,
                  3: 13, -3: 11, 4: 5, -4: 4, 5: 2, -5: 1})
code = huffman_code(counts)
```

Run it on that granule-shaped distribution (the real format codes values in pairs and quadruples, same idea) and the skew does all the work:

```text
value  0  x310  ->  1
value  1  x88   ->  011
value -1  x84   ->  010
value  2  x30   ->  0011
value -2  x28   ->  0010
value  3  x13   ->  0000
value -3  x11   ->  00010
value  4  x5    ->  000110
value -4  x4    ->  0001111
value  5  x2    ->  00011101
value -5  x1    ->  00011100

1247 bits total vs 2304 at fixed 4 bits: 2.16 bits per value
```

Zero, the overwhelmingly common value, costs a single bit. Claude Shannon proved the floor (you can't beat the entropy of the source, 2.12 bits per value for this distribution); Huffman's greedy merge lands within 0.05 bit of it. The 46 percent saving is measured against a fixed 4-bit baseline, which no real encoder would use, so the format's gain from this stage is smaller than that. And it's lossless: this stage adds zero artifacts, it only reclaims the redundancy the quantizer left behind.

MP3 tailors the idea in one important way: the tables are **fixed**, baked into the standard, not derived per-file. The encoder splits each granule's spectrum into three regions by value statistics: **big values** at the low end (coded in pairs, choosing among 32 table slots that map to 15 distinct codebooks, with an escape mechanism for magnitudes 15 and up), a **count1** region of quadruples where every value is -1, 0, or 1 (two dedicated tables), and an implicit run of zeros at the top that costs nothing at all, since the decoder infers its extent from the sizes of the other two regions.

Fixed tables mean nothing to ship in the file and a trivial decoder, at the price of statistics frozen to whatever late-1980s test material the tables were tuned against. (Arithmetic coding would have saved a few percent more, but in the late 1980s IBM's patents on it kept most codecs away; MPEG audio only adopted it with USAC in 2012.)

## A stream wearing no container

What leaves the encoder is just frames, back to back, each holding 1152 samples (26 ms at 44.1 kHz): a 32-bit header (a run of sync bits, then version, layer, bitrate index, sample rate, channel mode), an optional 16-bit CRC, side info, Huffman data.

Every frame re-declares everything, which is why MP3 streams so well: an internet radio client joins mid-stream, hunts for the next sync pattern, and starts decoding; a corrupted chunk costs a frame or two, not the file. (Strictly, the sync run is 12 set bits in MPEG-1 proper, but the unofficial MPEG-2.5 extension took one for its version field, so robust decoders match 11.) The one exception is the bit reservoir: a frame's audio payload may start up to 511 bytes back (a 9-bit pointer) inside earlier frames' spare room, so a blind byte-cut still plays, it just may garble its first moment.

Everything else you think of as "an MP3" is added by convention, not by the standard. The format carries no title, artist, or artwork. ID3v1 (1996) appends a fixed 128-byte block to the end of the file; ID3v2 (1998) prepends a variable-size container holding cover art and whatever else; decoders skip bytes that don't look like frames.

VBR works the same way: the bitrate index is per-frame, so varying it is trivial, but duration and seeking then need a table of contents, so encoders hide a Xing header (frame count plus a 100-entry seek table; Fraunhofer's variant is VBRI) in the first frame's unused space. Players that don't read it show wrong durations on VBR files and seek to wrong places.

That first frame also carries the fix for MP3's most user-visible flaw. Codec delay (the encoder's psychoacoustic look-ahead, 576 samples in LAME, plus 529 samples of decoder startup) and zero-padding to fill the final frame mean every decoded MP3 is longer than its source, silence welded to both ends, and the standard has no field to say by how much. The result is a click or gap between tracks of a continuous album.

LAME has written the exact delay and padding counts into its info tag since 2001, iTunes mirrors them in an `iTunSMPB` comment (since iTunes 7 in 2006), and players honoring either play gapless; players that don't interrupt *Dark Side of the Moon* between tracks. Gapless MP3 is a 2000s workaround that was never standardized. It won anyway.

## Breaking it on purpose

Every design compromise above has an audible signature at low-to-mid bitrates, and there is well-chosen material for triggering each one.

### The artifact catalog

- **Pre-echo**: a soft hiss-shadow up to ~20 ms before sharp attacks. Windows too long, pre-masking too short.
- **Birdies**: high spectral lines toggling on and off frame by frame as they cross the zeroing threshold, a watery chirping around steady tones.
- **Warble / underwater**: coarse quantization in the mids modulating frame to frame, the classic 96 kbps sound.
- **Applause smear**: thousands of uncorrelated transients defeat both the window switcher and the masker; claps smear into swirling noise.
- **Cymbal swish**: rides and hi-hats turn from metal into band-limited static.
- **Sibilance splatter**: "s" and "sh" sputter, same mechanism as cymbals, sitting just above where the ear is most sensitive.
- **Stereo collapse**: aggressive joint stereo narrowing the image or making reverb tails wander, mostly on older encoders.
- **The 16 kHz ceiling**: not an artifact so much as a policy (LAME low-passes at 15.1 kHz for 96 kbps, 17 kHz for 128, 18.6 kHz for 192, 20.5 kHz for 320); audible as dullness if your ears are young enough.

### Ten songs that make MP3 struggle

Codec listening tests live and die by material selection. Average music at 128 kbps has been close to transparent for most listeners for two decades; the differences show up only on killer samples. The formal test archetypes (the [EBU SQAM disc](https://tech.ebu.ch/docs/tech/tech3253.pdf)'s castanets, harpsichord, glockenspiel, celesta, solo speech) each have real-song equivalents:

| # | Track | Why it's hard | Listen for |
|---|-------|--------------|------------|
| 1 | Suzanne Vega, "Tom's Diner" (a cappella, *Solitude Standing*, 1987) | A bare voice with silence around it: nothing masks the coding noise | Grain and flutter riding the vocal, splattery sibilants |
| 2 | Paco de Lucía, "Entre dos aguas" | Flamenco: castanet-class attacks from guitar and bongos | Pre-echo shadowing each pluck and clap |
| 3 | Bach, *Goldberg Variations* on harpsichord (Scott Ross or Pierre Hantaï) | Harpsichord is the classic tonal killer: dense stable harmonics far past 10 kHz | Shimmer and warble on sustained chords |
| 4 | Tchaikovsky, "Dance of the Sugar Plum Fairy" | Exposed celesta: pure high tones surrounded by near-silence | Birdies, dulled attacks, hiss blooming around notes |
| 5 | Eagles, "Hotel California" (*Hell Freezes Over*, 1994) | The intro's audience: applause is the canonical codec killer | Claps dissolving into swirling noise |
| 6 | Dave Brubeck Quartet, "Take Five" | Continuous ride-cymbal wash under everything | Cymbal turning to static, stereo image narrowing |
| 7 | Massive Attack, "Angel" | Sub-bass line at the bottom of the audible range under a sparse, quiet mix | Wobble on the bass note, noise floor pumping in the gaps |
| 8 | Aphex Twin, "Windowlicker" | Synthetic clicks and noise textures with no natural masking pattern | Window switching overwhelmed: smeared clicks, gritty noise beds |
| 9 | Keith Jarrett, *The Köln Concert*, Part I | Solo piano: hard attacks into long decays, in a real room with an audience | Pre-echo on attacks, quantization noise breathing in the decays |
| 10 | Kraftwerk, "Computer Love" | Steady near-pure synth tones, the worst-case weak masker | Birdies at the top, hiss huddled around each tone |

Track 1 is also the historically correct choice: Brandenburg tested the encoder on the a cappella "Tom's Diner" over and over, precisely because an exposed voice conceals almost nothing, and Vega has been called ["the mother of the MP3"](https://en.wikipedia.org/wiki/Tom%27s_Diner) ever since. Early builds mangled her voice badly; the finished format handles it, which tells you the tuning worked. Tracks 1 to 3 are also the ones that come up in [Hydrogenaudio's own test-material discussions](https://hydrogenaudio.org/index.php/topic,64673.0.html); the rest are picks by mechanism.

The list is deliberately spread across mechanisms. Tracks 2, 8, and 9 attack time resolution (pre-echo, window switching). Tracks 3, 4, and 10 attack the weak-masker case. Tracks 5 and 6 attack noise-like breadth, track 7 the bottom of the equal-loudness curve, track 1 the midrange where the ear is most sensitive.

### Testing without fooling yourself

Sighted listening is worthless; expectation bias swamps codec differences at these levels. The standard protocol is ABX: known A (lossless), known B (encoded), unknown X, say which X is, over many trials. 12 or more correct out of 16 puts you under p = 0.05; [Hydrogenaudio's convention](https://wiki.hydrogenaudio.org/index.php?title=ABX) is stricter, 13 of 16 for p = 0.01.

```bash
# LAME, the reference-quality encoder since the early 2000s
lame -b 96  ref.wav test96.mp3    # artifacts on most of the table above
lame -b 128 ref.wav test128.mp3   # artifacts on the killer tracks
lame -V 2   ref.wav testV2.mp3    # ~190 kbps VBR, LAME's transparency setting
lame -b 320 ref.wav test320.mp3   # if you can ABX this, document it
```

Practical rules: loop 5 to 10 seconds of the hardest passage rather than whole songs, decode the MP3 back to WAV so the player treats both files identically, and level-match. foobar2000's [ABX comparator](https://www.foobar2000.org/components/view/foo_abx) is the usual harness, and since foobar2000 went cross-platform it runs natively on the Mac too; Lacinato ABX is the older Mac alternative. Expect humbling results: at `-V 2` on ordinary music, almost nobody passes. On track 5's applause at 128 kbps, most attentive listeners still can.

The encoder matters as much as the bitrate, which is itself an indictment of the standard: MPEG specified only the decoder and bitstream, leaving psychoacoustic quality to implementers, and for years commercial encoders (early Xing especially) were audibly bad at bitrates where [LAME](https://lame.sourceforge.io/), an open-source project started in 1998, approached transparency. Same format, same bits per second, different ears in the loop. LAME sat at 3.100 (October 2017) for almost nine years; the 3.101 and 4.0 releases of July 2026 are security and build fixes, with the psychoacoustics untouched.

## The same idea, pointed at other listeners

Everything above is one idea: model the listener, then throw away whatever the model says the listener won't use. Point that idea at a different listener and you get most of the audio technology you use daily. Four directions, from closest to MP3 to furthest.

### Real-time calls: the same model on a stopwatch

FaceTime applies MP3's perceptual approach in a codec built for conversation: **AAC-ELD** (Enhanced Low Delay), a direct descendant of the AAC that replaced MP3. It keeps the MDCT-into-a-masking-model core and strips out everything that costs time. MP3's framing, encoder look-ahead, and especially the bit reservoir stack up to over a hundred milliseconds of latency ([Fraunhofer's accounting](https://www.iis.fraunhofer.de/content/dam/iis/de/doc/ame/conference/AES-116-Convention_guideline-to-audio-codec-delay_AES116.pdf): 54 ms without the reservoir, 107 to 142 ms with it), fine for a file, unbearable in conversation. AAC-ELD all but drops the reservoir, a step AAC-LD had already taken, and halves the MDCT overlap to pull algorithmic delay down to 15 to 32 ms depending on mode.

{% asset_img codec-delay.png "Algorithmic delay compared: MP3 at 128 kbps is 54 ms, rising to 107 to 142 ms once the bit reservoir is counted; Opus is 26.5 ms at its default 20 ms frames and 5 ms at minimum; AAC-ELD is 15.7 ms, or 31.3 ms in its dual-rate SBR mode; a dashed line marks the ITU-T G.114 150 ms one-way budget for a whole call path" %}

A real-time codec also carries machinery a file never needs: it tracks the network and slides bitrate as bandwidth changes, conceals dropped packets by synthesizing a plausible patch, and buffers against jitter. An MP3 file never loses a packet.

The other major codec is **Opus**, [WebRTC's mandatory codec](https://www.rfc-editor.org/rfc/rfc7874.html), already inside every browser call plus Discord and WhatsApp: a linear-predictive speech coder (SILK, inherited from Skype) and a masking-based transform coder (CELT) in one bitstream, blending by content. In Hydrogenaudio's public listening tests it beat HE-AAC at 64 kbps ([2011](https://listening-tests.hydrogenaudio.org/igorc/results.html)) and, at 96 kbps, beat Apple's AAC and an MP3 given 30 percent more bitrate ([2014](https://listening-test.coresv.net/results.htm)). Later single-listener tests put xHE-AAC level with or ahead of Opus at those rates; against MP3 and plain AAC the verdict stands, which is why nobody designing a new real-time system reaches for MP3.

The frontier here is machine learning replacing individual DSP components: [Opus 1.5](https://opus-codec.org/demo/opus-1.5/) (2024) conceals lost packets with a small neural net instead of waveform extrapolation, and [Opus 1.6](https://opus-codec.org/demo/opus-1.6/) (December 2025) can regenerate the 8 to 20 kHz band at the decoder from wideband speech alone. Both ship as compile-time options, off by default. The decade's biggest low-bitrate deployment, meanwhile, is not neural at all: Meta's [MLow](https://engineering.fb.com/2024/06/13/web/mlow-metas-low-bitrate-audio-codec/) (2024), on every Instagram and Messenger call and rolling out on WhatsApp, holds intelligible speech near 6 kbps with a classical CELP design. Deployed reality is classical codecs growing optional neural parts, not neural codecs replacing classical ones.

### Cats: the right speech, the wrong ears

Play that call to your cat and you're running a lossy codec tuned for the wrong animal. A cat hears from roughly 48 Hz to 85 kHz ([Heffner and Heffner, 1985](https://pubmed.ncbi.nlm.nih.gov/4066516/), measured at 70 dB SPL), deep into ultrasound where rodents squeak; human hearing gives out around 20 kHz, and MP3 at 128 kbps discards everything past 16 to 17 kHz on top of that.

{% asset_img hearing-ranges.png "Frequency ranges of human (20 Hz to 20 kHz), cat (48 Hz to 85 kHz), and dog (67 Hz to 45 kHz) hearing on a log axis, with the human speech band and the MP3 16 kHz cutoff marked; all three ranges overlap across the speech band" %}

For a voice, it barely matters. Human speech lives almost entirely below 8 kHz: fundamentals between about 85 and 255 Hz, formants and sibilants stacked above. That band sits comfortably inside every ear in the chart, and every codec guards it, so the cat gets essentially the speech content it would hear in the room. What the codec deletes, the top octave and the ultrasonic range, is where a voice has little energy anyway, mostly the hiss of fricatives.

The subtler mismatch doesn't show on the chart. MP3 hides its quantization noise under the *human* masking curve from the figure earlier; a cat's critical bands aren't shaped like ours, so noise engineered to be inaudible to us could sit exposed for the cat, though at a decent bitrate it's low and buried in the shared speech band.

The real degradation is mono playback through a thumbnail speaker: cats localize sound to a few degrees and swivel each ear to do it, and a phone collapses everything to one point source, with none of the scent or body language that carries the rest of the message. They can still parse it; cats orient to a recording of their owner over a stranger's ([Saito and Shinozuka, 2013](https://link.springer.com/article/10.1007/s10071-013-0620-4)). It just arrives flattened.

### The machine listener: how Apple muted "Siri" at WWDC 2026

Now point the same idea at a machine. At WWDC 2026, every time a presenter said "Siri," Apple's video edit briefly notched out narrow bands around 3, 4, 5, and 6 kHz (spotted by Dutch audio engineer [Luuk de Leest](https://x.com/luuk58/status/2064085109980987720) and reported by [MacRumors](https://www.macrumors.com/2026/06/12/apple-cut-frequencies-to-prevent-siri-activations/); Apple has not confirmed the edit). Those mid frequencies carry the phonetic energy Siri's wake-word detector keys on. Remove them for the fraction of a second the word occupies and the on-device classifier no longer recognizes the pattern, while you, reconstructing the word from the untouched frequencies around it and from context, hear "Siri" perfectly.

{% asset_img siri-notch.png "A schematic magnitude response, flat near 0 dB across the spectrum with four narrow ~24 dB notches at 3, 4, 5, and 6 kHz, the band a wake-word detector relies on" %}

This is MP3 running backwards. MP3 removes the frequencies a human won't miss, to save bits. Apple removed the frequencies a machine needs, so a room full of HomePods wouldn't all wake at once, and a human misses nothing. Both work for the same reason: speech is redundant enough that you can carve a narrow band out of it without touching intelligibility. It also didn't fully work; many viewers reported HomePods and iPhones waking anyway, because the detector just matches whatever survives stream volume and room acoustics.

Amazon meets the identical problem (an Alexa ad waking every Echo in earshot) from the other side: it fingerprints the ad's audio in advance, and when a device hears "Alexa," it checks the surrounding audio against those fingerprints, on the device first and in the cloud as a backstop, and suppresses the wake. For media it hasn't seen, it watches for other households hearing the same wake word at the same instant and flags it as broadcast.

(Amazon's [2014 patent](https://patents.google.com/patent/US9548053B1/en) also sketches an inaudible stand-down signal embedded in the ad, and that version gets retold as fact, but fingerprinting is what [Amazon says actually runs](https://www.amazon.science/blog/why-alexa-wont-wake-up-when-she-hears-her-name-in-amazons-super-bowl-ad). Independent analysis of its 2017 spots found 3 to 6 kHz attenuation as well, though Amazon has only said it "alters" its ads, and a spectral check of the 2018 Super Bowl ad found no notch.) Apple hides the trigger from the machine. Amazon lets the machine hear it and teaches it to recognize the source.

### The inverse: podcast voice enhancement

Every technique so far throws information away. Podcast enhancement is the one that adds it back, and increasingly invents it.

The classic version is subtractive DSP, the iZotope RX or Audacity chain: profile the noise from a silent gap and subtract it per frequency bin, high-pass the rumble, pull down reverb, add a few dB of presence, tame the sibilants, then compress and normalize to Apple's podcast loudness target of -16 LUFS (Spotify normalizes to -14). Each stage's effect is visible on a spectrum:

{% asset_img enhance-chain.png "Long-term speech spectrum before and after enhancement: a high-pass removes low-frequency rumble, spectral subtraction drops the noise floor about 20 dB, presence EQ and de-essing reshape the mids, and a dashed band above 8 kHz marks bandwidth extension synthesizing a top octave the microphone never captured" %}

All of that cleans what was captured without manufacturing anything new. The neural version does manufacture. Adobe Podcast's [Enhance Speech](https://research.adobe.com/news/behind-the-tech-enhance-speech-in-adobe-podcast), Descript's Studio Sound, Krisp, and Apple's [Voice Isolation](https://support.apple.com/en-us/101993) (FaceTime first, cellular calls since iOS 16.4, Voice Memos in iOS 26) are networks trained on paired clean and degraded speech that separate the voice from the room and re-synthesize it. Adobe's is effectively generative, which is why a terrible room can come out sounding like a booth, and why it smears when music or a second laugh overlaps the speech it was trained to isolate.

The dashed segment in the figure is the sharpest case, and it ties straight back to the top of this post. Neural **bandwidth extension** hallucinates the high-frequency sibilance that a cheap mic or a low-bitrate codec discarded, guessing plausible detail from learned speech statistics. Compress a voice down past 8 kHz, "enhance" it back up, and the restored octave is not recovered, it's fabricated. The technique has even moved inside the codec: Opus 1.6's bandwidth extension, mentioned above, is exactly this, a neural net guessing the top octave at the decoder rather than spending bits on it. Compression models the ear. Enhancement models the voice.

## Verdict

By any technical measure MP3 lost a long time ago, and the section above is the eulogy: AAC does the same job with a cleaner filter bank and better transients (its newest descendant, xHE-AAC, is what Audible streams and what Netflix ships on Android), and Opus does the real-time job MP3 never could. One mainstream niche still defaults to MP3: podcast feeds, because every client ever written decodes it, even though [Apple's own podcast spec](https://podcasters.apple.com/support/893-audio-requirements) now recommends AAC. That is its own kind of verdict.

The interesting part was never the bitstream. MP3 proved at consumer scale that a codec should model the listener, not the signal, and that equal-loudness and masking data measured in psychoacoustics labs from the 1930s onward could be turned into an 11:1 discount on the entire recorded catalog. Every lossy codec since (AAC, Vorbis, Opus's CELT half, even video codecs' perceptual tricks) descends from that idea.

If you're encoding today: use Opus or AAC, and if it must be MP3 for compatibility, LAME at `-V 2` or better. The playback-side story on Apple platforms, from `AVPlayer` down to Core Audio, is covered in {% post_link Apple-Audio-Frameworks-Complete-Guide "the Apple audio frameworks guide" %}.

This post was prompted by listening to [S2E1 "MP3"](https://buzaichang.xyz/episodes/dotmp3) of 不在场 (Buzaichang), 重轻's Chinese-language podcast, from June 2021. The episode treats the format as a cultural object and a window onto how the digital world came to look the way it does; this post fills in the engineering behind it.
