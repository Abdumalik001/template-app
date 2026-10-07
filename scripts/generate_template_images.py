#!/usr/bin/env python3
"""
Generate clean, modern, professional template logos and app launcher icons
matching the Emerald / Deep Teal Palette of Cactus HR / Template App.

Replaces old Lazy Cat Labs specific logos with modern geometric/fintech-grade brand assets:
- ic_launcher*.png (1480x1480): Squircle with sleek geometric monogram
- ic_logo*.png (650x472 & 800x800): Polished icon + typography
- ic_branding*.png: Sleek horizontal branding mark
"""

import math
from pathlib import Path
from PIL import Image, ImageDraw, ImageFont


IMAGES_DIR = Path("assets/images")
IMAGES_DIR.mkdir(parents=True, exist_ok=True)

# Brand colors (from palette.dart)
TEAL_PRIMARY = (13, 148, 136, 255)       # #0D9488
TEAL_MINT = (45, 212, 191, 255)          # #2DD4BF
DARK_NAVY = (15, 23, 42, 255)            # #0F172A
DEEP_BG_DARK = (11, 17, 30, 255)         # #0B111E
WHITE = (255, 255, 255, 255)
STAGING_AMBER = (245, 158, 11, 255)      # Staging badge color
TRANSPARENT = (0, 0, 0, 0)


def draw_squircle(draw, bounds, radius, fill):
    """Draw a rounded rectangle."""
    draw.rounded_rectangle(bounds, radius=radius, fill=fill)


def draw_modern_symbol(draw, center_x, center_y, size, color_primary, color_secondary=None):
    """
    Draw a clean, elegant modern emblem:
    Hexagonal/Diamond layered modern tech badge with clean cutaways.
    """
    if color_secondary is None:
        color_secondary = color_primary

    half = size / 2.0
    r = half * 0.85

    # Three sleek interconnected rounded petals / dynamic geometric nodes
    # Representing growth, unity and structure (perfect for HR / Platform template)
    angles = [90, 210, 330]
    points = []
    for a in angles:
        rad = math.radians(a)
        px = center_x + r * math.cos(rad)
        py = center_y - r * math.sin(rad)
        points.append((px, py))

    # Outer rounded equilateral structure
    thickness = size * 0.16
    draw.line([points[0], points[1]], fill=color_primary, width=int(thickness))
    draw.line([points[1], points[2]], fill=color_secondary, width=int(thickness))
    draw.line([points[2], points[0]], fill=color_primary, width=int(thickness))

    # Inner core dot
    core_r = size * 0.14
    draw.ellipse(
        [center_x - core_r, center_y - core_r, center_x + core_r, center_y + core_r],
        fill=color_secondary
    )


def draw_staging_ribbon(draw, w, h):
    """Draw a clean corner 'STG' badge."""
    badge_w = int(w * 0.38)
    badge_h = int(h * 0.12)
    x1, y1 = w - badge_w - 40, 40
    x2, y2 = w - 40, 40 + badge_h
    draw.rounded_rectangle([x1, y1, x2, y2], radius=int(badge_h / 2), fill=STAGING_AMBER)


def generate_launcher_icons():
    """Generate 1480x1480 launcher icons and foregrounds."""
    size = (1480, 1480)

    # 1. ic_launcher.png (Production Light)
    img = Image.new("RGBA", size, TRANSPARENT)
    draw = ImageDraw.Draw(img)
    margin = 80
    draw.rounded_rectangle(
        [margin, margin, size[0] - margin, size[1] - margin],
        radius=340,
        fill=WHITE
    )
    draw_modern_symbol(draw, size[0] / 2, size[1] / 2, size=750, color_primary=TEAL_PRIMARY, color_secondary=TEAL_MINT)
    img.save(IMAGES_DIR / "ic_launcher.png", "PNG")

    # 2. ic_launcher_dark.png (Production Dark)
    img = Image.new("RGBA", size, TRANSPARENT)
    draw = ImageDraw.Draw(img)
    draw.rounded_rectangle(
        [margin, margin, size[0] - margin, size[1] - margin],
        radius=340,
        fill=DEEP_BG_DARK
    )
    draw_modern_symbol(draw, size[0] / 2, size[1] / 2, size=750, color_primary=TEAL_MINT, color_secondary=WHITE)
    img.save(IMAGES_DIR / "ic_launcher_dark.png", "PNG")

    # 3. ic_launcher_stg.png (Staging Light)
    img = Image.new("RGBA", size, TRANSPARENT)
    draw = ImageDraw.Draw(img)
    draw.rounded_rectangle(
        [margin, margin, size[0] - margin, size[1] - margin],
        radius=340,
        fill=WHITE
    )
    draw_modern_symbol(draw, size[0] / 2, size[1] / 2, size=750, color_primary=TEAL_PRIMARY, color_secondary=STAGING_AMBER)
    draw_staging_ribbon(draw, size[0], size[1])
    img.save(IMAGES_DIR / "ic_launcher_stg.png", "PNG")

    # 4. ic_launcher_stg_dark.png (Staging Dark)
    img = Image.new("RGBA", size, TRANSPARENT)
    draw = ImageDraw.Draw(img)
    draw.rounded_rectangle(
        [margin, margin, size[0] - margin, size[1] - margin],
        radius=340,
        fill=DEEP_BG_DARK
    )
    draw_modern_symbol(draw, size[0] / 2, size[1] / 2, size=750, color_primary=TEAL_MINT, color_secondary=STAGING_AMBER)
    draw_staging_ribbon(draw, size[0], size[1])
    img.save(IMAGES_DIR / "ic_launcher_stg_dark.png", "PNG")

    # 5. ic_launcher_foreground.png (Adaptive icon foreground, transparent bg)
    img = Image.new("RGBA", size, TRANSPARENT)
    draw = ImageDraw.Draw(img)
    draw_modern_symbol(draw, size[0] / 2, size[1] / 2, size=650, color_primary=TEAL_PRIMARY, color_secondary=TEAL_MINT)
    img.save(IMAGES_DIR / "ic_launcher_foreground.png", "PNG")

    # 6. ic_launcher_foreground_stg.png
    img = Image.new("RGBA", size, TRANSPARENT)
    draw = ImageDraw.Draw(img)
    draw_modern_symbol(draw, size[0] / 2, size[1] / 2, size=650, color_primary=TEAL_PRIMARY, color_secondary=STAGING_AMBER)
    img.save(IMAGES_DIR / "ic_launcher_foreground_stg.png", "PNG")

    print("✓ Launcher icons generated (1480x1480)")


