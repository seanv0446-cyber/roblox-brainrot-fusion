local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Config"))

local localPlayer = Players.LocalPlayer
local playerGui = localPlayer:WaitForChild("PlayerGui")

local remotes = ReplicatedStorage:WaitForChild("Remotes")
local purchaseRemote = remotes:WaitForChild("PurchaseBrainrot")
local stateRemote = remotes:WaitForChild("PlayerState")

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "BrainrotHUD"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

local topBar = Instance.new("Frame")
topBar.Name = "TopBar"
topBar.Size = UDim2.new(0, 360, 0, 110)
topBar.Position = UDim2.new(0.5, -180, 0, 18)
topBar.BackgroundColor3 = Color3.fromRGB(32, 32, 32)
topBar.BackgroundTransparency = 0.2
topBar.BorderSizePixel = 0
topBar.Parent = screenGui

local topCorner = Instance.new("UICorner")
topCorner.CornerRadius = UDim.new(0, 14)
topCorner.Parent = topBar

local cashLabel = Instance.new("TextLabel")
cashLabel.Name = "CashLabel"
cashLabel.Size = UDim2.new(1, -20, 0, 38)
cashLabel.Position = UDim2.new(0, 10, 0, 10)
cashLabel.BackgroundTransparency = 1
cashLabel.Font = Enum.Font.GothamBold
cashLabel.TextSize = 24
cashLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
cashLabel.Text = "$0"
cashLabel.TextXAlignment = Enum.TextXAlignment.Left
cashLabel.Parent = topBar

local incomeLabel = Instance.new("TextLabel")
incomeLabel.Name = "IncomeLabel"
incomeLabel.Size = UDim2.new(1, -20, 0, 28)
incomeLabel.Position = UDim2.new(0, 10, 0, 52)
incomeLabel.BackgroundTransparency = 1
incomeLabel.Font = Enum.Font.GothamMedium
incomeLabel.TextSize = 18
incomeLabel.TextColor3 = Color3.fromRGB(90, 255, 160)
incomeLabel.Text = "+0/s"
incomeLabel.TextXAlignment = Enum.TextXAlignment.Left
incomeLabel.Parent = topBar

local shopFrame = Instance.new("Frame")
shopFrame.Name = "ShopFrame"
shopFrame.Size = UDim2.new(0, 260, 0, 260)
shopFrame.Position = UDim2.new(0, 25, 0.5, -120)
shopFrame.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
shopFrame.BackgroundTransparency = 0.25
shopFrame.BorderSizePixel = 0
shopFrame.Parent = screenGui

local shopCorner = Instance.new("UICorner")
shopCorner.CornerRadius = UDim.new(0, 16)
shopCorner.Parent = shopFrame

local shopTitle = Instance.new("TextLabel")
shopTitle.Size = UDim2.new(1, -20, 0, 30)
shopTitle.Position = UDim2.new(0, 10, 0, 10)
shopTitle.BackgroundTransparency = 1
shopTitle.Font = Enum.Font.GothamBold
shopTitle.TextSize = 18
shopTitle.Text = "Brainrot Shop"
shopTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
shopTitle.TextXAlignment = Enum.TextXAlignment.Left
shopTitle.Parent = shopFrame

local listLayout = Instance.new("UIListLayout")
listLayout.Padding = UDim.new(0, 8)
listLayout.SortOrder = Enum.SortOrder.LayoutOrder
listLayout.Parent = shopFrame

local function createPurchaseButton(tierNumber, tierData)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, -20, 0, 38)
    button.BackgroundColor3 = Color3.fromRGB(55, 55, 55)
    button.BorderSizePixel = 0
    button.Font = Enum.Font.GothamMedium
    button.TextSize = 15
    button.Text = tierData.Name .. "  -  $" .. tostring(tierData.Cost)
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.Parent = shopFrame

    local buttonCorner = Instance.new("UICorner")
    buttonCorner.CornerRadius = UDim.new(0, 10)
    buttonCorner.Parent = button

    button.MouseButton1Click:Connect(function()
        purchaseRemote:FireServer(tierNumber)
    end)

    return button
end

for tierNumber, tierData in pairs(Config.BrainrotTiers) do
    createPurchaseButton(tierNumber, tierData)
end

stateRemote.OnClientEvent:Connect(function(payload)
    cashLabel.Text = "$" .. tostring(math.floor(payload.Cash or 0))
    incomeLabel.Text = "+" .. tostring(payload.IncomePerSecond or 0) .. "/s"
end)
