-- ArabFunny / Gen Alpha Library Effect
-- Nonsensical Video Generator v1.8.1.2 Workshop Effect
--
-- Install this generated addon at:
-- NonsensicalVideoGenerator\plugins\workshop\arabfunny_gen_alpha.lua
--
-- Add media to the declared workshop libraries below:
--   video/arabfunny_videos
--   audio/arabfunny_audio
--   image/arabfunny_images
--   video/arabfunny_overlays

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

local function randomChance(functions, percent)
    return functions.randomInt(1, 100) <= percent
end

local function randomSpeed(functions, chaosLevel)
    local speeds = { 0.50, 0.67, 0.80, 1.00, 1.25, 1.50, 1.75, 2.00, 2.50 }

    if chaosLevel >= 85 then
        speeds[#speeds + 1] = 0.33
        speeds[#speeds + 1] = 3.00
    end

    return speeds[functions.randomInt(1, #speeds)]
end

local function audioTempoFilter(speed)
    if speed <= 0.5 then
        return "atempo=0.5,atempo=" .. tostring(speed / 0.5)
    end

    if speed > 2.0 then
        return "atempo=2.0,atempo=" .. tostring(speed / 2.0)
    end

    return "atempo=" .. tostring(speed)
end

function Query(localeName, localizationTokens)
    return {
        ["name"] = "ArabFunny / Gen Alpha Library",
        ["description"] =
            "Randomly mixes ArabFunny and Gen Alpha videos, audio, images and overlays " ..
            "into the current render with chaotic meme edits.",

        ["settings"] = {
            {
                ["name"] = "Chance Roll",
                ["tooltip"] = "Chance that the ArabFunny / Gen Alpha effect runs.",
                ["value"] = "65",
                ["type"] = "number"
            },
            {
                ["name"] = "Chaos Level",
                ["tooltip"] = "Controls speed changes, color distortion, shake and loudness.",
                ["value"] = "70",
                ["type"] = "number"
            },
            {
                ["name"] = "Use Videos",
                ["tooltip"] = "Randomly cuts to a meme video from the ArabFunny Videos library.",
                ["value"] = "1",
                ["type"] = "bool"
            },
            {
                ["name"] = "Use Audio",
                ["tooltip"] = "Mixes a random sound from the ArabFunny Audio library.",
                ["value"] = "1",
                ["type"] = "bool"
            },
            {
                ["name"] = "Use Images",
                ["tooltip"] = "Overlays a random image from the ArabFunny Images library.",
                ["value"] = "1",
                ["type"] = "bool"
            },
            {
                ["name"] = "Use Overlays",
                ["tooltip"] = "Overlays a random transparent/green-screen video from the ArabFunny Overlays library.",
                ["value"] = "1",
                ["type"] = "bool"
            },
            {
                ["name"] = "Overlay Scale",
                ["tooltip"] = "Overlay/image size as a percentage of the output width.",
                ["value"] = "45",
                ["type"] = "number"
            },
            {
                ["name"] = "Audio Volume",
                ["tooltip"] = "Injected audio volume multiplier.",
                ["value"] = "1.4",
                ["type"] = "float"
            }
        },

        ["libraries"] = {
            {
                ["name"] = "ArabFunny Videos",
                ["tooltip"] = "Short ArabFunny / Gen Alpha meme video clips.",
                ["path"] = "arabfunny_videos",
                ["type"] = "video"
            },
            {
                ["name"] = "ArabFunny Audio",
                ["tooltip"] = "Arabic meme sounds, Gen Alpha SFX, distorted music and reactions.",
                ["path"] = "arabfunny_audio",
                ["type"] = "audio"
            },
            {
                ["name"] = "ArabFunny Images",
                ["tooltip"] = "PNG/JPG meme images, captions, emoji and reaction stills.",
                ["path"] = "arabfunny_images",
                ["type"] = "image"
            },
            {
                ["name"] = "ArabFunny Overlays",
                ["tooltip"] = "Transparent or green-screen video overlays.",
                ["path"] = "arabfunny_overlays",
                ["type"] = "video"
            }
        }
    }
end

function StartGeneration(options, pluginSettings, functions)
    if not functions.ffmpegInstalled() then
        return false
    end

    local chance = clamp(numberSetting(pluginSettings, "Chance Roll", 65), 0, 100)
    local chaos = clamp(numberSetting(pluginSettings, "Chaos Level", 70), 0, 100)
    local overlayScale = clamp(numberSetting(pluginSettings, "Overlay Scale", 45), 5, 200)
    local audioVolume = clamp(numberSetting(pluginSettings, "Audio Volume", 1.4), 0, 5)

    if not randomChance(functions, chance) then
        functions.fileCopy(options.inputVideo, options.outputVideo)
        return true
    end

    local width = tonumber(options.width) or 1280
    local height = tonumber(options.height) or 720

    local memeVideo = nil
    local memeAudio = nil
    local memeImage = nil
    local memeOverlay = nil

    if boolSetting(pluginSettings, "Use Videos", true) and randomChance(functions, chaos) then
        memeVideo = functions.getRandomLibraryFile("video", "arabfunny_videos")
    end

    if boolSetting(pluginSettings, "Use Audio", true) then
        memeAudio = functions.getRandomLibraryFile("audio", "arabfunny_audio")
    end

    if boolSetting(pluginSettings, "Use Images", true) and randomChance(functions, math.max(25, chaos)) then
        memeImage = functions.getRandomLibraryFile("image", "arabfunny_images")
    end

    if boolSetting(pluginSettings, "Use Overlays", true) and randomChance(functions, math.max(35, chaos)) then
        memeOverlay = functions.getRandomLibraryFile("video", "arabfunny_overlays")
    end

    if (memeVideo == nil or memeVideo == "") and
       (memeAudio == nil or memeAudio == "") and
       (memeImage == nil or memeImage == "") and
       (memeOverlay == nil or memeOverlay == "") then
        functions.fileCopy(options.inputVideo, options.outputVideo)
        return true
    end

    local inputs = { "-i \"" .. options.inputVideo .. "\"" }
    local inputIndex = 1
    local memeVideoIndex = nil
    local memeAudioIndex = nil
    local memeImageIndex = nil
    local memeOverlayIndex = nil

    if memeVideo ~= nil and memeVideo ~= "" then
        inputs[#inputs + 1] = "-stream_loop -1 -i \"" .. memeVideo .. "\""
        memeVideoIndex = inputIndex
        inputIndex = inputIndex + 1
    end

    if memeAudio ~= nil and memeAudio ~= "" then
        inputs[#inputs + 1] = "-i \"" .. memeAudio .. "\""
        memeAudioIndex = inputIndex
        inputIndex = inputIndex + 1
    end

    if memeImage ~= nil and memeImage ~= "" then
        inputs[#inputs + 1] = "-loop 1 -i \"" .. memeImage .. "\""
        memeImageIndex = inputIndex
        inputIndex = inputIndex + 1
    end

    if memeOverlay ~= nil and memeOverlay ~= "" then
        inputs[#inputs + 1] = "-stream_loop -1 -i \"" .. memeOverlay .. "\""
        memeOverlayIndex = inputIndex
    end

    local speed = randomSpeed(functions, chaos)
    local filters = {}
    local currentVideo = "basev"

    filters[#filters + 1] =
        "[0:v]scale=" .. tostring(width) .. ":" .. tostring(height) ..
        ",setpts=" .. tostring(1 / speed) .. "*PTS" ..
        ",eq=saturation=" .. tostring(1.5 + chaos / 75) ..
        ":contrast=" .. tostring(1.1 + chaos / 140) ..
        ":brightness=" .. tostring((chaos - 50) / 900) ..
        ",hue=h=" .. tostring(chaos * 1.8) ..
        ",format=yuv420p[" .. currentVideo .. "]"

    if memeVideoIndex ~= nil then
        filters[#filters + 1] =
            "[" .. tostring(memeVideoIndex) .. ":v]scale=" .. tostring(width) .. ":" .. tostring(height) ..
            ":force_original_aspect_ratio=increase,crop=" .. tostring(width) .. ":" .. tostring(height) ..
            ",setpts=PTS-STARTPTS[memev]"
        filters[#filters + 1] =
            "[" .. currentVideo .. "][memev]blend=all_mode=addition:all_opacity=" ..
            tostring(0.15 + chaos / 250) .. "[withmemev]"
        currentVideo = "withmemev"
    end

    if memeImageIndex ~= nil then
        local imageWidth = math.floor(width * (overlayScale / 100))
        filters[#filters + 1] =
            "[" .. tostring(memeImageIndex) .. ":v]scale=" .. tostring(imageWidth) .. ":-1[img]"
        filters[#filters + 1] =
            "[" .. currentVideo .. "][img]overlay=(W-w)/2:(H-h)/2:enable='between(t,0,4)'[withimg]"
        currentVideo = "withimg"
    end

    if memeOverlayIndex ~= nil then
        local overlayWidth = math.floor(width * (overlayScale / 100))
        filters[#filters + 1] =
            "[" .. tostring(memeOverlayIndex) .. ":v]scale=" .. tostring(overlayWidth) .. ":-1,setpts=PTS-STARTPTS[ovr]"
        filters[#filters + 1] =
            "[" .. currentVideo .. "][ovr]overlay=x='mod(t*" .. tostring(80 + chaos) .. ",W)':y='H-h-20'[withovr]"
        currentVideo = "withovr"
    end

    local audioLabel = "0:a?"
    if memeAudioIndex ~= nil then
        filters[#filters + 1] =
            "[" .. tostring(memeAudioIndex) .. ":a]volume=" .. tostring(audioVolume) .. "[memea]"
        filters[#filters + 1] =
            "[0:a][memea]amix=inputs=2:duration=first:dropout_transition=0[aout]"
        audioLabel = "[aout]"
    end

    local filterComplex = table.concat(filters, ";")
    local audioArgs = ""

    if audioLabel == "[aout]" then
        audioArgs = "-map \"[aout]\" -c:a aac "
    else
        audioArgs = "-map 0:a? -filter:a \"" .. audioTempoFilter(speed) .. "\" -c:a aac "
    end

    functions.runFFmpeg(
        table.concat(inputs, " ") .. " " ..
        "-filter_complex \"" .. filterComplex .. "\" " ..
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