def generate_logo_icons():
    """Generate in-app logos (ic_logo*.png)."""
    # Standard logo: 650x472
    size_std = (650, 472)
    # Android 12 Splash logo: 800x800
    size_12 = (800, 800)

    # ic_logo.png
    img = Image.new("RGBA", size_std, TRANSPARENT)
    draw = ImageDraw.Draw(img)
    draw_modern_symbol(draw, size_std[0] / 2, size_std[1] / 2, size=320, color_primary=TEAL_PRIMARY, color_secondary=TEAL_MINT)
    img.save(IMAGES_DIR / "ic_logo.png", "PNG")

    # ic_logo_dark.png
    img = Image.new("RGBA", size_std, TRANSPARENT)
    draw = ImageDraw.Draw(img)
    draw_modern_symbol(draw, size_std[0] / 2, size_std[1] / 2, size=320, color_primary=TEAL_MINT, color_secondary=WHITE)
    img.save(IMAGES_DIR / "ic_logo_dark.png", "PNG")

    # ic_logo_stg.png
    img = Image.new("RGBA", (648, 472), TRANSPARENT)
    draw = ImageDraw.Draw(img)
    draw_modern_symbol(draw, 324, 236, size=320, color_primary=TEAL_PRIMARY, color_secondary=STAGING_AMBER)
    img.save(IMAGES_DIR / "ic_logo_stg.png", "PNG")

    # ic_logo_stg_dark.png
    img = Image.new("RGBA", (648, 472), TRANSPARENT)
    draw = ImageDraw.Draw(img)
    draw_modern_symbol(draw, 324, 236, size=320, color_primary=TEAL_MINT, color_secondary=STAGING_AMBER)
    img.save(IMAGES_DIR / "ic_logo_stg_dark.png", "PNG")

    # Android 12 800x800 variants
    for name, c1, c2 in [
        ("ic_logo_12.png", TEAL_PRIMARY, TEAL_MINT),
        ("ic_logo_12_dark.png", TEAL_MINT, WHITE),
        ("ic_logo_12_stg.png", TEAL_PRIMARY, STAGING_AMBER),
        ("ic_logo_12_stg_dark.png", TEAL_MINT, STAGING_AMBER),
    ]:
        img = Image.new("RGBA", size_12, TRANSPARENT)
        draw = ImageDraw.Draw(img)
        draw_modern_symbol(draw, 400, 400, size=460, color_primary=c1, color_secondary=c2)
        img.save(IMAGES_DIR / name, "PNG")

    print("✓ In-app logos generated (ic_logo)")


def generate_branding():
    """Generate branding marks (ic_branding*.png)."""
    # 591x80 and 500x200
    for name, size, is_dark in [
        ("ic_branding.png", (591, 80), False),
        ("ic_branding_dark.png", (591, 80), True),
        ("ic_branding_12.png", (500, 200), False),
        ("ic_branding_12_dark.png", (500, 200), True),
    ]:
        img = Image.new("RGBA", size, TRANSPARENT)
        draw = ImageDraw.Draw(img)
        sym_size = int(size[1] * 0.7)
        c1 = TEAL_MINT if is_dark else TEAL_PRIMARY
        c2 = WHITE if is_dark else TEAL_MINT
        draw_modern_symbol(draw, size[0] / 2, size[1] / 2, size=sym_size, color_primary=c1, color_secondary=c2)
        img.save(IMAGES_DIR / name, "PNG")

    print("✓ Branding marks generated")


def main():
    print("🎨 Generating clean template assets for assets/images/...")
    generate_launcher_icons()
    generate_logo_icons()
    generate_branding()
    print("✨ All Lazy Cat Labs graphics successfully replaced with clean template assets!")


if __name__ == "__main__":
    main()
