-- Single Material Spam Effect
-- Nonsensical Video Generator
-- Suggested file:
-- NonsensicalVideoGenerator\plugins\workshop\single_material_spam.lua

local effectName = "Single Material Spam"

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
                ["value"] = "Spams one material/color overlay repeatedly throughout the video.",
                ["type"] = "label"
            },
            {
                ["name"] = "Chance Roll",
                ["tooltip"] = "Chance for the effect to activate.",
                ["value"] = "50",
                ["type"] = "int"
            },
            {
                ["name"] = "Opacity",
                ["tooltip"] = "Opacity of the material overlay from 0 to 100.",
                ["value"] = "55",
                ["type"] = "int"
            },
            {
                ["name"] = "Spam Count",
                ["tooltip"] = "Number of material flashes.",
                ["value"] = "12",
                ["type"] = "int"
            },
            {
                ["name"] = "Flash Duration",
                ["tooltip"] = "Duration of each material flash in seconds.",
                ["value"] = "0.08",
                ["type"] = "float"
            },
            {
                ["name"] = "Material Color",
                ["tooltip"] = "FFmpeg color used for the material overlay.",
                ["value"] = "FF00FFFF",
                ["type"] = "string"
            },
            {
                ["name"] = "Blend Mode",
                ["tooltip"] = "FFmpeg blend mode for the material.",
                ["value"] = "screen",
                ["type"] = "string"
            }
        }
    }
end

local function clamp(value, minimum, maximum)
    value = tonumber(value) or minimum

    if value < minimum then
        return minimum
    end

    if value > maximum then
        return maximum
    end

    return value
end

function StartGeneration(options, pluginSettings, functions)
    math.randomseed(os.time())

    local chance = clamp(pluginSettings["Chance Roll"], 0, 100)

    if math.random(1, 100) > chance then
        return true
    end

    if not functions.ffmpegInstalled() then
        return false
    end

    local opacity = clamp(pluginSettings["Opacity"], 0, 100) / 100
    local spamCount = math.floor(clamp(pluginSettings["Spam Count"], 1, 100))
    local duration = clamp(pluginSettings["Flash Duration"], 0.01, 5)

    local color = pluginSettings["Material Color"]
    local blendMode = pluginSettings["Blend Mode"]

    -- Keep the material color safe for an FFmpeg color expression.
    color = tostring(color):gsub("[^%w]", "")

    if color == "" then
        color = "FF00FFFF"
    end

    blendMode = tostring(blendMode):lower()

    local allowedBlendModes = {
        screen = true,
        overlay = true,
        addition = true,
        multiply = true,
        lighten = true,
        darken = true
    }

    if not allowedBlendModes[blendMode] then
        blendMode = "screen"
    end

    -- The material is created as a full-frame color source.
    -- The overlay is then repeatedly flashed over the original video.
    --
    -- A temporary filter script is generated so that every flash
    -- uses the same single material rather than random materials.

    local filterParts = {}

    table.insert(filterParts,
        "[0:v]format=rgba[base]"
    )

    for i = 1, spamCount do
        local startTime = (i - 1) * duration * 2
        local endTime = startTime + duration

        local materialLabel = "mat" .. tostring(i)

        table.insert(
            filterParts,
            "color=c=0x" .. color ..
            ":s=" .. tostring(options.width) .. "x" .. tostring(options.height) ..
            ":d=" .. tostring(duration) ..
            ":r=30,format=rgba,colorchannelmixer=aa=" ..
            string.format("%.3f", opacity) ..
            "[" .. materialLabel .. "]"
        )

        table.insert(
            filterParts,
            "[base][" .. materialLabel .. "]blend=all_mode=" ..
            blendMode ..
            ":all_opacity=1:enable='between(t," ..
            string.format("%.4f", startTime) ..
            "," ..
            string.format("%.4f", endTime) ..
            ")'[base]"
        )
    end

    local filterComplex = table.concat(filterParts, ";")

    -- Remove the initial [base] label from the first chain if needed
    -- and use the generated filter graph for the final render.
    local command =
        "-i \"" .. options.inputVideo .. "\" " ..
        "-filter_complex \"" .. filterComplex .. "\" " ..
        "-map \"[base]\" " ..
        "-map 0:a? " ..
        "-c:v libx264 " ..
        "-preset veryfast " ..
        "-crf 18 " ..
        "-c:a copy " ..
        "-y \"" .. options.outputVideo .. "\""

    functions.runFFmpeg(command)

    return true
end

function PostCommand(commandIndex, outputResult, errorResult,
                     options, pluginSettings, functions)

    -- NVG waits for the asynchronous FFmpeg command here.
    -- No additional processing is required.
    return nil
end

function StopGeneration(options, pluginSettings, functions)
    return true
end
