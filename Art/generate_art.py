#!/usr/bin/env python3
"""
Teeter — procedural sketchy-steampunk art generator.

Produces hand-drawn-looking steampunk sprites as SVG source (Art/svg/) and
rasterizes them to a drop-in Xcode asset catalog (Sources/Resources/Assets.xcassets)
at @1x / @2x / @3x.

The "sketch" look is built from GEOMETRY, not SVG filters:
  - every outline is drawn as 2-3 slightly jittered overlapping strokes
  - fills are flat metal tones with a thin cross-hatch shadow on one side
  - rivets, gear teeth and chain links are the steampunk vernacular
This keeps it 100% cairosvg-safe (filters like feTurbulence are NOT used).

Run:  python3 Art/generate_art.py
Deps: pip install cairosvg
"""

import os, math, random, json
import cairosvg

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
SVG_DIR = os.path.join(ROOT, "Art", "svg")
XCASSETS = os.path.join(ROOT, "Sources", "Resources", "Assets.xcassets")

# ---- Palette (steampunk, 6 named tones + ink) ------------------------------
INK        = "#241C16"   # warm near-black outline
PARCH      = "#E7D7B1"   # aged parchment
PARCH_DK   = "#C9B488"   # parchment shadow
BRASS      = "#C08A2E"   # primary metal
BRASS_HI   = "#E6BE6A"   # brass highlight
BRASS_DK   = "#8A5E1E"   # brass shadow
COPPER     = "#A85A34"   # accent metal
COPPER_DK  = "#6E3A20"   # copper shadow
RUST       = "#9E3B2A"   # danger / oxidised (lean meter red zone)
PATINA     = "#3E7C74"   # oxidised teal (sparing accent)
STEAM      = "#F3ECDD"   # steam / paper white

random.seed(1873)  # deterministic output (a steampunk-appropriate year)


# ---- low-level sketch primitives -------------------------------------------
def j(v, amt=1.6):
    return v + random.uniform(-amt, amt)

def sketch_path(points, closed=True, jitter=1.6):
    """One jittered stroke path 'd' string through points."""
    pts = [(j(x, jitter), j(y, jitter)) for (x, y) in points]
    d = f"M{pts[0][0]:.1f},{pts[0][1]:.1f} "
    for (x, y) in pts[1:]:
        d += f"L{x:.1f},{y:.1f} "
    if closed:
        d += "Z"
    return d

def sketch_outline(points, closed=True, stroke=INK, w=3.0, passes=2, jitter=1.6):
    """2-3 overlapping jittered strokes => hand-drawn double line."""
    s = ""
    for _ in range(passes):
        d = sketch_path(points, closed, jitter)
        s += (f'<path d="{d}" fill="none" stroke="{stroke}" '
               f'stroke-width="{w:.1f}" stroke-linecap="round" '
               f'stroke-linejoin="round" opacity="0.92"/>\n')
    return s

def filled_poly(points, fill):
    d = sketch_path(points, True, jitter=0.6)
    return f'<path d="{d}" fill="{fill}" stroke="none"/>\n'

def hatch(x, y, w, h, color=INK, gap=7, opacity=0.18):
    """Diagonal cross-hatch shading clipped to a rect (cheap shadow)."""
    cid = f"clip{random.randint(0,1_000_000)}"
    s = f'<clipPath id="{cid}"><rect x="{x}" y="{y}" width="{w}" height="{h}"/></clipPath>\n'
    s += f'<g clip-path="url(#{cid})" opacity="{opacity}">\n'
    n = int((w + h) / gap) + 2
    for i in range(-2, n):
        x0 = x + i * gap
        s += (f'<line x1="{j(x0,0.8):.1f}" y1="{j(y,0.8):.1f}" '
              f'x2="{j(x0 - h,0.8):.1f}" y2="{j(y + h,0.8):.1f}" '
              f'stroke="{color}" stroke-width="1.4"/>\n')
    s += "</g>\n"
    return s

