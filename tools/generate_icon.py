#!/usr/bin/env python3
"""
AGION App Icon Generator
Requires: pip install Pillow
Run from project root: python tools/generate_icon.py

Generates:
  assets/images/agion_icon.png          (1024x1024 master)
  android/.../mipmap-*/ic_launcher.png  (5 sizes: 48/72/96/144/192)
  android/.../mipmap-*/ic_launcher_round.png (same sizes, circular mask)
"""

import os
import math
from PIL import Image, ImageDraw, ImageFilter

# ── Color Constants ───────────────────────────────────────────────────────────
SIZE = 1024

BG_DARK     = (3,   8,   16,  255)   # #030810 voidBg
BG_CENTER   = (9,   21,  37,  255)   # slightly lighter for radial bloom
CYAN_MAIN   = (126, 200, 227, 255)   # #7EC8E3 glowCore
CYAN_DIM    = (74,  155, 181, 255)   # #4A9BB5 glowBloom (brackets)
HEX_RING    = (42,  90,  114, 30)    # #2A5A72 faint hexagon

# ── Output Paths ──────────────────────────────────────────────────────────────
ASSETS_DIR  = os.path.join("assets", "images")
MIPMAP_BASE = os.path.join("android", "app", "src", "main", "res")

SQUARE_SIZES = {
    "mipmap-mdpi":    48,
    "mipmap-hdpi":    72,
    "mipmap-xhdpi":   96,
    "mipmap-xxhdpi":  144,
    "mipmap-xxxhdpi": 192,
}

# ── Layer 1: Background with radial bloom ─────────────────────────────────────
def draw_background(img: Image.Image) -> None:
    draw = ImageDraw.Draw(img)
    # Start fully opaque dark navy — ALPHA MUST BE 255 so glow compositing works correctly
    draw.rectangle([0, 0, SIZE, SIZE], fill=(3, 8, 16, 255))

    # Radial bloom: very subtly brighten toward center using SOLID opaque colors
    # (never semi-transparent — semi-transparent background renders white in viewers)
    cx, cy = SIZE // 2, int(SIZE * 0.44)
    max_r = int(SIZE * 0.52)
    for r in range(max_r, 0, -8):
        t = 1.0 - (r / max_r)          # 0 at edge → 1 at center
        tt = t * t                      # quadratic for gentler falloff
        # Max brightening at center: R+7, G+16, B+33 (stays dark navy)
        rr = int(3  + 7  * tt)
        gg = int(8  + 16 * tt)
        bb = int(16 + 33 * tt)
        draw.ellipse([cx - r, cy - r, cx + r, cy + r], fill=(rr, gg, bb, 255))

# ── Layer 2: Faint hexagonal ring ────────────────────────────────────────────
def draw_hex_ring(draw: ImageDraw.Draw, cx: int, cy: int, radius: int) -> None:
    for r_off, alpha in [(0, 30), (4, 15), (-4, 15)]:
        r = radius + r_off
        pts = []
        for i in range(6):
            angle = math.radians(90 + i * 60)   # flat-top
            pts.append((cx + r * math.cos(angle), cy + r * math.sin(angle)))
        draw.polygon(pts, outline=(42, 90, 114, alpha))

# ── Layer 3: Corner brackets (matching SLPanel aesthetic) ─────────────────────
def draw_corner_brackets(draw: ImageDraw.Draw) -> None:
    margin = 72     # px from edge to bracket start
    arm    = 128    # bracket arm length (px at 1024)
    lw     = 14     # line width
    c      = (74, 155, 181, 210)   # CYAN_DIM, slightly transparent

    # Helper: draw one L-bracket given corner origin and directions
    def bracket(ox, oy, dx, dy):
        # Vertical arm
        draw.line([(ox, oy), (ox, oy + dy * arm)], fill=c, width=lw)
        # Horizontal arm
        draw.line([(ox, oy), (ox + dx * arm, oy)], fill=c, width=lw)

    bracket(margin,        margin,        +1, +1)   # top-left
    bracket(SIZE - margin, margin,        -1, +1)   # top-right
    bracket(margin,        SIZE - margin, +1, -1)   # bottom-left
    bracket(SIZE - margin, SIZE - margin, -1, -1)   # bottom-right

