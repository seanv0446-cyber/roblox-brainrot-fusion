return {
    GameName = "Brainrot Fusion",
    StartingCash = 250,
    IncomeTickSeconds = 1,
    StealSettings = {
        ProtectDuration = 10,
    },
    BrainrotTiers = {
        [1] = {
            Name = "Meme",
            Cost = 25,
            Income = 2,
            Color = Color3.fromRGB(255, 120, 200),
            EvolutionCount = 2,
            NextTier = 2,
        },
        [2] = {
            Name = "Bigger Meme",
            Cost = 80,
            Income = 8,
            Color = Color3.fromRGB(255, 170, 70),
            EvolutionCount = 3,
            NextTier = 3,
        },
        [3] = {
            Name = "Mega Brainrot",
            Cost = 200,
            Income = 18,
            Color = Color3.fromRGB(110, 255, 130),
            EvolutionCount = 2,
            NextTier = 4,
        },
        [4] = {
            Name = "Legendary Fusion",
            Cost = 500,
            Income = 60,
            Color = Color3.fromRGB(255, 220, 90),
            EvolutionCount = 1,
            NextTier = nil,
        },
    },
}
