local Workspace = game:GetService("Workspace")

local PlotService = {}
PlotService.__index = PlotService

function PlotService.new(config)
    local self = setmetatable({}, PlotService)
    self.Config = config
    self.PlayerPlots = {}
    self.PlotFolder = Workspace:FindFirstChild("Plots")

    if not self.PlotFolder then
        self.PlotFolder = Instance.new("Folder")
        self.PlotFolder.Name = "Plots"
        self.PlotFolder.Parent = Workspace
    end

    return self
end

function PlotService:SetupWorld()
    local altar = Workspace:FindFirstChild("EvolutionAltar")
    if not altar then
        altar = Instance.new("Part")
        altar.Name = "EvolutionAltar"
        altar.Size = Vector3.new(14, 2, 14)
        altar.Material = Enum.Material.Neon
        altar.Color = Color3.fromRGB(100, 255, 220)
        altar.Position = Vector3.new(0, 8, 0)
        altar.Anchored = true
        altar.Shape = Enum.PartType.Cylinder
        altar.Parent = Workspace
    end
end

function PlotService:GetNextPlotPosition(index)
    local spacing = 80
    local columns = 5
    local column = (index - 1) % columns
    local row = math.floor((index - 1) / columns)
    return Vector3.new(column * spacing, 0, row * spacing)
end

function PlotService:ClaimPlot(player)
    local existing = self.PlotFolder:FindFirstChild("Plot_" .. player.UserId)
    if existing then
        self.PlayerPlots[player.UserId] = existing
        return existing
    end

    local plotIndex = #self.PlotFolder:GetChildren() + 1
    local plotPosition = self:GetNextPlotPosition(plotIndex)

    local plotModel = Instance.new("Model")
    plotModel.Name = "Plot_" .. player.UserId
    plotModel:SetAttribute("OwnerUserId", player.UserId)
    plotModel.Parent = self.PlotFolder

    local base = Instance.new("Part")
    base.Name = "Base"
    base.Size = Vector3.new(50, 2, 50)
    base.Position = Vector3.new(plotPosition.X, 0, plotPosition.Z)
    base.Anchored = true
    base.Material = Enum.Material.SmoothPlastic
    base.Color = Color3.fromRGB(70, 70, 70)
    base.Parent = plotModel

    local spawnPad = Instance.new("Part")
    spawnPad.Name = "SpawnPad"
    spawnPad.Size = Vector3.new(8, 1, 8)
    spawnPad.Position = Vector3.new(plotPosition.X, 3, plotPosition.Z)
    spawnPad.Anchored = true
    spawnPad.Material = Enum.Material.SmoothPlastic
    spawnPad.Color = Color3.fromRGB(110, 110, 110)
    spawnPad.Parent = plotModel

    local spawnLocation = Instance.new("SpawnLocation")
    spawnLocation.Name = "SpawnPoint"
    spawnLocation.Size = Vector3.new(8, 1, 8)
    spawnLocation.Position = Vector3.new(plotPosition.X, 4, plotPosition.Z)
    spawnLocation.Anchored = true
    spawnLocation.Neutral = true
    spawnLocation.Transparency = 0.2
    spawnLocation.Color = Color3.fromRGB(255, 160, 90)
    spawnLocation.Parent = plotModel

    self.PlayerPlots[player.UserId] = plotModel

    local function teleportCharacter(character)
        if character and character:FindFirstChild("HumanoidRootPart") then
            character.HumanoidRootPart.CFrame = CFrame.new(spawnLocation.Position + Vector3.new(0, 5, 0))
        end
    end

    if player.Character then
        teleportCharacter(player.Character)
    end

    player.CharacterAdded:Connect(function(character)
        task.wait(0.2)
        teleportCharacter(character)
    end)

    return plotModel
end

function PlotService:GetPlotFolder(player)
    local plot = self.PlotFolder:FindFirstChild("Plot_" .. player.UserId)
    if plot then
        return plot
    end
    return self:ClaimPlot(player)
end

return PlotService
