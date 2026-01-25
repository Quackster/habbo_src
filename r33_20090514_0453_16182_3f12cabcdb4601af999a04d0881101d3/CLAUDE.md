# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is decompiled source code from the Habbo Hotel Shockwave client (release 33, dated May 2009). The code is written in **Lingo** (Macromedia/Adobe Director's scripting language) and was decompiled from DCR (Director Cast Resource) files using [ProjectorRays](https://github.com/ProjectorRays/ProjectorRays).

This is a historical archive of client-side game code - there are no build systems, tests, or development tooling.

## File Naming Convention

All source files follow the pattern:
```
Cast [Internal|External] [ScriptType] [Number] - [Name].ls
```

Script types:
- **MovieScript**: Global scripts that run at movie level (initialization, APIs)
- **ParentScript**: Class definitions (instantiable objects with `new()`)
- **BehaviorScript**: Scripts attached to sprites/frames for event handling

## Architecture

### Core Client (fuse_client/)

The Fuse client framework provides the base architecture. Key manager classes:

| Manager | Purpose |
|---------|---------|
| Object Manager | Central object lifecycle management, update/prepare loops |
| Thread Manager | Manages "threads" (logical modules that can be loaded/unloaded) |
| Connection Manager | Socket connections to game server |
| Resource Manager | Cast/member lookup and caching |
| Window Manager | UI window creation and management |
| Visualizer Manager | 2D sprite/visual composition |
| Broker Manager | Event/message pub-sub system |

### Module Structure (hh_* directories)

Each `hh_*` directory is a self-contained module following the Interface-Component-Handler pattern:

- **Interface Class**: UI/visual presentation layer
- **Component Class**: Business logic and state management
- **Handler Class**: Server message parsing and protocol handling

Key modules:
- `hh_entry`: Login and hotel entry screens
- `hh_room`: Room rendering, object placement, user interactions
- `hh_room_private`: Private room-specific logic
- `hh_human`: Avatar/figure rendering and animation
- `hh_navigator`: Room navigation and listing
- `hh_messenger`/`hh_instant_messenger`: Chat and friend systems
- `hh_furni_classes`: Furniture object behaviors
- `hh_cat_code`/`hh_cat_new`: Catalogue/shop functionality
- `hh_club`: Habbo Club membership features
- `hh_ig`/`hh_ig_gamesys`: In-game games framework

### Localization Modules

`hh_entry_*` directories contain locale-specific entry screens (es, fr, it, jp, nl, etc.)

`hh_patch_*` directories contain region-specific patches (br, cn, jp, ru)

### Room Types

`hh_room_*` directories define specific public room types (lobby, pool, disco, park, etc.)

## Key Patterns

### Object Creation
```lingo
createObject(objectID, "Class Name")
getObject(objectID).methodCall()
removeObject(objectID)
```

### Message/Event System
```lingo
registerMessage(#messageType, receiverID, #handlerMethod)
executeMessage(#messageType, data)
unregisterMessage(#messageType, receiverID)
```

### Thread/Module Loading
```lingo
getThread(#threadName).getInterface()
getThread(#threadName).getComponent()
```

### Server Communication
```lingo
getConnection(connectionID).send("MESSAGE_TYPE", [parameters])
```

## Global Objects

- `#session`: User session data (user_name, user_index, room data, permissions)
- `#layout_parser`: Parses room layout definitions
- Core managers accessed via `getObject(#manager_name)` or dedicated functions like `getWindow()`, `getVisualizer()`

---

## Browser Port Project (habbo-web-client/)

A modern browser port is being developed in the `habbo-web-client/` directory using:
- **TypeScript** for browser APIs (DOM, Canvas, WebSocket, Audio)
- **AssemblyScript → WASM** for performance-critical code (geometry, pathfinding)

### Current Task

**TASK**: Port the complete Habbo Shockwave client to a modern browser runtime. This includes:
1. All fuse_client core systems (managers, UI, networking)
2. All hh_* modules (room, navigator, messenger, catalogue, etc.)
3. Avatar/figure rendering system from hh_human
4. Asset loading from extracted DCR files
5. Create a runnable HTML player

### What I Know

