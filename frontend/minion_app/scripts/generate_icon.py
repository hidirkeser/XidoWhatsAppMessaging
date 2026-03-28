#!/usr/bin/env python3
"""Generate Minion app icon PNG files - Rose Gold shield with M lettermark"""

from PIL import Image, ImageDraw, ImageFont, ImageFilter
import os, math, json

def lerp_color(c1, c2, t):
    return tuple(int(c1[i] + (c2[i] - c1[i]) * t) for i in range(3))

def draw_rounded_rect_mask(draw, w, h, r):
    """Draw white rounded rect on mask."""
    draw.rectangle([r, 0, w - r, h], fill=255)
    draw.rectangle([0, r, w, h - r], fill=255)
    draw.ellipse([0, 0, 2*r, 2*r], fill=255)
    draw.ellipse([w - 2*r, 0, w, 2*r], fill=255)
    draw.ellipse([0, h - 2*r, 2*r, h], fill=255)
    draw.ellipse([w - 2*r, h - 2*r, w, h], fill=255)

def shield_polygon(cx, cy, sw, sh):
    """Return polygon points for a shield shape."""
    r = sw * 0.18
    pts = []
    # Top-left rounded corner
    for i in range(16):
        angle = math.pi + (math.pi / 2) * i / 15
        pts.append((cx - sw/2 + r + r*math.cos(angle),
                    cy - sh/2 + r + r*math.sin(angle)))
    # Top-right rounded corner
    for i in range(16):
        angle = -math.pi/2 + (math.pi/2) * i / 15
        pts.append((cx + sw/2 - r + r*math.cos(angle),
                    cy - sh/2 + r + r*math.sin(angle)))
    # Right side
    pts.append((cx + sw/2, cy - sh/2 + sh * 0.54))
    # Right curve to bottom
    for i in range(20):
        t = i / 19
        p0 = (cx + sw/2, cy - sh/2 + sh * 0.54)
        p1 = (cx + sw/2, cy - sh/2 + sh * 0.79)
        p2 = (cx + sw * 0.16, cy - sh/2 + sh * 0.91)
        p3 = (cx, cy + sh/2)
        bx = (1-t)**3*p0[0] + 3*(1-t)**2*t*p1[0] + 3*(1-t)*t**2*p2[0] + t**3*p3[0]
        by = (1-t)**3*p0[1] + 3*(1-t)**2*t*p1[1] + 3*(1-t)*t**2*p2[1] + t**3*p3[1]
        pts.append((bx, by))
    # Left curve from bottom
    for i in range(20):
        t = i / 19
        p0 = (cx, cy + sh/2)
        p1 = (cx - sw * 0.16, cy - sh/2 + sh * 0.91)
        p2 = (cx - sw/2, cy - sh/2 + sh * 0.79)
        p3 = (cx - sw/2, cy - sh/2 + sh * 0.54)
        bx = (1-t)**3*p0[0] + 3*(1-t)**2*t*p1[0] + 3*(1-t)*t**2*p2[0] + t**3*p3[0]
        by = (1-t)**3*p0[1] + 3*(1-t)**2*t*p1[1] + 3*(1-t)*t**2*p2[1] + t**3*p3[1]
        pts.append((bx, by))
    return pts

