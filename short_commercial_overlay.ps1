-- Short Commercial Overlay
-- Nonsensical Video Generator Workshop addon
-- NVG v1.8.x

local function numberSetting(settings, name, defaultValue)
    local value = tonumber(settings[name])
    if value == nil then
        return defaultValue
    end
    return value
end

function Query()
    return {
        ["name"] = "Short Commercial Overlay",
        ["description"] = "Randomly overlays a short commercial clip over the source video.",

        ["settings"] = {
            {
                ["name"] = "Chance",
                ["value"] = "35",
                ["type"] = "number"
            },
            {
                ["name"] = "Max Duration",
                ["value"] = "4",
                ["type"] = "number"
            }
        },

        ["libraries"] = {
            {
                ["name"] = "Commercials",
                ["type"] = "video",
                ["description"] = "Short commercial clips used as overlays."
            }
        }
    }
end

function StartGeneration(options, pluginSettings, functions)
    if not functions.ffmpegInstalled() then
        return false
    end

    local chance = numberSetting(pluginSettings, "Chance", 35)
    if functions.randomInt(1, 100) > chance then
        functions.fileCopy(options.inputVideo, options.outputVideo)
        return true
    end

    local commercial = functions.getRandomLibraryFile("video", "Commercials")
    if commercial == nil or commercial == "" then
        functions.fileCopy(options.inputVideo, options.outputVideo)
        return true
    end

    local maxDuration = math.max(0.1, numberSetting(pluginSettings, "Max Duration", 4))
    local width = tonumber(options.width) or 1280
    local height = tonumber(options.height) or 720

    local filter =
        "[1:v]trim=0:" .. tostring(maxDuration) ..
        ",setpts=PTS-STARTPTS,scale=" .. tostring(width) .. ":" .. tostring(height) ..
        ":force_original_aspect_ratio=increase,crop=" .. tostring(width) .. ":" .. tostring(height) ..
        "[ad];[0:v][ad]overlay=0:0:enable='between(t,0," .. tostring(maxDuration) .. ")'[v]"

    functions.runFFmpeg(
        "-i \"" .. options.inputVideo .. "\" " ..
        "-i \"" .. commercial .. "\" " ..
        "-filter_complex \"" .. filter .. "\" " ..
        "-map \"[v]\" -map 0:a? -c:v libx264 -preset veryfast -crf 18 " ..
        "-c:a copy -shortest -y \"" .. options.outputVideo .. "\""
    )

    return true
end

function PostCommand(commandIndex, outputResult, errorResult, options, pluginSettings, functions)
end

function StopGeneration(options, pluginSettings, functions)
    return true
end
