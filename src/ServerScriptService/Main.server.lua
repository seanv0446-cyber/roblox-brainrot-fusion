local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Shared = ReplicatedStorage:FindFirstChild("Shared")
if not Shared then
    Shared = Instance.new("Folder")
    Shared.Name = "Shared"
    Shared.Parent = ReplicatedStorage
end

local Config = require(Shared:WaitForChild("Config"))

local ServicesFolder = script.Parent:WaitForChild("Services")
local DataService = require(ServicesFolder:WaitForChild("DataService"))
local PlotService = require(ServicesFolder:WaitForChild("PlotService"))
local BrainrotService = require(ServicesFolder:WaitForChild("BrainrotService"))
local EvolutionService = require(ServicesFolder:WaitForChild("EvolutionService"))

local remotesFolder = ReplicatedStorage:FindFirstChild("Remotes")
if not remotesFolder then
    remotesFolder = Instance.new("Folder")
    remotesFolder.Name = "Remotes"
    remotesFolder.Parent = ReplicatedStorage
end

local function ensureRemote(name)
    local remote = remotesFolder:FindFirstChild(name)
    if not remote then
        remote = Instance.new("RemoteEvent")
        remote.Name = name
        remote.Parent = remotesFolder
    end
    return remote
end

local remotes = {
    Purchase = ensureRemote("PurchaseBrainrot"),
    Evolution = ensureRemote("TryEvolution"),
    PlayerState = ensureRemote("PlayerState"),
}

local dataService = DataService.new(remotes.PlayerState)
local plotService = PlotService.new(Config)
local brainrotService = BrainrotService.new(dataService, plotService, Config)
local evolutionService = EvolutionService.new(dataService, brainrotService, plotService, Config)

plotService:SetupWorld()
brainrotService:SetupWorld()

local function setupPlayer(player)
    dataService:LoadPlayer(player)
    plotService:ClaimPlot(player)
    brainrotService:GiveStarterBrainrot(player)
    brainrotService:SyncPlayerState(player)
end

Players.PlayerAdded:Connect(setupPlayer)

for _, player in ipairs(Players:GetPlayers()) do
    task.spawn(function()
        setupPlayer(player)
    end)
end

remotes.Purchase.OnServerEvent:Connect(function(player, tier)
    if type(tier) ~= "number" then
        return
    end

    brainrotService:HandlePurchase(player, tier)
end)

remotes.Evolution.OnServerEvent:Connect(function(player, tier)
    if type(tier) ~= "number" then
        return
    end

    evolutionService:TryEvolution(player, tier)
end)

Players.PlayerRemoving:Connect(function(player)
    dataService:SavePlayer(player)
end)

brainrotService:Init()

while true do
    task.wait(60)
    for _, player in ipairs(Players:GetPlayers()) do
        dataService:SavePlayer(player)
    end
end