def rivet(cx, cy, r=4.5):
    return (f'<circle cx="{cx:.1f}" cy="{cy:.1f}" r="{r:.1f}" fill="{BRASS_DK}" '
            f'stroke="{INK}" stroke-width="1.4"/>'
            f'<circle cx="{cx-1.2:.1f}" cy="{cy-1.2:.1f}" r="{r*0.4:.1f}" '
            f'fill="{BRASS_HI}" stroke="none"/>\n')

def gear_points(cx, cy, r, teeth, depth=0.22):
    pts = []
    steps = teeth * 4
    for i in range(steps):
        a = (i / steps) * 2 * math.pi
        phase = i % 4
        rr = r if phase in (1, 2) else r * (1 - depth)
        pts.append((cx + rr * math.cos(a), cy + rr * math.sin(a)))
    return pts


# ---- svg document wrapper ---------------------------------------------------
def svg_doc(w, h, body):
    return (f'<svg xmlns="http://www.w3.org/2000/svg" width="{w}" height="{h}" '
            f'viewBox="0 0 {w} {h}">\n{body}</svg>\n')


# ---- a steampunk metal plate (base for blocks & buttons) -------------------
def metal_plate(w, h, pad=8, fill=BRASS, hi=BRASS_HI, dk=BRASS_DK,
                corner_rivets=True, edge_rivets=False, hatch_shadow=True):
    x0, y0 = pad, pad
    x1, y1 = w - pad, h - pad
    corners = [(x0, y0), (x1, y0), (x1, y1), (x0, y1)]
    s = ""
    # base fill
    s += filled_poly(corners, fill)
    # highlight band (top-left)
    s += (f'<path d="{sketch_path([(x0,y0),(x1,y0),(x1,y0+6),(x0+6,y0+6),(x0+6,y1),(x0,y1)],True,0.5)}" '
          f'fill="{hi}" opacity="0.5" stroke="none"/>\n')
    # shadow band (bottom-right) via hatch
    if hatch_shadow:
        s += hatch(x0, y0 + (y1 - y0) * 0.55, x1 - x0, (y1 - y0) * 0.45, INK, gap=6, opacity=0.16)
        s += filled_poly([(x1-6,y0+6),(x1,y0),(x1,y1),(x0,y1),(x0+6,y1-6),(x1-6,y1-6)], dk)
    # outline
    s += sketch_outline(corners, True, INK, 3.4, passes=2)
    # rivets
    if corner_rivets:
        for (cx, cy) in [(x0+10,y0+10),(x1-10,y0+10),(x1-10,y1-10),(x0+10,y1-10)]:
            s += rivet(cx, cy)
    if edge_rivets:
        mx = (x0 + x1) / 2
        my = (y0 + y1) / 2
        for (cx, cy) in [(mx, y0+9),(mx, y1-9),(x0+9, my),(x1-9, my)]:
            s += rivet(cx, cy, 3.8)
    return s


# ============================================================================
#  SPRITE BUILDERS  (return (name, width, height, svg_string))
# ============================================================================
SPRITES = []
def reg(name, w, h, body):
    SPRITES.append((name, w, h, svg_doc(w, h, body)))


