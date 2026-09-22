-- SpaDinner Effect
-- Nonsensical Video Generator v1.8.1.2
-- Applies several SFX over time.
-- Effect idea by Waltman13
--
-- Suggested location:
-- NonsensicalVideoGenerator/plugins/workshop/spadinner.lua

local Effect = {}

Effect.Name = "SpaDinner SFX"
Effect.Description = "Applies several SpaDinner SFX over time."
Effect.Author = "Waltman13"
Effect.Version = "1.0"

Effect.Settings = {
    MinDelay = {
        Name = "Min Delay",
        Type = "number",
        Default = 0.10,
        Min = 0.01,
        Max = 10.0
    },

    MaxDelay = {
        Name = "Max Delay",
        Type = "number",
        Default = 0.75,
        Min = 0.01,
        Max = 10.0
    },

    MinSFXCount = {
        Name = "Min SFX Count",
        Type = "integer",
        Default = 5,
        Min = 1,
        Max = 100
    },

    MaxSFXCount = {
        Name = "Max SFX Count",
        Type = "integer",
        Default = 10,
        Min = 1,
        Max = 100
    },

    UseSpadinnerLibrary = {
        Name = "Use Spadinner Library",
        Type = "boolean",
        Default = true
    }
}

local function randomRange(min, max)
    return min + math.random() * (max - min)
end

local function randomInt(min, max)
    return math.random(min, max)
end

-- Attempts to locate an SFX from the SpaDinner library.
local function GetSpaDinnerSFX()
    if not Effect.Settings.UseSpadinnerLibrary.Default then
        return nil
    end

    if type(Spadinner) == "table" then
        if type(Spadinner.GetRandomSFX) == "function" then
            return Spadinner.GetRandomSFX()
        end

        if type(Spadinner.SFX) == "table" and #Spadinner.SFX > 0 then
            return Spadinner.SFX[randomInt(1, #Spadinner.SFX)]
        end
    end

    return nil
end

function Effect:Apply(context)
    local minDelay = tonumber(self:GetSetting("Min Delay")) or 0.10
    local maxDelay = tonumber(self:GetSetting("Max Delay")) or 0.75

    local minCount = math.floor(
        tonumber(self:GetSetting("Min SFX Count")) or 5
    )

    local maxCount = math.floor(
        tonumber(self:GetSetting("Max SFX Count")) or 10
    )

    local useLibrary = self:GetSetting("Use Spadinner Library")

    if minDelay > maxDelay then
        minDelay, maxDelay = maxDelay, minDelay
    end

    if minCount > maxCount then
        minCount, maxCount = maxCount, minCount
    end

    local count = randomInt(minCount, maxCount)
    local currentTime = 0

    for i = 1, count do
        local delay = randomRange(minDelay, maxDelay)
        currentTime = currentTime + delay

        local sfx = nil

        if useLibrary then
            sfx = GetSpaDinnerSFX()
        end

        -- NVG integration point.
        -- The host API can replace this with its native audio-event
        -- creation function.
        if type(context.AddSoundEffect) == "function" and sfx then
            context:AddSoundEffect({
                Time = currentTime,
                Sound = sfx,
                Volume = randomRange(0.75, 1.0),
                Pitch = randomRange(0.90, 1.10)
            })
        elseif type(context.AddSFX) == "function" and sfx then
            context:AddSFX(currentTime, sfx)
        end
    end
end

return Effect
