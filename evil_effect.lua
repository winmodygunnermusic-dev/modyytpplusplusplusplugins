-- Evil Effect
-- Nonsensical Video Generator Workshop Effect
-- File: evil_effect.lua

local tempVideo = "evil_effect_temp.mp4"

function Query(localeName, localizationTokens)
    return {
        ["settings"] = {
            {
                ["name"] = "Display Name",
                ["value"] = "Evil",
                ["type"] = "label"
            },
            {
                ["name"] = "Description",
                ["value"] = "Turns the video into a sinister evil-themed effect with dark colors, red highlights, contrast, distortion, and unsettling audio.",
                ["type"] = "label"
            },
            {
                ["name"] = "Darkness",
                ["tooltip"] = "Controls how dark the evil effect becomes.",
                ["value"] = "70",
                ["type"] = "int"
            },
            {
                ["name"] = "Red Intensity",
                ["tooltip"] = "Controls the amount of red coloring.",
                ["value"] = "75",
                ["type"] = "int"
            },
            {
                ["name"] = "Audio Evil",
                ["tooltip"] = "Adds a darker, lower-pitched audio treatment.",
                ["value"] = "1",
                ["type"] = "bool"
            }
        }
    }
end

function StartGeneration(options, pluginSettings, functions)
    local darkness = tonumber(pluginSettings["Darkness"]) or 70
    local red = tonumber(pluginSettings["Red Intensity"]) or 75
    local audioEvil = pluginSettings["Audio Evil"] == "1"

    -- Clamp settings.
    darkness = math.max(0, math.min(100, darkness))
    red = math.max(0, math.min(100, red))

    -- Convert settings into FFmpeg-friendly values.
    local contrast = 1.0 + (darkness / 100.0) * 1.8
    local brightness = -(darkness / 100.0) * 0.18
    local saturation = math.max(0.15, 1.0 - (darkness / 100.0) * 0.65)

    -- Strong red/black color treatment.
    local redMix = red / 100.0

    -- Slight randomized evil visual movement.
    local shakeX = functions.randomInt(1, 4)
    local shakeY = functions.randomInt(1, 4)

    -- Store values for PostCommand.
    _G.evilContrast = contrast
    _G.evilBrightness = brightness
    _G.evilSaturation = saturation
    _G.evilRedMix = redMix
    _G.evilShakeX = shakeX
    _G.evilShakeY = shakeY
    _G.evilAudio = audioEvil

    print("<[180,0,0]>Evil Effect: awakening...")

    -- First pass:
    -- darken, increase contrast, reduce saturation, add red tint,
    -- and apply a subtle unstable zoom/shake.
    local vf =
        "eq=contrast=" .. string.format("%.3f", contrast) ..
        ":brightness=" .. string.format("%.3f", brightness) ..
        ":saturation=" .. string.format("%.3f", saturation) ..
        ",colorchannelmixer=" ..
        "rr=" .. string.format("%.3f", 1.0 + redMix * 0.8) ..
        ":rg=" .. string.format("%.3f", redMix * 0.12) ..
        ":rb=0:" ..
        "gr=0:" ..
        "gg=" .. string.format("%.3f", 1.0 - redMix * 0.35) ..
        ":gb=0:" ..
        "br=0:bg=0:bb=" .. string.format("%.3f", 1.0 - redMix * 0.55) ..
        ",scale=iw*1.015:ih*1.015," ..
        "crop=iw/1.015:ih/1.015:" ..
        tostring(shakeX) .. ":" .. tostring(shakeY) ..
        ",vignette=PI/4"

    local audioFilter = "anull"

    if audioEvil then
        -- Lower pitch and add a subtle ominous echo.
        -- atempo keeps the final duration approximately synchronized.
        audioFilter =
            "asetrate=44100*0.82," ..
            "aresample=44100," ..
            "atempo=1.2195," ..
            "aecho=0.8:0.7:90:0.28"
    end

    functions.runFFmpeg(
        "-i \"" .. options.inputVideo .. "\" " ..
        "-vf \"" .. vf .. "\" " ..
        "-af \"" .. audioFilter .. "\" " ..
        "-c:v libx264 -preset veryfast -crf 18 " ..
        "-c:a aac -b:a 192k " ..
        "-pix_fmt yuv420p " ..
        "-movflags +faststart " ..
        "-y \"" .. tempVideo .. "\""
    )

    return true
end

function PostCommand(commandIndex, outputResult, errorResult, options, pluginSettings, functions)
    if commandIndex == 1 then
        print("<[180,0,0]>Evil Effect: finishing the corruption...")

        functions.runFFmpeg(
            "-i \"" .. tempVideo .. "\" " ..
            "-map 0:v:0 -map 0:a? " ..
            "-c:v libx264 -preset veryfast -crf 18 " ..
            "-c:a aac -b:a 192k " ..
            "-pix_fmt yuv420p " ..
            "-movflags +faststart " ..
            "-y \"" .. options.outputVideo .. "\""
        )

    elseif commandIndex == 2 then
        functions.fileDelete(tempVideo)

        print("<[255,0,0]>Evil Effect: complete.")
    end
end

function StopGeneration(options, pluginSettings, functions)
    -- Clean up if rendering was stopped unexpectedly.
    if functions.fileExists(tempVideo) then
        functions.fileDelete(tempVideo)
    end

    print("<[120,0,0]>Evil Effect: darkness has finished.")
    return true
end
