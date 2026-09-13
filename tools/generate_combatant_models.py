#!/usr/bin/env python3
"""Generate lightweight, replaceable ZOOVORTEX combatant OBJ models."""

from math import cos, sin, tau
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1] / "prototype3d" / "models" / "combatants"


class Obj:
    def __init__(self, name):
        self.name, self.vertices, self.groups = name, [], []

    def add(self, vertices, faces, material):
        start = len(self.vertices) + 1
        self.vertices.extend(vertices)
        self.groups.append((material, [[start + i for i in face] for face in faces]))

    def box(self, center, size, material, angle=0.0):
        cx, cy, cz = center
        sx, sy, sz = (v / 2 for v in size)
        vertices = []
        for x, y, z in [(-1,-1,-1),(1,-1,-1),(1,1,-1),(-1,1,-1),(-1,-1,1),(1,-1,1),(1,1,1),(-1,1,1)]:
            px, pz = x * sx, z * sz
            vertices.append((cx + px*cos(angle) + pz*sin(angle), cy + y*sy, cz - px*sin(angle) + pz*cos(angle)))
        self.add(vertices, [(0,1,2,3),(4,7,6,5),(0,4,5,1),(1,5,6,2),(2,6,7,3),(4,0,3,7)], material)

    def prism(self, center, bottom, top, height, sides, material, angle=0.0):
        cx, cy, cz = center
        vertices = []
        for y, radius in ((cy-height/2, bottom), (cy+height/2, top)):
            for i in range(sides):
                a = angle + tau*i/sides
                vertices.append((cx + sin(a)*radius, y, cz + cos(a)*radius))
        faces = [tuple(range(sides-1, -1, -1)), tuple(range(sides, sides*2))]
        faces += [(i, (i+1)%sides, sides+(i+1)%sides, sides+i) for i in range(sides)]
        self.add(vertices, faces, material)

    def gem(self, center, scale, material, sides=8):
        cx, cy, cz = center; sx, sy, sz = scale
        vertices = [(cx, cy+sy, cz), (cx, cy-sy, cz)]
        vertices += [(cx+sin(tau*i/sides)*sx, cy, cz+cos(tau*i/sides)*sz) for i in range(sides)]
        faces = []
        for i in range(sides):
            n = (i+1) % sides
            faces += [(0, 2+i, 2+n), (1, 2+n, 2+i)]
        self.add(vertices, faces, material)

    def write(self):
        lines = ["mtllib combatants.mtl", f"o {self.name}"]
        lines += [f"v {x:.5f} {y:.5f} {z:.5f}" for x, y, z in self.vertices]
        for material, faces in self.groups:
            lines.append(f"usemtl {material}")
            lines += ["f " + " ".join(map(str, face)) for face in faces]
        (ROOT / f"{self.name}.obj").write_text("\n".join(lines) + "\n", encoding="utf-8")


def hover_base(o, armor, glow, wide=1.0):
    o.prism((0, .05, 0), 1.68*wide, 1.34*wide, .68, 12, "hull")
    o.prism((0, .43, -.08), 1.12*wide, .78*wide, .56, 10, armor)
    o.prism((0, .78, -.14), .66, .48, .52, 10, "glass")
    o.box((0, .16, 1.48), (1.75*wide, .35, .38), "bumper")
    for side in (-1, 1):
        o.box((side*1.24*wide, .18, -.38), (.42, .48, 1.25), armor)
        o.prism((side*.91*wide, -.37, -.67), .29, .20, .18, 8, glow)
        o.prism((side*.91*wide, -.37, .66), .29, .20, .18, 8, glow)
        o.box((side*.82*wide, .16, -1.32), (.48, .42, .42), "engine")
        o.gem((side*.82*wide, .14, -1.57), (.20, .17, .12), glow, 6)


def elephant(name, support=False):
    o = Obj(name); hover_base(o, "blue_support" if support else "blue_armor", "blue_glow", 1.06 if not support else .98)
    o.gem((0, 1.47, .06), (.58, .55, .53), "elephant", 10)
    for side in (-1, 1):
        o.gem((side*.57, 1.49, .01), (.34, .40, .13), "elephant_inner" if support else "elephant", 8)
        o.box((side*.42, 1.00, .58), (.20, .22, .66), "elephant", side*.22)
    o.prism((0, 1.20, .55), .16, .12, .82, 8, "elephant", 0.0)
    o.gem((-.20, 1.61, .52), (.055, .06, .035), "eye", 6); o.gem((.20, 1.61, .52), (.055, .06, .035), "eye", 6)
    if support:
        o.prism((0, .70, -1.50), .55, .32, .80, 8, "blue_glow")
        for side in (-1, 1): o.box((side*1.42, .55, .25), (.18, .72, .72), "blue_support")
    else:
        for x in (-.72, 0, .72): o.box((x, .18, 1.66), (.58, .48, .34), "bumper")
    o.write()


def monkey(name, brute=False):
    o = Obj(name); hover_base(o, "orange_heavy" if brute else "orange_armor", "orange_glow", 1.12 if brute else .94)
    o.gem((0, 1.48, .05), (.55, .55, .50), "monkey_fur", 10)
    o.gem((0, 1.42, .47), (.38, .31, .26), "monkey_face", 9)
    for side in (-1, 1):
        o.gem((side*.55, 1.49, .02), (.24, .30, .13), "monkey_fur", 8)
        o.gem((side*.18, 1.57, .69), (.05, .06, .035), "eye", 6)
    if brute:
        for side in (-1, 1):
            o.box((side*1.56, .46, .12), (.48, .76, 1.18), "orange_heavy")
            o.prism((side*1.56, .88, .12), .22, .04, .48, 6, "spike")
    else:
        for side in (-1, 1): o.box((side*1.14, .62, -.72), (.18, .18, 1.0), "orange_glow", side*.42)
    o.write()


def main():
    ROOT.mkdir(parents=True, exist_ok=True)
    (ROOT / "combatants.mtl").write_text("""newmtl hull
Kd 0.08 0.11 0.17
Ns 100
newmtl glass
Kd 0.08 0.18 0.31
Ke 0.02 0.09 0.19
Ns 160
newmtl bumper
Kd 0.08 0.09 0.12
newmtl engine
Kd 0.18 0.20 0.25
newmtl blue_armor
Kd 0.07 0.36 0.78
Ns 120
newmtl blue_support
Kd 0.05 0.60 0.78
Ns 120
newmtl blue_glow
Kd 0.20 0.82 1.0
Ke 0.10 0.52 0.82
newmtl orange_armor
Kd 0.90 0.28 0.05
Ns 110
newmtl orange_heavy
Kd 0.62 0.12 0.05
Ns 100
newmtl orange_glow
Kd 1.0 0.61 0.08
Ke 0.72 0.22 0.02
newmtl elephant
Kd 0.43 0.49 0.60
newmtl elephant_inner
Kd 0.34 0.65 0.72
newmtl monkey_fur
Kd 0.34 0.16 0.07
newmtl monkey_face
Kd 0.78 0.49 0.25
newmtl eye
Kd 0.01 0.015 0.025
newmtl spike
Kd 0.65 0.66 0.72
Ns 100
""", encoding="utf-8")
    elephant("elephant_vanguard")
    elephant("elephant_guardian", True)
    monkey("monkey_raider")
    monkey("monkey_brute", True)


if __name__ == "__main__":
    main()
