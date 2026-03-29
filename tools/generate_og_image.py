#!/usr/bin/env python3
"""Generate OG image for the blog.

Usage:
    python3 scripts/generate_og_image.py
    python3 scripts/generate_og_image.py --subtitle "Custom subtitle"
    python3 scripts/generate_og_image.py --output source/images/custom-og.png
"""

import argparse
import os
import random
from PIL import Image, ImageDraw, ImageFont, ImageFilter

SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
BLOG_DIR = os.path.dirname(SCRIPT_DIR)

W, H = 1200, 630
BG = (13, 13, 16)
ACCENT = (59, 130, 246)

FIRA_BOLD = os.path.expanduser("~/Library/Fonts/FiraCodeNerdFont-Bold.ttf")
FIRA_MEDIUM = os.path.expanduser("~/Library/Fonts/FiraCodeNerdFontMono-Medium.ttf")
FIRA_RETINA = os.path.expanduser("~/Library/Fonts/FiraCodeNerdFont-Retina.ttf")
AVATAR_PATH = os.path.join(BLOG_DIR, "source/images/Avatar.jpeg")


def generate(
    title: str = "Luminoid",
    subtitle: str = "Dispatches from the terminal",
    url: str = "blog.luminoid.dev",
    output: str = "source/images/og-image.png",
    show_cursor: bool = True,
):
    img = Image.new("RGB", (W, H), BG)
    draw = ImageDraw.Draw(img)

    ft = ImageFont.truetype(FIRA_BOLD, 72)
    fs = ImageFont.truetype(FIRA_MEDIUM, 28)
    fu = ImageFont.truetype(FIRA_RETINA, 26)

    # Radial glow
    glow = Image.new("RGB", (W, H), BG)
    gd = ImageDraw.Draw(glow)
    cx, cy = W // 2, H // 2 + 30
    for r in range(500, 0, -1):
        frac = 1 - r / 500
        color = tuple(
            min(255, int(BG[c] + (ACCENT[c] - BG[c]) * 0.12 * frac)) for c in range(3)
        )
        gd.ellipse((cx - r, cy - r, cx + r, cy + r), fill=color)
    glow = glow.filter(ImageFilter.GaussianBlur(radius=100))
    img = Image.blend(img, glow, 0.7)
    draw = ImageDraw.Draw(img)

    # Top accent line
    for x in range(W):
        brightness = (1 - abs(x / W - 0.5) * 2) ** 1.5
        c = tuple(int(ACCENT[i] * brightness * 0.9) for i in range(3))
        for y in range(3):
            draw.point((x, y), fill=c)

    # Avatar
    avatar = Image.open(AVATAR_PATH).convert("RGBA")
    av_size = 180
    avatar = avatar.resize((av_size, av_size), Image.LANCZOS)
    mask = Image.new("L", (av_size, av_size), 0)
    ImageDraw.Draw(mask).ellipse((0, 0, av_size - 1, av_size - 1), fill=255)
    avatar_circle = Image.new("RGBA", (av_size, av_size), (0, 0, 0, 0))
    avatar_circle.paste(avatar, (0, 0), mask)

    # Glow ring
    pad = 16
    ring_sz = av_size + pad * 2
    ring = Image.new("RGBA", (ring_sz, ring_sz), (0, 0, 0, 0))
    rd = ImageDraw.Draw(ring)
    for i in range(12, 0, -1):
        a = int(20 * (i / 12))
        rd.ellipse(
            (pad - i, pad - i, ring_sz - pad + i - 1, ring_sz - pad + i - 1),
            outline=(*ACCENT, a),
            width=1,
        )
    rd.ellipse(
        (pad - 2, pad - 2, ring_sz - pad + 1, ring_sz - pad + 1),
        outline=(*ACCENT, 100),
        width=2,
    )

    av_x = (W - av_size) // 2
    av_y = 72
    img.paste(ring, (av_x - pad, av_y - pad), ring)
    img.paste(avatar_circle, (av_x, av_y), avatar_circle)

    # Title
    bbox = draw.textbbox((0, 0), title, font=ft)
    tw = bbox[2] - bbox[0]
    title_y = av_y + av_size + 30
    draw.text(((W - tw) // 2, title_y), title, fill=(245, 245, 250), font=ft)

    # Subtitle + cursor
    bbox_sub = draw.textbbox((0, 0), subtitle, font=fs)
    sub_w = bbox_sub[2] - bbox_sub[0]
    cursor_w = 14 if show_cursor else 0
    cursor_gap = 6 if show_cursor else 0
    total_w = sub_w + cursor_gap + cursor_w
    sub_y = title_y + 88
    sub_x = (W - total_w) // 2
    draw.text((sub_x, sub_y), subtitle, fill=(140, 140, 160), font=fs)
    if show_cursor:
        cursor_x = sub_x + sub_w + cursor_gap
        cursor_top = sub_y + bbox_sub[1]
        cursor_bottom = sub_y + bbox_sub[3]
        draw.rectangle(
            (cursor_x, cursor_top, cursor_x + cursor_w, cursor_bottom), fill=ACCENT
        )

    # URL
    bbox3 = draw.textbbox((0, 0), url, font=fu)
    uw = bbox3[2] - bbox3[0]
    url_y = sub_y + 54
    draw.text(((W - uw) // 2, url_y), url, fill=ACCENT, font=fu)

    # Noise
    random.seed(42)
    pixels = img.load()
    for _ in range(20000):
        nx, ny = random.randint(0, W - 1), random.randint(0, H - 1)
        r, g, b = pixels[nx, ny]
        n = random.randint(-5, 5)
        pixels[nx, ny] = (
            max(0, min(255, r + n)),
            max(0, min(255, g + n)),
            max(0, min(255, b + n)),
        )

    out = os.path.join(BLOG_DIR, output)
    img.save(out, "PNG", optimize=True)
    print(f"Saved {out} ({os.path.getsize(out)} bytes)")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Generate blog OG image")
    parser.add_argument("--title", default="Luminoid")
    parser.add_argument("--subtitle", default="Dispatches from the terminal")
    parser.add_argument("--url", default="blog.luminoid.dev")
    parser.add_argument("--output", default="source/images/og-image.png")
    parser.add_argument("--no-cursor", action="store_true")
    args = parser.parse_args()

    generate(
        title=args.title,
        subtitle=args.subtitle,
        url=args.url,
        output=args.output,
        show_cursor=not args.no_cursor,
    )
