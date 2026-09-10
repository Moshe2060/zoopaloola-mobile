# Battle Gates prototype test plan

This branch starts at stable commit `ddfac5f`. It must not be merged or deployed
until every item below passes on Web and Android.

## Gameplay invariants

- The twenty-piece opening formation is unchanged.
- Turn switching and extra-turn scoring rules are unchanged.
- Ball radius, collisions, friction, rails, entry triggers, and hole centers are unchanged.
- Friend and online match payloads remain compatible with the stable client.
- No Battle Gates code or asset is present on `main` before approval.

## Visual checks

- The arena reads as a floating, premium 3D structure in landscape.
- All six gates are structural wall openings and stay fixed to their approved hole centers.
- Blue and purple energy cores remain easy to distinguish at phone size.
- The battle HUD never covers the board or a gate.
- Aim lines, ball hints, score state, and result dialogs remain readable.

## Effect checks

Trigger every gate independently and confirm that the captured core is removed exactly once:

1. Push — green outward impulse animation.
2. Gravity — purple orbit and collapse animation.
3. Electric — cyan lightning animation.
4. Bounce — gold repeated vertical bounce animation.
5. Ice — pale-blue crystal freeze animation.
6. Fire — orange flame burst animation.

## Required automated checks

- `npm test` in `server/`.
- Godot headless project import and scene parse.
- Web export completes.
- Android debug export completes.
- GitHub Actions pass on the prototype branch.

## Manual matrix

- Web: Chrome Android, Chrome desktop.
- Android APK: landscape launch, pause/resume, system Back, repeated matches.
- Modes: computer, friend room on two devices, online arena.
- Cases: own core scored, opponent core scored, extra turn, final core, rematch, exit mid-match.
