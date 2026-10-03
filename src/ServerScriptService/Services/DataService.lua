local DataStoreService = game:GetService("DataStoreService")

local DataService = {}
DataService.__index = DataService

function DataService.new(stateRemote)
    local self = setmetatable({}, DataService)
    self._dataStore = DataStoreService:GetDataStore("BrainrotFusion_V1")
    self._playerData = {}
    self._stateRemote = stateRemote
    return self
end

local function cloneTable(target)
    if type(target) ~= "table" then
        return target
    end

    local copied = {}
    for key, value in pairs(target) do
        copied[key] = cloneTable(value)
    end
    return copied
end

local function defaultPlayerData()
    return {
        Cash = 250,
        UnlockedTiers = { [1] = true },
        ActiveBrainrots = {},
        TotalEarnings = 0,
    }
end

function DataService:LoadPlayer(player)
    local userId = player.UserId
    local success, data = pcall(function()
        return self._dataStore:GetAsync("player_" .. userId)
    end)

    local profile = success and data or nil
    if type(profile) ~= "table" then
        profile = defaultPlayerData()
    end

    local merged = defaultPlayerData()
    for key, value in pairs(profile) do
        if type(merged[key]) == "table" and type(value) == "table" then
            merged[key] = cloneTable(value)
        else
            merged[key] = value
        end
    end

    self._playerData[userId] = merged
    player:SetAttribute("Cash", merged.Cash)
    return merged
end

function DataService:GetPlayerData(player)
    local userId = player.UserId
    if not self._playerData[userId] then
        return self:LoadPlayer(player)
    end
    return self._playerData[userId]
end

function DataService:SavePlayer(player)
    local data = self:GetPlayerData(player)
    if not data then
        return
    end

    local prepared = cloneTable(data)
    prepared.Cash = math.max(0, math.floor(prepared.Cash or 0))

    local success, err = pcall(function()
        self._dataStore:SetAsync("player_" .. player.UserId, prepared)
    end)

    if not success then
        warn("[DataService] Failed to save player data: " .. tostring(err))
    end
end

function DataService:GetCash(player)
    local data = self:GetPlayerData(player)
    return math.max(0, data.Cash or 0)
end

function DataService:SetCash(player, amount)
    local data = self:GetPlayerData(player)
    data.Cash = math.max(0, amount)
    player:SetAttribute("Cash", data.Cash)
end

function DataService:AddCash(player, amount)
    local data = self:GetPlayerData(player)
    data.Cash = math.max(0, (data.Cash or 0) + amount)
    player:SetAttribute("Cash", data.Cash)
end

function DataService:RewardIncome(player, amount)
    self:AddCash(player, amount)
    local data = self:GetPlayerData(player)
    data.TotalEarnings = (data.TotalEarnings or 0) + amount
end

function DataService:UnlockTier(player, tier)
    local data = self:GetPlayerData(player)
    if not data.UnlockedTiers then
        data.UnlockedTiers = {}
    end

    if type(tier) == "number" and tier > 0 then
        data.UnlockedTiers[tier] = true
    end
end

function DataService:CanUseTier(player, tier)
    local data = self:GetPlayerData(player)
    if not data.UnlockedTiers then
        return false
    end
    return data.UnlockedTiers[tier] == true
end

function DataService:SyncPlayerState(player)
    local data = self:GetPlayerData(player)
    local payload = {
        Cash = data.Cash or 0,
        IncomePerSecond = 0,
    }

    if self._stateRemote then
        self._stateRemote:FireClient(player, payload)
    end
end

return DataService
