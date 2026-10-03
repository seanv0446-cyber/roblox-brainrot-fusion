local Workspace = game:GetService("Workspace")

local BrainrotService = {}
BrainrotService.__index = BrainrotService

function BrainrotService.new(dataService, plotService, config)
    local self = setmetatable({}, BrainrotService)
    self.DataService = dataService
    self.PlotService = plotService
    self.Config = config
    self._incomeLoopRunning = false
    return self
end

function BrainrotService:SetupWorld()
    local folder = Workspace:FindFirstChild("Brainrots")
    if not folder then
        folder = Instance.new("Folder")
        folder.Name = "Brainrots"
        folder.Parent = Workspace
    end
end

local function createBrainrotModel(tier, color)
    local model = Instance.new("Model")
    model.Name = "Brainrot_Tier" .. tier
    model:SetAttribute("Tier", tier)

    local core = Instance.new("Part")
    core.Name = "Core"
    core.Shape = Enum.PartType.Ball
    core.Size = Vector3.new(3, 3, 3)
    core.Material = Enum.Material.SmoothPlastic
    core.Color = color
    core.Anchored = true
    core.CanCollide = false
    model.PrimaryPart = core
    core.Parent = model

    local glow = Instance.new("PointLight")
    glow.Brightness = 1.5
    glow.Range = 9
    glow.Color = color
    glow.Parent = core

    return model, core
end

function BrainrotService:BuildBrainrotModel(player, tier, position)
    local config = self.Config.BrainrotTiers[tier]
    if not config then
        warn("Unknown brainrot tier: " .. tostring(tier))
        return nil
    end

    local model, core = createBrainrotModel(tier, config.Color)
    model:SetAttribute("OwnerUserId", player.UserId)
    model:SetAttribute("Tier", tier)
    model:SetAttribute("IncomeValue", config.Income)
    model:SetAttribute("ProtectedUntil", 0)
    model:SetAttribute("NameKey", config.Name)

    model:PivotTo(CFrame.new(position))
    model.Parent = self.PlotService:GetPlotFolder(player)

    local prompt = Instance.new("ProximityPrompt")
    prompt.ObjectText = config.Name
    prompt.ActionText = "Steal Brainrot"
    prompt.HoldDuration = 2
    prompt.RequiresLineOfSight = false
    prompt.Parent = core

    prompt.Triggered:Connect(function(triggerPlayer)
        self:AttemptSteal(triggerPlayer, model)
    end)

    return model
end

function BrainrotService:GiveStarterBrainrot(player)
    local data = self.DataService:GetPlayerData(player)
    if data.ActiveBrainrots and #data.ActiveBrainrots > 0 then
        return
    end

    local plot = self.PlotService:GetPlotFolder(player)
    local spawnPosition = plot:GetPivot().Position + Vector3.new(0, 5, 0)
    local model = self:BuildBrainrotModel(player, 1, spawnPosition)
    if model then
        data.ActiveBrainrots = {
            { Tier = 1, Position = spawnPosition },
        }
    end
end

function BrainrotService:HandlePurchase(player, tier)
    local config = self.Config.BrainrotTiers[tier]
    if not config then
        return
    end

    if not self.DataService:CanUseTier(player, tier) then
        if tier > 1 then
            return
        end
    end

    local cash = self.DataService:GetCash(player)
    if cash < config.Cost then
        return
    end

    self.DataService:SetCash(player, cash - config.Cost)

    local plot = self.PlotService:GetPlotFolder(player)
    local xOffset = (#plot:GetChildren() + 1) * 5
    local position = plot:GetPivot().Position + Vector3.new(xOffset, 5, 0)
    self:BuildBrainrotModel(player, tier, position)
    self:SyncPlayerState(player)
end

function BrainrotService:AttemptSteal(player, brainrotModel)
    if not player or not brainrotModel then
        return
    end

    local ownerId = brainrotModel:GetAttribute("OwnerUserId")
    if ownerId == player.UserId then
        return
    end

    local protectedUntil = brainrotModel:GetAttribute("ProtectedUntil") or 0
    if os.clock() < protectedUntil then
        return
    end

    local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    if not root then
        return
    end

    local distance = (root.Position - brainrotModel:GetPivot().Position).Magnitude
    if distance > 18 then
        return
    end

    local newOwnerPlot = self.PlotService:GetPlotFolder(player)
    brainrotModel:SetAttribute("OwnerUserId", player.UserId)
    brainrotModel:SetAttribute("ProtectedUntil", os.clock() + self.Config.StealSettings.ProtectDuration)
    brainrotModel.Parent = newOwnerPlot

    local offset = Vector3.new(math.random(-8, 8), 4, math.random(-8, 8))
    brainrotModel:PivotTo(CFrame.new(newOwnerPlot:GetPivot().Position + offset))
end

function BrainrotService:GetIncomeForPlayer(player)
    local total = 0
    local plotFolder = self.PlotService:GetPlotFolder(player)

    for _, descendant in ipairs(plotFolder:GetDescendants()) do
        if descendant:IsA("Model") and descendant:GetAttribute("Tier") then
            local tier = descendant:GetAttribute("Tier")
            local tierConfig = self.Config.BrainrotTiers[tier]
            if tierConfig then
                total += tierConfig.Income
            end
        end
    end

    return total
end

function BrainrotService:SyncPlayerState(player)
    local payload = {
        Cash = self.DataService:GetCash(player),
        IncomePerSecond = self:GetIncomeForPlayer(player),
    }

    self.DataService._stateRemote:FireClient(player, payload)
end

function BrainrotService:Init()
    if self._incomeLoopRunning then
        return
    end

    self._incomeLoopRunning = true
    task.spawn(function()
        while true do
            task.wait(self.Config.IncomeTickSeconds)
            for _, player in ipairs(game.Players:GetPlayers()) do
                local income = self:GetIncomeForPlayer(player)
                if income > 0 then
                    self.DataService:RewardIncome(player, income)
                    self:SyncPlayerState(player)
                end
            end
        end
    end)
end

return BrainrotService
