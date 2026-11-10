# OpenHub

A small Roblox script hub I've been putting together. Everything loads straight from this repo, so pushing a change here updates it for anyone using the loader. No packing or obfuscation, just a handful of Lua files you can read through.

## Loader

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/nilo23475/OpenHub/main/loader.lua"))()
```

Paste that into your executor and the menu shows up in the middle of the screen. Drag it by the title bar, close it with the X. You'll need `loadstring` and `HttpGet`, which most executors have.

## Tabs

### Main
- Fullbright: bumps the lighting and kills the fog. Turning it off restores the old values.
- Teleport to Mouse: click anywhere and your character moves there. It doesn't clip against walls, so you can end up inside the map.
- Fly: WASD to move, Space and Left Ctrl for up and down. Speed is the box next to the toggle.
- Speed: walk speed, editable while it's running.
- Infinite Jump: keep jumping in mid-air.

### Combat
- Aimbot: works off the camera and normal Humanoid characters, so it isn't tied to one game. The `...` button opens the settings: FOV, smoothing, target part, prediction, team and wall checks, auto-shoot, and the aim key. Hold right mouse by default.

### Visuals
- ESP: box, name, health, distance and tracers for other players, plus optional skeletons and chams. Settings cover colors, max distance, team check, visibility check, text size, and a players-only / include-NPCs switch. The Drawing elements need an executor with the Drawing API. Chams use `Highlight` and work without it.

### Players
Everyone in the server, with buttons to set a target, teleport to them, or clear the target. Picking someone flips ESP and Aimbot to the selected target; clearing it puts both back on everyone.

### Games
- Driving Empire
  - Halloween Event
  - Index Hub

### Tools
- SimpleSpy
- Cobalt Spy
- Dex++
- Copy job ID to clipboard

### Universal
- Infinite Yield
- R15 Animations (you can save your own animation list now)
- Noclip
- Anti-AFK

### Server
- Rejoin
- Server hop

## Settings

Any toggle with a `...` button has its own settings page, and changes apply immediately. If your executor has `writefile`, `readfile` and `isfile`, settings are saved to `OpenHubConfig.json` and loaded on the next injection, so you don't have to redo them every time. Without file access everything still works, it just resets when you re-execute.

The search box at the top searches everything, including items inside folders. It only matches names, so "fly" gets you Fly and not much else.

## Notes

- ESP and Aimbot are generic on purpose. They read the character models and camera, so they should behave the same in most games, but anything with custom hitboxes or server-side checks is going to be hit or miss.
- Auto-shoot calls `mouse1click`, so it needs an executor that exposes it. The aim itself doesn't depend on that.
- Noclip only changes `CanCollide` on your own character. It won't get you through a server-side wall.
- Anti-AFK uses `VirtualUser`, which some executors lock down. If it doesn't work, that's probably why.
- Server hop needs an HTTP function (`request`, `syn.request`, etc.) to hit the Roblox servers endpoint. Rejoin uses `TeleportService` directly.
- I test this in a couple of games, not all of them. If something breaks after a Roblox update, open an issue with the game and what happened.

## Adding a script

Drop a `.lua` file in `scripts/` and add it to `CATEGORIES` in `main-ui.lua`. Toggles need `_G.<Name>Script` with `Start()` and `Stop()`; the menu calls those. Buttons just run the file. Optional settings go in a `settings` table on the item, and the menu builds the widgets and stores values in `_G.<store>`.

## Disclaimer

Use an alt. I'm not responsible if you get banned or mess up a save.
