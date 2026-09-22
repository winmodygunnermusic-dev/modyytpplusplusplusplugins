--[[
    Get Down Dance Effect
    Nonsensical Video Generator v1.8.1.2
    Workshop Addon

    File:
        get_down_dance.lua

    Description:
        A chaotic "Get Down Dance" remix effect.

        Features:
        - Random dance-style speed changes
        - Beat-like stutter sections
        - Horizontal mirror pulses
        - Zoom / bounce pulses
        - Small rotation pulses
        - Color/contrast pumping
        - Optional audio tempo/pitch-style processing
        - Randomized intensity
        - Configurable chance roll

    This addon is intentionally self-contained.
    It does not require an external Video/Audio/Image library.
]]

local Effect = {}

----------------------------------------------------------------
-- Metadata
----------------------------------------------------------------

Effect.name = "Get Down Dance"
Effect.description = "Adds a chaotic dance-style remix with rhythmic zooms, speed changes, stutters and audio pumping."

----------------------------------------------------------------
-- Settings
----------------------------------------------------------------

Effect.settings = {
    {
        name = "Chance Roll",
        key = "chance",
        type = "number",
        default = 100,
        min = 0,
        max = 100
    },

    {
        name = "Dance Intensity",
        key = "intensity",
        type = "number",
        default = 70,
        min = 0,
        max = 100
    },

    {
        name = "Dance Speed",
        key = "speed",
        type = "number",
        default = 70,
        min = 0,
        max = 100
    },

    {
        name = "Visual Chaos",
        key = "visualChaos",
        type = "number",
        default = 65,
        min = 0,
        max = 100
    },

    {
        name = "Audio Pump",
        key = "audioPump",
        type = "number",
        default = 55,
        min = 0,
        max = 100
    },

    {
        name = "Stutter",
        key = "stutter",
        type = "number",
        default = 45,
        min = 0,
        max = 100
    }
}

----------------------------------------------------------------
-- Utility
----------------------------------------------------------------

local function clamp(value, minimum, maximum)
    if value < minimum then
        return minimum
    end

    if value > maximum then
        return maximum
    end

    return value
end

local function randomFloat(minimum, maximum)
    return minimum + math.random() * (maximum - minimum)
end

local function chance(percent)
    return math.random(0, 10000) / 100 <= percent
end

----------------------------------------------------------------
-- Query
--
-- NVG Workshop effects use Query() to describe the addon and
-- declare libraries used by the effect.
----------------------------------------------------------------

function Effect.Query()
    return {
        name = "Get Down Dance",
        description = "Chaotic dance-style video remix effect.",
        libraries = {}
    }
end

----------------------------------------------------------------
-- Effect construction
----------------------------------------------------------------

