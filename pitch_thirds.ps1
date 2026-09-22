--[[
    Pitch Thirds Effect
    Nonsensical Video Generator
    NVG Workshop Addon

    Applies a musical-third pitch shift to the audio:
      +4 semitones = major third upward
      -4 semitones = major third downward

    The pitch shift preserves the approximate original duration by
    compensating the sample-rate change with atempo.

    File:
      pitch_thirds.lua
]]

local effectName = "Pitch Thirds"

-- Convert semitones to a pitch ratio.
local function semitonesToRatio(semitones)
    return math.pow(2.0, semitones / 12.0)
end

-- Safely convert a plugin setting to a number.
local function settingNumber(settings, name, defaultValue)
    local value = tonumber(settings[name])

    if value == nil then
        return defaultValue
    end

    return value
end

-- Clamp a number to a range.
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
                ["value"] = effectName,
                ["type"] = "label"
            },

            {
                ["name"] = "Description",
                ["value"] =
                    "Shifts the video's audio by a musical third while keeping the original duration.",
                ["type"] = "label"
            },

            {
                ["name"] = "Pitch Direction",
                ["tooltip"] =
                    "Choose whether the pitch goes upward, downward, or randomly.",
                ["value"] = "Random",
                ["type"] = "string"
            },

            {
                ["name"] = "Intensity",
                ["tooltip"] =
                    "0 = no pitch shift, 100 = full major-third pitch shift.",
                ["value"] = "100",
                ["type"] = "int"
            },

            {
                ["name"] = "Randomize",
                ["tooltip"] =
                    "Randomly chooses upward or downward pitch thirds when enabled.",
                ["value"] = "1",
                ["type"] = "bool"
            },

            {
                ["name"] = "Chance Roll",
                ["tooltip"] =
                    "Percentage chance for the effect to use the pitch-third transformation.",
                ["value"] = "100",
                ["type"] = "int"
            }
        }
    }
end


function StartGeneration(options, pluginSettings, functions)

    -- Seed randomness using NVG's helper where possible.
    math.randomseed(os.time())

    local chance = clamp(
        settingNumber(pluginSettings, "Chance Roll", 100),
        0,
        100
    )

    local roll = functions.randomInt(1, 100)

    if roll > chance then

        -- Effect did not trigger.
        print("<[180,180,180]>Pitch Thirds: skipped by chance roll.")

        functions.runFFmpeg(
            "-i \"" .. options.inputVideo .. "\" " ..
            "-map 0:v? -map 0:a? " ..
            "-c:v libx264 -preset veryfast -crf 18 " ..
            "-c:a aac -b:a 192k " ..
            "-movflags +faststart " ..
            "-y \"" .. options.outputVideo .. "\""
        )

        return true
    end


    local intensity = clamp(
        settingNumber(pluginSettings, "Intensity", 100),
        0,
        100
    )

    -- Full major third = 4 semitones.
    local semitones = 4.0 * (intensity / 100.0)

    local randomize =
        tostring(pluginSettings["Randomize"] or "1") == "1"

    local direction =
        tostring(pluginSettings["Pitch Direction"] or "Random")


    if randomize then

        if functions.randomBool() then
            semitones = math.abs(semitones)
        else
            semitones = -math.abs(semitones)
        end

    elseif string.lower(direction) == "up"
        or string.lower(direction) == "upward"
        or string.lower(direction) == "positive" then

        semitones = math.abs(semitones)

    elseif string.lower(direction) == "down"
        or string.lower(direction) == "downward"
        or string.lower(direction) == "negative" then

        semitones = -math.abs(semitones)

    else

        -- Unknown/random direction.
        if functions.randomBool() then
            semitones = math.abs(semitones)
        else
            semitones = -math.abs(semitones)
        end
    end


    local ratio = semitonesToRatio(semitones)

    -- After changing sample rate, atempo is used to restore the
    -- original duration.
    local tempoCompensation = 1.0 / ratio

    print(
        "<[120,220,255]>Pitch Thirds: " ..
        string.format("%.2f", semitones) ..
        " semitones, ratio " ..
        string.format("%.5f", ratio)
    )


    -- Normalize audio to 48 kHz first.
    --
    -- Then:
    --   asetrate = changes pitch and speed
    --   aresample = returns audio to 48 kHz
    --   atempo = restores original timing
    --
    -- 4 semitones:
    --   ratio ≈ 1.25992
    --
    -- -4 semitones:
    --   ratio ≈ 0.79370
    --
    -- Both atempo values are inside FFmpeg's normal single-filter
    -- operating range.

    local audioFilter =
        "[0:a]" ..
        "aresample=48000," ..
        "asetrate=" ..
        string.format("%.8f", 48000.0 * ratio) ..
        "," ..
        "aresample=48000," ..
        "atempo=" ..
        string.format("%.8f", tempoCompensation) ..
        "[pitched]"


    -- Video remains visually unchanged.
    -- Audio is replaced with the pitch-shifted stream.
    --
    -- -map 0:v? allows video-only material.
    -- -map "[pitched]" uses the transformed audio when available.
    local command =
        "-i \"" .. options.inputVideo .. "\" " ..

        "-filter_complex \"" ..
        audioFilter ..
        "\" " ..

        "-map 0:v? " ..
        "-map \"[pitched]\" " ..

        "-c:v libx264 " ..
        "-preset veryfast " ..
        "-crf 18 " ..

        "-c:a aac " ..
        "-b:a 192k " ..

        "-movflags +faststart " ..

        "-y \"" .. options.outputVideo .. "\""


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

    if errorResult ~= nil and errorResult ~= "" then

        print(
            "<[255,120,120]>Pitch Thirds FFmpeg output: " ..
            tostring(errorResult)
        )

    end

    if outputResult ~= nil and outputResult ~= "" then

        print(
            "<[180,255,180]>Pitch Thirds FFmpeg completed."
        )

    end

    return nil
end


function StopGeneration(options, pluginSettings, functions)

    print("<[120,255,180]>Pitch Thirds: finished.")

    return true
end
