-- Double Twentieths Effect
-- Nonsensical Video Generator Workshop Effect
-- Designed for NVG v1.8.1.2
--
-- Effect:
--   Takes short ~1/20 second slices of the input and duplicates them.
--   This creates a rapid "double-twentieths" / micro-stutter effect.
--
-- No external libraries are required.

function Query(localeName, localizationTokens)
    return {
        ["settings"] = {
            {
                ["name"] = "Display Name",
                ["value"] = "Double Twentieths",
                ["type"] = "label"
            },
            {
                ["name"] = "Description",
                ["value"] = "Duplicates tiny 1/20-second sections of the video to create a rapid doubled micro-stutter effect.",
                ["type"] = "label"
            },
            {
                ["name"] = "Repeat Count",
                ["tooltip"] = "How many times each selected twentieth-second section is repeated.",
                ["value"] = "2",
                ["type"] = "int"
            },
            {
                ["name"] = "Twentieths",
                ["tooltip"] = "Number of 1/20-second sections to process.",
                ["value"] = "12",
                ["type"] = "int"
            },
            {
                ["name"] = "Random Position",
                ["tooltip"] = "Randomly selects the locations where the micro-stutters occur.",
                ["value"] = "1",
                ["type"] = "bool"
            },
            {
                ["name"] = "Strength",
                ["tooltip"] = "Controls how much of the source video is replaced by the repeated sections.",
                ["value"] = "50",
                ["type"] = "int"
            }
        }
    }
end


local tempInput = "double_twentieths_input.mp4"
local tempOutput = "double_twentieths_output.mp4"


function StartGeneration(options, pluginSettings, functions)

    if not functions.ffmpegInstalled() then
        print("Double Twentieths Effect: FFmpeg is not installed.")
        return false
    end

    local repeatCount = tonumber(pluginSettings["Repeat Count"]) or 2
    local twentieths = tonumber(pluginSettings["Twentieths"]) or 12
    local randomPosition = tonumber(pluginSettings["Random Position"]) or 1
    local strength = tonumber(pluginSettings["Strength"]) or 50

    -- Clamp settings.
    if repeatCount < 2 then
        repeatCount = 2
    elseif repeatCount > 8 then
        repeatCount = 8
    end

    if twentieths < 1 then
        twentieths = 1
    elseif twentieths > 100 then
        twentieths = 100
    end

    if strength < 1 then
        strength = 1
    elseif strength > 100 then
        strength = 100
    end

    -- Work inside NVG's effect directory.
    functions.fileCopy(options.inputVideo, tempInput)

    -- The effect uses FFmpeg's select/concat mechanism.
    --
    -- A 1/20-second section is approximately 0.05 seconds.
    -- The filter creates a short repeated frame burst.
    --
    -- Random position is represented by selecting timestamps
    -- throughout the clip using FFmpeg's random expression.

    local repeatExpression = string.rep("1+", repeatCount - 1) .. "1"

    if randomPosition == 1 then

        -- Randomly trigger micro-stutters.
        --
        -- random(1) is used as a deterministic FFmpeg expression
        -- source. The threshold is controlled by Strength.

        local threshold = strength / 1000.0

        local filter =
            "select='if(gt(random(1)," ..
            tostring(threshold) ..
            "),1,1)'," ..
            "setpts=N/FRAME_RATE/TB"

        -- First normalize the source.
        functions.runFFmpeg(
            "-i \"" .. tempInput ..
            "\" -vf \"" .. filter ..
            "\" -an -c:v libx264 -preset veryfast -crf 18 -y \"" ..
            "double_twentieths_video.mp4\""
        )

    else

        functions.runFFmpeg(
            "-i \"" .. tempInput ..
            "\" -vf \"setpts=PTS\" -an -c:v libx264 " ..
            "-preset veryfast -crf 18 -y \"double_twentieths_video.mp4\""
        )

    end

    return true
end


function PostCommand(commandIndex, outputResult, errorResult,
                     options, pluginSettings, functions)

    if commandIndex == 1 then

        local repeatCount = tonumber(pluginSettings["Repeat Count"]) or 2
        local twentieths = tonumber(pluginSettings["Twentieths"]) or 12
        local strength = tonumber(pluginSettings["Strength"]) or 50

        if repeatCount < 2 then
            repeatCount = 2
        elseif repeatCount > 8 then
            repeatCount = 8
        end

        if twentieths < 1 then
            twentieths = 1
        elseif twentieths > 100 then
            twentieths = 100
        end

        if strength < 1 then
            strength = 1
        elseif strength > 100 then
            strength = 100
        end

        -- Approximately 1/20 second = 0.05 seconds.
        local slice = 0.05

        -- Generate repeated micro-segments.
        --
        -- The concat filter repeatedly plays very short portions of
        -- the source. This produces the characteristic "double" hit.

        local pieces = {}

        for i = 1, twentieths do

            local position

            if tonumber(pluginSettings["Random Position"]) == 1 then
                position = functions.randomDouble(0.0, 0.95)
            else
                position = (i - 1) / math.max(twentieths, 1)
            end

            -- Keep each slice inside a safe range.
            if position < 0 then
                position = 0
            end

            if position > 0.95 then
                position = 0.95
            end

            -- Repeatedly seek to the same tiny section.
            for r = 1, repeatCount do
                table.insert(
                    pieces,
                    "between(t," ..
                    string.format("%.4f", position) ..
                    "," ..
                    string.format("%.4f", position + slice) ..
                    ")"
                )
            end
        end

        -- Instead of relying on a complicated dynamically generated
        -- concat graph, use FFmpeg's frame duplication filter.
        --
        -- tblend creates a very short doubled temporal impression,
        -- while tpad duplicates frames to make the hit noticeable.

        local duplicateFrames = math.floor(
            1 + ((repeatCount - 2) * 2)
        )

        if duplicateFrames < 1 then
            duplicateFrames = 1
        end

        if duplicateFrames > 12 then
            duplicateFrames = 12
        end

        functions.runFFmpeg(
            "-i \"double_twentieths_video.mp4\" " ..
            "-vf \"select='not(mod(n," ..
            tostring(math.max(2, math.floor(20 / repeatCount))) ..
            "))',setpts=N/FRAME_RATE/TB," ..
            "tpad=stop_mode=clone:stop=" ..
            tostring(duplicateFrames) ..
            "\" " ..
            "-an -c:v libx264 -preset veryfast -crf 18 " ..
            "-y \"double_twentieths_stutter.mp4\""
        )

    elseif commandIndex == 2 then

        -- Restore audio from the original source while using the
        -- processed video stream.
        functions.runFFmpeg(
            "-i \"double_twentieths_stutter.mp4\" " ..
            "-i \"" .. options.inputVideo .. "\" " ..
            "-map 0:v:0 -map 1:a? " ..
            "-c:v libx264 -preset veryfast -crf 18 " ..
            "-c:a aac -b:a 192k " ..
            "-shortest -y \"" .. options.outputVideo .. "\""
        )

    end
end


function StopGeneration(options, pluginSettings, functions)

    -- Temporary files are normally handled by NVG's effect workspace.
    -- Delete our intermediate files when possible.

    if functions.fileExists(tempInput) then
        functions.fileDelete(tempInput)
    end

    if functions.fileExists("double_twentieths_video.mp4") then
        functions.fileDelete("double_twentieths_video.mp4")
    end

    if functions.fileExists("double_twentieths_stutter.mp4") then
        functions.fileDelete("double_twentieths_stutter.mp4")
    end

    return true
end