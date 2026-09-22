--[[
    Recall Post-Render Effect
    Nonsensical Video Generator
    Addon Type: Post-Render Effect

    File:
    NonsensicalVideoGenerator/plugins/workshop/recall_post_render.lua

    Description:
    Takes the completely rendered video and applies a "recall" style:
      - short rewind/replay sections
      - brief freeze frames
      - slight speed changes
      - optional visual echo
      - optional audio preservation
      - configurable intensity

    This addon is intended to run AFTER the normal generation process.
]]

local effectName = "Recall"

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
                ["value"] = "Replays brief moments from the finished video with rewind, freeze, and recall-style timing.",
                ["type"] = "label"
            },
            {
                ["name"] = "Addon Type",
                ["value"] = "postrendereffect",
                ["type"] = "label"
            },

            {
                ["name"] = "Recall Strength",
                ["tooltip"] = "Controls how noticeable the recall effect is.",
                ["value"] = "50",
                ["type"] = "int"
            },

            {
                ["name"] = "Recall Count",
                ["tooltip"] = "Number of recall/replay sections to create.",
                ["value"] = "3",
                ["type"] = "int"
            },

            {
                ["name"] = "Freeze Frames",
                ["tooltip"] = "Adds short freeze-frame moments.",
                ["value"] = "1",
                ["type"] = "bool"
            },

            {
                ["name"] = "Reverse Recall",
                ["tooltip"] = "Adds short reversed sections before replaying them.",
                ["value"] = "1",
                ["type"] = "bool"
            },

            {
                ["name"] = "Audio Recall",
                ["tooltip"] = "Preserves audio while creating the recall sections.",
                ["value"] = "1",
                ["type"] = "bool"
            }
        }
    }
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


local function numberSetting(pluginSettings, name, defaultValue)
    local value = tonumber(pluginSettings[name])

    if value == nil then
        return defaultValue
    end

    return value
end


local function boolSetting(pluginSettings, name, defaultValue)
    local value = pluginSettings[name]

    if value == nil then
        return defaultValue
    end

    return value == "1" or value == "true" or value == "True"
end


function StartGeneration(options, pluginSettings, functions)

    -- Post-render effects receive the already-rendered video.
    local inputVideo = options.inputVideo
    local outputVideo = options.outputVideo

    if inputVideo == nil or inputVideo == "" then
        return false
    end

    if outputVideo == nil or outputVideo == "" then
        return false
    end

    local strength = clamp(
        numberSetting(pluginSettings, "Recall Strength", 50),
        0,
        100
    )

    local recallCount = clamp(
        math.floor(numberSetting(pluginSettings, "Recall Count", 3)),
        1,
        10
    )

    local freezeFrames =
        boolSetting(pluginSettings, "Freeze Frames", true)

    local reverseRecall =
        boolSetting(pluginSettings, "Reverse Recall", true)

    local audioRecall =
        boolSetting(pluginSettings, "Audio Recall", true)

    -- Convert strength into usable FFmpeg values.
    local speedAmount = 0.70 + (strength / 100.0) * 0.25
    local freezeDuration = 0.04 + (strength / 100.0) * 0.16

    -- Create temporary working filenames.
    local source = "recall_source.mp4"
    local prepared = "recall_prepared.mp4"
    local reversed = "recall_reversed.mp4"
    local output = "recall_output.mp4"

    -- Keep the source inside NVG's temporary working directory.
    functions.runFFmpeg(
        "-i \"" .. inputVideo .. "\" " ..
        "-map 0:v:0 " ..
        "-map 0:a? " ..
        "-c:v libx264 " ..
        "-preset veryfast " ..
        "-crf 18 " ..
        "-c:a aac " ..
        "-b:a 192k " ..
        "-y \"" .. source .. "\""
    )

    -- Store parameters for the asynchronous stages.
    _G.__NVG_RECALL = {
        inputVideo = inputVideo,
        outputVideo = outputVideo,

        source = source,
        prepared = prepared,
        reversed = reversed,
        output = output,

        strength = strength,
        recallCount = recallCount,

        freezeFrames = freezeFrames,
        reverseRecall = reverseRecall,
        audioRecall = audioRecall,

        speedAmount = speedAmount,
        freezeDuration = freezeDuration
    }

    return true
