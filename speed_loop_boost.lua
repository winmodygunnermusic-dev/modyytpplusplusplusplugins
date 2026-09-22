--[[
    Speed Loop Boost Effect
    Nonsensical Video Generator Workshop Addon

    Effect:
        Takes a short section from the beginning of the video,
        repeats it several times while progressively increasing
        playback speed, then continues with the remainder.

    Suggested filename:
        speed_loop_boost.lua

    Suggested addon folder:
        speed_loop_boost
]]

local EFFECT_NAME = "Speed Loop Boost"
local EFFECT_DESCRIPTION =
    "Repeats a short video loop with progressively increasing playback speed."

local function settingNumber(pluginSettings, name, defaultValue)
    local value = tonumber(pluginSettings[name])
    if value == nil then
        return defaultValue
    end
    return value
end

local function clamp(value, minimum, maximum)
    if value < minimum then
        return minimum
    end

    if value > maximum then
        return maximum
    end

    return value
end

function Query(localeName, localizationTokens)
    return {
        ["settings"] = {
            {
                ["name"] = "Display Name",
                ["value"] = EFFECT_NAME,
                ["type"] = "label"
            },

            {
                ["name"] = "Description",
                ["value"] = EFFECT_DESCRIPTION,
                ["type"] = "label"
            },

            {
                ["name"] = "Loop Count",
                ["tooltip"] = "Number of times the boosted loop is repeated.",
                ["value"] = "4",
                ["type"] = "int"
            },

            {
                ["name"] = "Loop Duration",
                ["tooltip"] = "Length of the loop section in seconds.",
                ["value"] = "0.60",
                ["type"] = "float"
            },

            {
                ["name"] = "Starting Speed",
                ["tooltip"] = "Playback speed of the first loop.",
                ["value"] = "1.00",
                ["type"] = "float"
            },

            {
                ["name"] = "Boost Multiplier",
                ["tooltip"] = "Speed multiplier applied to each successive loop.",
                ["value"] = "1.50",
                ["type"] = "float"
            },

            {
                ["name"] = "Maximum Speed",
                ["tooltip"] = "Maximum playback speed allowed for a loop.",
                ["value"] = "8.00",
                ["type"] = "float"
            },

            {
                ["name"] = "Randomize Boost",
                ["tooltip"] = "Adds small random variations to each loop speed.",
                ["value"] = "1",
                ["type"] = "bool"
            }
        }
    }
end