# ── Layer 4: The geometric "A" glyph ─────────────────────────────────────────
def make_a_polygons(cx: int, top: int, bot: int):
    """
    Returns (left_leg, right_leg, crossbar) as polygon point lists.
    The A is drawn as filled polygons — no font rendering.
    """
    half_apex  = 24    # half-width of the apex tip
    half_base  = 218   # half-width at the base
    thickness  = 76    # leg wall thickness (outer – inner)

    # Crossbar vertical center = 54% down the glyph height
    bar_center = top + int((bot - top) * 0.54)
    bar_h      = 60    # crossbar height in pixels
    bar_top    = bar_center - bar_h // 2
    bar_bot    = bar_center + bar_h // 2
    # Inset from each inner edge so bar doesn't touch legs
    bar_inset  = 18

    # Interpolation: outer edge x-coord at given y
    def outer_left(y):
        t = (y - top) / (bot - top)
        return cx - (half_apex + (half_base - half_apex) * t)

    def inner_left(y):
        return outer_left(y) + thickness

    def outer_right(y):
        t = (y - top) / (bot - top)
        return cx + (half_apex + (half_base - half_apex) * t)

    def inner_right(y):
        return outer_right(y) - thickness

    # Inner apex: where the two inner slopes meet at the top
    inner_apex_x = cx
    inner_apex_y = top + int(thickness * 1.05)   # slightly below outer apex

    # LEFT LEG: outer left edge going down, across base, inner left edge going up
    left_leg = [
        (cx - half_apex, top),          # outer apex left
        (outer_left(bot), bot),         # outer base left
        (inner_left(bot), bot),         # inner base left
        (inner_left(bar_bot) + bar_inset, bar_bot),  # inner left at crossbar bottom
        (inner_apex_x - 2, inner_apex_y),            # inner apex
    ]

    # RIGHT LEG: mirror
    right_leg = [
        (cx + half_apex, top),          # outer apex right
        (outer_right(bot), bot),        # outer base right
        (inner_right(bot), bot),        # inner base right
        (inner_right(bar_bot) - bar_inset, bar_bot), # inner right at crossbar bottom
        (inner_apex_x + 2, inner_apex_y),            # inner apex
    ]

    # CROSSBAR: rectangle connecting the two inner legs
    crossbar = [
        (inner_left(bar_top)  + bar_inset, bar_top),
        (inner_right(bar_top) - bar_inset, bar_top),
        (inner_right(bar_bot) - bar_inset, bar_bot),
        (inner_left(bar_bot)  + bar_inset, bar_bot),
    ]

    return left_leg, right_leg, crossbar


def draw_glyph_with_glow(base: Image.Image, polys: tuple) -> None:
    """Draw the A glyph with 3 glow layers + 1 sharp core layer."""
    all_polys = list(polys)

    # Layer A — outermost soft bloom (tight so it doesn't bleach background)
    g = Image.new('RGBA', (SIZE, SIZE), (0, 0, 0, 0))
    d = ImageDraw.Draw(g)
    for p in all_polys:
        d.polygon(p, fill=(126, 200, 227, 28))
    g = g.filter(ImageFilter.GaussianBlur(radius=22))
    base.alpha_composite(g)

    # Layer B — mid glow
    g = Image.new('RGBA', (SIZE, SIZE), (0, 0, 0, 0))
    d = ImageDraw.Draw(g)
    for p in all_polys:
        d.polygon(p, fill=(126, 200, 227, 70))
    g = g.filter(ImageFilter.GaussianBlur(radius=10))
    base.alpha_composite(g)

    # Layer C — inner edge glow
    g = Image.new('RGBA', (SIZE, SIZE), (0, 0, 0, 0))
    d = ImageDraw.Draw(g)
    for p in all_polys:
        d.polygon(p, fill=(126, 200, 227, 130))
    g = g.filter(ImageFilter.GaussianBlur(radius=4))
    base.alpha_composite(g)

    # Layer D — sharp core, fully opaque
    g = Image.new('RGBA', (SIZE, SIZE), (0, 0, 0, 0))
    d = ImageDraw.Draw(g)
    for p in all_polys:
        d.polygon(p, fill=(126, 200, 227, 255))
    base.alpha_composite(g)

    # Layer E — bright specular highlight on the crossbar top edge
    g = Image.new('RGBA', (SIZE, SIZE), (0, 0, 0, 0))
    d = ImageDraw.Draw(g)
    cx, top, bot = SIZE // 2, 272, 752
    bar_center = top + int((bot - top) * 0.54)
    bar_h      = 60
    bar_top_y  = bar_center - bar_h // 2
    thickness  = 76
    half_apex  = 24
    half_base  = 218
    def inner_left_y(y):
        t = (y - top) / (bot - top)
        return cx - (half_apex + (half_base - half_apex) * t) + thickness
    def inner_right_y(y):
        t = (y - top) / (bot - top)
        return cx + (half_apex + (half_base - half_apex) * t) - thickness
    bar_inset = 18
    xl = inner_left_y(bar_top_y) + bar_inset
    xr = inner_right_y(bar_top_y) - bar_inset
    d.line([(xl, bar_top_y), (xr, bar_top_y)],
           fill=(220, 240, 250, 180), width=4)
    g = g.filter(ImageFilter.GaussianBlur(radius=3))
    base.alpha_composite(g)

