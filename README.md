# BlindScribe

A procedurally generated dungeon crawler built in [LÖVE2D](https://love2d.org/).

One player is the **Dungeon Master** — they can see the map. The others are **Pawns** — they can't. With a limited number of moves, Pawns must escape the dungeon alive, guided (or misled) by the DM.

---

## Running

1. Install [LÖVE2D](https://love2d.org/) 11.x
2. Clone this repo
3. Run from the project root:

```bash
love .
```

---

## Project Structure

```
BlindScribe/
├── main.lua              entry point, routes Love2D callbacks to systems
├── conf.lua              window title, size, version
│
├── config/
│   └── settings.lua      all tunable values in one place
│
├── src/
│   ├── camera.lua        smooth lerp camera, F1 to toggle
│   ├── fog.lua           fog of war, F2 to toggle
│   ├── grid.lua          map renderer, generation animation, tile collision
│   ├── hud.lua           all UI — top bar, stats panel, inventory, debug overlay
│   ├── map.lua           procedural dungeon generation (pure module, no globals)
│   ├── menu.lua          main menu and game state management
│   └── player.lua        movement, tile interactions, dice cutscene
│
└── assets/
    ├── fonts/
    ├── sounds/
    └── sprites/
```

---

## Configuration

Everything tunable lives in `config/settings.lua` — no hunting through source files.

| Key | Default | What it does |
|-----|---------|--------------|
| `TILE_SIZE` | 32 | Pixel size of each tile |
| `PLAYER_SPEED` | 10 | Visual lerp speed |
| `PLAYER_HP` | 10 | Starting HP |
| `CAMERA_SPEED` | 6 | Camera follow speed |
| `CAMERA_ON` | true | Camera enabled at start |
| `FOG_ON` | true | Fog enabled at start |
| `LOG_DURATION` | 4.0 | Seconds HUD messages stay on screen |
| `MAP_WIDTH` | 15 | Dungeon width in tiles |
| `MAP_HEIGHT` | 15 | Dungeon height in tiles |
| `ENEMY_MIN/MAX` | 3–8 | Enemy count range |
| `GOLD_MIN/MAX` | 3–8 | Gold pile count range |
| `ROOM_MIN/MAX` | 3–6 | Number of carved rooms |
| `SHOP_COUNT` | 2 | Number of shop tiles |
| `DEBUG_VISIBLE` | true | Debug overlay on at start |
| `DEBUG_ANIM_SPEED` | 0.04 | Generation animation step rate |

---

## Controls

| Key | Action |
|-----|--------|
| Arrow keys | Move |
| ESC | Return to menu |
| F1 | Toggle camera |
| F2 | Toggle fog of war |
| F3 | Toggle debug overlay |
| ENTER | Confirm |

---

## Tile Values

| Value | Tile |
|-------|------|
| 0 | Empty |
| 1 | Wall |
| 2 | Shop |
| 3 | Enemy |
| 4 | Portal in |
| 5 | Portal out |
| 6 | Exit |
| 7 | Gold |

---

## Roadmap

- [ ] Multiplayer / Dungeon Master mode
- [ ] Shop system — Wrath, Spiritus, Kinesis items
- [ ] Inventory logic (slots are in the HUD)
- [ ] Pawn-to-Pawn trading on shared tiles
- [ ] DM abilities — Pawn Swap, Tile Swap, Inflation, Mutation
- [ ] Sound and music
- [ ] Custom dungeon editor
