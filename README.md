# Brainrot Fusion Prototype

This project is a modular Roblox game framework inspired by the core loop of `Steal a Brainrot` with a custom evolution and fusion mechanic.

## Included systems

- Plot assignment and spawning
- Passive income generation
- Brainrot purchase system
- Evolution altar merging rules
- Stealing mechanic with protection timer
- RemoteEvent-driven server/client communication
- Data save/load design with DataStoreService
- Client HUD and shop GUI

## Folder structure

- `src/ServerScriptService/Main.server.lua`
- `src/ServerScriptService/Services/DataService.lua`
- `src/ServerScriptService/Services/PlotService.lua`
- `src/ServerScriptService/Services/BrainrotService.lua`
- `src/ServerScriptService/Services/EvolutionService.lua`
- `src/ServerScriptService/Services/StealService.lua`
- `src/ReplicatedStorage/Shared/Config.lua`
- `src/StarterPlayerScripts/BrainrotClient.client.lua`

## Recommended Roblox Studio setup

1. Create a new place.
2. Add a `Folder` named `ReplicatedStorage` and paste the shared config there.
3. Add `ServerScriptService` and `StarterPlayerScripts` scripts with the provided paths.
4. Run the game in Studio and test the flow.

## Notes

- All money and progression should be validated server-side.
- This is a prototype framework, not a full production game.
- For larger scale projects, `ProfileService` is recommended.

## Quick gameplay loop

- Join server
- Get assigned a plot
- Buy base brainrot
- Earn passive cash
- Bring matching tiers to Evolution Altar
- Merge into higher-tier units
- Protect them from stealing