def build_blocks():
    S = 128  # base block unit
    # square
    reg("block_square", S, S, metal_plate(S, S, fill=BRASS, edge_rivets=True))
    # wide rectangle (2x1)
    reg("block_rect", S*2, S, metal_plate(S*2, S, fill=COPPER, hi="#C9784E",
        dk=COPPER_DK, edge_rivets=True))
    # long bar (3x0.7) — the awkward narrow piece
    reg("block_bar", S*3, int(S*0.72), metal_plate(S*3, int(S*0.72), fill=BRASS,
        edge_rivets=True))
    # L-shape
    Lw, Lh = S*2, S*2
    body = ""
    pts = [(8,8),(Lw-8,8),(Lw-8,S-8),(S-8,S-8),(S-8,Lh-8),(8,Lh-8)]
    body += filled_poly(pts, BRASS)
    body += hatch(8, S, Lw-16, S-16, INK, gap=6, opacity=0.15)
    body += sketch_outline(pts, True, INK, 3.4, 2)
    for (cx,cy) in [(20,20),(Lw-20,20),(S-20,S+4),(Lw-20,S-20) if False else (S-20,Lh-20),(20,Lh-20)]:
        body += rivet(cx,cy)
    reg("block_L", Lw, Lh, body)
    # T-shape
    Tw, Th = S*3, S*2
    tpts = [(8,8),(Tw-8,8),(Tw-8,S-8),(2*S-8,S-8),(2*S-8,Th-8),(S+8,Th-8),(S+8,S-8),(8,S-8)]
    tbody = filled_poly(tpts, COPPER)
    tbody += sketch_outline(tpts, True, INK, 3.4, 2)
    for (cx,cy) in [(20,20),(Tw-20,20),(Tw/2,Th-20)]:
        tbody += rivet(cx,cy)
    reg("block_T", Tw, Th, tbody)
    # triangle (very awkward)
    Vw, Vh = S*2, int(S*1.4)
    vpts = [(Vw/2,10),(Vw-10,Vh-10),(10,Vh-10)]
    vbody = filled_poly(vpts, BRASS)
    vbody += hatch(10, Vh*0.5, Vw-20, Vh*0.5, INK, gap=6, opacity=0.15)
    vbody += sketch_outline(vpts, True, INK, 3.4, 2)
    vbody += rivet(Vw/2, 26); vbody += rivet(28, Vh-22); vbody += rivet(Vw-28, Vh-22)
    reg("block_triangle", Vw, Vh, vbody)
    # gear / round (rolls — the most unstable)
    G = int(S*1.5)
    cx = cy = G/2
    gp = gear_points(cx, cy, G*0.42, 10, 0.22)
    gbody = filled_poly(gp, BRASS)
    gbody += sketch_outline(gp, True, INK, 3.0, 2)
    gbody += (f'<circle cx="{cx}" cy="{cy}" r="{G*0.18}" fill="{BRASS_DK}" '
              f'stroke="{INK}" stroke-width="2.6"/>')
    gbody += (f'<circle cx="{cx}" cy="{cy}" r="{G*0.07}" fill="{PARCH}" '
              f'stroke="{INK}" stroke-width="1.8"/>')
    for k in range(6):
        a = k/6*2*math.pi
        gbody += rivet(cx+G*0.27*math.cos(a), cy+G*0.27*math.sin(a), 3.6)
    reg("block_gear", G, G, gbody)


def build_crane():
    # hook
    W = 90; H = 120
    body = ""
    # eye ring
    body += (f'<circle cx="{W/2}" cy="22" r="13" fill="none" stroke="{BRASS}" '
             f'stroke-width="7"/>')
    body += (f'<circle cx="{W/2}" cy="22" r="13" fill="none" stroke="{INK}" '
             f'stroke-width="2.2"/>')
    # shank + hook curve as jittered strokes
    hook = [(W/2,34),(W/2,72),(W/2+22,96),(W/2-2,112),(W/2-24,92)]
    body += sketch_outline(hook, False, BRASS, 9, 1, 1.0)
    body += sketch_outline(hook, False, INK, 3, 1, 1.2)
    reg("crane_hook", W, H, body)
    # chain link (tileable)
    body = (f'<ellipse cx="24" cy="30" rx="13" ry="22" fill="none" '
            f'stroke="{BRASS}" stroke-width="8"/>'
            f'<ellipse cx="24" cy="30" rx="13" ry="22" fill="none" '
            f'stroke="{INK}" stroke-width="2.2"/>')
    reg("chain_link", 48, 60, body)
    # crane arm girder (horizontal beam with truss)
    W=560; H=70
    beam = [(6,18),(W-6,18),(W-6,H-18),(6,H-18)]
    body = filled_poly(beam, BRASS)
    body += sketch_outline(beam, True, INK, 3.2, 2)
    # truss zig-zag
    zz = []
    n = 9
    for i in range(n+1):
        x = 12 + i*(W-24)/n
        zz.append((x, 22 if i%2==0 else H-22))
    body += sketch_outline(zz, False, INK, 2.4, 1, 1.0)
    for i in range(0, W, 60):
        body += rivet(20+i, 26, 3.4); body += rivet(20+i, H-26, 3.4)
    reg("crane_arm", W, H, body)