**Source Code Structure:**
- Original client is written in Lingo (Director scripting language)
- ~70+ DCR files containing cast members, scripts, and assets
- Follows Interface-Component-Handler pattern for modules
- Uses isometric coordinate system for room rendering
- Server protocol uses binary messages with specific IDs

**Key Technical Details:**
- Isometric transformation: `screenX = (x - y) * 32 + offset`, `screenY = (x + y) * 16 + offset`
- Height map encoding: 'x' = blocked, 'y' = door, '0'-'9' = heights, 'A'-'H' = high elevations
- TILE_BLOCKED = 200000, TILE_DOOR = 100000
- Avatar figure format: `hd-180-1.ch-255-92.lg-285-82` (type-setId-colorId)
- Message format: 4-byte length + 2-byte message ID + payload

### What Has Been Completed

**Phase 0: Core Infrastructure - COMPLETE**
- [x] Project configuration (package.json, tsconfig.json, asconfig.json, vite.config.ts)
- [x] Core TypeScript modules (ObjectManager, MessageBus, MainLoop, TimeoutManager)
- [x] Base classes (BaseObject, Session, VariableContainer)
- [x] Manager classes (ThreadManager, ConnectionManager, ResourceManager)
- [x] Network layer (HabboConnection, Protocol encoding/decoding, RC4Cipher)
- [x] AssemblyScript WASM modules (isometric.ts, roomGeometry.ts, astar.ts)
- [x] WASM loader with JavaScript fallbacks
- [x] Entry module port (EntryComponent, LoginHandler)
- [x] HTML entry point (index.html with loading screen)
- [x] Public assets (gamedata config files)

**Phase 1: UI System - COMPLETE**
- [x] Window Manager (z-ordering, activation, modal support)
- [x] Window Instance (sprites, elements, drag/scale behavior)
- [x] Layout Parser (text-based layout definitions)
- [x] Visualizer Manager (room visualization system)
- [x] Sprite Manager (canvas-based sprite management)
- [x] Element classes (BaseElement, UniqueElement, WrapperElement)
- [x] Asset Loader (DCR-style resource loading)
- [x] ResourceManager integration with AssetLoader

**Phase 2: Room Module - COMPLETE**
- [x] Room types (RoomType, Direction, RoomLocation, ScreenCoordinate)
- [x] Room Geometry (coordinate transformation, height map parsing)
- [x] Room Objects (ActiveObject, PassiveObject, ItemObject, UserObject)
- [x] Room Component (object management, status updates, trading)
- [x] Room Interface (rendering, interaction, hiliter, object mover)
- [x] Room Handler (server message handling)

**Phase 3: Navigator Module - COMPLETE**
- [x] Navigator types (NavNode, FlatInfo, FavoriteRoom)
- [x] Navigator Component (node caching, favorites, search)
- [x] Navigator Handler (message handling, room navigation)

**Phase 4: Messenger Module - COMPLETE**
- [x] Messenger types (BuddyData, FriendRequest, MessageData)
- [x] Messenger Component (buddy list, messages, requests)
- [x] Messenger Handler (all message types)

**Phase 5: Catalogue Module - COMPLETE**
- [x] Catalogue types (CatalogueProduct, CataloguePage, GiftProps)
- [x] Catalogue Component (index, pages, product ordering)
- [x] Catalogue Handler (purchase handling, page loading)

**Phase 6: Purse Module - COMPLETE**
- [x] Purse types (Transaction, VoucherResult)
- [x] Purse Component (credits, tickets, transactions)
- [x] Purse Handler (voucher redemption)

**Phase 7: Avatar/Figure System - COMPLETE**
- [x] Avatar types (FigurePart, ParsedFigure, AnimationDefinition)
- [x] Figure Data (XML parsing, colors, sets, parts)
- [x] Figure System (figure parsing, draw orders, animations)
- [x] Avatar Renderer (canvas rendering, sprite sheets, color tinting)

**Phase 8: Runnable Player - COMPLETE**
- [x] HTML player with loading screen
- [x] Game canvas with isometric grid rendering
- [x] Connection UI (server host/port)
- [x] Chat system
- [x] Navigator room list

### What Needs To Be Done Next