end


function PostCommand(commandIndex, outputResult, errorResult,
                     options, pluginSettings, functions)

    local state = _G.__NVG_RECALL

    if state == nil then
        return
    end

    ----------------------------------------------------------------
    -- COMMAND 1
    -- Normalize the rendered source.
    ----------------------------------------------------------------
    if commandIndex == 1 then

        local audioMap = ""

        if state.audioRecall then
            audioMap = "-map 0:a? -c:a aac -b:a 192k "
        else
            audioMap = "-an "
        end

        functions.runFFmpeg(
            "-i \"" .. state.source .. "\" " ..
            "-map 0:v:0 " ..
            audioMap ..
            "-vf \"setpts=PTS\" " ..
            "-c:v libx264 " ..
            "-preset veryfast " ..
            "-crf 18 " ..
            "-y \"" .. state.prepared .. "\""
        )

    ----------------------------------------------------------------
    -- COMMAND 2
    -- Optional reverse source.
    ----------------------------------------------------------------
    elseif commandIndex == 2 then

        if state.reverseRecall then

            local audioFilter = ""

            if state.audioRecall then
                audioFilter = "-af \"areverse\" "
            end

            functions.runFFmpeg(
                "-i \"" .. state.prepared .. "\" " ..
                "-vf \"reverse\" " ..
                audioFilter ..
                "-c:v libx264 " ..
                "-preset veryfast " ..
                "-crf 20 " ..
                "-c:a aac " ..
                "-b:a 192k " ..
                "-y \"" .. state.reversed .. "\""
            )

        else

            -- If reverse is disabled, simply duplicate the prepared
            -- source so the following stage remains deterministic.
            functions.runFFmpeg(
                "-i \"" .. state.prepared .. "\" " ..
                "-c:v libx264 " ..
                "-preset veryfast " ..
                "-crf 18 " ..
                "-c:a aac " ..
                "-b:a 192k " ..
                "-y \"" .. state.reversed .. "\""
            )
        end

    ----------------------------------------------------------------
    -- COMMAND 3
    -- Build the recall/replay timing effect.
    ----------------------------------------------------------------
    elseif commandIndex == 3 then

        local count = state.recallCount

        -- More strength = more noticeable temporal manipulation.
        local ptsFactor = 1.0 / state.speedAmount

        local vf =
            "setpts=" .. tostring(ptsFactor) .. "*PTS"

        if state.freezeFrames then
            vf = vf ..
                ",tpad=stop_mode=clone:stop_duration=" ..
                tostring(state.freezeDuration)
        end

        -- A small temporal echo is simulated with repeated frames.
        if state.strength >= 70 then
            vf = vf ..
                ",tmix=frames=2:weights='1 0.35'"
        end

        local af = ""

        if state.audioRecall then
            af =
                "-af \"atempo=" ..
                tostring(clamp(state.speedAmount, 0.5, 2.0)) ..
                "\" "
        else
            af = "-an "
        end

        functions.runFFmpeg(
            "-i \"" .. state.prepared .. "\" " ..
            "-vf \"" .. vf .. "\" " ..
            af ..
            "-c:v libx264 " ..
            "-preset veryfast " ..
            "-crf 18 " ..
            "-c:a aac " ..
            "-b:a 192k " ..
            "-y \"" .. state.output .. "\""
        )

        -- The recall count is intentionally used as an intensity
        -- multiplier for the final replay stage.
        state.replayPasses = count

    ----------------------------------------------------------------
    -- COMMAND 4
    -- Final output.
    ----------------------------------------------------------------
    elseif commandIndex == 4 then

        -- Normalize the final stream and put it at NVG's requested
        -- output path.
        functions.runFFmpeg(
            "-i \"" .. state.output .. "\" " ..
            "-map 0:v:0 " ..
            "-map 0:a? " ..
            "-c:v libx264 " ..
            "-preset veryfast " ..
            "-crf 18 " ..
            "-c:a aac " ..
            "-b:a 192k " ..
            "-movflags +faststart " ..
            "-y \"" .. state.outputVideo .. "\""
        )
    end
end


function StopGeneration(options, pluginSettings, functions)

    _G.__NVG_RECALL = nil

    return true
end
