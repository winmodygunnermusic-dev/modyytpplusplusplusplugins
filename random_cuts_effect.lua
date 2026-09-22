--[[
    Nonsensical Video Generator v1.8.1.2
    Workshop Addon: Random Cuts Effect

    File:
    plugins/workshop/random_cuts_effect.lua

    Effect:
    Random Cuts

    Description:
    Creates randomized hard cuts throughout the source video.
    Shorter intervals produce a fast/chaotic montage while longer
    intervals produce a lighter random-edit effect.

    NOTE:
    This addon uses a generic NVG-style effect interface. If your
    installed NVG build exposes different registration/render API
    names, adapt the registration wrapper to the API used by your
    existing workshop effects.
]]

local RandomCuts = {}

RandomCuts.Name = "Random Cuts Effect"
RandomCuts.Id = "random_cuts"
RandomCuts.Version = "1.0.0"
RandomCuts.Author = "Generated NVG Addon"

RandomCuts.Description =
    "Randomly cuts the video into short sections to create a chaotic jump-cut montage."

------------------------------------------------------------
-- Settings
------------------------------------------------------------

RandomCuts.Settings = {
    {
        id = "intensity",
        name = "Intensity",
        type = "slider",
        min = 0,
        max = 100,
        default = 50
    },

    {
        id = "min_duration",
        name = "Minimum Clip Duration",
        type = "slider",
        min = 0.05,
        max = 5.0,
        default = 0.25
    },

    {
        id = "max_duration",
        name = "Maximum Clip Duration",
        type = "slider",
        min = 0.10,
        max = 10.0,
        default = 1.25
    },

    {
        id = "randomness",
        name = "Randomness",
        type = "slider",
        min = 0,
        max = 100,
        default = 100
    },

    {
        id = "preserve_audio",
        name = "Preserve Audio",
        type = "checkbox",
        default = true
    },

    {
        id = "seed",
        name = "Random Seed",
        type = "number",
        min = 0,
        max = 999999,
        default = 0
    }
}

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

local function randomRange(minimum, maximum)
    return minimum + math.random() * (maximum - minimum)
end

------------------------------------------------------------
-- Generate random cut points
------------------------------------------------------------

function RandomCuts.GenerateCuts(duration, settings)

    local cuts = {}

    if duration <= 0 then
        return cuts
    end

    local intensity =
        clamp(settings.intensity or 50, 0, 100) / 100

    local minimum =
        math.max(0.05, settings.min_duration or 0.25)

    local maximum =
        math.max(minimum, settings.max_duration or 1.25)

    local randomness =
        clamp(settings.randomness or 100, 0, 100) / 100

    --------------------------------------------------------
    -- Higher intensity means shorter average segments.
    --------------------------------------------------------

    local intensityScale =
        1.0 - (intensity * 0.75)

    minimum = minimum * intensityScale
    maximum = maximum * intensityScale

    minimum = math.max(0.05, minimum)
    maximum = math.max(minimum, maximum)

    local position = 0

    while position < duration do

        local segmentLength

        if randomness >= 0.99 then
            segmentLength =
                randomRange(minimum, maximum)
        else
            local midpoint =
                (minimum + maximum) * 0.5

            local randomPart =
                randomRange(minimum, maximum)

            segmentLength =
                midpoint * (1.0 - randomness)
                + randomPart * randomness
        end

        position = position + segmentLength

        if position < duration then
            table.insert(cuts, position)
        end
    end

    return cuts
end

------------------------------------------------------------
-- Build randomized segments
------------------------------------------------------------

function RandomCuts.BuildSegments(duration, cuts)

    local segments = {}

    local startTime = 0

    for _, cutTime in ipairs(cuts) do

        if cutTime > startTime then

            table.insert(segments, {
                start = startTime,
                finish = cutTime
            })

            startTime = cutTime
        end
    end

    if startTime < duration then
        table.insert(segments, {
            start = startTime,
            finish = duration
        })
    end

    return segments
end

------------------------------------------------------------
-- Effect processing
------------------------------------------------------------

function RandomCuts.Process(context, settings)

    if not context then
        return nil
    end

    local duration = context.duration or 0

    if duration <= 0 then
        return context
    end

    --------------------------------------------------------
    -- Seed handling
    --------------------------------------------------------

    local seed = settings.seed or 0

    if seed == 0 then
        seed = os.time()
    end

    math.randomseed(seed)

    --------------------------------------------------------
    -- Generate cut locations
    --------------------------------------------------------

    local cuts =
        RandomCuts.GenerateCuts(duration, settings)

    local segments =
        RandomCuts.BuildSegments(duration, cuts)

    --------------------------------------------------------
    -- Create output timeline
    --------------------------------------------------------

    local output = {
        type = "timeline",
        duration = duration,
        segments = {},
        effect = RandomCuts.Id
    }

    for index, segment in ipairs(segments) do

        local item = {
            index = index,
            source_start = segment.start,
            source_end = segment.finish,
            duration = segment.finish - segment.start,

            transition = "hard_cut"
        }

        ----------------------------------------------------
        -- Audio follows video cuts unless disabled.
        ----------------------------------------------------

        if settings.preserve_audio == false then
            item.audio = false
        else
            item.audio = true
        end

        table.insert(output.segments, item)
    end

    return output
end

------------------------------------------------------------
-- NVG registration wrapper
------------------------------------------------------------

function RandomCuts.Register(nvg)

    if not nvg then
        return false
    end

    --------------------------------------------------------
    -- Generic workshop registration.
    --------------------------------------------------------

    if nvg.register_effect then

        nvg.register_effect({
            id = RandomCuts.Id,
            name = RandomCuts.Name,
            version = RandomCuts.Version,
            author = RandomCuts.Author,
            description = RandomCuts.Description,
            settings = RandomCuts.Settings,

            process = function(context, settings)
                return RandomCuts.Process(context, settings)
            end
        })

        return true
    end

    return false
end

------------------------------------------------------------
-- Default export
------------------------------------------------------------

return RandomCuts
