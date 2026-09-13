#!/usr/bin/env python3
"""Generate the first lightweight ZOOVORTEX environment OBJ kit."""

from pathlib import Path
from math import cos, sin, tau
import random

ROOT = Path(__file__).resolve().parents[1] / "prototype3d" / "models" / "environment"


class Obj:
    def __init__(self, name):
        self.name = name
        self.vertices = []
        self.groups = []

    def add(self, vertices, faces, material):
        start = len(self.vertices) + 1
        self.vertices.extend(vertices)
        self.groups.append((material, [[start + i for i in face] for face in faces]))

    def box(self, center, size, material, angle=0.0):
        cx, cy, cz = center
        sx, sy, sz = (v / 2 for v in size)
        v = []
        for x,y,z in [(-1,-1,-1),(1,-1,-1),(1,1,-1),(-1,1,-1),(-1,-1,1),(1,-1,1),(1,1,1),(-1,1,1)]:
            px, pz = x*sx, z*sz
            v.append((cx + px*cos(angle) + pz*sin(angle), cy+y*sy, cz - px*sin(angle) + pz*cos(angle)))
        f = [(0,1,2,3),(4,7,6,5),(0,4,5,1),(1,5,6,2),(2,6,7,3),(4,0,3,7)]
        self.add(v, f, material)

    def prism(self, center, bottom_radius, top_radius, height, sides, material, angle=0.0):
        cx, cy, cz = center
        v = []
        for y, radius in ((cy-height/2, bottom_radius), (cy+height/2, top_radius)):
            for i in range(sides):
                a = angle + tau * i / sides
                v.append((cx + sin(a)*radius, y, cz + cos(a)*radius))
        f = [tuple(range(sides-1, -1, -1)), tuple(range(sides, sides*2))]
        for i in range(sides):
            n = (i + 1) % sides
            f.append((i, n, sides+n, sides+i))
        self.add(v, f, material)

    def gem(self, center, scale, material, sides=7):
        cx, cy, cz = center
        sx, sy, sz = scale
        v = [(cx, cy+sy, cz), (cx, cy-sy, cz)]
        for i in range(sides):
            a = tau * i / sides
            v.append((cx + sin(a)*sx, cy, cz + cos(a)*sz))
        f = []
        for i in range(sides):
            n = (i + 1) % sides
            f.extend([(0, 2+i, 2+n), (1, 2+n, 2+i)])
        self.add(v, f, material)

    def write(self):
        lines = [f"mtllib environment.mtl", f"o {self.name}"]
        lines += [f"v {x:.5f} {y:.5f} {z:.5f}" for x,y,z in self.vertices]
        for material, faces in self.groups:
            lines.append(f"usemtl {material}")
            lines += ["f " + " ".join(map(str, face)) for face in faces]
        (ROOT / f"{self.name}.obj").write_text("\n".join(lines) + "\n", encoding="utf-8")


def rock():
    o = Obj("rock_cover")
    rng = random.Random(7)
    for center, radius, height, sides in [((0,1.8,0),3.7,3.6,7),((3.0,2.4,1.2),2.5,4.8,6),((-2.8,1.7,-1.0),2.2,3.4,7)]:
        o.prism(center, radius, radius*rng.uniform(.58,.76), height, sides, "rock", rng.random())
    o.gem((1.0,4.65,.5),(.65,.8,.65),"crystal",6)
    o.write()


def tree():
    o = Obj("jungle_tree")
    o.prism((0,2.5,0),.72,.5,5.0,7,"wood",.2)
    o.prism((0,5.15,0),1.0,.55,2.1,6,"wood",.5)
    for c,s,m in [((0,6.6,0),(3.3,2.2,3.0),"leaf_dark"),((2.2,6.1,.7),(2.3,1.7,2.1),"leaf"),((-2.0,6.2,-.5),(2.5,1.8,2.2),"leaf"),((.3,8.0,-.2),(2.2,1.5,2.0),"leaf_light")]:
        o.gem(c,s,m,8)
    o.write()


def ruin():
    o = Obj("ruin_wall")
    o.box((-4.4,2.6,0),(2.0,5.2,2.5),"temple")
    o.box((4.4,1.9,0),(2.0,3.8,2.5),"temple")
    o.box((-1.7,1.45,0),(3.4,2.9,2.1),"stone")
    o.box((1.6,.9,0),(3.2,1.8,2.1),"stone")
    o.box((-1.0,4.75,0),(5.0,.65,2.7),"temple_light")
    o.prism((-4.4,5.55,0),1.45,.8,1.0,6,"temple_light")
    o.box((2.8,2.25,-1.2),(.35,3.6,.25),"vine")
    o.write()