**Phase 9: Asset Pipeline**
- [ ] DCR extraction tool integration
- [ ] Sprite sheet generator from extracted assets
- [ ] Manifest generation for asset loading
- [ ] Audio conversion pipeline (WAV → MP3/OGG)

**Phase 10: Additional Modules**
- [ ] hh_friend_list module
- [ ] hh_club (Habbo Club features)
- [ ] hh_photo (camera/photos)
- [ ] hh_soundmachine (Trax/music)
- [ ] hh_pets_common
- [ ] hh_recycler (Ecotron)
- [ ] hh_roomdimmer

**Phase 11: Server Integration**
- [ ] Full protocol implementation
- [ ] WebSocket to TCP proxy (for connecting to real servers)
- [ ] Local mock server for testing

**Phase 12: Polish**
- [ ] Sound effects and music
- [ ] Full animation support
- [ ] Performance optimization
- [ ] Mobile/touch support

### How Assets Are Loaded From Director Port

The original Director client loads assets from DCR (Director Cast Resource) files. For the web port:

1. **DCR Extraction**: Use ProjectorRays or similar tools to extract cast members:
   ```
   DCR → Bitmaps (.png), Sounds (.wav), Scripts (.ls), Data
   ```

2. **Asset Conversion**:
   - **Images**: Convert to PNG, create sprite sheets
   - **Sounds**: Convert WAV → MP3/OGG
   - **Data**: Convert to JSON manifests

3. **Manifest Format** (`assets/manifest.json`):
   ```json
   {
     "hh_human": {
       "sheets": ["hh_human_body.png", "hh_human_face.png"],
       "frames": {
         "h_std_bd_1_2_0": {"x": 0, "y": 0, "w": 64, "h": 110, "regX": 32, "regY": 100}
       }
     }
   }
   ```

4. **Asset Loading** (AssetLoader.ts):
   ```typescript
   const assetLoader = new AssetLoader('/assets/');
   await assetLoader.loadManifest('manifest.json');
   const sprite = assetLoader.getFrame('hh_human', 'h_std_bd_1_2_0');
   ```

5. **Directory Structure**:
   ```
   habbo-web-client/
   └── public/
       └── assets/
           ├── manifest.json
           ├── hh_human/
           │   ├── hh_human.json (sprite sheet manifest)
           │   └── hh_human.png (sprite sheet image)
           ├── hh_room/
           ├── hh_furni/
           └── sounds/
   ```

---

## Port Status Summary

| Module | Status | Location |
|--------|--------|----------|
| Core Infrastructure | ✅ Complete | `src/core/` |
| UI System | ✅ Complete | `src/ui/` |
| Room Module | ✅ Complete | `src/modules/room/` |
| Navigator Module | ✅ Complete | `src/modules/navigator/` |
| Messenger Module | ✅ Complete | `src/modules/messenger/` |
| Catalogue Module | ✅ Complete | `src/modules/catalogue/` |
| Purse Module | ✅ Complete | `src/modules/purse/` |
| Avatar System | ✅ Complete | `src/avatar/` |
| HTML Player | ✅ Complete | `public/index.html` |
| Asset Pipeline | 🔲 Pending | - |
| Server Integration | 🔲 Pending | - |

---

## Development Commands

```bash
cd habbo-web-client
npm install          # Install dependencies
npm run dev          # Start Vite dev server (http://localhost:3000)
npm run build        # Build for production (WASM + TypeScript)
npm run build:wasm   # Compile AssemblyScript to WASM only
npm run typecheck    # Run TypeScript type checking
npm run test         # Run tests with Vitest
npm run clean        # Remove build artifacts
```

## Project Structure (habbo-web-client/)

