local StealService = {}
StealService.__index = StealService

function StealService.new(brainrotService)
    local self = setmetatable({}, StealService)
    self.BrainrotService = brainrotService
    return self
end

function StealService:InitializePrompt(model)
    local primaryPart = model.PrimaryPart
    if not primaryPart then
        return
    end

    local prompt = primaryPart:FindFirstChildOfClass("ProximityPrompt")
    if prompt then
        prompt.Triggered:Connect(function(player)
            self.BrainrotService:AttemptSteal(player, model)
        end)
    end
end

return StealService
