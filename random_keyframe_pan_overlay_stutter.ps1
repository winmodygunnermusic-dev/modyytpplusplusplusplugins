-- Random Keyframe Pan / Crop / Overlay Stutter Effect
-- Nonsensical Video Generator v1.8.1.2 Workshop Effect
--
-- Install this generated addon at:
-- NonsensicalVideoGenerator\plugins\workshop\random_keyframe_pan_overlay_stutter.lua
--
-- Effect style:
--   Random keyframing for pan/crop movement, snapping zoom cuts, image overlays,
--   stuttered frames and loud synchronized audio layers.
--
-- Suggested workshop library folders:
--   image/keyframe_overlays    PNG/JPG stickers, captions, emojis and visual layers
--   audio/keyframe_hits        Impacts, whooshes, bass hits and loud sync sounds

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

local function maybeLibraryFile(functions, mediaType, path)
    local value = functions.getRandomLibraryFile(mediaType, path)
    if value == nil or value == "" then
        return nil
    end

    return value
end

function Query(localeName, localizationTokens)
    return {
        ["name"] = "Random Keyframe Pan Overlay Stutter",
        ["description"] =
            "Adds random keyframed pan/crop motion, snapping zooms, image overlays, " ..
            "frame stutters and loud synced audio hits.",

        ["settings"] = {
            {
                ["name"] = "Chance Roll",
                ["tooltip"] = "Chance that this effect runs.",
                ["value"] = "100",
                ["type"] = "number"
            },
            {
                ["name"] = "Motion Amount",
                ["tooltip"] = "Strength of random keyframed pan and crop motion.",
                ["value"] = "70",
                ["type"] = "number"
            },
            {
                ["name"] = "Snap Amount",
                ["tooltip"] = "Strength of snapping zoom cuts and hard keyframe jumps.",
                ["value"] = "65",
                ["type"] = "number"
            },
            {
                ["name"] = "Stutter Amount",
                ["tooltip"] = "How aggressively frames are repeated for stutter edits.",
                ["value"] = "45",
                ["type"] = "number"
            },
            {
                ["name"] = "Use Overlay Images",
                ["tooltip"] = "Layer random images from the overlay image library.",
                ["value"] = "1",
                ["type"] = "bool"
            },
            {
                ["name"] = "Overlay Count",
                ["tooltip"] = "How many random image layers to place over the video.",
                ["value"] = "3",
                ["type"] = "number"
            },
            {
                ["name"] = "Use Loud Audio Hits",
                ["tooltip"] = "Mix loud audio hits in sync with snap/stutter moments.",
                ["value"] = "1",
                ["type"] = "bool"
            },
            {
                ["name"] = "Audio Loudness",
                ["tooltip"] = "Volume multiplier for synchronized hit sounds.",
                ["value"] = "1.8",
                ["type"] = "float"
            }
        },

        ["libraries"] = {
            {
                ["name"] = "Keyframe Overlays",
                ["tooltip"] = "PNG/JPG stickers, captions, emojis and overlay images.",
                ["path"] = "keyframe_overlays",
                ["type"] = "image"
            },
            {
                ["name"] = "Keyframe Hits",
                ["tooltip"] = "Whooshes, impacts, bass hits and loud sync sounds.",
                ["path"] = "keyframe_hits",
                ["type"] = "audio"
            }
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

    local motionAmount = clamp(numberSetting(pluginSettings, "Motion Amount", 70), 0, 100)
    local snapAmount = clamp(numberSetting(pluginSettings, "Snap Amount", 65), 0, 100)
    local stutterAmount = clamp(numberSetting(pluginSettings, "Stutter Amount", 45), 0, 100)
    local overlayCount = math.floor(clamp(numberSetting(pluginSettings, "Overlay Count", 3), 0, 8))
    local audioLoudness = clamp(numberSetting(pluginSettings, "Audio Loudness", 1.8), 0, 6)
    local useOverlays = boolSetting(pluginSettings, "Use Overlay Images", true)
    local useAudioHits = boolSetting(pluginSettings, "Use Loud Audio Hits", true)
    local width = tonumber(options.width) or 1280
    local height = tonumber(options.height) or 720

    local overlayFiles = {}
    if useOverlays then
        for i = 1, overlayCount do
            local overlay = maybeLibraryFile(functions, "image", "keyframe_overlays")
            if overlay ~= nil then
                overlayFiles[#overlayFiles + 1] = overlay
            end
        end
    end

    local hitFile = nil
    if useAudioHits then
        hitFile = maybeLibraryFile(functions, "audio", "keyframe_hits")
    end

    local inputs = { "-i \"" .. options.inputVideo .. "\"" }
    local inputIndex = 1
    local overlayIndexes = {}
    local hitIndex = nil

    for i = 1, #overlayFiles do
        inputs[#inputs + 1] = "-loop 1 -i \"" .. overlayFiles[i] .. "\""
        overlayIndexes[#overlayIndexes + 1] = inputIndex
        inputIndex = inputIndex + 1
    end

    if hitFile ~= nil then
        inputs[#inputs + 1] = "-i \"" .. hitFile .. "\""
        hitIndex = inputIndex
    end

    local filters = {}
    local currentVideo = "keybase"
    local zoom = 1.0 + motionAmount / 180
    local snapZoom = 1.0 + snapAmount / 120
    local cropWidth = math.max(2, math.floor(width / zoom))
    local cropHeight = math.max(2, math.floor(height / zoom))
    local snapWidth = math.max(2, math.floor(width / snapZoom))
    local snapHeight = math.max(2, math.floor(height / snapZoom))
    local stutterSelect = math.max(2, math.floor(10 - stutterAmount / 14))

    filters[#filters + 1] =
        "[0:v]scale=" .. tostring(width) .. ":" .. tostring(height) ..
        ",crop=" .. tostring(cropWidth) .. ":" .. tostring(cropHeight) ..
        ":x='(iw-ow)/2+(iw-ow)/2*sin(t*2.7)'" ..
        ":y='(ih-oh)/2+(ih-oh)/2*cos(t*2.1)'" ..
        ",scale=" .. tostring(width) .. ":" .. tostring(height) ..
        ",crop=" .. tostring(snapWidth) .. ":" .. tostring(snapHeight) ..
        ":x='if(lt(mod(t,0.75),0.10),(iw-ow)*0.85,(iw-ow)/2)'" ..
        ":y='if(lt(mod(t,0.75),0.10),(ih-oh)*0.15,(ih-oh)/2)'" ..
        ",scale=" .. tostring(width) .. ":" .. tostring(height) ..
        ",select='not(eq(mod(n," .. tostring(stutterSelect) .. "),1))',setpts=N/FRAME_RATE/TB" ..
        ",tblend=all_mode=average:enable='lt(mod(t,0.50),0.08)'" ..
        ",format=rgba[" .. currentVideo .. "]"

    for i = 1, #overlayIndexes do
        local idx = overlayIndexes[i]
        local label = "keyoverlay" .. tostring(i)
        local outputLabel = "withoverlay" .. tostring(i)
        local startTime = (i - 1) * 0.65
        local endTime = startTime + 2.25
        local overlayWidth = math.floor(width * (0.18 + (i % 3) * 0.07))

        filters[#filters + 1] =
            "[" .. tostring(idx) .. ":v]scale=" .. tostring(overlayWidth) .. ":-1,format=rgba[" .. label .. "]"
        filters[#filters + 1] =
            "[" .. currentVideo .. "][" .. label .. "]overlay=" ..
            "x='(W-w)*(0.15+0.70*abs(sin(t*" .. tostring(1.7 + i) .. ")))':" ..
            "y='(H-h)*(0.10+0.75*abs(cos(t*" .. tostring(1.3 + i) .. ")))':" ..
            "enable='between(t," .. tostring(startTime) .. "," .. tostring(endTime) .. ")'[" .. outputLabel .. "]"
        currentVideo = outputLabel
    end

    filters[#filters + 1] =
        "[" .. currentVideo .. "]drawtext=text='SNAP':" ..
        "x=(w-text_w)/2:y=h*0.08:fontsize=" .. tostring(math.floor(height / 10)) ..
        ":fontcolor=white:borderw=5:bordercolor=black:" ..
        "enable='lt(mod(t,0.75),0.10)'[withsnaptext]"
    currentVideo = "withsnaptext"

    local audioArgs = "-map 0:a? -c:a aac "
    if hitIndex ~= nil then
        filters[#filters + 1] =
            "[" .. tostring(hitIndex) .. ":a]volume=" .. tostring(audioLoudness) .. ",aloop=loop=-1:size=44100[hitloop];" ..
            "[0:a][hitloop]amix=inputs=2:duration=first:dropout_transition=0[aout]"
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