def build_background():
    W, H = 900, 1600
    body = (f'<rect width="{W}" height="{H}" fill="{PARCH}"/>\n')
    # faint blueprint grid
    body += '<g opacity="0.10">\n'
    for x in range(0, W, 60):
        body += f'<line x1="{x}" y1="0" x2="{x}" y2="{H}" stroke="{INK}" stroke-width="1"/>'
    for y in range(0, H, 60):
        body += f'<line x1="0" y1="{y}" x2="{W}" y2="{y}" stroke="{INK}" stroke-width="1"/>'
    body += '</g>\n'
    # faint ghost gears scattered
    body += '<g opacity="0.07">\n'
    for (gx, gy, gr, gt) in [(180,300,150,12),(720,650,220,16),(300,1050,180,14),
                             (650,1300,120,10),(120,900,90,9)]:
        gp = gear_points(gx, gy, gr, gt, 0.2)
        d = "M" + " L".join(f"{x:.0f},{y:.0f}" for (x,y) in gp) + " Z"
        body += f'<path d="{d}" fill="none" stroke="{INK}" stroke-width="3"/>'
        body += f'<circle cx="{gx}" cy="{gy}" r="{gr*0.3}" fill="none" stroke="{INK}" stroke-width="3"/>'
    body += '</g>\n'
    # vignette (corners darkened with hatch)
    body += hatch(0,0,W,150,INK,gap=10,opacity=0.10)
    body += hatch(0,H-220,W,220,COPPER_DK,gap=9,opacity=0.12)
    reg("bg_main", W, H, body)


def build_gauge():
    # THE SIGNATURE ELEMENT: brass lean-meter gauge frame (semicircle)
    W=260; H=170
    cx, cy, r = W/2, H-24, 110
    body = ""
    # arc face
    body += (f'<path d="M{cx-r},{cy} A{r},{r} 0 0 1 {cx+r},{cy}" '
             f'fill="{PARCH}" stroke="{INK}" stroke-width="4"/>')
    # green->amber->red zones
    def arc(a0,a1,col,rr):
        x0=cx+rr*math.cos(math.radians(a0)); y0=cy-rr*math.sin(math.radians(a0))
        x1=cx+rr*math.cos(math.radians(a1)); y1=cy-rr*math.sin(math.radians(a1))
        large = 1 if (a0-a1)>180 else 0
        return (f'<path d="M{x0:.1f},{y0:.1f} A{rr},{rr} 0 {large} 1 {x1:.1f},{y1:.1f}" '
                f'fill="none" stroke="{col}" stroke-width="16" stroke-linecap="butt" opacity="0.85"/>')
    body += arc(180,120,PATINA,r-18)
    body += arc(120,60,BRASS,r-18)
    body += arc(60,0,RUST,r-18)
    # tick marks
    for deg in range(0,181,20):
        x0=cx+(r-2)*math.cos(math.radians(deg)); y0=cy-(r-2)*math.sin(math.radians(deg))
        x1=cx+(r-12)*math.cos(math.radians(deg)); y1=cy-(r-12)*math.sin(math.radians(deg))
        body += f'<line x1="{x0:.1f}" y1="{y0:.1f}" x2="{x1:.1f}" y2="{y1:.1f}" stroke="{INK}" stroke-width="2.4"/>'
    # brass bezel ring (outer)
    body += (f'<path d="M{cx-r-8},{cy} A{r+8},{r+8} 0 0 1 {cx+r+8},{cy}" '
             f'fill="none" stroke="{BRASS}" stroke-width="9"/>')
    body += (f'<path d="M{cx-r-8},{cy} A{r+8},{r+8} 0 0 1 {cx+r+8},{cy}" '
             f'fill="none" stroke="{INK}" stroke-width="2.4"/>')
    for deg in (180,90,0):
        body += rivet(cx+(r+8)*math.cos(math.radians(deg)), cy-(r+8)*math.sin(math.radians(deg)),4)
    body += f'<line x1="{cx-r-8}" y1="{cy}" x2="{cx+r+8}" y2="{cy}" stroke="{INK}" stroke-width="4"/>'
    reg("gauge_frame", W, H, body)
    # needle
    nW, nH = 22, 120
    npts=[(nW/2,6),(nW-3,nH-18),(nW/2,nH-6),(3,nH-18)]
    nbody=filled_poly(npts, COPPER)
    nbody+=sketch_outline(npts,True,INK,2.4,2)
    nbody+=(f'<circle cx="{nW/2}" cy="{nH-12}" r="9" fill="{BRASS}" stroke="{INK}" stroke-width="2.4"/>')
    reg("gauge_needle", nW, nH, nbody)


