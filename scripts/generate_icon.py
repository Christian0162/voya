"""
Generates the Voya app icon.

v2 design: rather than a generic microphone-in-a-square (which reads as
"any voice utility app"), the icon now mirrors the in-app AI avatar — a
friendly rounded face — flanked by small warm-accent soundwave bars, so it
reads as "an AI is talking to you" and ties directly to the character users
meet inside the app (the same logic behind Duolingo's owl: a personality
users recognize, not just a utility glyph). A soft drop shadow gives the
badge a bit of claymorphism-style depth/pop for a store listing, while
staying a single bold silhouette so it's still legible at 16px.

Outputs:
  assets/icon/app_icon.png             1024x1024, opaque background (master icon)
  assets/icon/app_icon_foreground.png  1024x1024, transparent background,
                                        glyph inset for Android adaptive icons
"""

from PIL import Image, ImageDraw

SIZE = 1024
PRIMARY = (79, 70, 229)   # #4F46E5 indigo
ACCENT = (124, 58, 237)   # #7C3AED violet
WAVE_ACCENT = (251, 191, 36)  # #FBBF24 warm amber — the "pop" color


def lerp(a, b, t):
    return tuple(int(a[i] + (b[i] - a[i]) * t) for i in range(3))


def diagonal_gradient(size, c1, c2):
    img = Image.new("RGB", (size, size))
    px = img.load()
    for y in range(size):
        for x in range(size):
            t = (x + y) / (2 * size)
            px[x, y] = lerp(c1, c2, t)
    return img


def rounded_mask(size, radius):
    mask = Image.new("L", (size, size), 0)
    draw = ImageDraw.Draw(mask)
    draw.rounded_rectangle([0, 0, size - 1, size - 1], radius=radius, fill=255)
    return mask


def draw_face(draw, cx, cy, scale, color):
    """A simple, friendly face — echoes the in-app AiAvatar's own painted
    face (round head, two eyes, a smile) so the icon and the character the
    user talks to inside the app feel like the same thing."""
    radius = scale * 0.5
    draw.ellipse([cx - radius, cy - radius, cx + radius, cy + radius], fill=color)


def draw_face_features(draw, cx, cy, scale, color, is_foreground=False):
    radius = scale * 0.5
    eye_y = cy - radius * 0.12
    eye_spacing = radius * 0.38
    eye_w = radius * 0.16
    eye_h = radius * 0.22
    for dx in (-eye_spacing, eye_spacing):
        ex = cx + dx
        draw.rounded_rectangle(
            [ex - eye_w / 2, eye_y - eye_h / 2, ex + eye_w / 2, eye_y + eye_h / 2],
            radius=eye_w / 2,
            fill=color,
        )

    mouth_y = cy + radius * 0.32
    mouth_w = radius * 0.5
    stroke = max(2, int(radius * 0.07))
    draw.arc(
        [cx - mouth_w / 2, mouth_y - mouth_w * 0.35, cx + mouth_w / 2, mouth_y + mouth_w * 0.55],
        start=20,
        end=160,
        fill=color,
        width=stroke,
    )


def draw_soundwave(draw, cx, cy, scale, color, side):
    """A little 3-bar equalizer flanking the face, suggesting speech/voice
    activity — the visual cue that this is a *talking* AI, not a static icon.
    `side` is -1 (left) or 1 (right)."""
    bar_w = scale * 0.075
    gap = scale * 0.06
    heights = [0.34, 0.58, 0.42]  # short-tall-medium, taller nearer the face
    if side < 0:
        heights = list(reversed(heights))
    x = cx
    for i, h_frac in enumerate(heights):
        bar_h = scale * h_frac
        bx = x + side * (i * (bar_w + gap) + bar_w / 2)
        draw.rounded_rectangle(
            [bx - bar_w / 2, cy - bar_h / 2, bx + bar_w / 2, cy + bar_h / 2],
            radius=bar_w / 2,
            fill=color,
        )


def draw_mark(draw, cx, cy, scale, face_color, wave_color):
    draw_face(draw, cx, cy, scale, face_color)
    draw_face_features(draw, cx, cy, scale, PRIMARY)
    wave_gap = scale * 0.72
    draw_soundwave(draw, cx - wave_gap / 2, cy, scale * 0.6, wave_color, side=-1)
    draw_soundwave(draw, cx + wave_gap / 2, cy, scale * 0.6, wave_color, side=1)


def build_master_icon():
    # Full-bleed background (edge to edge): the OS applies its own corner
    # mask/shadow at the springboard/launcher level, so anything drawn in a
    # margin outside a smaller "badge" would just get clipped away — there's
    # no point drawing a drop shadow into space the OS is going to crop.
    bg = diagonal_gradient(SIZE, PRIMARY, ACCENT)

    # Subtle inner highlight for a touch of depth — a soft glow in the
    # upper-left third, not a wash over half the icon.
    highlight = Image.new("L", (SIZE, SIZE), 0)
    hd = ImageDraw.Draw(highlight)
    hd.ellipse([-SIZE * 0.25, -SIZE * 0.45, SIZE * 0.75, SIZE * 0.35], fill=26)
    bg = Image.composite(Image.new("RGB", (SIZE, SIZE), (255, 255, 255)), bg, highlight)

    mask = rounded_mask(SIZE, radius=int(SIZE * 0.225))
    icon = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
    icon.paste(bg, (0, 0), mask)

    draw = ImageDraw.Draw(icon)
    draw_mark(draw, SIZE / 2, SIZE / 2, SIZE * 0.42, (255, 255, 255, 255), WAVE_ACCENT)

    icon.save("assets/icon/app_icon.png")


def build_adaptive_foreground():
    # Android adaptive icons render the foreground inside a safe zone that's
    # roughly 66% of the canvas, so the mark is inset and the background is
    # transparent (Android supplies its own solid background layer).
    img = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    draw_mark(draw, SIZE / 2, SIZE / 2, SIZE * 0.3, (255, 255, 255, 255), WAVE_ACCENT)
    img.save("assets/icon/app_icon_foreground.png")


if __name__ == "__main__":
    build_master_icon()
    build_adaptive_foreground()
    print("Generated assets/icon/app_icon.png and app_icon_foreground.png")