```
habbo-web-client/
├── assembly/              # AssemblyScript (compiles to WASM)
│   ├── geometry/          # Isometric math, room height maps
│   │   ├── isometric.ts
│   │   └── roomGeometry.ts
│   ├── pathfinding/       # A* algorithm
│   │   └── astar.ts
│   └── index.ts           # WASM entry point
├── public/
│   ├── index.html         # Runnable HTML player
│   ├── wasm/              # Compiled WASM output
│   ├── assets/            # Extracted DCR assets (images, sounds)
│   └── gamedata/          # External configuration files
├── src/
│   ├── core/              # Fuse client core systems
│   │   ├── ObjectManager.ts
│   │   ├── MessageBus.ts
│   │   ├── MainLoop.ts
│   │   ├── BaseObject.ts
│   │   ├── Session.ts
│   │   └── VariableContainer.ts
│   ├── managers/          # Manager classes
│   │   ├── ThreadManager.ts
│   │   ├── ConnectionManager.ts
│   │   └── ResourceManager.ts
│   ├── network/           # Network layer
│   │   ├── HabboConnection.ts
│   │   └── RC4Cipher.ts
│   ├── ui/                # UI system
│   │   ├── types.ts
│   │   ├── SpriteManager.ts
│   │   ├── LayoutParser.ts
│   │   ├── WindowManager.ts
│   │   ├── WindowInstance.ts
│   │   ├── VisualizerManager.ts
│   │   └── elements/
│   ├── assets/            # Asset loading
│   │   └── AssetLoader.ts
│   ├── avatar/            # Avatar/figure system
│   │   ├── types.ts
│   │   ├── FigureData.ts
│   │   ├── FigureSystem.ts
│   │   └── AvatarRenderer.ts
│   ├── modules/           # Ported hh_* modules
│   │   ├── room/          # Room system
│   │   ├── navigator/     # Room navigation
│   │   ├── messenger/     # Friends/messaging
│   │   ├── catalogue/     # Shop
│   │   ├── purse/         # Wallet
│   │   └── entry/         # Login
│   ├── wasm/              # WASM loader
│   ├── types.ts           # Global type definitions
│   └── index.ts           # Main entry point
├── package.json
├── tsconfig.json
├── asconfig.json
└── vite.config.ts
```

## Key Lingo → TypeScript Mappings

| Lingo | TypeScript |
|-------|------------|
| `property pVar` | `private var: Type` |
| `on construct me` | `construct(): void` |
| `me.method()` | `this.method()` |
| `#symbol` | `"symbol"` (string literal) |
| `[#key: value]` | `{ key: value }` or `Map` |
| `VOID` | `undefined` |
| `voidp(x)` | `x === undefined` |
| `createObject(#id, "Class")` | `objectManager.create("id", Class)` |
| `registerMessage(#msg, id, #handler)` | `messageBus.register("msg", id, handler)` |
| `the milliSeconds` | `performance.now()` |

## Protocol Message IDs

**Room Messages (hh_room):**
- 28: USERS (user list)
- 29: LOGOUT (user left)
- 30: OBJECTS (furniture list)
- 31: HEIGHTMAP
- 32: ACTIVEOBJECTS (floor items)
- 33: ITEMS (wall items)
- 34: STATUS (position updates)
- 24: CHAT
- 25: SHOUT
- 26: WHISPER

**Navigator Messages (hh_navigator):**
- 220: NAVNODEINFO
- 54: FLATINFO
- 221: USERFLATCATS
- 55: FLAT_RESULTS

**Messenger Messages (hh_messenger):**
- 12: MESSENGER_INIT
- 263: BUDDYLIST
- 137: ADD_BUDDY
- 138: REMOVE_BUDDY
- 313: MESSENGER_MESSAGES

**Catalogue Messages (hh_cat_code):**
- 126: CATALOG_INDEX
- 127: CATALOG_PAGE
- 67: PURCHASE_OK
- 65: PURCHASE_ERROR

## Key Source Files to Reference

**Core Managers (fuse_client/):**
- `ParentScript 27 - Object Manager Class.ls`
- `ParentScript 29 - Thread Manager Class.ls`
- `ParentScript 30 - Resource Manager Class.ls`
- `ParentScript 33 - Connection Manager Class.ls`

**UI System (fuse_client/):**
- `ParentScript 38 - Visualizer Manager Class.ls`
- `ParentScript 39 - Window Manager Class.ls`
- `ParentScript 53 - Layout Parser Class.ls`
- `ParentScript 54 - Visualizer Instance Class.ls`
- `ParentScript 55 - Window Instance Class.ls`

**Room Module (hh_room/):**
- `ParentScript 3-8` - Room classes

**Human Module (hh_human/):**
- `ParentScript 2 - Human Class EX.ls`
- `ParentScript 11 - Figure System Class.ls`
- `ParentScript 9 - Figure Data Class.ls`
