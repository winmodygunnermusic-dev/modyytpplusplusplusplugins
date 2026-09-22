-- NVG YTPMV Effect Addon
-- Nonsensical Video Generator workshop effect with optional user libraries.

local function numberSetting(settings, name, defaultValue)
    if settings ~= nil and settings[name] ~= nil then
        local value = tonumber(settings[name])
        if value ~= nil then
            return value
        end
    end

    return defaultValue
end

local function boolSetting(settings, name, defaultValue)
    if settings == nil or settings[name] == nil then
        return defaultValue
    end

    local value = settings[name]
    return value == true or value == "1" or value == "true" or value == "True"
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

local function randomLibraryFile(functions, mediaType, path)
    local value = functions.getRandomLibraryFile(mediaType, path)
    if value == nil or value == "" then
        return nil
    end

    return value
end

function Query(localeName, localizationTokens)
    return {
        ["name"] = "YTPMV Effect Addon",
        ["description"] =
            "Beat-synced YTPMV remix effect with chromatic movement, stutters, " ..
            "optional source overlays and optional audio-hit libraries.",
        ["version"] = "2.0",

        ["settings"] = {
            { ["name"] = "Chance Roll", ["value"] = "100", ["type"] = "number", ["tooltip"] = "Chance that this addon processes the clip." },
            { ["name"] = "Amount", ["value"] = "10", ["type"] = "number", ["tooltip"] = "Pixel displacement and chromatic offset amount." },
            { ["name"] = "Speed", ["value"] = "1.25", ["type"] = "float", ["tooltip"] = "Visual movement and audio tempo multiplier." },
            { ["name"] = "Beat Frames", ["value"] = "8", ["type"] = "number", ["tooltip"] = "Frame cadence for YTPMV stutter selection." },
            { ["name"] = "Frame Reduction", ["value"] = "30", ["type"] = "number", ["tooltip"] = "Output frame rate after stutter processing." },
            { ["name"] = "Use Overlay Library", ["value"] = "1", ["type"] = "bool", ["tooltip"] = "Blend one random YTPMV overlay image if available." },
            { ["name"] = "Use Audio Library", ["value"] = "1", ["type"] = "bool", ["tooltip"] = "Mix one random YTPMV audio hit/loop if available." }
        },

        ["libraries"] = {
            { ["name"] = "YTPMV Overlay Images", ["path"] = "ytpmv_overlay_images", ["type"] = "image", ["tooltip"] = "PNG/JPG masks, captions, sprites and YTPMV visual layers." },
            { ["name"] = "YTPMV Audio Hits", ["path"] = "ytpmv_audio_hits", ["type"] = "audio", ["tooltip"] = "Short musical hits, memes, stabs and loops for beat accents." }
        }
    }
end

function StartGeneration(options, pluginSettings, functions)
    if not functions.ffmpegInstalled() then
        return false
    end

    local chanceRoll = clamp(numberSetting(pluginSettings, "Chance Roll", 100), 0, 100)
    if functions.randomInt(1, 100) > chanceRoll then
        functions.fileCopy(options.inputVideo, options.outputVideo)
        return true
    end

    local amount = clamp(numberSetting(pluginSettings, "Amount", 10), 0, 80)
    local speed = clamp(numberSetting(pluginSettings, "Speed", 1.25), 0.50, 2.00)
    local beatFrames = math.floor(clamp(numberSetting(pluginSettings, "Beat Frames", 8), 2, 30))
    local frameReduction = math.floor(clamp(numberSetting(pluginSettings, "Frame Reduction", 30), 6, 60))
    local useOverlay = boolSetting(pluginSettings, "Use Overlay Library", true)
    local useAudio = boolSetting(pluginSettings, "Use Audio Library", true)
    local width = tonumber(options.width) or 1280
    local height = tonumber(options.height) or 720

    local overlayFile = nil
    if useOverlay then
        overlayFile = randomLibraryFile(functions, "image", "ytpmv_overlay_images")
    end

    local audioFile = nil
    if useAudio then
        audioFile = randomLibraryFile(functions, "audio", "ytpmv_audio_hits")
    end

    local inputs = { "-i \"" .. options.inputVideo .. "\"" }
    local overlayIndex = nil
    local audioIndex = nil

    if overlayFile ~= nil then
        inputs[#inputs + 1] = "-loop 1 -i \"" .. overlayFile .. "\""
        overlayIndex = #inputs - 1
    end

    if audioFile ~= nil then
        inputs[#inputs + 1] = "-i \"" .. audioFile .. "\""
        audioIndex = #inputs - 1
    end

    local hueSpeed = tostring(speed * 90)
    local pulse = tostring(1.0 + amount / 120)
    local filters = {
        "[0:v]scale=" .. tostring(width) .. ":" .. tostring(height) ..
        ",hue=h='mod(t*" .. hueSpeed .. ",360)':s=" .. pulse ..
        ",eq=contrast=1.18:saturation=1.65" ..
        ",select='lt(mod(n," .. tostring(beatFrames) .. ")," .. tostring(math.max(1, math.floor(beatFrames / 3))) .. ")'" ..
        ",setpts=N/FRAME_RATE/TB,fps=" .. tostring(frameReduction) ..
        ",tblend=all_mode=average:enable='lt(mod(t,0.32),0.08)'[ytpmvbase]"
    }

    local currentVideo = "ytpmvbase"
    if overlayIndex ~= nil then
        filters[#filters + 1] =
            "[" .. tostring(overlayIndex) .. ":v]scale='min(iw," .. tostring(math.floor(width * 0.36)) .. ")':-1,format=rgba[ytpmvoverlay]"
        filters[#filters + 1] =
            "[" .. currentVideo .. "][ytpmvoverlay]overlay=" ..
            "x='(W-w)*abs(sin(t*" .. tostring(speed * 2.2) .. "))':" ..
            "y='(H-h)*abs(cos(t*" .. tostring(speed * 2.8) .. "))':" ..
            "enable='lt(mod(t,1.0),0.55)'[withytpmvoverlay]"
        currentVideo = "withytpmvoverlay"
    end

    local audioArgs = "-map 0:a? -filter:a \"atempo=" .. tostring(speed) .. "\" -c:a aac "
    if audioIndex ~= nil then
        filters[#filters + 1] =
            "[0:a]atempo=" .. tostring(speed) .. "[maina];" ..
            "[" .. tostring(audioIndex) .. ":a]volume=1.15,aloop=loop=-1:size=44100[hit];" ..
            "[maina][hit]amix=inputs=2:duration=first:dropout_transition=0[aout]"
        audioArgs = "-map \"[aout]\" -c:a aac "
    end

    functions.runFFmpeg(
        table.concat(inputs, " ") .. " " ..
        "-filter_complex \"" .. table.concat(filters, ";") .. "\" " ..
        "-map \"[" .. currentVideo .. "]\" " ..
        audioArgs ..
        "-c:v libx264 -preset veryfast -crf 18 -shortest -y \"" ..
        options.outputVideo .. "\""
    )

    return true
end

function PostCommand(commandIndex, outputResult, errorResult, options, pluginSettings, functions)
end

function StopGeneration(options, pluginSettings, functions)
    return true
end
