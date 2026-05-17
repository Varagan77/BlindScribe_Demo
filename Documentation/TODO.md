Refactor Everyyyything
Try not to cry


├───Art
│   ├───Animations
│   │   └───AniDice
│   │       ├───AniDiceEnemy
│   │       └───AniGoldEnemy
│   ├───Dungeon
│   │   ├───EnemySprite
│   │   ├───ExitSprite
│   │   ├───FloorSprite
│   │   ├───GoldSprite
│   │   ├───PortalInSprite
│   │   ├───PortalOutSprite
│   │   ├───ShopSprite
│   │   └───WallSprite
│   ├───Fonts
│   ├───HUD
│   │   ├───HUDDirArrows
│   │   ├───HUDDrawMap
│   │   ├───HUDGoldBar
│   │   ├───HUDHealthBar
│   │   ├───HUDItems
│   │   └───HUDWalkBar
│   ├───Particles
│   ├───Player
│   │   ├───Classes
│   │   │   ├───PlayerArcherSprite
│   │   │   ├───PlayerCommonerSprite
│   │   │   ├───PlayerKnightSprite
│   │   │   ├───PlayerMerchantSprite
│   │   │   └───PlayerWizardSprite
│   │   └───DungeonMaster
│   ├───Shaders
│   ├───Shop
│   │   └───ShopItems
│   │       ├───Equiptment
│   │       ├───Kinesis
│   │       ├───miscItems
│   │       ├───Spiritus
│   │       └───Wrath
│   ├───SpriteSheet
│   └───UI
│       ├───UIButtons
│       ├───UIGFX
│       ├───UIInventory
│       ├───UIShaders
│       ├───UISliders
│       └───UITitle
├───Audio
│   ├───Music
│   └───SFX
├───Code
│   ├───Managers
│   │   ├───AudioManager
│   │   ├───DungeonManager
│   │   ├───EventManager
│   │   ├───GameStateManager
│   │   ├───InputManager
│   │   ├───SaveManager
│   │   ├───SceneManager
│   │   ├───TileManager
│   │   ├───TurnManager
│   │   └───UIManager
│   └───Scripts
│       ├───ScriptMap
│       │   ├───MapEntities
│       │   │   ├───MapEnemy
│       │   │   ├───MapExit
│       │   │   ├───MapFloor
│       │   │   ├───MapGold
│       │   │   ├───MapPortalIn
│       │   │   ├───MapPortalOut
│       │   │   ├───MapShop
│       │   │   └───MapWall
│       │   └───MapGeneration
│       │       └───MazeGenerator
│       ├───ScriptPlayer
│       │   ├───PlayerCamera
│       │   ├───PlayerEnemyEvent
│       │   ├───PlayerFog
│       │   ├───PlayerGoldPickupEvent
│       │   ├───PlayerHUD
│       │   ├───PlayerInventory
│       │   ├───PlayerMovement 
│       │   ├───PlayerPosition
│       │   ├───PlayerShopEvent
│       │   ├───PlayerTotalGold
│       │   ├───PlayerTotalHealth
│       │   ├───PlayerTotalSteps
│       │   └───PlayerUI
│       ├───ScriptStates
│       │   ├───ScriptDice
│       │   ├───ScriptHints
│       │   ├───ScriptStartGame
│       │   ├───StateAbout
│       │   ├───StateDebug
│       │   ├───StateExit
│       │   ├───StateLoseGame
│       │   ├───StateMenu
│       │   ├───StateMultiPlayer
│       │   ├───StateSettings
│       │   ├───StateSinglePlayer
│       │   └───StateWinGame
│       └───ScriptWIP
├───Documentation
├───Prefabs
│   ├───Config
│   └───ThirdParty
│       ├───enet
│       ├───hump
│       ├───inspect
│       ├───json
│       └───lume
└───Scenes
    ├───SceneDice
    │   ├───EnemyDice
    │   └───GoldDice
    ├───SceneLoseGame
    ├───SceneMenus
    │   └───MainMenu
    │       ├───About
    │       ├───Exit
    │       ├───Help
    │       ├───MultiPlayer
    │       ├───Options
    │       └───SinglePlayer
    ├───SceneShop
    ├───SceneStartGame
    ├───SceneStartupGame
    └───SceneWinGame

PHASE 1 – SAFE CLEANUP (no gameplay changes)

Centralize all config usage through Config.map, Config.player, Config.keys
Remove all hardcoded values like 32, speeds, tile IDs from logic files
Reduce reliance on hidden globals (map, spawnX, spawnY, player)
Begin grouping shared state into a single structure (optional Game table, not required yet)
Standardize naming conventions across files (grid_x vs gridX, etc.)
Document which system owns which responsibility (no code movement yet)

PHASE 2 – SYSTEM SEPARATION

Split player.lua into separate responsibilities
PlayerState (hp, gold, stats)
MovementSystem (grid/act position interpolation)
PlayerRenderer (drawing only)
Extract movement logic into a reusable MovementSystem
Remove movement logic from gameplay files after extraction is verified
Replace direct map access (map[y][x]) with helper functions
Dungeon:isWalkable(x, y)
Dungeon:getTile(x, y)
Dungeon:setTile(x, y, value)

PHASE 3 – DUNGEON UNIFICATION

Create a single dungeon.lua as authoritative map system
Move map.lua generation logic into dungeon system
Merge grid.lua responsibilities into dungeon.lua or remove grid.lua entirely
Ensure only dungeon.lua owns map state, spawn position, and generation log
Remove duplicate map handling across multiple files

PHASE 4 – INPUT AND FLOW CONSOLIDATION

Centralize all input handling into InputManager
Remove direct input logic from player, camera, HUD, DM files
Route all keypresses through InputManager
Standardize game flow initialization into a single Game load sequence
Replace multiple load calls with a single orchestrator call (Game:load or equivalent)

PHASE 5 – STATE AND SCENE CONSOLIDATION

Decide between Scene system or State system and reduce overlap
Merge duplicated responsibilities between SceneManager and GameStateManager if needed
Simplify startup and reset flow into a single controlled entry point
Remove redundant scene/state switching logic duplication

PHASE 6 – ENGINE STRUCTURE REFACTOR

Introduce a central Game table as the single runtime container
Organize code into systems with clear responsibilities
MovementSystem
RenderSystem
CombatSystem
FogSystem
InputSystem
Move logic out of entity files into systems where appropriate
Reduce cross-file direct dependencies between gameplay modules
Ensure systems operate on passed-in state rather than globals

PHASE 7 – TOOLING AND DEBUG INFRASTRUCTURE

Add debug overlay system for runtime inspection
Add tile inspection (player position, tile type, collision state)
Add movement debugging (interpolation, grid alignment)
Add hot reload for config and optionally game systems
Add toggles for visual debugging layers (grid, fog, collisions)

FINAL STATE GOAL

All systems are modular and independent
Dungeon system is single source of truth for map data
Player is split into state, movement, and rendering
Input is fully centralized
No duplicate map or player logic exists
Globals are minimized or fully removed
Game can be reset or rebuilt from one entry poin