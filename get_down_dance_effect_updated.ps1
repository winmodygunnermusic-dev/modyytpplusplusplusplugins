-- Get Down Dance Effect (UPDATED)
-- Nonsensical Video Generator
-- Original implementation for NVG 1.8.x
--
-- Visual style:
--   * rhythmic zoom/bounce
--   * left/right dance movement
--   * small rotation
--   * camera shake
--   * optional speed-up
--   * optional audio boost
--
-- No external Lua libraries are required.

local effectName = "Get Down Dance"

local function numberSetting(settings, name, defaultValue)
    local value = tonumber(settings[name])
    if value == nil then
        return defaultValue
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
                ["value"] = "Adds a rhythmic get-down dance effect with bouncing zoom, camera movement, rotation, shake and optional audio punch.",
                ["type"] = "label"
            },
            {
                ["name"] = "Chance Roll",
                ["tooltip"] = "Chance from 0-100 for the effect to activate.",
                ["value"] = "100",
                ["type"] = "int"
            },
            {
                ["name"] = "Dance Intensity",
                ["tooltip"] = "Controls the strength of the dance movement.",
                ["value"] = "70",
                ["type"] = "int"
            },
            {
                ["name"] = "Dance Speed",
                ["tooltip"] = "Controls how quickly the dance motion repeats.",
                ["value"] = "2.5",
                ["type"] = "float"
            },
            {
                ["name"] = "Speed Up",
                ["tooltip"] = "Slightly speeds up the video for a more energetic dance.",
                ["value"] = "1",
                ["type"] = "bool"
            },
            {
                ["name"] = "Audio Punch",
                ["tooltip"] = "Adds a small audio volume boost.",
                ["value"] = "1",
                ["type"] = "bool"
            }
        }
    }
end

function StartGeneration(options, pluginSettings, functions)

    local chance = math.max(
        0,
        math.min(100, numberSetting(pluginSettings, "Chance Roll", 100))
    )

    if functions.randomInt(1, 100) > chance then
        functions.fileCopy(options.inputVideo, options.outputVideo)
        return false
    end

    local intensity = math.max(
        0,
        math.min(100, numberSetting(pluginSettings, "Dance Intensity", 70))
    )

    local danceSpeed = math.max(
        0.25,
        math.min(8.0, numberSetting(pluginSettings, "Dance Speed", 2.5))
    )

    local intensityScale = intensity / 100.0

    -- Movement values.
    local zoomAmount = 1.0 + (0.10 * intensityScale)
    local shakeAmount = 7.0 * intensityScale
    local rotationAmount = 0.025 * intensityScale

    -- Make the animation pulse more noticeably.
    local frequency = danceSpeed

    local tempo = 1.0
    if pluginSettings["Speed Up"] == "1" then
        tempo = 1.04
    end

    local audioFilter = "anull"

    if pluginSettings["Audio Punch"] == "1" then
        audioFilter = "volume=1.12"
    end

    -- Store the filter parameters for PostCommand.
    _G.GetDownDanceData = {
        zoom = zoomAmount,
        shake = shakeAmount,
        rotation = rotationAmount,
        frequency = frequency,
        tempo = tempo,
        audioFilter = audioFilter
    }

    -- Command 1:
    -- Apply the main dancing camera effect.
    local data = _G.GetDownDanceData

    local videoFilter =
        "scale=ceil(iw*" .. string.format("%.4f", data.zoom) .. "/2)*2:" ..
        "ceil(ih*" .. string.format("%.4f", data.zoom) .. "/2)*2," ..

        "crop=" ..
        "iw/" .. string.format("%.4f", data.zoom) .. ":" ..
        "ih/" .. string.format("%.4f", data.zoom) .. ":" ..

        "(iw-iw/" .. string.format("%.4f", data.zoom) .. ")/2+" ..
        string.format("%.3f", data.shake) ..
        "*sin(2*PI*t*" .. string.format("%.3f", data.frequency) .. "):" ..

        "(ih-ih/" .. string.format("%.4f", data.zoom) .. ")/2+" ..
        string.format("%.3f", data.shake * 0.55) ..
        "*sin(4*PI*t*" .. string.format("%.3f", data.frequency) .. ")," ..

        "rotate=" ..
        string.format("%.5f", data.rotation) ..
        "*sin(2*PI*t*" .. string.format("%.3f", data.frequency) .. ")" ..
        ":ow=iw:oh=ih:c=black," ..

        "eq=" ..
        "contrast=1.04:" ..
        "brightness=0.015:saturation=1.04," ..

        "setpts=" ..
        string.format("%.5f", 1.0 / data.tempo) ..
        "*PTS"

    functions.runFFmpeg(
        "-i \"" .. options.inputVideo .. "\" " ..
        "-vf \"" .. videoFilter .. "\" " ..
        "-af \"" .. data.audioFilter .. ",atempo=" ..
        string.format("%.5f", data.tempo) .. "\" " ..
        "-map 0:v:0 -map 0:a? " ..
        "-c:v libx264 " ..
        "-preset veryfast " ..
        "-crf 18 " ..
        "-pix_fmt yuv420p " ..
        "-c:a aac " ..
        "-b:a 192k " ..
        "-movflags +faststart " ..
        "-y \"" .. options.outputVideo .. "\""
    )

    return true
end

function PostCommand(commandIndex, outputResult, errorResult,
                     options, pluginSettings, functions)

    if errorResult ~= nil and errorResult ~= "" then
        print("<[255,180,0]>Get Down Dance: FFmpeg reported an error:")
        print(errorResult)
    end

    if outputResult ~= nil and outputResult ~= "" then
        print("<[100,255,100]>Get Down Dance: processing command completed.")
    end
end

function StopGeneration(options, pluginSettings, functions)

    _G.GetDownDanceData = nil

    print("<[100,255,100]>Get Down Dance Effect finished.")
    return true
end