def build_ui():
    # gear icon for "catches remaining" (lit + dim)
    for name, col, op in [("gear_icon", BRASS, 1.0), ("gear_icon_dim", PARCH_DK, 0.55)]:
        G=72; cx=cy=G/2
        gp=gear_points(cx,cy,G*0.4,8,0.24)
        b=filled_poly(gp,col)
        b+=sketch_outline(gp,True,INK,2.6,2)
        b+=(f'<circle cx="{cx}" cy="{cy}" r="{G*0.15}" fill="{PARCH}" stroke="{INK}" stroke-width="2.2"/>')
        SPRITES.append((name,G,G,svg_doc(G,G,f'<g opacity="{op}">{b}</g>')))
    # brass button (large) and small
    for name,(w,h) in [("btn_brass",(300,96)),("btn_brass_small",(120,96))]:
        reg(name, w, h, metal_plate(w,h,fill=BRASS,edge_rivets=False,corner_rivets=True))
    # ribbon / score banner
    W,H=360,108
    rp=[(10,24),(W-10,24),(W-34,H/2),(W-10,H-24),(10,H-24),(34,H/2)]
    rb=filled_poly(rp,COPPER)
    rb+=sketch_outline(rp,True,INK,3.2,2)
    rb+=hatch(10,H/2,W-20,H/2-24,INK,gap=7,opacity=0.14)
    reg("ribbon",W,H,rb)
    # small icons: share, sound on/off, close — simple sketchy glyphs on brass discs
    def disc(glyph, name):
        D=84;cx=cy=D/2
        b=(f'<circle cx="{cx}" cy="{cy}" r="{D*0.44}" fill="{BRASS}" stroke="{INK}" stroke-width="3.2"/>'
           f'<circle cx="{cx}" cy="{cy}" r="{D*0.44}" fill="none" stroke="{BRASS_HI}" stroke-width="1.4" opacity="0.6"/>')
        b+=glyph
        reg(name,D,D,b)
    disc(f'<path d="{sketch_path([(30,30),(54,42),(30,54)],False,1.0)}" fill="none" stroke="{INK}" stroke-width="4" stroke-linejoin="round"/>'
         f'<circle cx="30" cy="30" r="6" fill="{INK}"/><circle cx="54" cy="42" r="6" fill="{INK}"/><circle cx="30" cy="54" r="6" fill="{INK}"/>',
         "icon_share")
    disc(f'<path d="M28,34 L40,34 L52,24 L52,60 L40,50 L28,50 Z" fill="{INK}"/>'
         f'<path d="M58,30 Q66,42 58,54" fill="none" stroke="{INK}" stroke-width="3.4"/>',
         "icon_sound_on")
    disc(f'<path d="M28,34 L40,34 L52,24 L52,60 L40,50 L28,50 Z" fill="{INK}"/>'
         f'<line x1="56" y1="30" x2="66" y2="54" stroke="{RUST}" stroke-width="4"/>'
         f'<line x1="66" y1="30" x2="56" y2="54" stroke="{RUST}" stroke-width="4"/>',
         "icon_sound_off")
    disc(f'<line x1="28" y1="28" x2="56" y2="56" stroke="{INK}" stroke-width="5" stroke-linecap="round"/>'
         f'<line x1="56" y1="28" x2="28" y2="56" stroke="{INK}" stroke-width="5" stroke-linecap="round"/>',
         "icon_close")


