--[[
    Video Remixed / Meme Effect
    Nonsensical Video Generator - Workshop Addon

    Suggested addon filename:
        video_remixed_meme.lua

    Suggested addon folder:
        NonsensicalVideoGenerator\plugins\workshop\video_remixed_meme\

    Effect style:
        - Random meme-style visual remixing
        - Speed changes
        - Mirror flips
        - Contrast / saturation boosts
        - Slight zoom
        - Frame duplication / stutter
        - Optional audio pitch/speed chaos
        - Randomized intensity

    No external libraries are required.
]]

local function clamp(value, minimum, maximum)
    if value < minimum then
        return minimum
    end

    if value > maximum then
        return maximum
    end

    return value
end


function Query(localeName, localizationTokens)

    return {
        ["settings"] = {
            {
                ["name"] = "Display Name",
                ["value"] = "Video Remixed / Meme",
                ["type"] = "label"
            },

            {
                ["name"] = "Description",
                ["value"] =
                    "Randomly remixes video clips with meme-style speed, mirror, color, zoom, stutter, and audio effects.",
                ["type"] = "label"
            },

            {
                ["name"] = "Chance Roll",
                ["tooltip"] =
                    "Chance from 0-100 for the effect to perform a remix.",
                ["value"] = "50",
                ["type"] = "int"
            },

            {
                ["name"] = "Meme Intensity",
                ["tooltip"] =
                    "Controls how aggressive the remix effects are.",
                ["value"] = "60",
                ["type"] = "int"
            },

            {
                ["name"] = "Visual Chaos",
                ["tooltip"] =
                    "Enables randomized visual meme effects.",
                ["value"] = "1",
                ["type"] = "bool"
            },

            {
                ["name"] = "Audio Chaos",
                ["tooltip"] =
                    "Enables randomized audio speed and pitch effects.",
                ["value"] = "1",
                ["type"] = "bool"
            },

            {
                ["name"] = "Mirror Chance",
                ["tooltip"] =
                    "Chance that the video will be horizontally mirrored.",
                ["value"] = "35",
                ["type"] = "int"
            },

            {
                ["name"] = "Stutter Chance",
                ["tooltip"] =
                    "Chance that a short section will be repeated.",
                ["value"] = "30",
                ["type"] = "int"
            },

            {
                ["name"] = "Speed Chaos",
                ["tooltip"] =
                    "Allows randomized fast/slow playback.",
                ["value"] = "1",
                ["type"] = "bool"
            }
        }
    }
end


function StartGeneration(options, pluginSettings, functions)

    -- Read settings.
    local chance = tonumber(pluginSettings["Chance Roll"]) or 50
    local intensity = tonumber(pluginSettings["Meme Intensity"]) or 60

    chance = clamp(chance, 0, 100)
    intensity = clamp(intensity, 0, 100)

    -- Roll the main effect.
    if functions.randomInt(1, 100) > chance then
        return false
    end

    -- Generate a unique temporary filename.
    local tempVideo = "video_remixed_meme_input.mp4"
    local tempAudio = "video_remixed_meme_audio.m4a"

    -- Copy the input into the effect working directory.
    functions.fileCopy(options.inputVideo, tempVideo)

    -- Determine which effects will be used.
    local mirror = false
    local stutter = false
    local speed = 1.0

    if pluginSettings["Visual Chaos"] == "1" then

        local mirrorChance =
            clamp(
                tonumber(pluginSettings["Mirror Chance"]) or 35,
                0,
                100
            )

        if functions.randomInt(1, 100) <= mirrorChance then
            mirror = true
        end

        local stutterChance =
            clamp(
                tonumber(pluginSettings["Stutter Chance"]) or 30,
                0,
                100
            )

        if functions.randomInt(1, 100) <= stutterChance then
            stutter = true
        end
    end

    if pluginSettings["Speed Chaos"] == "1" then

        local speedRoll = functions.randomInt(1, 5)

        if speedRoll == 1 then
            speed = 0.50
        elseif speedRoll == 2 then
            speed = 0.75
        elseif speedRoll == 3 then
            speed = 1.25
        elseif speedRoll == 4 then
            speed = 1.50
        else
            speed = 2.00
        end
    end

    -- Intensity controls the amount of color/contrast.
    local saturation =
        1.0 + ((intensity / 100.0) * 1.5)

    local contrast =
        1.0 + ((intensity / 100.0) * 0.7)

    local brightness =
        (functions.randomDouble(-0.08, 0.08))
        * (intensity / 100.0)

    -- Random meme zoom.
    local zoom =
        1.0 + functions.randomDouble(0.0, 0.12)
        * (intensity / 100.0)

    -- Build the video filter.
    local filters = {}

    -- Speed.
    table.insert(
        filters,
        "setpts=" .. string.format("%.4f", 1.0 / speed) .. "*PTS"
    )

    -- Mirror.
    if mirror then
        table.insert(filters, "hflip")
    end

    -- Meme zoom.
    if zoom > 1.001 then
        table.insert(
            filters,
            "scale=iw*" ..
                string.format("%.4f", zoom) ..
                ":ih*" ..
                string.format("%.4f", zoom)
        )

        table.insert(
            filters,
            "crop=iw/" ..
                string.format("%.4f", zoom) ..
                ":ih/" ..
                string.format("%.4f", zoom)
        )
    end

    -- Strong meme-style color processing.
    table.insert(
        filters,
        "eq=contrast=" ..
            string.format("%.4f", contrast) ..
            ":brightness=" ..
            string.format("%.4f", brightness) ..
            ":saturation=" ..
            string.format("%.4f", saturation)
    )

    -- Slight sharpening.
    if intensity >= 35 then
        table.insert(filters, "unsharp=5:5:0.7:5:5:0.0")
    end

    -- Stutter effect.
    --
    -- This intentionally uses a short repeated frame section.
    -- The exact amount scales with intensity.
    if stutter then
        local stutterFrames =
            math.floor(
                2 + ((intensity / 100) * 8)
            )

        table.insert(
            filters,
            "tpad=stop_mode=clone:stop=" ..
                tostring(stutterFrames)
        )
    end

    local filterString = table.concat(filters, ",")

    -- First asynchronous command:
    -- create the remixed video.
    local command =
        "-i \"" .. tempVideo .. "\"" ..
        " -vf \"" .. filterString .. "\"" ..
        " -an" ..
        " -c:v libx264" ..
        " -preset veryfast" ..
        " -pix_fmt yuv420p" ..
        " -y \"" .. tempAudio .. "\""

    -- We use a separate temporary filename even though this first
    -- output contains video only.
    functions.runFFmpeg(command)

    -- Store generated state for PostCommand.
    _G.VideoRemixedMeme = {
        tempVideo = tempVideo,
        tempOutput = tempAudio,
        speed = speed,
        audioEnabled = pluginSettings["Audio Chaos"] == "1",
        options = options
    }

    return true
