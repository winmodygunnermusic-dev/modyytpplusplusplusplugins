--[[
    Sus Effect
    Nonsensical Video Generator Workshop Addon

    File:
        sus_effect.lua

    Folder:
        NonsensicalVideoGenerator\plugins\workshop\sus_effect\

    Description:
        Adds a chaotic "Sus" / YTP-style distortion effect.

        Features:
        - Random zoom
        - Random crop
        - Horizontal mirror
        - RGB/color distortion
        - Hue rotation
        - Contrast boost
        - Saturation boost
        - Brightness changes
        - Random shake
        - Optional vignette
        - Optional audio pitch/tempo chaos
        - Configurable intensity
        - Configurable audio distortion
        - Configurable mirror chance

    No external libraries are required.
]]

------------------------------------------------------------
-- Query
------------------------------------------------------------

function Query(localeName, localizationTokens)

    return {
        ["settings"] = {

            {
                ["name"] = "Display Name",
                ["value"] = "Sus",
                ["type"] = "label"
            },

            {
                ["name"] = "Description",
                ["value"] = "Random sus-style visual distortion, zoom, shake, color chaos and audio weirdness.",
                ["type"] = "label"
            },

            {
                ["name"] = "Intensity",
                ["tooltip"] = "Controls the overall strength of the sus effect.",
                ["value"] = "65",
                ["type"] = "int"
            },

            {
                ["name"] = "Visual Chaos",
                ["tooltip"] = "Controls random zoom, shake, color and distortion.",
                ["value"] = "70",
                ["type"] = "int"
            },

            {
                ["name"] = "Audio Chaos",
                ["tooltip"] = "Controls pitch and tempo distortion.",
                ["value"] = "35",
                ["type"] = "int"
            },

            {
                ["name"] = "Mirror Chance",
                ["tooltip"] = "Percentage chance that the clip will be horizontally mirrored.",
                ["value"] = "35",
                ["type"] = "int"
            },

            {
                ["name"] = "Vignette",
                ["tooltip"] = "Adds a dark vignette around the image.",
                ["value"] = "0",
                ["type"] = "bool"
            },

            {
                ["name"] = "Audio Distortion",
                ["tooltip"] = "Enable strange pitch and tempo changes.",
                ["value"] = "1",
                ["type"] = "bool"
            }
        }
    }
end


------------------------------------------------------------
-- Helpers
------------------------------------------------------------

local function clamp(value, minimum, maximum)

    if value < minimum then
        return minimum
    end

    if value > maximum then
        return maximum
    end

    return value
end


local function getSetting(settings, name, defaultValue)

    local value = settings[name]

    if value == nil then
        return defaultValue
    end

    local numberValue = tonumber(value)

    if numberValue == nil then
        return defaultValue
    end

    return numberValue
end


local function getBoolSetting(settings, name, defaultValue)

    local value = settings[name]

    if value == nil then
        return defaultValue
    end

    if value == "1" or value == "true" then
        return true
    end

    if value == "0" or value == "false" then
        return false
    end

    return defaultValue
end


------------------------------------------------------------
-- StartGeneration
------------------------------------------------------------

