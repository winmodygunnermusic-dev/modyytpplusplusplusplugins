--[[
    Old Crusty Video Effect
    Nonsensical Video Generator v1.8.1.2
    Workshop Effect

    Effect concept:
      Makes modern footage look like an old, heavily degraded video recording.

    Features:
      - Washed/faded colors
      - Contrast reduction
      - Film grain/noise
      - Random brightness flicker
      - Horizontal tracking distortion
      - VHS-style chromatic offset
      - Soft blur
      - Old-video scratches
      - Occasional frame instability
      - Optional black/white damage
]]

local function clamp(value, minimum, maximum)
    if value < minimum then
        return minimum
    elseif value > maximum then
        return maximum
    end

    return value
end

local function randomFloat(minimum, maximum)
    return minimum + math.random() * (maximum - minimum)
end

local function randomChance(chance)
    return math.random(0, 10000) / 10000 < chance
end

-- ============================================================
-- QUERY
-- ============================================================

function Query()
    return {
        name = "Old Crusty Video Effect",
        description =
            "Turns footage into a faded, noisy and unstable old video recording.",
        type = "video",

        -- No external libraries are required.
        libraries = {},

        settings = {
            {
                name = "Crust Level",
                type = "number",
                default = 70,
                minimum = 0,
                maximum = 100
            },

            {
                name = "Flicker",
                type = "number",
                default = 55,
                minimum = 0,
                maximum = 100
            },

            {
                name = "Grain",
                type = "number",
                default = 65,
                minimum = 0,
                maximum = 100
            },

            {
                name = "Tracking Damage",
                type = "number",
                default = 45,
                minimum = 0,
                maximum = 100
            },

            {
                name = "Color Fade",
                type = "number",
                default = 60,
                minimum = 0,
                maximum = 100
            },

            {
                name = "Chance Roll",
                type = "number",
                default = 100,
                minimum = 0,
                maximum = 100
            }
        }
    }
end


-- ============================================================
-- EFFECT
-- ============================================================

function Effect(job, settings)
    settings = settings or {}

    local crust = tonumber(settings["Crust Level"]) or 70
    local flicker = tonumber(settings["Flicker"]) or 55
    local grain = tonumber(settings["Grain"]) or 65
    local tracking = tonumber(settings["Tracking Damage"]) or 45
    local colorFade = tonumber(settings["Color Fade"]) or 60
    local chance = tonumber(settings["Chance Roll"]) or 100

    crust = clamp(crust, 0, 100)
    flicker = clamp(flicker, 0, 100)
    grain = clamp(grain, 0, 100)
    tracking = clamp(tracking, 0, 100)
    colorFade = clamp(colorFade, 0, 100)
    chance = clamp(chance, 0, 100)

    -- Chance roll.
    if not randomChance(chance / 100) then
        return job
    end

    -- --------------------------------------------------------
    -- Base old-video color treatment
    -- --------------------------------------------------------

    local saturation =
        clamp(1.0 - (colorFade / 100) * 0.72, 0.15, 1.0)

    local contrast =
        clamp(1.0 - (crust / 100) * 0.25, 0.55, 1.0)

    local brightness =
        randomFloat(
            -0.035 * (crust / 100),
             0.035 * (crust / 100)
        )

    -- Slight warm/dirty old-camera tint.
    local redGain   = 1.00 + 0.035 * (crust / 100)
    local greenGain = 0.99
    local blueGain  = 0.94 - 0.035 * (crust / 100)

    -- --------------------------------------------------------
    -- Flickering exposure
    -- --------------------------------------------------------

    if randomChance(flicker / 100) then
        local flickerAmount =
            randomFloat(-0.10, 0.10) *
            (flicker / 100)

        brightness = brightness + flickerAmount
    end

    -- --------------------------------------------------------
    -- Tracking instability
    -- --------------------------------------------------------

    local horizontalShift = 0
    local verticalShift = 0
    local waveAmount = 0

    if randomChance(tracking / 100) then
        horizontalShift =
            randomFloat(-0.018, 0.018) *
            (tracking / 100)

        verticalShift =
            randomFloat(-0.006, 0.006) *
            (tracking / 100)

        waveAmount =
            randomFloat(0.002, 0.018) *
            (tracking / 100)
    end

    -- --------------------------------------------------------
    -- Random damaged-frame events
    -- --------------------------------------------------------

    local damagedFrame = false

    if randomChance((crust / 100) * 0.10) then
        damagedFrame = true
    end

    -- --------------------------------------------------------
    -- Build video filter description.
    --
    -- NVG effects are intentionally expressed as FFmpeg
    -- filter operations. The exact backend exposes these
    -- through the job/filter interface of the installed
    -- NVG version.
    -- --------------------------------------------------------

    local filters = {}

    -- Slight softness.
    local blurAmount =
        0.15 + (crust / 100) * 0.75

    filters[#filters + 1] =
        string.format(
            "gblur=sigma=%.3f",
            blurAmount
        )

    -- Contrast and brightness.
    filters[#filters + 1] =
        string.format(
            "eq=contrast=%.4f:brightness=%.4f:saturation=%.4f",
            contrast,
            brightness,
            saturation
        )

    -- Old-camera color balance.
    filters[#filters + 1] =
        string.format(
            "colorbalance=rs=%.4f:gs=%.4f:bs=%.4f",
            redGain - 1.0,
            greenGain - 1.0,
            blueGain - 1.0
        )

    -- Fine analogue grain.
    local noiseAmount =
        math.floor(
            3 + (grain / 100) * 22
        )

    filters[#filters + 1] =
        string.format(
            "noise=alls=%d:allf=t+u",
            noiseAmount
        )

    -- Mild horizontal wobble.
    if waveAmount > 0 then
        filters[#filters + 1] =
            string.format(
                "wave=mode=horizontal:amplitude=%d:frequency=%d",
                math.max(1, math.floor(waveAmount * 100)),
                math.random(1, 4)
            )
    end

    -- Tracking damage.
    if horizontalShift ~= 0 then
        filters[#filters + 1] =
            string.format(
                "crop=iw:ih:%d:%d",
                math.max(0, math.floor(horizontalShift * 1000)),
                math.max(0, math.floor(verticalShift * 1000))
            )
    end

    -- Severe damaged frame.
    if damagedFrame then
        filters[#filters + 1] =
            "eq=contrast=0.72:brightness=-0.025:saturation=0.55"

        filters[#filters + 1] =
            "noise=alls=35:allf=t+u"
    end

    -- --------------------------------------------------------
    -- Apply filters.
    -- --------------------------------------------------------

    local filterString = table.concat(filters, ",")

    if job and job.AddVideoFilter then
        job:AddVideoFilter(filterString)

    elseif job and job.FilterVideo then
        job:FilterVideo(filterString)

    elseif job and job.AddFilter then
        job:AddFilter(filterString)

    end

    return job
end


-- ============================================================
-- OPTIONAL RANDOM EVENT DESCRIPTION
-- ============================================================

function GetDescription()
    return
        "Old Crusty Video: faded colors, analogue grain, " ..
        "flickering exposure, tracking damage, blur and " ..
        "unstable old-camera artifacts."
end