function Effect.Create(settings)
    settings = settings or {}

    local intensity = tonumber(settings.intensity) or 70
    local speed = tonumber(settings.speed) or 70
    local visualChaos = tonumber(settings.visualChaos) or 65
    local audioPump = tonumber(settings.audioPump) or 55
    local stutter = tonumber(settings.stutter) or 45
    local chanceRoll = tonumber(settings.chance) or 100

    intensity = clamp(intensity, 0, 100)
    speed = clamp(speed, 0, 100)
    visualChaos = clamp(visualChaos, 0, 100)
    audioPump = clamp(audioPump, 0, 100)
    stutter = clamp(stutter, 0, 100)
    chanceRoll = clamp(chanceRoll, 0, 100)

    ------------------------------------------------------------
    -- Chance roll
    ------------------------------------------------------------

    if not chance(chanceRoll) then
        return {
            videoFilters = {},
            audioFilters = {}
        }
    end

    ------------------------------------------------------------
    -- Convert percentages into useful effect ranges
    ------------------------------------------------------------

    local intensityScale = intensity / 100
    local speedScale = speed / 100
    local chaosScale = visualChaos / 100
    local stutterScale = stutter / 100
    local audioScale = audioPump / 100

    ------------------------------------------------------------
    -- Random dance parameters
    ------------------------------------------------------------

    local speedUp = 1.05 + (0.55 * speedScale)
    local slowDown = 0.98 - (0.45 * speedScale)

    local zoomAmount =
        1.0 +
        randomFloat(0.02, 0.14) *
        intensityScale *
        chaosScale

    local rotation =
        randomFloat(-2.5, 2.5) *
        intensityScale *
        chaosScale

    local saturation =
        1.0 +
        randomFloat(0.05, 0.45) *
        intensityScale

    local contrast =
        1.0 +
        randomFloat(0.03, 0.30) *
        intensityScale

    ------------------------------------------------------------
    -- Build video filters
    ------------------------------------------------------------

    local videoFilters = {}

    ------------------------------------------------------------
    -- Dance speed
    ------------------------------------------------------------

    if chance(80 * speedScale) then
        if chance(55) then
            table.insert(
                videoFilters,
                string.format(
                    "setpts=%.4f*PTS",
                    slowDown
                )
            )
        else
            table.insert(
                videoFilters,
                string.format(
                    "setpts=%.4f*PTS",
                    1.0 / speedUp
                )
            )
        end
    end

    ------------------------------------------------------------
    -- Mirror dance pulse
    ------------------------------------------------------------

    if chance(55 * chaosScale) then
        table.insert(
            videoFilters,
            "hflip"
        )
    end

    ------------------------------------------------------------
    -- Zoom / bounce
    ------------------------------------------------------------

    if chance(75 * chaosScale) then
        table.insert(
            videoFilters,
            string.format(
                "scale=iw*%.4f:ih*%.4f",
                zoomAmount,
                zoomAmount
            )
        )

        table.insert(
            videoFilters,
            "crop=iw/zoom:ih/zoom"
        )
    end

    ------------------------------------------------------------
    -- Dance rotation
    ------------------------------------------------------------

    if chance(45 * chaosScale) then
        table.insert(
            videoFilters,
            string.format(
                "rotate=%frad:fillcolor=black@0",
                rotation
            )
        )
    end

    ------------------------------------------------------------
    -- Color pump
    ------------------------------------------------------------

    if chance(65 * intensityScale) then
        table.insert(
            videoFilters,
            string.format(
                "eq=contrast=%.3f:saturation=%.3f",
                contrast,
                saturation
            )
        )
    end

    ------------------------------------------------------------
    -- RGB / chromatic-style dance wobble
    ------------------------------------------------------------

    if chance(35 * chaosScale) then
        table.insert(
            videoFilters,
            "rgbashift=rh=2:gh=-1:bh=1"
        )
    end

    ------------------------------------------------------------
    -- Stutter / frame repetition
    --
    -- Uses a short fps cycle to give the footage a rhythmic,
    -- chopped-up dance-video appearance.
    ------------------------------------------------------------

    if chance(70 * stutterScale) then
        local fps = math.random(8, 18)

        table.insert(
            videoFilters,
            string.format(
                "fps=%d",
                fps
            )
        )

        table.insert(
            videoFilters,
            "tblend=all_mode=average:all_opacity=0.35"
        )
    end

    ------------------------------------------------------------
    -- Subtle motion blur / frame blending
    ------------------------------------------------------------

    if chance(40 * intensityScale) then
        table.insert(
            videoFilters,
            "tmix=frames=2:weights='1 1'"
        )
    end

    ------------------------------------------------------------
    -- Audio processing
    ------------------------------------------------------------

    local audioFilters = {}

    ------------------------------------------------------------
    -- Audio volume pumping
    ------------------------------------------------------------

    if chance(75 * audioScale) then
        local volume =
            1.0 +
            randomFloat(0.10, 0.65) *
            audioScale

        table.insert(
            audioFilters,
            string.format(
                "volume=%.3f",
                volume
            )
        )
    end

    ------------------------------------------------------------
    -- Dance-style EQ
    ------------------------------------------------------------

    if chance(60 * audioScale) then
        local bass =
            1.0 +
            randomFloat(1.0, 5.0) *
            audioScale

        local treble =
            randomFloat(-1.0, 3.0) *
            audioScale

        table.insert(
            audioFilters,
            string.format(
                "equalizer=f=90:t=q:w=1:g=%.2f",
                bass
            )
        )

        table.insert(
            audioFilters,
            string.format(
                "equalizer=f=6000:t=q:w=1:g=%.2f",
                treble
            )
        )
    end

    ------------------------------------------------------------
    -- Slight audio tempo change
    ------------------------------------------------------------

    if chance(45 * speedScale) then
        local tempo

        if chance(50) then
            tempo = 1.0 + randomFloat(0.02, 0.12) * speedScale
        else
            tempo = 1.0 - randomFloat(0.02, 0.10) * speedScale
        end

        tempo = clamp(tempo, 0.5, 2.0)

        table.insert(
            audioFilters,
            string.format(
                "atempo=%.4f",
                tempo
            )
        )
    end

    ------------------------------------------------------------
    -- Optional echo-like dance tail
    ------------------------------------------------------------

    if chance(25 * intensityScale) then
        table.insert(
            audioFilters,
            "aecho=0.8:0.7:90:0.25"
        )
    end

    ------------------------------------------------------------
    -- Return NVG effect data
    ------------------------------------------------------------

    return {
        videoFilters = videoFilters,
        audioFilters = audioFilters
    }
end

----------------------------------------------------------------
-- Process
--
-- This function provides a simple effect processor interface.
-- The exact NVG runtime may wrap the returned filter lists into
-- its own FFmpeg command pipeline.
----------------------------------------------------------------

function Effect.Process(job, settings)
    local result = Effect.Create(settings)

    if not result then
        return job
    end

    job.videoFilters = job.videoFilters or {}
    job.audioFilters = job.audioFilters or {}

    for _, filter in ipairs(result.videoFilters) do
        table.insert(job.videoFilters, filter)
    end

    for _, filter in ipairs(result.audioFilters) do
        table.insert(job.audioFilters, filter)
    end

    return job
end

----------------------------------------------------------------
-- Export
----------------------------------------------------------------

return Effect