function StartGeneration(options, pluginSettings, functions)

    if not functions.ffmpegInstalled() then

        print("<[255,80,80]>Sus Effect: FFmpeg is not available.")

        return false
    end


    --------------------------------------------------------
    -- Read settings
    --------------------------------------------------------

    local intensity =
        clamp(
            getSetting(pluginSettings, "Intensity", 65),
            0,
            100
        )

    local visualChaos =
        clamp(
            getSetting(pluginSettings, "Visual Chaos", 70),
            0,
            100
        )

    local audioChaos =
        clamp(
            getSetting(pluginSettings, "Audio Chaos", 35),
            0,
            100
        )

    local mirrorChance =
        clamp(
            getSetting(pluginSettings, "Mirror Chance", 35),
            0,
            100
        )

    local vignette =
        getBoolSetting(
            pluginSettings,
            "Vignette",
            false
        )

    local audioDistortion =
        getBoolSetting(
            pluginSettings,
            "Audio Distortion",
            true
        )


    --------------------------------------------------------
    -- Randomized parameters
    --------------------------------------------------------

    local intensityMultiplier =
        intensity / 100.0

    local visualMultiplier =
        visualChaos / 100.0


    --------------------------------------------------------
    -- Zoom
    --------------------------------------------------------

    local zoomAmount =
        functions.randomDouble(
            1.00,
            1.00 + (0.30 * intensityMultiplier)
        )


    --------------------------------------------------------
    -- Crop position
    --------------------------------------------------------

    local cropX =
        functions.randomInt(
            0,
            math.floor(
                25 * visualMultiplier
            )
        )

    local cropY =
        functions.randomInt(
            0,
            math.floor(
                20 * visualMultiplier
            )
        )


    --------------------------------------------------------
    -- Shake
    --------------------------------------------------------

    local shake =
        functions.randomInt(
            0,
            math.floor(
                18 * visualMultiplier
            )
        )


    --------------------------------------------------------
    -- Rotation / hue
    --------------------------------------------------------

    local hue =
        functions.randomDouble(
            -35 * visualMultiplier,
            35 * visualMultiplier
        )


    --------------------------------------------------------
    -- Contrast
    --------------------------------------------------------

    local contrast =
        functions.randomDouble(
            1.0,
            1.0 + (1.8 * intensityMultiplier)
        )


    --------------------------------------------------------
    -- Saturation
    --------------------------------------------------------

    local saturation =
        functions.randomDouble(
            1.0,
            1.0 + (2.5 * intensityMultiplier)
        )


    --------------------------------------------------------
    -- Brightness
    --------------------------------------------------------

    local brightness =
        functions.randomDouble(
            -0.12 * intensityMultiplier,
            0.12 * intensityMultiplier
        )


    --------------------------------------------------------
    -- Mirror
    --------------------------------------------------------

    local mirror = false

    if functions.randomInt(1, 100) <= mirrorChance then
        mirror = true
    end


    --------------------------------------------------------
    -- Audio parameters
    --------------------------------------------------------

    local pitch =
        functions.randomDouble(
            1.0 - (0.18 * (audioChaos / 100)),
            1.0 + (0.22 * (audioChaos / 100))
        )

    local tempo =
        functions.randomDouble(
            1.0 - (0.10 * (audioChaos / 100)),
            1.0 + (0.14 * (audioChaos / 100))
        )


    --------------------------------------------------------
    -- Save parameters globally for PostCommand
    --------------------------------------------------------

    SusEffect = {

        intensity = intensity,

        zoom = zoomAmount,

        cropX = cropX,

        cropY = cropY,

        shake = shake,

        hue = hue,

        contrast = contrast,

        saturation = saturation,

        brightness = brightness,

        mirror = mirror,

        pitch = pitch,

        tempo = tempo,

        vignette = vignette,

        audioDistortion = audioDistortion,

        outputVideo = options.outputVideo,

        inputVideo = options.inputVideo
    }


    --------------------------------------------------------
    -- Debug output
    --------------------------------------------------------

    print(
        "<[255,80,255]>Sus Effect activated!"
    )

    print(
        "Intensity: " ..
        tostring(intensity)
    )

    print(
        "Zoom: " ..
        string.format("%.2f", zoomAmount)
    )

    print(
        "Shake: " ..
        tostring(shake)
    )

    print(
        "Mirror: " ..
        tostring(mirror)
    )

    print(
        "Hue: " ..
        string.format("%.2f", hue)
    )


    --------------------------------------------------------
    -- Start FFmpeg
    --------------------------------------------------------

    local filterParts = {}


    --------------------------------------------------------
    -- Scale / zoom
    --------------------------------------------------------

    table.insert(
        filterParts,
        "scale=iw*" ..
        string.format("%.3f", zoomAmount) ..
        ":ih*" ..
        string.format("%.3f", zoomAmount)
    )


    --------------------------------------------------------
    -- Crop
    --------------------------------------------------------

    table.insert(
        filterParts,
        "crop=iw-" ..
        tostring(cropX * 2) ..
        ":ih-" ..
        tostring(cropY * 2) ..
        ":" ..
        tostring(cropX) ..
        ":" ..
        tostring(cropY)
    )


    --------------------------------------------------------
    -- Random shake
    --------------------------------------------------------

    if shake > 0 then

        table.insert(
            filterParts,
            "crop=iw-" ..
            tostring(shake * 2) ..
            ":ih-" ..
            tostring(shake * 2) ..
            ":" ..
            tostring(shake) ..
            ":" ..
            tostring(shake)
        )

    end


    --------------------------------------------------------
    -- Mirror
    --------------------------------------------------------

    if mirror then

        table.insert(
            filterParts,
            "hflip"
        )

    end


    --------------------------------------------------------
    -- Color / contrast
    --------------------------------------------------------

    table.insert(
        filterParts,
        "eq=contrast=" ..
        string.format("%.3f", contrast) ..
        ":brightness=" ..
        string.format("%.3f", brightness) ..
        ":saturation=" ..
        string.format("%.3f", saturation)
    )


    --------------------------------------------------------
    -- Hue
    --------------------------------------------------------

    table.insert(
        filterParts,
        "hue=h=" ..
        string.format("%.3f", hue)
    )


    --------------------------------------------------------
    -- Optional vignette
    --------------------------------------------------------

    if vignette then

        table.insert(
            filterParts,
            "vignette=PI/5"
        )

    end


    --------------------------------------------------------
    -- Pixel format
    --------------------------------------------------------

    table.insert(
        filterParts,
        "format=yuv420p"
    )


    --------------------------------------------------------
    -- Build video filter
    --------------------------------------------------------

    local videoFilter =
        table.concat(
            filterParts,
            ","
        )


    --------------------------------------------------------
    -- Audio filter
    --------------------------------------------------------

    local audioFilter = ""

    if audioDistortion then

        audioFilter =
            "aresample=48000," ..
            "asetrate=48000*" ..
            string.format("%.5f", pitch) ..
            ",aresample=48000," ..
            "atempo=" ..
            string.format("%.5f", tempo)

    end


    --------------------------------------------------------
    -- Temporary output
    --------------------------------------------------------

    local tempVideo =
        "sus_effect_video.mp4"


    --------------------------------------------------------
    -- FFmpeg command
    --------------------------------------------------------

    local command

    if audioDistortion then

        command =
            "-i \"" ..
            options.inputVideo ..
            "\" " ..
            "-vf \"" ..
            videoFilter ..
            "\" " ..
            "-af \"" ..
            audioFilter ..
            "\" " ..
            "-map 0:v:0 " ..
            "-map 0:a? " ..
            "-c:v libx264 " ..
            "-preset veryfast " ..
            "-crf 20 " ..
            "-c:a aac " ..
            "-b:a 192k " ..
            "-movflags +faststart " ..
            "-y \"" ..
            tempVideo ..
            "\""

    else

        command =
            "-i \"" ..
            options.inputVideo ..
            "\" " ..
            "-vf \"" ..
            videoFilter ..
            "\" " ..
            "-map 0:v:0 " ..
            "-map 0:a? " ..
            "-c:v libx264 " ..
            "-preset veryfast " ..
            "-crf 20 " ..
            "-c:a copy " ..
            "-movflags +faststart " ..
            "-y \"" ..
            tempVideo ..
            "\""

    end


    --------------------------------------------------------
    -- Execute
    --------------------------------------------------------

    functions.runFFmpeg(command)


    return true
end


------------------------------------------------------------
-- PostCommand
------------------------------------------------------------

function PostCommand(
    commandIndex,
    outputResult,
    errorResult,
    options,
    pluginSettings,
    functions
)

    if commandIndex == 1 then

        print(
            "<[255,150,0]>Sus Effect: FFmpeg processing finished."
        )


        ----------------------------------------------------
        -- Move processed file to NVG output
        ----------------------------------------------------

        if functions.fileExists(
            "sus_effect_video.mp4"
        ) then

            functions.fileMove(
                "sus_effect_video.mp4",
                options.outputVideo
            )

            print(
                "<[120,255,120]>Sus Effect: Output created."
            )

        else

            print(
                "<[255,80,80]>Sus Effect: Output file was not found."
            )

        end

    end
end


------------------------------------------------------------
-- StopGeneration
------------------------------------------------------------

function StopGeneration(
    options,
    pluginSettings,
    functions
)

    print(
        "<[255,80,255]>Sus Effect finished."
    )

    return true
end