def generate_icon(size):
    s = size
    img = Image.new('RGBA', (s, s), (0, 0, 0, 0))

    # Colors
    bg1 = (190, 24, 93)       # #BE185D Rose Gold
    bg2 = (131, 14, 62)       # deeper rose
    shield_light = (253, 205, 224)  # light pink
    shield_white = (255, 255, 255)
    letter_col = (131, 14, 62)  # dark rose

    # ── Background ──
    bg_r = int(s * 0.22)
    bg_grad = Image.new('RGB', (s, s))
    for y in range(s):
        for x in range(s):
            t = (x / s * 0.4 + y / s * 0.6)
            bg_grad.putpixel((x, y), lerp_color(bg1, bg2, t))
    bg_mask = Image.new('L', (s, s), 0)
    draw_rounded_rect_mask(ImageDraw.Draw(bg_mask), s, s, bg_r)
    img.paste(bg_grad, (0, 0), bg_mask)

    # ── Shield shadow ──
    pad = s * 0.12
    sw = s - 2 * pad
    sh = s - 2 * pad
    cx = s / 2
    cy = s / 2

    shadow_img = Image.new('RGBA', (s, s), (0, 0, 0, 0))
    shadow_draw = ImageDraw.Draw(shadow_img)
    shadow_pts = shield_polygon(cx, cy + s*0.03, sw*0.95, sh*0.95)
    shadow_draw.polygon(shadow_pts, fill=(80, 0, 30, 100))
    shadow_img = shadow_img.filter(ImageFilter.GaussianBlur(radius=max(1, int(s*0.035))))
    img = Image.alpha_composite(img, shadow_img)

    # ── Shield ──
    pts = shield_polygon(cx, cy, sw, sh)

    shield_mask = Image.new('L', (s, s), 0)
    ImageDraw.Draw(shield_mask).polygon(pts, fill=255)

    shield_grad = Image.new('RGB', (s, s))
    for y in range(s):
        for x in range(s):
            t = (x / s * 0.35 + y / s * 0.65)
            shield_grad.putpixel((x, y), lerp_color(shield_light, shield_white, t))

    img.paste(shield_grad, (0, 0), shield_mask)

    # ── Highlight overlay on top third of shield ──
    hi = Image.new('RGBA', (s, s), (0, 0, 0, 0))
    hi_draw = ImageDraw.Draw(hi)
    hi_pts = shield_polygon(cx, cy, sw, sh)
    hi_draw.polygon(hi_pts, fill=(255, 255, 255, 30))
    img = Image.alpha_composite(img, hi)

    draw = ImageDraw.Draw(img)

    # ── "M" Letter ──
    font_size = int(sw * 0.52)
    font = None
    for fp in [
        '/System/Library/Fonts/Supplemental/Arial Black.ttf',
        '/System/Library/Fonts/Supplemental/Arial Bold.ttf',
        '/System/Library/Fonts/Supplemental/Arial Rounded Bold.ttf',
        '/System/Library/Fonts/NewYork.ttf',
    ]:
        try:
            font = ImageFont.truetype(fp, font_size)
            break
        except:
            continue
    if font is None:
        font = ImageFont.load_default()

    text = 'M'
    bbox = draw.textbbox((0, 0), text, font=font)
    tw = bbox[2] - bbox[0]
    th = bbox[3] - bbox[1]
    tx = cx - tw / 2 - bbox[0]
    ty = cy - th * 0.47 - bbox[1]

    # Subtle shadow
    draw.text((tx + max(1, s//200), ty + max(1, s//200)), text, font=font, fill=(80, 0, 30, 120))
    # Main letter
    draw.text((tx, ty), text, font=font, fill=letter_col)

    return img

# ── iOS App Icon specification ──
ios_dir = os.path.abspath(
    os.path.join(os.path.dirname(__file__), '..', 'ios', 'Runner',
                 'Assets.xcassets', 'AppIcon.appiconset'))
os.makedirs(ios_dir, exist_ok=True)

icon_spec = [
    # (filename, pts_size, scale, idiom)
    ('Icon-App-20x20@1x.png',      20,   1, 'ipad'),
    ('Icon-App-20x20@2x.png',      20,   2, 'iphone'),
    ('Icon-App-20x20@2x-1.png',    20,   2, 'ipad'),
    ('Icon-App-20x20@3x.png',      20,   3, 'iphone'),
    ('Icon-App-29x29@1x.png',      29,   1, 'iphone'),
    ('Icon-App-29x29@1x-1.png',    29,   1, 'ipad'),
    ('Icon-App-29x29@2x.png',      29,   2, 'iphone'),
    ('Icon-App-29x29@2x-1.png',    29,   2, 'ipad'),
    ('Icon-App-29x29@3x.png',      29,   3, 'iphone'),
    ('Icon-App-40x40@1x.png',      40,   1, 'ipad'),
    ('Icon-App-40x40@2x.png',      40,   2, 'iphone'),
    ('Icon-App-40x40@2x-1.png',    40,   2, 'ipad'),
    ('Icon-App-40x40@3x.png',      40,   3, 'iphone'),
    ('Icon-App-60x60@2x.png',      60,   2, 'iphone'),
    ('Icon-App-60x60@3x.png',      60,   3, 'iphone'),
    ('Icon-App-76x76@1x.png',      76,   1, 'ipad'),
    ('Icon-App-76x76@2x.png',      76,   2, 'ipad'),
    ('Icon-App-83.5x83.5@2x.png',  84,   2, 'ipad'),   # 83.5 -> use 84pt*2=168px
    ('Icon-App-1024x1024@1x.png', 1024,  1, 'ios-marketing'),
]

# Cache rendered sizes
cache = {}
images_entries = []

print(f'Generating iOS app icons...')
for (fname, pts, scale, idiom) in icon_spec:
    px = pts * scale
    if fname == 'Icon-App-83.5x83.5@2x.png':
        px = 167  # actual iOS requirement

    if px not in cache:
        print(f'  Rendering {px}x{px}px...')
        cache[px] = generate_icon(px)

    filepath = os.path.join(ios_dir, fname)
    cache[px].save(filepath, 'PNG')

    size_str = f'{pts}x{pts}' if pts != 84 else '83.5x83.5'
    scale_str = f'{scale}x'
    images_entries.append({
        'size': size_str,
        'idiom': idiom,
        'filename': fname,
        'scale': scale_str,
    })
    print(f'  ✓ {fname}')

# Write Contents.json
contents = {'images': images_entries, 'info': {'version': 1, 'author': 'xcode'}}
with open(os.path.join(ios_dir, 'Contents.json'), 'w') as f:
    json.dump(contents, f, indent=2)

# Also save master icon
assets_dir = os.path.abspath(os.path.join(os.path.dirname(__file__), '..', 'assets', 'icons'))
os.makedirs(assets_dir, exist_ok=True)
cache[1024].save(os.path.join(assets_dir, 'app_icon.png'), 'PNG')

print('\n✅ Done! iOS app icons generated.')
