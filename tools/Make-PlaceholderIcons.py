"""Placeholder building icons for the housing tiers and Rail Works.

Tints an existing BOI icon and stamps a short label, so the new buildings can be
told apart in the construction lens until real art exists. Writes the 256x256 RGBA
DDS with nine mips that the game reads, using the horse icon's header (the same
format tools/Convert-HousingIcons.ps1 writes), plus a PNG beside it.

Run from anywhere: python tools/Make-PlaceholderIcons.py
"""
import colorsys
from pathlib import Path

from PIL import Image, ImageDraw, ImageFont

MOD = Path(__file__).resolve().parent.parent
ICONS = MOD / "gfx/interface/icons/building_icons"
HEADER = (MOD / "gfx/interface/icons/goods_icons/boi_horses.dds").read_bytes()[:128]

# new icon: (source icon, hue shift 0-1, label)
PLACEHOLDERS = {
    "boi_regulated_terraces": ("boi_tenements", 0.10, "TER"),
    "boi_tenement_blocks": ("boi_tenements", 0.55, "BLK"),
    "boi_model_dwellings": ("boi_tenements", 0.30, "MOD"),
    "boi_municipal_estates": ("boi_apartments", 0.60, "MUN"),
    "boi_elevator_apartments": ("boi_apartments", 0.30, "ELV"),
    "boi_boulevard_apartments": ("boi_luxury_apartments", 0.15, "BLV"),
    "boi_elevator_residences": ("boi_luxury_apartments", 0.45, "ELV"),
    "boi_railway_suburbs": ("boi_suburbs", 0.60, "RLY"),
    "boi_streetcar_suburbs": ("boi_suburbs", 0.30, "TRM"),
    "boi_motor_suburbs": ("boi_suburbs", 0.80, "MOT"),
    "boi_rail_works": ("boi_public_works", 0.55, "RAIL"),
}


def tint(image: Image.Image, shift: float) -> Image.Image:
    pixels = image.load()
    for y in range(image.height):
        for x in range(image.width):
            r, g, b, a = pixels[x, y]
            if a:
                h, s, v = colorsys.rgb_to_hsv(r / 255, g / 255, b / 255)
                r2, g2, b2 = colorsys.hsv_to_rgb((h + shift) % 1, min(1, s + 0.15), v)
                pixels[x, y] = (int(r2 * 255), int(g2 * 255), int(b2 * 255), a)
    return image


def stamp(image: Image.Image, label: str) -> Image.Image:
    draw = ImageDraw.Draw(image)
    try:
        font = ImageFont.truetype("arialbd.ttf", 60)
    except OSError:
        font = ImageFont.load_default()
    box = draw.textbbox((0, 0), label, font=font)
    width, height = box[2] - box[0], box[3] - box[1]
    x, y = (256 - width) // 2, 256 - height - 28
    draw.rectangle((x - 10, y - 4, x + width + 10, y + height + 16), fill=(20, 20, 20, 215))
    draw.text((x - box[0], y - box[1]), label, font=font, fill=(255, 255, 255, 255))
    return image


def write_dds(image: Image.Image, path: Path) -> None:
    with path.open("wb") as out:
        out.write(HEADER)
        for size in (256, 128, 64, 32, 16, 8, 4, 2, 1):
            mip = image.resize((size, size), Image.LANCZOS)
            r, g, b, a = mip.split()
            out.write(Image.merge("RGBA", (b, g, r, a)).tobytes())


for name, (source, shift, label) in PLACEHOLDERS.items():
    if (MOD / 'art/buildings' / f'{name}.png').exists():
        print(f'{name}: finished artwork exists; skipping placeholder')
        continue
    icon = Image.open(ICONS / f"{source}.png").convert("RGBA").resize((256, 256))
    icon = stamp(tint(icon, shift), label)
    icon.save(ICONS / f"{name}.png")
    write_dds(icon, ICONS / f"{name}.dds")
    print(name)
