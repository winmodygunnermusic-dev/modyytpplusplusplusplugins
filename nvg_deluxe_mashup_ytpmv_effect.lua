-- NVG Deluxe Mashup / YTPMV Edit Effect
-- Nonsensical Video Generator v1.8.1.3 Workshop Effect
--
-- Install this generated addon at:
-- NonsensicalVideoGenerator\plugins\workshop\nvg_deluxe_mashup_ytpmv_effect.lua
--
-- Combines mashup mixing, rainbow/mirror symmetry, screen clips, image/source
-- overlays, SpaDinner-style audio hits, sentence-mixing accents, shuffle/loop
-- frames, framerate reduction, random cuts, speed-loop boost, scrambling/random
-- chopping and a Vegas-friendly auto-keyframe metadata sidecar.

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

local function libraryFile(functions, mediaType, path)
    local value = functions.getRandomLibraryFile(mediaType, path)
    if value == nil or value == "" then
        return nil
    end

    return value
end

local function writeVegasMetadata(path, instructions)
    local file = io.open(path, "w")
    if file == nil then
        return false
    end

    file:write("NVG Deluxe Auto-Keyframe Metadata\n")
    file:write("format=plain-envelope-v1\n")
    file:write("# Import manually or translate into Vegas scripting keyframes.\n\n")

    for i = 1, #instructions do
        local item = instructions[i]
        file:write(
            string.format(
                "time=%.3f action=%s value=%s note=%s\n",
                item.time,
                item.action,
                item.value,
                item.note
            )
        )
    end

    file:close()
    return true
end