# ── Layer 5: Scattered energy particles ───────────────────────────────────────
# Fixed positions (not random) for reproducibility
PARTICLE_POSITIONS = [
    (168, 188), (856, 172), (142, 676), (884, 714),
    (312, 128), (734, 136), (196, 488), (822, 472),
    (396, 804), (628, 818), (460, 68),  (570, 72),
]

def draw_particles(draw: ImageDraw.Draw) -> None:
    for (px, py) in PARTICLE_POSITIONS:
        # Soft outer dot
        r_out = 10
        draw.ellipse([px - r_out, py - r_out, px + r_out, py + r_out],
                     fill=(126, 200, 227, 40))
        # Bright inner core
        r_in = 4
        draw.ellipse([px - r_in, py - r_in, px + r_in, py + r_in],
                     fill=(126, 200, 227, 150))

# ── Round variant mask ────────────────────────────────────────────────────────
def apply_circle_mask(img: Image.Image) -> Image.Image:
    """Return copy of img with pixels outside the inscribed circle set transparent."""
    size = img.size[0]
    mask = Image.new('L', (size, size), 0)
    ImageDraw.Draw(mask).ellipse([0, 0, size - 1, size - 1], fill=255)
    result = img.copy().convert('RGBA')
    result.putalpha(mask)
    return result

# ── Master assembly ───────────────────────────────────────────────────────────
def generate_master() -> Image.Image:
    img = Image.new('RGBA', (SIZE, SIZE), BG_DARK)

    # Background bloom
    draw_background(img)

    # Hex ring
    draw_obj = ImageDraw.Draw(img)
    draw_hex_ring(draw_obj, SIZE // 2, SIZE // 2, 320)

    # A glyph with glow (composited as separate layers)
    polys = make_a_polygons(cx=SIZE // 2, top=272, bot=752)
    draw_glyph_with_glow(img, polys)

    # Corner brackets + particles (drawn on top of glyph)
    draw_obj = ImageDraw.Draw(img)
    draw_corner_brackets(draw_obj)
    draw_particles(draw_obj)

    return img

# ── Save all outputs ──────────────────────────────────────────────────────────
def save_all(master: Image.Image) -> None:
    # 1. Master asset (1024x1024, RGBA PNG)
    os.makedirs(ASSETS_DIR, exist_ok=True)
    master_path = os.path.join(ASSETS_DIR, 'agion_icon.png')
    master.save(master_path, 'PNG')
    size_kb = os.path.getsize(master_path) // 1024
    print(f"[OK] {master_path}  (1024×1024, {size_kb} KB)")

    # 2. All mipmap sizes
    for folder, px in SQUARE_SIZES.items():
        mipmap_dir = os.path.join(MIPMAP_BASE, folder)
        os.makedirs(mipmap_dir, exist_ok=True)

        square = master.resize((px, px), Image.LANCZOS)

        sq_path = os.path.join(mipmap_dir, 'ic_launcher.png')
        square.save(sq_path, 'PNG')
        print(f"[OK] {folder}/ic_launcher.png  ({px}×{px})")

        round_img = apply_circle_mask(square)
        rd_path   = os.path.join(mipmap_dir, 'ic_launcher_round.png')
        round_img.save(rd_path, 'PNG')
        print(f"[OK] {folder}/ic_launcher_round.png  ({px}×{px})")

# ── Entry point ───────────────────────────────────────────────────────────────
if __name__ == '__main__':
    # Must be run from the AGION project root
    if not os.path.exists('pubspec.yaml'):
        print("ERROR: Run from the AGION project root (where pubspec.yaml lives).")
        raise SystemExit(1)

    print("AGION Icon Generator — compositing master image...")
    master = generate_master()
    print("Master image built. Saving all outputs...\n")
    save_all(master)
    print("\nDone! Rebuild the APK to use the new icons.")
