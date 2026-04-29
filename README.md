# BlindScribe_Demo
The offical demo for Blind Scribe!

# BlindScribe

A procedurally generated dungeon crawler built in [LÖVE2D](https://love2d.org/) (Lua).

One player acts as the **Dungeon Master** they can see the map. The others are **Pawns** they can't. With a limited number of moves, the Pawns must escape the dungeon alive, guided (or misled) by the DM.

---

## Gameplay

- **Pawns** are placed randomly in a procedurally generated dungeon
- Movement is tile-based (up / down / left / right)
- The map is hidden behind fog of war — tiles reveal as you step on them
- Escape through the **Exit** tile before your moves run out

### Tile Types

| Tile | Effect |
|------|--------|
| Empty | Safe to walk through |
| Wall | Impassable |
| Monster | Roll a d6 — lose that many HP |
| Loot | Roll a d6 — gain that many gold |
| Shop | Visit to purchase items |
| Portal (in/out) | Teleports the pawn to the linked portal |
| Exit | Escape the dungeon — you win |

### Items (planned)

Items are split into three categories, purchasable at Shop tiles:

- **Wrath** — spawn temporary Monster tiles in the dungeon
- **Spiritus** — heal your own or other Pawns' HP
- **Kinesis** — add movement points to yourself or other Pawns

---

## Controls

| Key | Action |
|-----|--------|
| Arrow keys | Move |
| ESC | Return to menu |
| F1 | Toggle camera follow |
| F2 | Toggle fog of war |
| F3 | Toggle debug overlay |
| ENTER | Confirm (menus / win screen) |

---

## Running the Game

1. Install [LÖVE2D](https://love2d.org/) (tested on 11.x)
2. Clone this repo
3. Run from the project root:

```bash
love .
```

Or drag the project folder onto the LÖVE executable.

---

## Project Structure

```
BlindScribe/
├── main.lua        # Entry point — wires up all systems
├── menu.lua        # Main menu and game state management
├── map.lua         # Procedural dungeon generation (recursive backtracker + rooms)
├── grid.lua        # Map rendering and tile collision
├── player.lua      # Player movement, tile interaction, dice cutscene
├── camera.lua      # Smooth camera follow with lerp
├── fog.lua         # Fog of war — tiles reveal on visit
├── hud.lua         # UI layout: top bar, stats panel, inventory, debug overlay
└── assets/         # Sprites, fonts, sounds (WIP)
```

---

## How the Dungeon Generates

1. A grid is filled with walls
2. A **recursive backtracker** carves a perfect maze from a starting cell
3. Random **rooms** are punched in to open up the space
4. Special tiles (exit, portals, shops, enemies, gold) are placed on valid empty cells
5. The player spawns on a remaining empty cell

The generation is animated on load — you can watch the maze carve itself.

---

## Roadmap

- [ ] Multiplayer / Dungeon Master mode
- [ ] Full shop system with Wrath / Spiritus / Kinesis items
- [ ] Inventory system (slots are in the HUD, logic TBD)
- [ ] Pawn-to-Pawn trading on shared empty tiles
- [ ] DM abilities (Pawn Swap, Tile Swap, Inflation, Mutation)
- [ ] Sound effects and music
- [ ] Custom dungeon editor

---

## Built With

- [LÖVE2D](https://love2d.org/) — Lua game framework
- Pure Lua — no external libraries

---

## License

WIP — license TBD.