def tower(name, energy_material):
    o = Obj(name)
    o.prism((0,1.3,0),6.8,5.9,2.6,10,"metal_dark")
    o.prism((0,6.0,0),4.6,4.0,7.0,10,"tower")
    o.prism((0,9.8,0),5.5,5.5,.7,10,"metal")
    o.prism((0,12.0,0),2.1,1.45,4.0,8,energy_material)
    for i in range(4):
        a = tau*i/4
        x,z = sin(a)*4.35, cos(a)*4.35
        o.box((x,6.0,z),(1.0,6.2,1.0),energy_material)
    o.write()


def spike_trap():
    o = Obj("spike_trap")
    o.prism((0,.08,0),8.0,8.0,.16,16,"spike_base")
    for ring in range(3):
        radius = 2.0 + ring * 2.15
        count = 6 + ring * 4
        for i in range(count):
            a = tau*i/count + ring*.28
            o.prism((sin(a)*radius,.72,cos(a)*radius),.42,.035,1.45,6,"spike",a)
    o.write()


def gravity_core():
    o = Obj("gravity_core")
    o.prism((0,.12,0),7.2,7.2,.24,16,"gravity_dark")
    o.prism((0,.27,0),5.7,5.7,.16,16,"gravity")
    o.prism((0,.42,0),3.9,3.9,.18,14,"gravity_dark")
    o.prism((0,.72,0),1.5,.8,1.1,10,"gravity")
    for i in range(8):
        a=tau*i/8
        o.gem((sin(a)*5.9,.65,cos(a)*5.9),(.35,.55,.35),"gravity",6)
    o.write()


def laser_reactor():
    o = Obj("laser_reactor")
    o.prism((0,.45,0),2.2,1.75,.9,10,"metal_dark")
    o.prism((0,1.15,0),1.55,1.15,.8,8,"metal")
    o.gem((0,1.9,0),(.62,.75,.62),"laser",8)
    for i in range(4):
        a=tau*i/4
        o.box((sin(a)*1.6,.7,cos(a)*1.6),(.45,.65,1.1),"laser")
    o.write()


def spinner_hub():
    o = Obj("spinner_hub")
    o.prism((0,.2,0),2.3,2.0,.4,10,"metal_dark")
    o.prism((0,.75,0),1.45,1.05,1.1,8,"laser")
    for i in range(3):
        a=tau*i/3
        x,z=sin(a)*4.5,cos(a)*4.5
        o.box((x,.75,z),(1.05,.72,7.2),"spinner",a)
    o.write()


def main():
    ROOT.mkdir(parents=True, exist_ok=True)
    (ROOT / "environment.mtl").write_text("""newmtl rock
Kd 0.24 0.29 0.32
Ns 20
newmtl crystal
Kd 0.22 0.82 1.0
Ke 0.12 0.48 0.72
newmtl wood
Kd 0.34 0.20 0.11
newmtl leaf_dark
Kd 0.06 0.35 0.20
newmtl leaf
Kd 0.10 0.55 0.28
newmtl leaf_light
Kd 0.27 0.68 0.32
newmtl temple
Kd 0.34 0.31 0.39
newmtl stone
Kd 0.25 0.29 0.34
newmtl temple_light
Kd 0.48 0.43 0.55
newmtl vine
Kd 0.12 0.48 0.23
newmtl metal_dark
Kd 0.10 0.12 0.18
Ns 80
newmtl metal
Kd 0.28 0.32 0.40
Ns 100
newmtl tower
Kd 0.17 0.20 0.28
Ns 70
newmtl energy
Kd 0.18 0.72 1.0
Ke 0.08 0.38 0.75
Ns 120
newmtl energy_orange
Kd 1.0 0.30 0.08
Ke 0.72 0.12 0.02
Ns 120
newmtl spike_base
Kd 0.28 0.04 0.11
Ke 0.30 0.01 0.06
newmtl spike
Kd 0.72 0.06 0.18
Ke 0.35 0.02 0.09
Ns 90
newmtl gravity_dark
Kd 0.10 0.04 0.22
Ke 0.08 0.01 0.18
newmtl gravity
Kd 0.55 0.10 0.95
Ke 0.32 0.03 0.72
Ns 110
newmtl laser
Kd 1.0 0.10 0.08
Ke 0.80 0.02 0.02
Ns 140
newmtl spinner
Kd 0.38 0.20 0.48
Ke 0.62 0.18 0.03
Ns 80
""", encoding="utf-8")
    rock(); tree(); ruin(); tower("team_tower_blue", "energy"); tower("team_tower_orange", "energy_orange")
    spike_trap(); gravity_core(); laser_reactor(); spinner_hub()


if __name__ == "__main__":
    main()