def build_fx():
    # steam puff (soft cloud of overlapping circles)
    W=H=96
    body=""
    for (dx,dy,r,op) in [(0,8,30,0.9),(-22,18,20,0.8),(22,16,22,0.8),(0,-10,24,0.95),(-14,-6,16,0.85),(16,-4,16,0.85)]:
        body+=f'<circle cx="{W/2+dx}" cy="{H/2+dy}" r="{r}" fill="{STEAM}" opacity="{op}"/>'
    reg("steam_puff",W,H,body)
    # spark (perfect placement) — brass starburst
    W=H=72;cx=cy=W/2
    body=""
    for k in range(8):
        a=k/8*2*math.pi
        body+=(f'<line x1="{cx}" y1="{cy}" x2="{cx+30*math.cos(a):.1f}" y2="{cy+30*math.sin(a):.1f}" '
               f'stroke="{BRASS_HI}" stroke-width="4" stroke-linecap="round"/>')
    body+=f'<circle cx="{cx}" cy="{cy}" r="8" fill="{STEAM}"/>'
    reg("spark",W,H,body)
    # dust (topple) — scattered specks
    W=H=120
    body=""
    random.seed(7)
    for _ in range(26):
        x=random.uniform(8,W-8);y=random.uniform(8,H-8);r=random.uniform(2,6)
        body+=f'<circle cx="{x:.0f}" cy="{y:.0f}" r="{r:.0f}" fill="{COPPER_DK}" opacity="{random.uniform(0.3,0.7):.2f}"/>'
    random.seed(1873)
    reg("dust",W,H,body)


def build_sharecard_frame():
    W,H=640,900
    body=(f'<rect x="6" y="6" width="{W-12}" height="{H-12}" rx="14" fill="none" '
          f'stroke="{BRASS}" stroke-width="10"/>')
    body+=(f'<rect x="6" y="6" width="{W-12}" height="{H-12}" rx="14" fill="none" '
           f'stroke="{INK}" stroke-width="2.6"/>')
    body+=(f'<rect x="22" y="22" width="{W-44}" height="{H-44}" rx="8" fill="none" '
           f'stroke="{INK}" stroke-width="1.6" opacity="0.5"/>')
    for (cx,cy) in [(28,28),(W-28,28),(W-28,H-28),(28,H-28)]:
        body+=rivet(cx,cy,7)
    # corner gears
    for (cx,cy) in [(60,60),(W-60,60),(60,H-60),(W-60,H-60)]:
        gp=gear_points(cx,cy,26,8,0.22)
        body+=f'<path d="{sketch_path(gp,True,0.6)}" fill="{BRASS}" stroke="{INK}" stroke-width="2.4"/>'
        body+=f'<circle cx="{cx}" cy="{cy}" r="8" fill="{PARCH}" stroke="{INK}" stroke-width="2"/>'
    reg("sharecard_frame",W,H,body)


