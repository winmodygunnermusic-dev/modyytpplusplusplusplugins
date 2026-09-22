--[[
    Nonsensical Video Generator
    Workshop Addon: Lagfun Effect
    Target: NVG v1.8.1.2

    Effect:
        Lagfun / frame persistence / temporal smearing

    FFmpeg filter:
        lagfun

    Suggested location:
        NonsensicalVideoGenerator\plugins\workshop\LagfunEffect.lua

    The effect creates a trailing / persistence appearance by allowing
    previous frames to influence the current frame.

    NOTE:
    NVG addon APIs can differ between versions/templates. The filter
    construction is kept separate so it can be adapted easily to the
    exact v1.8.1.2 addon template.
]]

------------------------------------------------------------
-- Addon metadata
------------------------------------------------------------

local addon = {
    name = "Lagfun Effect",
    version = "1.0.0",
    author = "Generated NVG Addon",
    description = "Applies FFmpeg's lagfun temporal frame persistence effect.",
    type = "Effect"
}

------------------------------------------------------------
-- Configuration
------------------------------------------------------------

local DEFAULT_DECAY = 0.95

local MIN_DECAY = 0.01
local MAX_DECAY = 0.99

------------------------------------------------------------
-- Utility
------------------------------------------------------------

local function clamp(value, minimum, maximum)
    if value < minimum then
        return minimum
    end

    if value > maximum then
        return maximum
    end

    return value
end

local function numberToString(value)
    return string.format("%.3f", value)
end

------------------------------------------------------------
-- Effect settings
------------------------------------------------------------

local settings = {
    {
        id = "decay",
        name = "Lag Decay",
        description = "Controls how strongly previous frames remain visible.",
        type = "number",
        default = DEFAULT_DECAY,
        minimum = MIN_DECAY,
        maximum = MAX_DECAY,
        step = 0.01
    }
}

------------------------------------------------------------
-- Build FFmpeg filter
------------------------------------------------------------

local function buildLagfunFilter(decay)
    decay = tonumber(decay) or DEFAULT_DECAY
    decay = clamp(decay, MIN_DECAY, MAX_DECAY)

    return "lagfun=decay=" .. numberToString(decay)
end

------------------------------------------------------------
-- Presets
------------------------------------------------------------

local presets = {
    {
        name = "Subtle",
        decay = 0.80
    },

    {
        name = "Normal",
        decay = 0.95
    },

    {
        name = "Heavy",
        decay = 0.97
    },

    {
        name = "Extreme",
        decay = 0.99
    }
}

------------------------------------------------------------
-- Public effect information
------------------------------------------------------------

addon.settings = settings
addon.presets = presets

addon.getFilter = function(options)
    options = options or {}

    local decay = options.decay or DEFAULT_DECAY

    return buildLagfunFilter(decay)
end

------------------------------------------------------------
-- FFmpeg command helper
------------------------------------------------------------

addon.buildVideoFilter = function(options)
    return addon.getFilter(options)
end

------------------------------------------------------------
-- Effect description
------------------------------------------------------------

addon.getDescription = function(options)
    options = options or {}

    local decay = tonumber(options.decay) or DEFAULT_DECAY

    return string.format(
        "Lagfun temporal persistence enabled. Decay: %s",
        numberToString(clamp(decay, MIN_DECAY, MAX_DECAY))
    )
end

------------------------------------------------------------
-- Optional preset helper
------------------------------------------------------------

addon.getPreset = function(name)
    for _, preset in ipairs(presets) do
        if preset.name == name then
            return {
                decay = preset.decay
            }
        end
    end

    return nil
end

------------------------------------------------------------
-- NVG integration
------------------------------------------------------------

-- The following function is intentionally isolated.
-- Connect this function to the Effect/FFmpeg hook used by
-- your NVG v1.8.1.2 addon template.

addon.apply = function(context)
    context = context or {}

    local options = context.options or {}

    local filter = addon.buildVideoFilter(options)

    --------------------------------------------------------
    -- Common context layouts
    --------------------------------------------------------

    -- If the NVG template provides an FFmpeg filter list:
    if context.filters then
        table.insert(context.filters, filter)
        return context
    end

    -- If the template provides a video filter string:
    if context.videoFilter then
        if context.videoFilter ~= "" then
            context.videoFilter = context.videoFilter .. "," .. filter
        else
            context.videoFilter = filter
        end

        return context
    end

    -- If the template provides a filter_complex list:
    if context.filterComplex then
        table.insert(context.filterComplex, filter)
        return context
    end

    -- Return the generated filter so the NVG template can
    -- consume it directly.
    return filter
end

------------------------------------------------------------
-- Simple FFmpeg argument helper
------------------------------------------------------------

addon.getFFmpegArguments = function(options)
    local filter = addon.buildVideoFilter(options)

    return {
        "-vf",
        filter
    }
end

------------------------------------------------------------
-- Randomized effect level
------------------------------------------------------------

addon.fromIntensity = function(intensity)
    intensity = tonumber(intensity) or 50

    intensity = clamp(intensity, 0, 100)

    -- 0% intensity:
    -- approximately no visible persistence.
    --
    -- 100% intensity:
    -- very strong persistence.

    local decay =
        MIN_DECAY +
        ((MAX_DECAY - MIN_DECAY) * (intensity / 100))

    return {
        decay = decay
    }
end

------------------------------------------------------------
-- Example:
--
-- local args = addon.getFFmpegArguments({
--     decay = 0.97
-- })
--
-- Produces conceptually:
--
-- -vf lagfun=decay=0.970
--
------------------------------------------------------------

------------------------------------------------------------
-- Export
------------------------------------------------------------

return addon
