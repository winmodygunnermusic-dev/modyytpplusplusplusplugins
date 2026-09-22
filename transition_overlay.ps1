--[[
    Transition Overlay Effect
    Nonsensical Video Generator
    NVG v1.8.x

    Applies a randomly selected transition video over the input.
    The transition is scaled to the input resolution and composited
    over the original video.

    Library:
        Video / Transitions
]]

local transitionFile = nil
local tempVideo = "transition_overlay_input.mp4"

local function settingNumber(settings, name, defaultValue)
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
                ["value"] = "Transition Overlay",
                ["type"] = "label"
            },
            {
                ["name"] = "Description",
                ["value"] = "Overlays a random transition video on top of the current video.",
                ["type"] = "label"
            },
            {
                ["name"] = "Opacity",
                ["tooltip"] = "Opacity of the transition overlay, from 0 to 100.",
                ["value"] = "85",
                ["type"] = "int"
            },
            {
                ["name"] = "Transition Scale",
                ["tooltip"] = "Scale of the transition video. 100 = fill the frame.",
                ["value"] = "100",
                ["type"] = "int"
            },
            {
                ["name"] = "Blend Mode",
                ["tooltip"] = "FFmpeg blend mode used for the transition.",
                ["value"] = "screen",
                ["type"] = "string"
            }
        },

        ["libraries"] = {
            {
                ["name"] = "Transitions",
                ["tooltip"] = "Video clips used as transition overlays.",
                ["path"] = "transitions",
                ["type"] = "video"
            }
        }
    }
end

function StartGeneration(options, pluginSettings, functions)
    if not functions.ffmpegInstalled() then
        print("<[255,0,0]>Transition Overlay: FFmpeg is not available.")
        return false
    end

    transitionFile =
        functions.getRandomLibraryFile("video", "transitions")

    if transitionFile == nil or transitionFile == "" then
        print("<[255,0,0]>Transition Overlay: No transition videos found.")
        return false
    end

    local opacity =
        math.max(0, math.min(100,
            settingNumber(pluginSettings, "Opacity", 85)))

    local scale =
        math.max(10, math.min(200,
            settingNumber(pluginSettings, "Transition Scale", 100)))

    local blendMode =
        pluginSettings["Blend Mode"] or "screen"

    -- Protect against accidentally entering an invalid blend mode.
    local allowedBlendModes = {
        screen = true,
        addition = true,
        multiply = true,
        overlay = true,
        hardlight = true,
        softlight = true,
        difference = true,
        exclusion = true
    }

    if not allowedBlendModes[blendMode] then
        blendMode = "screen"
    end

    -- Copy the source into the effect working directory.
    -- NVG sanitizes library placeholders when used by FFmpeg.
    functions.runFFmpeg(
        "-i \"" .. options.inputVideo ..
        "\" -c:v libx264 -preset veryfast -crf 18 " ..
        "-c:a aac -y \"" .. tempVideo .. "\""
    )

    -- Store settings for PostCommand.
    _transitionOpacity = opacity / 100.0
    _transitionScale = scale / 100.0
    _transitionBlend = blendMode

    return true
end

function PostCommand(commandIndex, outputResult, errorResult,
                     options, pluginSettings, functions)

    if commandIndex == 1 then

        local opacity = _transitionOpacity or 0.85
        local scale = _transitionScale or 1.0
        local blend = _transitionBlend or "screen"

        local scaledWidth =
            math.floor(options.width * scale)

        local scaledHeight =
            math.floor(options.height * scale)

        -- Transition video:
        --   * scaled to the requested size
        --   * centered
        --   * given an alpha value
        --   * blended over the source
        --
        -- shortest=1 prevents the overlay from extending beyond
        -- the main video.

        local filter =
            "[1:v]scale=" ..
            scaledWidth .. ":" .. scaledHeight ..
            ":force_original_aspect_ratio=decrease," ..
            "format=rgba," ..
            "colorchannelmixer=aa=" .. opacity .. "," ..
            "pad=" ..
            options.width .. ":" ..
            options.height ..
            ":(ow-iw)/2:(oh-ih)/2:color=black@0," ..
            "setpts=PTS-STARTPTS[transition];" ..

            "[0:v]setpts=PTS-STARTPTS[base];" ..

            "[base][transition]blend=" ..
            "all_mode=" .. blend ..
            ":shortest=1[outv]"

        functions.runFFmpeg(
            "-i \"" .. tempVideo ..
            "\" " ..
            "-i \"" .. transitionFile ..
            "\" " ..
            "-filter_complex \"" .. filter .. "\" " ..
            "-map \"[outv]\" " ..
            "-map 0:a? " ..
            "-c:v libx264 " ..
            "-preset veryfast " ..
            "-crf 18 " ..
            "-c:a aac " ..
            "-shortest " ..
            "-y \"" .. options.outputVideo .. "\""
        )

    elseif commandIndex == 2 then

        print(
            "<[0,255,0]>Transition Overlay: " ..
            "render complete."
        )

    end
end

function StopGeneration(options, pluginSettings, functions)

    if functions.fileExists(tempVideo) then
        functions.fileDelete(tempVideo)
    end

    transitionFile = nil
    _transitionOpacity = nil
    _transitionScale = nil
    _transitionBlend = nil

    return true
end