function StartGeneration(options, pluginSettings, functions)
    if not functions.ffmpegInstalled() then
        print("<[255,0,0]>Speed Loop Boost: FFmpeg is not installed.")
        return false
    end

    local loopCount = math.floor(
        clamp(
            settingNumber(pluginSettings, "Loop Count", 4),
            2,
            12
        )
    )

    local loopDuration = clamp(
        settingNumber(pluginSettings, "Loop Duration", 0.60),
        0.05,
        10.0
    )

    local startingSpeed = clamp(
        settingNumber(pluginSettings, "Starting Speed", 1.0),
        0.25,
        16.0
    )

    local boostMultiplier = clamp(
        settingNumber(pluginSettings, "Boost Multiplier", 1.50),
        1.01,
        4.0
    )

    local maximumSpeed = clamp(
        settingNumber(pluginSettings, "Maximum Speed", 8.0),
        1.0,
        32.0
    )

    local randomize = tostring(pluginSettings["Randomize Boost"] or "1") == "1"

    -- Store calculated values for PostCommand.
    _G.SpeedLoopBoostState = {
        loopCount = loopCount,
        loopDuration = loopDuration,
        startingSpeed = startingSpeed,
        boostMultiplier = boostMultiplier,
        maximumSpeed = maximumSpeed,
        randomize = randomize
    }

    local state = _G.SpeedLoopBoostState

    -- Build the video filter.
    --
    -- Input:
    --   [0:v]
    --
    -- For every loop:
    --   take the same beginning segment
    --   change playback speed
    --   reset timestamps
    --
    -- Finally:
    --   concatenate all boosted loops
    --   append the remainder of the original video
    --

    local videoInputs = {}
    local videoLabels = {}

    for i = 1, state.loopCount do
        local speed = state.startingSpeed *
            (state.boostMultiplier ^ (i - 1))

        if state.randomize then
            local variation = functions.randomDouble(0.90, 1.10)
            speed = speed * variation
        end

        speed = clamp(speed, 0.25, state.maximumSpeed)

        local inputLabel = "[vloop" .. tostring(i) .. "]"
        local outputLabel = "[vboost" .. tostring(i) .. "]"

        table.insert(
            videoInputs,
            string.format(
                "[0:v]trim=start=0:end=%.4f,setpts=PTS-STARTPTS,setpts=PTS/%.5f%s",
                state.loopDuration,
                speed,
                outputLabel
            )
        )

        table.insert(videoLabels, outputLabel)
    end

    -- The remainder begins after the loop segment.
    table.insert(
        videoInputs,
        string.format(
            "[0:v]trim=start=%.4f,setpts=PTS-STARTPTS[vrest]",
            state.loopDuration
        )
    )

    -- Concat all boosted sections and the rest of the video.
    local concatInputs = ""

    for _, label in ipairs(videoLabels) do
        concatInputs = concatInputs .. label
    end

    concatInputs = concatInputs .. "[vrest]"

    local filterComplex =
        table.concat(videoInputs, ";") ..
        ";" ..
        concatInputs ..
        "concat=n=" ..
        tostring(#videoLabels + 1) ..
        ":v=1:a=0[vout]"

    -- Audio is kept synchronized by applying the same looping concept.
    --
    -- Each loop receives an atempo chain so speeds above 2x remain valid.
    -- The original remainder is appended afterward.
    local audioInputs = {}
    local audioLabels = {}

    for i = 1, state.loopCount do
        local speed = state.startingSpeed *
            (state.boostMultiplier ^ (i - 1))

        if state.randomize then
            -- Reuse a deterministic approximation for audio.
            speed = clamp(speed, 0.25, state.maximumSpeed)
        end

        speed = clamp(speed, 0.25, state.maximumSpeed)

        local label = "[aboost" .. tostring(i) .. "]"

        -- atempo accepts a maximum of 2.0 per filter instance.
        -- Generate a chain of atempo filters for high speed values.
        local remaining = speed
        local atempoFilters = ""

        while remaining > 2.0 do
            atempoFilters = atempoFilters .. "atempo=2.0,"
            remaining = remaining / 2.0
        end

        while remaining < 0.5 do
            atempoFilters = atempoFilters .. "atempo=0.5,"
            remaining = remaining / 0.5
        end

        atempoFilters = atempoFilters ..
            string.format("atempo=%.5f", remaining)

        table.insert(
            audioInputs,
            string.format(
                "[0:a]atrim=start=0:end=%.4f,asetpts=PTS-STARTPTS,%s%s",
                state.loopDuration,
                atempoFilters,
                label
            )
        )

        table.insert(audioLabels, label)
    end

    table.insert(
        audioInputs,
        string.format(
            "[0:a]atrim=start=%.4f,asetpts=PTS-STARTPTS[arest]",
            state.loopDuration
        )
    )

    local audioConcatInputs = ""

    for _, label in ipairs(audioLabels) do
        audioConcatInputs = audioConcatInputs .. label
    end

    audioConcatInputs = audioConcatInputs .. "[arest]"

    local audioFilter =
        table.concat(audioInputs, ";") ..
        ";" ..
        audioConcatInputs ..
        "concat=n=" ..
        tostring(#audioLabels + 1) ..
        ":v=0:a=1[aout]"

    filterComplex = filterComplex .. ";" .. audioFilter

    -- Save the filter for PostCommand.
    state.filterComplex = filterComplex

    -- Start FFmpeg.
    --
    -- The optional audio map allows videos without audio to be handled
    -- without forcing an audio stream.
    local command =
        "-i \"" .. options.inputVideo .. "\" " ..
        "-filter_complex \"" .. state.filterComplex .. "\" " ..
        "-map \"[vout]\" " ..
        "-map \"[aout]\"? " ..
        "-c:v libx264 " ..
        "-preset veryfast " ..
        "-crf 18 " ..
        "-c:a aac " ..
        "-b:a 192k " ..
        "-movflags +faststart " ..
        "-y \"" .. options.outputVideo .. "\""

    print("<[0,220,255]>Speed Loop Boost: starting effect.")
    print("Loop count: " .. tostring(state.loopCount))
    print("Loop duration: " .. tostring(state.loopDuration) .. " seconds")
    print("Starting speed: " .. tostring(state.startingSpeed) .. "x")
    print("Boost multiplier: " .. tostring(state.boostMultiplier) .. "x")

    functions.runFFmpeg(command)

    return true
end

function PostCommand(
    commandIndex,
    outputResult,
    errorResult,
    options,
    pluginSettings,
    functions
)
    if commandIndex == 1 then
        if errorResult ~= nil and errorResult ~= "" then
            print("<[255,80,80]>Speed Loop Boost FFmpeg error:")
            print(errorResult)
        else
            print("<[100,255,100]>Speed Loop Boost completed.")
        end
    end
end

function StopGeneration(options, pluginSettings, functions)
    _G.SpeedLoopBoostState = nil
    return true
end