-- Pitch Shift Effect
-- Nonsensical Video Generator
-- Changes the pitch of the video's audio without intentionally changing
-- the video's playback speed.
--
-- File:
-- plugins/workshop/pitch_shift/pitch_shift.lua

local effectName = "Pitch Shift"

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
                ["value"] = "Shifts the pitch of the audio up or down.",
                ["type"] = "label"
            },
            {
                ["name"] = "Pitch Semitones",
                ["tooltip"] = "Pitch shift in semitones. Positive raises pitch, negative lowers it.",
                ["value"] = "5",
                ["type"] = "float"
            },
            {
                ["name"] = "Randomize",
                ["tooltip"] = "Randomly selects a pitch shift within the selected range.",
                ["value"] = "0",
                ["type"] = "bool"
            },
            {
                ["name"] = "Random Range",
                ["tooltip"] = "Maximum random pitch distance in semitones.",
                ["value"] = "8",
                ["type"] = "float"
            }
        }
    }
end

function StartGeneration(options, pluginSettings, functions)

    local input = options.inputVideo
    local output = options.outputVideo

    local semitones = tonumber(pluginSettings["Pitch Semitones"]) or 5
    local randomize = pluginSettings["Randomize"] == "1"
    local randomRange = tonumber(pluginSettings["Random Range"]) or 8

    if randomize then
        semitones = functions.randomDouble(-randomRange, randomRange)
    end

    -- Convert semitones to an audio pitch multiplier.
    --
    -- 1 semitone = approximately 1.059463x frequency.
    local pitch = math.pow(2, semitones / 12.0)

    -- Keep the value within a practical range.
    if pitch < 0.25 then
        pitch = 0.25
    elseif pitch > 4.0 then
        pitch = 4.0
    end

    -- FFmpeg's rubberband filter may not be available in every build,
    -- so use the standard asetrate + aresample + atempo technique.
    --
    -- asetrate changes pitch and speed.
    -- atempo compensates for the speed change while preserving duration.
    local sampleRate = 48000

    local args =
        "-i \"" .. input .. "\" " ..
        "-map 0:v? " ..
        "-map 0:a? " ..
        "-c:v copy " ..
        "-af \"asetrate=" .. sampleRate .. "*" .. string.format("%.8f", pitch) ..
        ",aresample=" .. sampleRate ..
        ",atempo=" .. string.format("%.8f", 1.0 / pitch) .. "\" " ..
        "-c:a aac " ..
        "-b:a 192k " ..
        "-ar " .. sampleRate .. " " ..
        "-y \"" .. output .. "\""

    functions.runFFmpeg(args)

    print(
        "<[120,220,255]>Pitch Shift: " ..
        string.format("%.2f", semitones) ..
        " semitones"
    )

    return true
end

function PostCommand(commandIndex, outputResult, errorResult,
                     options, pluginSettings, functions)

    if commandIndex == 1 then
        if errorResult ~= nil and errorResult ~= "" then
            print("<[255,80,80]>Pitch Shift FFmpeg error: " .. errorResult)
        else
            print("<[120,255,120]>Pitch Shift complete.")
        end
    end
end

function StopGeneration(options, pluginSettings, functions)
    return true
end