def build_appicon():
    W=H=1024
    body=f'<rect width="{W}" height="{H}" fill="{PARCH}"/>'
    body+=hatch(0,0,W,H,COPPER_DK,gap=26,opacity=0.06)
    # big ghost gear behind
    gp=gear_points(W*0.72,H*0.30,300,14,0.2)
    body+=f'<path d="{sketch_path(gp,True,0.6)}" fill="{BRASS}" opacity="0.30" stroke="none"/>'
    # a little leaning brass tower (3 blocks)
    bx=W*0.34
    sizes=[(300,0),(250,-26),(190,34)]
    yb=H*0.80
    for i,(s,off) in enumerate(sizes):
        x=bx+off; y=yb - sum(z[0] for z in sizes[:i]) - 40*i
        pts=[(x-s/2,y-s),(x+s/2,y-s),(x+s/2,y),(x-s/2,y)]
        body+=filled_poly(pts, BRASS if i%2==0 else COPPER)
        body+=sketch_outline(pts,True,INK,9,2,2.2)
        body+=rivet(x-s/2+26,y-s+26,11);body+=rivet(x+s/2-26,y-s+26,11)
        body+=rivet(x-s/2+26,y-26,11);body+=rivet(x+s/2-26,y-26,11)
    reg("appicon", W, H, body)


# ---- asset-catalog writing --------------------------------------------------
def write_imageset(name, w, h, svg):
    # save svg source
    with open(os.path.join(SVG_DIR, f"{name}.svg"), "w") as f:
        f.write(svg)
    iset = os.path.join(XCASSETS, f"{name}.imageset")
    os.makedirs(iset, exist_ok=True)
    imgs = []
    for scale in (1, 2, 3):
        png = f"{name}@{scale}x.png" if scale > 1 else f"{name}.png"
        cairosvg.svg2png(bytestring=svg.encode(), write_to=os.path.join(iset, png),
                         output_width=int(w*scale), output_height=int(h*scale))
        imgs.append({"idiom": "universal", "filename": png, "scale": f"{scale}x"})
    with open(os.path.join(iset, "Contents.json"), "w") as f:
        json.dump({"images": imgs, "info": {"version": 1, "author": "xcode"}}, f, indent=2)

def write_appicon(svg):
    with open(os.path.join(SVG_DIR, "appicon.svg"), "w") as f:
        f.write(svg)
    ai = os.path.join(XCASSETS, "AppIcon.appiconset")
    os.makedirs(ai, exist_ok=True)
    cairosvg.svg2png(bytestring=svg.encode(), write_to=os.path.join(ai, "icon_1024.png"),
                     output_width=1024, output_height=1024)
    with open(os.path.join(ai, "Contents.json"), "w") as f:
        json.dump({"images": [{"idiom": "universal", "platform": "ios",
                               "size": "1024x1024", "filename": "icon_1024.png"}],
                   "info": {"version": 1, "author": "xcode"}}, f, indent=2)

def write_catalog_root():
    with open(os.path.join(XCASSETS, "Contents.json"), "w") as f:
        json.dump({"info": {"version": 1, "author": "xcode"}}, f, indent=2)


def main():
    os.makedirs(SVG_DIR, exist_ok=True)
    os.makedirs(XCASSETS, exist_ok=True)
    build_blocks(); build_crane(); build_background(); build_gauge()
    build_ui(); build_fx(); build_sharecard_frame(); build_appicon()
    write_catalog_root()
    count = 0
    for (name, w, h, svg) in SPRITES:
        if name == "appicon":
            write_appicon(svg)
        else:
            write_imageset(name, w, h, svg)
        count += 1
    print(f"Generated {count} sprites -> {XCASSETS}")
    print("Block/UI sprite names:", ", ".join(s[0] for s in SPRITES))

if __name__ == "__main__":
    main()
