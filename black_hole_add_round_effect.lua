-- Black Hole Add Round Effect
-- Nonsensical Video Generator v1.8.1.2 Workshop Effect
--
-- Install this generated addon at:
-- NonsensicalVideoGenerator\plugins\workshop\black_hole_add_round_effect.lua
--
-- Trend style:
--   A looping black-hole animation where each new round pulls another
--   character, object, item or clip toward the center as the round label
--   increases, similar to YouTube/Scratch "black hole add round" projects.
--
-- Suggested workshop library folders:
--   image/black_hole_items     PNG/JPG characters, objects and item cutouts
--   video/black_hole_clips     Short transparent/green-screen object clips
--   audio/black_hole_sfx       Whooshes, suction sounds, impacts and pops

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

local function getLibraryFile(functions, mediaType, path)
    local value = functions.getRandomLibraryFile(mediaType, path)
    if value == nil or value == "" then
        return nil
    end

    return value
end

function Query(localeName, localizationTokens)
    return {
        ["name"] = "Black Hole Add Round",
        ["description"] =
            "Creates a looping black-hole add-round trend effect where random " ..
            "characters, objects or clips get pulled into the center each round.",

        ["settings"] = {
            {
                ["name"] = "Chance Roll",
                ["tooltip"] = "Chance that the black-hole round effect is applied.",
                ["value"] = "100",
                ["type"] = "number"
            },
            {
                ["name"] = "Round Count",
                ["tooltip"] = "How many visible add-round beats to create.",
                ["value"] = "4",
                ["type"] = "number"
            },
            {
                ["name"] = "Vortex Strength",
                ["tooltip"] = "Controls swirl, darkening and pull-in intensity.",
                ["value"] = "75",
                ["type"] = "number"
            },
            {
                ["name"] = "Use Item Images",
                ["tooltip"] = "Pull PNG/JPG characters or objects from the item image library.",
                ["value"] = "1",
                ["type"] = "bool"
            },
            {
                ["name"] = "Use Item Clips",
                ["tooltip"] = "Pull a transparent/green-screen video clip into the black hole.",
                ["value"] = "1",
                ["type"] = "bool"
            },
            {
                ["name"] = "Use SFX",
                ["tooltip"] = "Mix whoosh/suction/pop sounds from the SFX library.",
                ["value"] = "1",
                ["type"] = "bool"
            },
            {
                ["name"] = "Item Scale",
                ["tooltip"] = "Item size as a percentage of output width.",
                ["value"] = "24",
                ["type"] = "number"
            },
            {
                ["name"] = "Show Round Text",
                ["tooltip"] = "Draw ROUND labels like a black-hole add-round project.",
                ["value"] = "1",
                ["type"] = "bool"
            },
            {
                ["name"] = "SFX Volume",
                ["tooltip"] = "Whoosh/suction sound volume multiplier.",
                ["value"] = "1.2",
                ["type"] = "float"
            }
        },

        ["libraries"] = {
            {
                ["name"] = "Black Hole Items",
                ["tooltip"] = "PNG/JPG characters, props, objects and add-round item cutouts.",
                ["path"] = "black_hole_items",
                ["type"] = "image"
            },
            {
                ["name"] = "Black Hole Clips",
                ["tooltip"] = "Short transparent or green-screen object/character clips.",
                ["path"] = "black_hole_clips",
                ["type"] = "video"
            },
            {
                ["name"] = "Black Hole SFX",
                ["tooltip"] = "Whooshes, suction sounds, impacts, pops and round transition sounds.",
                ["path"] = "black_hole_sfx",
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
    if not chance(functions, chanceRoll) then
        functions.fileCopy(options.inputVideo, options.outputVideo)
        return true
    end

    local roundCount = math.floor(clamp(numberSetting(pluginSettings, "Round Count", 4), 1, 8))
    local vortexStrength = clamp(numberSetting(pluginSettings, "Vortex Strength", 75), 0, 100)
    local itemScale = clamp(numberSetting(pluginSettings, "Item Scale", 24), 5, 100)
    local sfxVolume = clamp(numberSetting(pluginSettings, "SFX Volume", 1.2), 0, 5)
    local showRoundText = boolSetting(pluginSettings, "Show Round Text", true)
    local useImages = boolSetting(pluginSettings, "Use Item Images", true)
    local useClips = boolSetting(pluginSettings, "Use Item Clips", true)
    local useSfx = boolSetting(pluginSettings, "Use SFX", true)
    local width = tonumber(options.width) or 1280
    local height = tonumber(options.height) or 720

    local itemFiles = {}
    if useImages then
        for i = 1, roundCount do
            local item = getLibraryFile(functions, "image", "black_hole_items")
            if item ~= nil then
                itemFiles[#itemFiles + 1] = item
            end
        end
    end

    local clipFile = nil
    if useClips then
        clipFile = getLibraryFile(functions, "video", "black_hole_clips")
    end

    local sfxFile = nil
    if useSfx then
        sfxFile = getLibraryFile(functions, "audio", "black_hole_sfx")
    end

    if #itemFiles == 0 and clipFile == nil and sfxFile == nil then
        functions.fileCopy(options.inputVideo, options.outputVideo)
        return true
    end

    local inputs = { "-i \"" .. options.inputVideo .. "\"" }
    local inputIndex = 1
    local itemIndexes = {}
    local clipIndex = nil
    local sfxIndex = nil

    for i = 1, #itemFiles do
        inputs[#inputs + 1] = "-loop 1 -i \"" .. itemFiles[i] .. "\""
        itemIndexes[#itemIndexes + 1] = inputIndex
        inputIndex = inputIndex + 1
    end

    if clipFile ~= nil then
        inputs[#inputs + 1] = "-stream_loop -1 -i \"" .. clipFile .. "\""
        clipIndex = inputIndex
        inputIndex = inputIndex + 1
    end

    if sfxFile ~= nil then
        inputs[#inputs + 1] = "-i \"" .. sfxFile .. "\""
        sfxIndex = inputIndex
    end

    local filters = {}
    local currentVideo = "holebase"
    local holeSize = math.floor(math.min(width, height) * (0.22 + vortexStrength / 500))
    local itemWidth = math.floor(width * itemScale / 100)
    local roundDuration = 1.25
    local totalDuration = roundDuration * roundCount
    local darkOpacity = 0.28 + vortexStrength / 260

    filters[#filters + 1] =
        "[0:v]scale=" .. tostring(width) .. ":" .. tostring(height) ..
        ",eq=saturation=" .. tostring(0.85 + vortexStrength / 180) ..
        ":contrast=" .. tostring(1.05 + vortexStrength / 180) ..
        ",vignette=PI/3,format=rgba[bg];" ..
        "color=c=black@" .. tostring(darkOpacity) .. ":s=" .. tostring(width) .. "x" .. tostring(height) ..
        ":r=30,format=rgba[dim];" ..
        "[bg][dim]overlay=0:0[dimmed];" ..
        "color=c=black:s=" .. tostring(holeSize) .. "x" .. tostring(holeSize) ..
        ":r=30,format=rgba[hole];" ..
        "[dimmed][hole]overlay=(W-w)/2:(H-h)/2[" .. currentVideo .. "]"

    for i = 1, #itemIndexes do
        local idx = itemIndexes[i]
        local startTime = (i - 1) * roundDuration
        local endTime = startTime + roundDuration + 0.4
        local angle = (i - 1) * 1.57
        local label = "item" .. tostring(i)
        local outputLabel = "withitem" .. tostring(i)

        filters[#filters + 1] =
            "[" .. tostring(idx) .. ":v]scale=" .. tostring(itemWidth) .. ":-1,format=rgba[" .. label .. "]"
        filters[#filters + 1] =
            "[" .. currentVideo .. "][" .. label .. "]overlay=" ..
            "x='W/2-w/2+(W*0.42*cos(" .. tostring(angle) .. "))*(1-min(max((t-" .. tostring(startTime) .. ")/" .. tostring(roundDuration) .. ",0),1))':" ..
            "y='H/2-h/2+(H*0.35*sin(" .. tostring(angle) .. "))*(1-min(max((t-" .. tostring(startTime) .. ")/" .. tostring(roundDuration) .. ",0),1))':" ..
            "enable='between(t," .. tostring(startTime) .. "," .. tostring(endTime) .. ")'[" .. outputLabel .. "]"
        currentVideo = outputLabel
    end

    if clipIndex ~= nil then
        filters[#filters + 1] =
            "[" .. tostring(clipIndex) .. ":v]scale=" .. tostring(itemWidth) .. ":-1,setpts=PTS-STARTPTS,format=rgba[roundclip]"
        filters[#filters + 1] =
            "[" .. currentVideo .. "][roundclip]overlay=" ..
            "x='W/2-w/2+(W*0.40)*(1-min(t/" .. tostring(totalDuration) .. ",1))':" ..
            "y='H/2-h/2-(H*0.30)*(1-min(t/" .. tostring(totalDuration) .. ",1))':" ..
            "enable='between(t,0," .. tostring(totalDuration + 0.5) .. ")'[withclip]"
        currentVideo = "withclip"
    end

    if showRoundText then
        filters[#filters + 1] =
            "[" .. currentVideo .. "]drawtext=text='BLACK HOLE ADD ROUND':" ..
            "x=(w-text_w)/2:y=32:fontsize=" .. tostring(math.floor(height / 16)) ..
            ":fontcolor=white:borderw=4:bordercolor=black[title]"
        currentVideo = "title"

        for i = 1, roundCount do
            local startTime = (i - 1) * roundDuration
            local endTime = startTime + roundDuration
            local outputLabel = "roundtext" .. tostring(i)
            filters[#filters + 1] =
                "[" .. currentVideo .. "]drawtext=text='ROUND " .. tostring(i) .. "':" ..
                "x=(w-text_w)/2:y=h-" .. tostring(math.floor(height / 8)) ..
                ":fontsize=" .. tostring(math.floor(height / 11)) ..
                ":fontcolor=yellow:borderw=5:bordercolor=black:" ..
                "enable='between(t," .. tostring(startTime) .. "," .. tostring(endTime) .. ")'[" .. outputLabel .. "]"
            currentVideo = outputLabel
        end
    end

    local audioArgs = "-map 0:a? -c:a aac "
    if sfxIndex ~= nil then
        filters[#filters + 1] =
            "[" .. tostring(sfxIndex) .. ":a]volume=" .. tostring(sfxVolume) .. "[holesfx];" ..
            "[0:a][holesfx]amix=inputs=2:duration=first:dropout_transition=0[aout]"
        audioArgs = "-map \"[aout]\" -c:a aac "
    end

    functions.runFFmpeg(
        table.concat(inputs, " ") .. " " ..
        "-filter_complex \"" .. table.concat(filters, ";") .. "\" " ..
        "-map \"[" .. currentVideo .. "]\" " ..
        audioArgs ..
        "-c:v libx264 -preset veryfast -crf 18 -t " .. tostring(totalDuration) ..
        " -shortest -y \"" .. options.outputVideo .. "\""
    )

    return true
end

function PostCommand(commandIndex, outputResult, errorResult, options, pluginSettings, functions)
end

function StopGeneration(options, pluginSettings, functions)
    return true
end