function Query(localeName, localizationTokens)
    return {
        ["name"] = "NVG Deluxe Mashup YTPMV",
        ["description"] =
            "Deluxe silly edit generator with mashups, rainbow mirror symmetry, " ..
            "overlay sources, frame loops, random chops and Vegas keyframe metadata.",

        ["settings"] = {
            { ["name"] = "Chance Roll", ["value"] = "100", ["type"] = "number", ["tooltip"] = "Chance that the deluxe effect runs." },
            { ["name"] = "Chaos", ["value"] = "80", ["type"] = "number", ["tooltip"] = "Overall rainbow, mirror, chop and overlay intensity." },
            { ["name"] = "YTPMV Tempo", ["value"] = "1.25", ["type"] = "float", ["tooltip"] = "Speed-loop boost / YTPMV tempo multiplier." },
            { ["name"] = "Frame Reduction", ["value"] = "18", ["type"] = "number", ["tooltip"] = "Output FPS for choppy silly edits." },
            { ["name"] = "Overlay Count", ["value"] = "3", ["type"] = "number", ["tooltip"] = "Random image overlays/sources to layer." },
            { ["name"] = "Caption Text", ["value"] = "NVG DELUXE YTPMV", ["type"] = "string", ["tooltip"] = "Flashing caption text drawn over the generated remix." },
            { ["name"] = "Use Screen Clip", ["value"] = "1", ["type"] = "bool", ["tooltip"] = "Blend in a random screen clip/source video." },
            { ["name"] = "Use SpaDinner Audio", ["value"] = "1", ["type"] = "bool", ["tooltip"] = "Mix SpaDinner-style hits and silly audio." },
            { ["name"] = "Use Sentence Mix", ["value"] = "1", ["type"] = "bool", ["tooltip"] = "Mix short sentence/audio chops as accents." },
            { ["name"] = "Generate Vegas Metadata", ["value"] = "1", ["type"] = "bool", ["tooltip"] = "Write a simple keyframe instruction sidecar next to the output." }
        },

        ["libraries"] = {
            { ["name"] = "Deluxe Overlay Images", ["path"] = "deluxe_overlay_images", ["type"] = "image", ["tooltip"] = "PNG/JPG stickers, captions, source images and silly overlays." },
            { ["name"] = "Deluxe Screen Clips", ["path"] = "deluxe_screen_clips", ["type"] = "video", ["tooltip"] = "Source clips, screen captures and mashup video layers." },
            { ["name"] = "SpaDinner Audio", ["path"] = "spadinner_audio", ["type"] = "audio", ["tooltip"] = "SpaDinner SFX, bleeps, boings, screams and loud hits." },
            { ["name"] = "Sentence Mix Audio", ["path"] = "sentence_mix_audio", ["type"] = "audio", ["tooltip"] = "Short words, phrases and chopped audio for sentence-mix accents." },
            { ["name"] = "YTPMV Audio Hits", ["path"] = "ytpmv_audio_hits", ["type"] = "audio", ["tooltip"] = "Shared YTPMV hits for deluxe musical accents." }
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

    local chaos = clamp(numberSetting(pluginSettings, "Chaos", 80), 0, 100)
    local tempo = clamp(numberSetting(pluginSettings, "YTPMV Tempo", 1.25), 0.50, 2.50)
    local frameReduction = math.floor(clamp(numberSetting(pluginSettings, "Frame Reduction", 18), 6, 60))
    local overlayCount = math.floor(clamp(numberSetting(pluginSettings, "Overlay Count", 3), 0, 8))
    local useScreenClip = boolSetting(pluginSettings, "Use Screen Clip", true)
    local useSpaDinnerAudio = boolSetting(pluginSettings, "Use SpaDinner Audio", true)
    local useSentenceMix = boolSetting(pluginSettings, "Use Sentence Mix", true)
    local writeMetadata = boolSetting(pluginSettings, "Generate Vegas Metadata", true)
    local captionText = pluginSettings["Caption Text"] or "NVG DELUXE YTPMV"
    local width = tonumber(options.width) or 1280
    local height = tonumber(options.height) or 720

    local overlayFiles = {}
    for i = 1, overlayCount do
        local overlay = libraryFile(functions, "image", "deluxe_overlay_images")
        if overlay ~= nil then
            overlayFiles[#overlayFiles + 1] = overlay
        end
    end

    local screenClip = nil
    if useScreenClip then
        screenClip = libraryFile(functions, "video", "deluxe_screen_clips")
    end

    local spaDinnerAudio = nil
    if useSpaDinnerAudio then
        spaDinnerAudio = libraryFile(functions, "audio", "spadinner_audio")
    end

    local sentenceAudio = nil
    if useSentenceMix then
        sentenceAudio = libraryFile(functions, "audio", "sentence_mix_audio")
    end

    local inputs = { "-i \"" .. options.inputVideo .. "\"" }
    local inputIndex = 1
    local overlayIndexes = {}
    local screenIndex = nil
    local spaIndex = nil
    local sentenceIndex = nil

    for i = 1, #overlayFiles do
        inputs[#inputs + 1] = "-loop 1 -i \"" .. overlayFiles[i] .. "\""
        overlayIndexes[#overlayIndexes + 1] = inputIndex
        inputIndex = inputIndex + 1
    end

    if screenClip ~= nil then
        inputs[#inputs + 1] = "-stream_loop -1 -i \"" .. screenClip .. "\""
        screenIndex = inputIndex
        inputIndex = inputIndex + 1
    end

    if spaDinnerAudio ~= nil then
        inputs[#inputs + 1] = "-i \"" .. spaDinnerAudio .. "\""
        spaIndex = inputIndex
        inputIndex = inputIndex + 1
    end

    if sentenceAudio ~= nil then
        inputs[#inputs + 1] = "-i \"" .. sentenceAudio .. "\""
        sentenceIndex = inputIndex
    end

    local filters = {}
    local currentVideo = "deluxebase"
    local cropZoom = 1.0 + chaos / 160
    local cropWidth = math.max(2, math.floor(width / cropZoom))
    local cropHeight = math.max(2, math.floor(height / cropZoom))
    local chopInterval = 0.22 + (100 - chaos) / 220
    local mirrorOpacity = 0.22 + chaos / 260

    filters[#filters + 1] =
        "[0:v]scale=" .. tostring(width) .. ":" .. tostring(height) ..
        ",crop=" .. tostring(cropWidth) .. ":" .. tostring(cropHeight) ..
        ":x='(iw-ow)*abs(sin(t*3.1))':y='(ih-oh)*abs(cos(t*2.4))'" ..
        ",scale=" .. tostring(width) .. ":" .. tostring(height) ..
        ",hue=h='mod(t*160,360)':s=" .. tostring(1.2 + chaos / 80) ..
        ",eq=contrast=" .. tostring(1.05 + chaos / 120) .. ":saturation=" .. tostring(1.2 + chaos / 70) ..
        ",fps=" .. tostring(frameReduction) ..
        ",setpts=(PTS-STARTPTS)/" .. tostring(tempo) ..
        ",tblend=all_mode=average:enable='lt(mod(t," .. tostring(chopInterval) .. "),0.07)'" ..
        ",format=rgba[base];" ..
        "[base]hflip[mirror];" ..
        "[base][mirror]blend=all_mode=screen:all_opacity=" .. tostring(mirrorOpacity) .. "[" .. currentVideo .. "]"

    if screenIndex ~= nil then
        filters[#filters + 1] =
            "[" .. tostring(screenIndex) .. ":v]scale=" .. tostring(width) .. ":" .. tostring(height) ..
            ":force_original_aspect_ratio=increase,crop=" .. tostring(width) .. ":" .. tostring(height) ..
            ",setpts=PTS-STARTPTS,format=rgba[screenclip]"
        filters[#filters + 1] =
            "[" .. currentVideo .. "][screenclip]blend=all_mode=overlay:all_opacity=" ..
            tostring(0.16 + chaos / 360) .. "[withscreen]"
        currentVideo = "withscreen"
    end

    for i = 1, #overlayIndexes do
        local idx = overlayIndexes[i]
        local label = "deluxeoverlay" .. tostring(i)
        local out = "withdeluxeoverlay" .. tostring(i)
        local scale = math.floor(width * (0.16 + (i % 4) * 0.05))
        local startTime = (i - 1) * 0.45
        local endTime = startTime + 2.6

        filters[#filters + 1] =
            "[" .. tostring(idx) .. ":v]scale=" .. tostring(scale) .. ":-1,format=rgba[" .. label .. "]"
        filters[#filters + 1] =
            "[" .. currentVideo .. "][" .. label .. "]overlay=" ..
            "x='(W-w)*abs(sin(t*" .. tostring(1.1 + i) .. "))':" ..
            "y='(H-h)*abs(cos(t*" .. tostring(1.4 + i) .. "))':" ..
            "enable='between(t," .. tostring(startTime) .. "," .. tostring(endTime) .. ")'[" .. out .. "]"
        currentVideo = out
    end

    filters[#filters + 1] =
        "[" .. currentVideo .. "]drawtext=text='" .. captionText .. "':" ..
        "x=(w-text_w)/2:y=h*0.08:fontsize=" .. tostring(math.floor(height / 13)) ..
        ":fontcolor=cyan:borderw=5:bordercolor=black:" ..
        "enable='lt(mod(t,0.80),0.42)'[withtitle]"
    currentVideo = "withtitle"

    local audioInputs = { "0:a" }
    if spaIndex ~= nil then
        filters[#filters + 1] =
            "[" .. tostring(spaIndex) .. ":a]volume=" .. tostring(1.0 + chaos / 90) .. ",aloop=loop=-1:size=44100[spaa]"
        audioInputs[#audioInputs + 1] = "spaa"
    end

    if sentenceIndex ~= nil then
        filters[#filters + 1] =
            "[" .. tostring(sentenceIndex) .. ":a]volume=" .. tostring(0.8 + chaos / 130) ..
            ",atrim=0:4,asetpts=PTS-STARTPTS,aloop=loop=-1:size=22050[senta]"
        audioInputs[#audioInputs + 1] = "senta"
    end

    local audioArgs = "-map 0:a? -filter:a \"atempo=" .. tostring(math.min(2.0, tempo)) .. "\" -c:a aac "
    if #audioInputs > 1 then
        local mix = ""
        for i = 1, #audioInputs do
            mix = mix .. "[" .. audioInputs[i] .. "]"
        end
        filters[#filters + 1] =
            mix .. "amix=inputs=" .. tostring(#audioInputs) .. ":duration=first:dropout_transition=0[aout]"
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

    if writeMetadata then
        local metadataPath = options.outputVideo .. ".vegas_keyframes.txt"
        local instructions = {
            { time = 0.000, action = "pan_crop", value = "start_wide", note = "Begin source at full frame." },
            { time = 0.500, action = "pan_crop", value = "snap_zoom_" .. tostring(cropZoom), note = "Hard YTPMV zoom keyframe." },
            { time = 1.000, action = "mirror_symmetry", value = "screen_blend", note = "Enable mirrored rainbow layer." },
            { time = 1.500, action = "overlay", value = "random_image_layer", note = "Animate overlay position with sine/cosine envelope." },
            { time = 2.000, action = "frame_loop", value = "stutter_shuffle", note = "Loop or duplicate frames on beat." },
            { time = 2.500, action = "audio", value = "loud_sync_hit", note = "Place SpaDinner/sentence hit at visual snap." }
        }
        writeVegasMetadata(metadataPath, instructions)
    end

    return true
end

function PostCommand(commandIndex, outputResult, errorResult, options, pluginSettings, functions)
end

function StopGeneration(options, pluginSettings, functions)
    return true
end
