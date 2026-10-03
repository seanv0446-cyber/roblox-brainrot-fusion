local EvolutionService = {}
EvolutionService.__index = EvolutionService

function EvolutionService.new(dataService, brainrotService, plotService, config)
    local self = setmetatable({}, EvolutionService)
    self.DataService = dataService
    self.BrainrotService = brainrotService
    self.PlotService = plotService
    self.Config = config
    return self
end

local function getTierModelsInAltarRange(player, tier, altar)
    local results = {}
    local plot = player and player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    if not plot then
        return results
    end

    local plotFolder = player and plot and plot.Parent and script.Parent or nil
    if not plotFolder then
        return results
    end

    for _, descendant in ipairs(plotFolder:GetDescendants()) do
        if descendant:IsA("Model") and descendant:GetAttribute("Tier") == tier then
            local distance = (descendant:GetPivot().Position - altar.Position).Magnitude
            if distance <= 18 then
                table.insert(results, descendant)
            end
        end
    end

    return results
end

function EvolutionService:TryEvolution(player, tier)
    local tierConfig = self.Config.BrainrotTiers[tier]
    if not tierConfig then
        return
    end

    local altar = workspace:FindFirstChild("EvolutionAltar")
    if not altar then
        return
    end

    local nearby = {}
    local plotFolder = self.PlotService:GetPlotFolder(player)
    for _, descendant in ipairs(plotFolder:GetDescendants()) do
        if descendant:IsA("Model") and descendant:GetAttribute("Tier") == tier then
            local distance = (descendant:GetPivot().Position - altar.Position).Magnitude
            if distance <= 18 then
                table.insert(nearby, descendant)
            end
        end
    end

    if #nearby < (tierConfig.EvolutionCount or 2) then
        return
    end

    local sorted = nearby
    table.sort(sorted, function(a, b)
        return a:GetPivot().Position.Magnitude < b:GetPivot().Position.Magnitude
    end)

    local countNeeded = tierConfig.EvolutionCount or 2
    for i = 1, countNeeded do
        if sorted[i] then
            sorted[i]:Destroy()
        end
    end

    local nextTier = tierConfig.NextTier
    if not nextTier then
        return
    end

    self.DataService:UnlockTier(player, nextTier)
    local evolvedPosition = altar.Position + Vector3.new(math.random(-4, 4), 4, math.random(-4, 4))
    local evolved = self.BrainrotService:BuildBrainrotModel(player, nextTier, evolvedPosition)
    if evolved then
        evolved:SetAttribute("ProtectedUntil", os.clock() + self.Config.StealSettings.ProtectDuration)
    end

    self.BrainrotService:SyncPlayerState(player)
end

return EvolutionService
