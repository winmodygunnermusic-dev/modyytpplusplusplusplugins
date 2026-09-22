-- Repeatedly Slow Down Effect
-- Nonsensical Video Generator
-- NVG Workshop Lua Effect
--
-- Repeatedly applies a slow-motion pass to the input.
-- Each pass makes the video progressively slower.

local currentPass = 0
local totalPasses = 3
local slowFactor = 0.75
local tempA = "repeatedly_slow_down_a.mp4"
local tempB = "repeatedly_slow_down_b.mp4"

function Query(localeName, localizationTokens)
    return {
        ["name"] = "Repeatedly Slow Down",

        ["settings"] = {
            {
                ["name"] = "Display Name",
                ["value"] = "Repeatedly Slow Down"
            },
            {
                ["name"] = "Description",
                ["value"] = "Repeatedly slows the video down through multiple passes."
            },
            {
                ["name"] = "Slowdown Passes",
                ["tooltip"] = "Number of times the slowdown is applied.",
                ["value"] = "3",
                ["type"] = "int"
            },
            {
                ["name"] = "Slowdown Factor",
                ["tooltip"] = "Playback speed used on every pass. 0.75 = 25% slower.",
                ["value"] = "0.75",
                ["type"] = "float"
            }
        }
    }
end

function StartGeneration(options, pluginSettings, functions)
    currentPass = 0

    totalPasses = tonumber(pluginSettings["Slowdown Passes"]) or 3
    slowFactor = tonumber(pluginSettings["Slowdown Factor"]) or 0.75

    -- Safety limits.
    if totalPasses < 1 then
        totalPasses = 1
    end

    if totalPasses > 8 then
        totalPasses = 8
    end

    if slowFactor <= 0 then
        slowFactor = 0.75
    end

    if slowFactor >= 1 then
        slowFactor = 0.99
    end

    -- First slowdown pass.
    currentPass = 1

    functions.runFFmpeg(
        "-i \"" .. options.inputVideo .. "\" " ..
        "-filter_complex " ..
        "\"[0:v]setpts=" .. (1 / slowFactor) .. "*PTS[v];" ..
        "[0:a]atempo=" .. slowFactor .. "[a]\" " ..
        "-map \"[v]\" -map \"[a]\" " ..
        "-c:v libx264 -preset veryfast -crf 18 " ..
        "-c:a aac -b:a 192k " ..
        "-y \"" .. tempA .. "\""
    )

    return true
end

function PostCommand(commandIndex, outputResult, errorResult,
                     options, pluginSettings, functions)

    -- If this is not the first pass, continue with another pass.
    if currentPass < totalPasses then

        currentPass = currentPass + 1

        local inputFile
        local outputFile

        if currentPass % 2 == 0 then
            inputFile = tempA
            outputFile = tempB
        else
            inputFile = tempB
            outputFile = tempA
        end

        functions.runFFmpeg(
            "-i \"" .. inputFile .. "\" " ..
            "-filter_complex " ..
            "\"[0:v]setpts=" .. (1 / slowFactor) .. "*PTS[v];" ..
            "[0:a]atempo=" .. slowFactor .. "[a]\" " ..
            "-map \"[v]\" -map \"[a]\" " ..
            "-c:v libx264 -preset veryfast -crf 18 " ..
            "-c:a aac -b:a 192k " ..
            "-y \"" .. outputFile .. "\""
        )

    else
        -- Final pass has finished.
        local finalFile

        if currentPass % 2 == 0 then
            finalFile = tempB
        else
            finalFile = tempA
        end

        functions.fileMove(finalFile, options.outputVideo)
    end
end

function StopGeneration(options, pluginSettings, functions)
    return true
end