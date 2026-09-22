-- MLG 2012 Meme Edit Effect
-- Nonsensical Video Generator v1.8.1.2 Workshop Effect
--
-- Install this generated addon at:
-- NonsensicalVideoGenerator\plugins\workshop\mlg_2012_meme_effect.lua
--
-- Meme style:
--   Parodies early YouTube remix culture with abrupt sound effects,
--   deep-fried colors, flashing lights, dramatic zoom-ins and oversized
--   2012-era MLG-style text/image/video overlays.
--
-- Suggested workshop library folders:
--   audio/mlg_sfx        airhorns, hitmarkers, wow, explosions, bass boosts
--   image/mlg_images     deal-with-it glasses, doritos, mountain-dew, hitmarkers
--   video/mlg_overlays   transparent/green-screen meme overlays and flashes

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

local function chance(functions, percent)
    return functions.randomInt(1, 100) <= percent
end

local function randomChoice(functions, items)
    return items[functions.randomInt(1, #items)]
end

local function safeText(value)
    value = tostring(value or "")
    value = string.gsub(value, "\\", "\\\\")
    value = string.gsub(value, ":", "\\:")
    value = string.gsub(value, "'", "\\'")
    return value
end

function Query(localeName, localizationTokens)
    return {
        ["name"] = "MLG 2012 Meme Edit",
        ["description"] =
            "Chaotic early-YouTube/MLG remix effect with airhorns, flashes, " ..
            "deep-fried colors, zooms and over-the-top text overlays.",

        ["settings"] = {
            {
                ["name"] = "Chance Roll",
                ["tooltip"] = "Chance that the MLG meme edit is applied.",
                ["value"] = "80",
                ["type"] = "number"
            },
            {
                ["name"] = "Meme Intensity",
                ["tooltip"] = "Controls deep-fry strength, flashing, shake and overlay chaos.",
                ["value"] = "85",
                ["type"] = "number"
            },
            {
                ["name"] = "Airhorn Audio",
                ["tooltip"] = "Mix a random loud meme SFX from the MLG SFX library.",
                ["value"] = "1",
                ["type"] = "bool"
            },
            {
                ["name"] = "Image Spam",
                ["tooltip"] = "Overlay a random meme PNG/JPG from the MLG Images library.",
                ["value"] = "1",
                ["type"] = "bool"
            },
            {
                ["name"] = "Video Overlay",
                ["tooltip"] = "Overlay a random transparent/green-screen meme clip.",
                ["value"] = "1",
                ["type"] = "bool"
            },
            {
                ["name"] = "Text Overlay",
                ["tooltip"] = "Draw oversized MLG parody text on top of the video.",
                ["value"] = "1",
                ["type"] = "bool"
            },
            {
                ["name"] = "Overlay Scale",
                ["tooltip"] = "Image/video overlay size as a percent of output width.",
                ["value"] = "45",
                ["type"] = "number"
            },
            {
                ["name"] = "SFX Volume",
                ["tooltip"] = "Injected airhorn/SFX volume multiplier.",
                ["value"] = "1.7",
                ["type"] = "float"
            },
            {
                ["name"] = "Caption Text",
                ["tooltip"] = "Optional fixed caption. Leave blank for a random MLG phrase.",
                ["value"] = "",
                ["type"] = "string"
            }
        },

        ["libraries"] = {
            {
                ["name"] = "MLG SFX",
                ["tooltip"] = "Airhorns, hitmarkers, bass drops, explosions and reaction sounds.",
                ["path"] = "mlg_sfx",
                ["type"] = "audio"
            },
            {
                ["name"] = "MLG Images",
                ["tooltip"] = "Transparent meme PNGs/JPGs such as glasses, hitmarkers and logos.",
                ["path"] = "mlg_images",
                ["type"] = "image"
            },
            {
                ["name"] = "MLG Overlays",
                ["tooltip"] = "Short transparent or green-screen MLG-style video overlays.",
                ["path"] = "mlg_overlays",
                ["type"] = "video"
            }
        }
    }
end

function StartGeneration(options, pluginSettings, functions)
    if not functions.ffmpegInstalled() then
        return false
    end

    local chanceRoll = clamp(numberSetting(pluginSettings, "Chance Roll", 80), 0, 100)
    if not chance(functions, chanceRoll) then
        functions.fileCopy(options.inputVideo, options.outputVideo)
        return true
    end

    local intensity = clamp(numberSetting(pluginSettings, "Meme Intensity", 85), 0, 100)
    local overlayScale = clamp(numberSetting(pluginSettings, "Overlay Scale", 45), 5, 200)
    local sfxVolume = clamp(numberSetting(pluginSettings, "SFX Volume", 1.7), 0, 6)
    local width = tonumber(options.width) or 1280
    local height = tonumber(options.height) or 720

    local sfxFile = nil
    local imageFile = nil
    local overlayFile = nil

    if boolSetting(pluginSettings, "Airhorn Audio", true) then
        sfxFile = functions.getRandomLibraryFile("audio", "mlg_sfx")
    end

    if boolSetting(pluginSettings, "Image Spam", true) and chance(functions, math.max(35, intensity)) then
        imageFile = functions.getRandomLibraryFile("image", "mlg_images")
    end

    if boolSetting(pluginSettings, "Video Overlay", true) and chance(functions, math.max(35, intensity)) then
        overlayFile = functions.getRandomLibraryFile("video", "mlg_overlays")
    end

    local captions = {
        "360 NOSCOPE",
        "WOMBO COMBO",
        "GET REKT",
        "MLG PRO",
        "DANK EDIT",
        "AIRHORN INTENSIFIES"
    }

    local caption = pluginSettings["Caption Text"] or ""
    if caption == "" then
        caption = randomChoice(functions, captions)
    end

    local inputs = { "-i \"" .. options.inputVideo .. "\"" }
    local inputIndex = 1
    local sfxIndex = nil
    local imageIndex = nil
    local overlayIndex = nil

    if sfxFile ~= nil and sfxFile ~= "" then
        inputs[#inputs + 1] = "-i \"" .. sfxFile .. "\""
        sfxIndex = inputIndex
        inputIndex = inputIndex + 1
    end

    if imageFile ~= nil and imageFile ~= "" then
        inputs[#inputs + 1] = "-loop 1 -i \"" .. imageFile .. "\""
        imageIndex = inputIndex
        inputIndex = inputIndex + 1
    end

    if overlayFile ~= nil and overlayFile ~= "" then
        inputs[#inputs + 1] = "-stream_loop -1 -i \"" .. overlayFile .. "\""
        overlayIndex = inputIndex
    end

    local filters = {}
    local currentVideo = "deepfried"
    local saturation = 1.8 + intensity / 35
    local contrast = 1.2 + intensity / 70
    local brightness = (intensity - 50) / 600
    local flashOpacity = 0.18 + intensity / 260
    local zoomWidth = math.max(2, math.floor(width * (1.0 - intensity / 900)))
    local zoomHeight = math.max(2, math.floor(height * (1.0 - intensity / 900)))

    filters[#filters + 1] =
        "[0:v]scale=" .. tostring(width) .. ":" .. tostring(height) ..
        ",crop=" .. tostring(zoomWidth) .. ":" .. tostring(zoomHeight) .. ":(iw-ow)/2:(ih-oh)/2" ..
        ",scale=" .. tostring(width) .. ":" .. tostring(height) ..
        ",eq=saturation=" .. tostring(saturation) ..
        ":contrast=" .. tostring(contrast) ..
        ":brightness=" .. tostring(brightness) ..
        ",hue=h='45*sin(t*8)'" ..
        ",noise=alls=" .. tostring(math.floor(8 + intensity / 4)) .. ":allf=t+u" ..
        ",format=rgba[basefried];" ..
        "color=c=white@" .. tostring(flashOpacity) .. ":s=" .. tostring(width) .. "x" .. tostring(height) ..
        ":r=30,format=rgba[flash];" ..
        "[basefried][flash]overlay=0:0:enable='lt(mod(t,0.22),0.06)'[" .. currentVideo .. "]"

    if imageIndex ~= nil then
        local imageWidth = math.floor(width * overlayScale / 100)
        filters[#filters + 1] =
            "[" .. tostring(imageIndex) .. ":v]scale=" .. tostring(imageWidth) .. ":-1,format=rgba[mlgimg]"
        filters[#filters + 1] =
            "[" .. currentVideo .. "][mlgimg]overlay=x='W-w-40+20*sin(t*15)':y='40+30*cos(t*12)'" ..
            ":enable='between(t,0.25,5.5)'[withimg]"
        currentVideo = "withimg"
    end

    if overlayIndex ~= nil then
        local overlayWidth = math.floor(width * overlayScale / 100)
        filters[#filters + 1] =
            "[" .. tostring(overlayIndex) .. ":v]scale=" .. tostring(overlayWidth) .. ":-1,setpts=PTS-STARTPTS,format=rgba[mlgovr]"
        filters[#filters + 1] =
            "[" .. currentVideo .. "][mlgovr]overlay=x='(W-w)/2+60*sin(t*10)':y='H-h-35'" ..
            ":enable='between(t,0.5,6.0)'[withovr]"
        currentVideo = "withovr"
    end

    if boolSetting(pluginSettings, "Text Overlay", true) then
        filters[#filters + 1] =
            "[" .. currentVideo .. "]drawtext=text='" .. safeText(caption) ..
            "':x=(w-text_w)/2:y=h*0.10:fontsize=" .. tostring(math.floor(height / 9)) ..
            ":fontcolor=lime:borderw=6:bordercolor=black:enable='lt(mod(t,1.0),0.65)'[withtext]"
        currentVideo = "withtext"
    end

    local audioArgs = "-map 0:a? -c:a aac "
    if sfxIndex ~= nil then
        filters[#filters + 1] =
            "[" .. tostring(sfxIndex) .. ":a]volume=" .. tostring(sfxVolume) .. "[sfx];" ..
            "[0:a][sfx]amix=inputs=2:duration=first:dropout_transition=0[aout]"
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
