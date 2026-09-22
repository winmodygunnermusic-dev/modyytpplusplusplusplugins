-- YTPMV Short Effects
-- Nonsensical Video Generator
-- Short/simple YTPMV-style effect addon

function Query()
    return {
        ["name"] = "YTPMV Short Effects",
        ["description"] = "Short chaotic effects for YTPMV-style edits.",
        ["version"] = "1.0",

        ["settings"] = {
            {
                ["name"] = "Effect",
                ["value"] = "Stutter",
                ["type"] = "label"
            }
        }
    }
end

function StartGeneration(options, pluginSettings, functions)
    if not functions.ffmpegInstalled() then
        return false
    end

    local filter =
        "select='lt(mod(n,8),2)',setpts=N/FRAME_RATE/TB," ..
        "tblend=all_mode=average,fps=30"

    functions.runFFmpeg(
        "-i \"" .. options.inputVideo .. "\" " ..
        "-vf \"" .. filter .. "\" " ..
        "-filter:a \"atempo=1.25\" " ..
        "-c:v libx264 -preset veryfast -crf 18 -c:a aac -y \"" ..
        options.outputVideo .. "\""
    )

    return true
end

function PostCommand(commandIndex, outputResult, errorResult, options, pluginSettings, functions)
end

function StopGeneration(options, pluginSettings, functions)
    return true
end