end


function PostCommand(
    commandIndex,
    outputResult,
    errorResult,
    options,
    pluginSettings,
    functions
)

    local state = _G.VideoRemixedMeme

    if state == nil then
        return
    end

    -- First command has completed.
    if commandIndex == 1 then

        -- If audio chaos is disabled, simply remux the generated video
        -- with the original audio.
        if not state.audioEnabled then

            functions.runFFmpeg(
                "-i \"" ..
                    state.tempOutput ..
                    "\" -i \"" ..
                    state.tempVideo ..
                    "\" " ..
                    "-map 0:v:0 -map 1:a? " ..
                    "-c:v copy -c:a aac -shortest " ..
                    "-y \"" ..
                    options.outputVideo ..
                    "\""
            )

            return
        end

        -- Audio remix.
        local audioSpeed = state.speed

        -- atempo accepts values between 0.5 and 2.0.
        audioSpeed = clamp(audioSpeed, 0.5, 2.0)

        local pitchChoice =
            functions.randomInt(1, 4)

        local audioFilter

        if pitchChoice == 1 then
            audioFilter =
                "atempo=" ..
                string.format("%.4f", audioSpeed)
        elseif pitchChoice == 2 then
            audioFilter =
                "atempo=" ..
                string.format("%.4f", audioSpeed) ..
                ",highpass=f=120"
        elseif pitchChoice == 3 then
            audioFilter =
                "atempo=" ..
                string.format("%.4f", audioSpeed) ..
                ",lowpass=f=9000"
        else
            audioFilter =
                "atempo=" ..
                string.format("%.4f", audioSpeed) ..
                ",volume=1.35"
        end

        -- Second command:
        -- combine remixed video with processed original audio.
        functions.runFFmpeg(
            "-i \"" ..
                state.tempOutput ..
                "\" -i \"" ..
                state.tempVideo ..
                "\" " ..
                "-filter_complex \"" ..
                "[1:a]" ..
                audioFilter ..
                "[a]\" " ..
                "-map 0:v:0 -map \"[a]\" " ..
                "-c:v copy -c:a aac " ..
                "-shortest " ..
                "-y \"" ..
                options.outputVideo ..
                "\""
        )

    elseif commandIndex == 2 then

        -- Finalization command.
        -- Nothing else is required here.
        return
    end
end


function StopGeneration(options, pluginSettings, functions)

    -- Clean temporary files if they exist.
    if functions.fileExists("video_remixed_meme_input.mp4") then
        functions.fileDelete("video_remixed_meme_input.mp4")
    end

    if functions.fileExists("video_remixed_meme_audio.m4a") then
        functions.fileDelete("video_remixed_meme_audio.m4a")
    end

    _G.VideoRemixedMeme = nil

    return true
end
