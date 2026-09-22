--[[
    Low Quality Meme Effect
    Nonsensical Video Generator
    NVG Lua Workshop Effect

    Creates a deliberately degraded / compressed meme-video look:
      - Low resolution
      - Low FPS
      - Strong JPEG-like quantization
      - Pixelation
      - Color reduction
      - Blocky noise
      - Optional sharpening
      - Low video bitrate
      - Low audio bitrate
      - Optional mono audio
      - Optional generation of an extra-crunchy result

    Effect name:
        Low Quality Meme

    Requires:
        FFmpeg
]]

local commandIndex = 0

----------------------------------------------------------------------
-- Helpers
----------------------------------------------------------------------

local function settingNumber(settings, name, defaultValue)
    local value = tonumber(settings[name])

    if value == nil then
        return defaultValue
    end

    return value
end

local function settingBool(settings, name, defaultValue)
    local value = settings[name]

    if value == nil then
        return defaultValue
    end

    return value == "1" or value == "true" or value == "True"
end

----------------------------------------------------------------------
-- Query
----------------------------------------------------------------------

function Query(localeName, localizationTokens)

    return {
        ["settings"] = {

            {
                ["name"] = "Display Name",
                ["value"] = "Low Quality Meme",
                ["type"] = "label"
            },

            {
                ["name"] = "Description",
                ["value"] =
                    "Turns the video into a deliberately low-quality meme with " ..
                    "pixelation, compression, reduced FPS, noise, and degraded audio.",
                ["type"] = "label"
            },

            {
                ["name"] = "Chance Roll",
                ["tooltip"] =
                    "Chance from 0-100 for the effect to activate.",
                ["value"] = "100",
                ["type"] = "int"
            },

            {
                ["name"] = "Quality",
                ["tooltip"] =
                    "Overall degradation strength. 0 is subtle and 100 is extremely crunchy.",
                ["value"] = "75",
                ["type"] = "int"
            },

            {
                ["name"] = "Resolution",
                ["tooltip"] =
                    "Downscale factor. Higher values create a smaller source before it is enlarged.",
                ["value"] = "4",
                ["type"] = "int"
            },

            {
                ["name"] = "FPS",
                ["tooltip"] =
                    "Output frame rate. Lower values create a choppier meme-video appearance.",
                ["value"] = "15",
                ["type"] = "int"
            },

            {
                ["name"] = "Video Bitrate",
                ["tooltip"] =
                    "Target video bitrate in kilobits per second.",
                ["value"] = "350",
                ["type"] = "int"
            },

            {
                ["name"] = "Audio Bitrate",
                ["tooltip"] =
                    "Target audio bitrate in kilobits per second.",
                ["value"] = "48",
                ["type"] = "int"
            },

            {
                ["name"] = "Pixelation",
                ["tooltip"] =
                    "Adds visible blocky pixelation.",
                ["value"] = "1",
                ["type"] = "bool"
            },

            {
                ["name"] = "Color Crush",
                ["tooltip"] =
                    "Reduces the number of color levels for a crude meme appearance.",
                ["value"] = "1",
                ["type"] = "bool"
            },

            {
                ["name"] = "Block Noise",
                ["tooltip"] =
                    "Adds compression-like visual noise.",
                ["value"] = "1",
                ["type"] = "bool"
            },

            {
                ["name"] = "Sharpen",
                ["tooltip"] =
                    "Adds exaggerated sharpening after the low-resolution upscale.",
                ["value"] = "1",
                ["type"] = "bool"
            },

            {
                ["name"] = "Mono Audio",
                ["tooltip"] =
                    "Converts the audio to mono for an older low-quality meme feel.",
                ["value"] = "0",
                ["type"] = "bool"
            },

            {
                ["name"] = "Extra Crunch",
                ["tooltip"] =
                    "Applies an additional low-bitrate encode for maximum degradation.",
                ["value"] = "0",
                ["type"] = "bool"
            }
        }
    }
end

----------------------------------------------------------------------
-- StartGeneration
----------------------------------------------------------------------

function StartGeneration(options, pluginSettings, functions)

    commandIndex = 0

    if not functions.ffmpegInstalled() then
        print("<[255,0,0]>Low Quality Meme Effect: FFmpeg is not installed.")
        return false
    end

    local chance = settingNumber(pluginSettings, "Chance Roll", 100)

    if chance < 0 then
        chance = 0
    end

    if chance > 100 then
        chance = 100
    end

    math.randomseed(os.time())

    local roll = math.random(1, 100)

    if roll > chance then
        print("<[150,150,150]>Low Quality Meme Effect skipped.")
        return true
    end

    local quality = settingNumber(pluginSettings, "Quality", 75)

    if quality < 0 then
        quality = 0
    end

    if quality > 100 then
        quality = 100
    end

    local resolution = settingNumber(pluginSettings, "Resolution", 4)

    if resolution < 1 then
        resolution = 1
    end

    if resolution > 12 then
        resolution = 12
    end

    local fps = settingNumber(pluginSettings, "FPS", 15)

    if fps < 1 then
        fps = 1
    end

    if fps > 60 then
        fps = 60
    end

    local videoBitrate =
        settingNumber(pluginSettings, "Video Bitrate", 350)

    if videoBitrate < 32 then
        videoBitrate = 32
    end

    local audioBitrate =
        settingNumber(pluginSettings, "Audio Bitrate", 48)

    if audioBitrate < 16 then
        audioBitrate = 16
    end

    local pixelation =
        settingBool(pluginSettings, "Pixelation", true)

    local colorCrush =
        settingBool(pluginSettings, "Color Crush", true)

    local blockNoise =
        settingBool(pluginSettings, "Block Noise", true)

    local sharpen =
        settingBool(pluginSettings, "Sharpen", true)

    local monoAudio =
        settingBool(pluginSettings, "Mono Audio", false)

    local extraCrunch =
        settingBool(pluginSettings, "Extra Crunch", false)

    ------------------------------------------------------------------
    -- Calculate internal resolution.
    --
    -- Keep dimensions divisible by 2 so common YUV encoders work.
    ------------------------------------------------------------------

    local width = tonumber(options.width) or 640
    local height = tonumber(options.height) or 360

    local lowWidth =
        math.max(2, math.floor(width / resolution))

    local lowHeight =
        math.max(2, math.floor(height / resolution))

    lowWidth = lowWidth - (lowWidth % 2)
    lowHeight = lowHeight - (lowHeight % 2)

    if lowWidth < 2 then
        lowWidth = 2
    end

    if lowHeight < 2 then
        lowHeight = 2
    end

    ------------------------------------------------------------------
    -- Build video filter.
    ------------------------------------------------------------------

    local filters = {}

    -- Reduce FPS.
    table.insert(
        filters,
        "fps=" .. tostring(fps)
    )

    -- Downscale to a deliberately tiny resolution.
    table.insert(
        filters,
        "scale=" ..
        tostring(lowWidth) ..
        ":" ..
        tostring(lowHeight) ..
        ":flags=area"
    )

    ------------------------------------------------------------------
    -- Pixelation.
    --
    -- Scale down and then immediately scale back up using nearest
    -- neighbour interpolation.
    ------------------------------------------------------------------

    if pixelation then

        local pixelWidth =
            math.max(2, math.floor(lowWidth * 0.75))

        local pixelHeight =
            math.max(2, math.floor(lowHeight * 0.75))

        pixelWidth = pixelWidth - (pixelWidth % 2)
        pixelHeight = pixelHeight - (pixelHeight % 2)

        if pixelWidth < 2 then
            pixelWidth = 2
        end

        if pixelHeight < 2 then
            pixelHeight = 2
        end

        table.insert(
            filters,
            "scale=" ..
            tostring(pixelWidth) ..
            ":" ..
            tostring(pixelHeight) ..
            ":flags=neighbor"
        )

        table.insert(
            filters,
            "scale=" ..
            tostring(lowWidth) ..
            ":" ..
            tostring(lowHeight) ..
            ":flags=neighbor"
        )
    end

    ------------------------------------------------------------------
    -- Color crushing.
    --
    -- The expression changes according to the Quality setting.
    ------------------------------------------------------------------

    if colorCrush then

        local crushAmount =
            math.floor(2 + (quality / 100) * 12)

        local divisor =
            tostring(crushAmount)

        table.insert(
            filters,
            "lutrgb=" ..
            "r='floor(val/" .. divisor .. ")*" .. divisor ..
            "':" ..
            "g='floor(val/" .. divisor .. ")*" .. divisor ..
            "':" ..
            "b='floor(val/" .. divisor .. ")*" .. divisor
        )
    end

    ------------------------------------------------------------------
    -- Block/compression noise.
    ------------------------------------------------------------------

    if blockNoise then

        local noiseAmount =
            math.floor(2 + (quality / 100) * 18)

        table.insert(
            filters,
            "noise=" ..
            "alls=" ..
            tostring(noiseAmount) ..
            ":allf=t+u"
        )
    end

    ------------------------------------------------------------------
    -- Exaggerated sharpening.
    ------------------------------------------------------------------

    if sharpen then

        local sharpenAmount =
            0.4 + (quality / 100) * 1.8

        table.insert(
            filters,
            "unsharp=5:5:" ..
            string.format("%.2f", sharpenAmount) ..
            ":5:5:0"
        )
    end

    ------------------------------------------------------------------
    -- Scale back to original resolution.
    --
    -- Bicubic produces the characteristic "badly enlarged" look.
    ------------------------------------------------------------------

    table.insert(
        filters,
        "scale=" ..
        tostring(width) ..
        ":" ..
        tostring(height) ..
        ":flags=bicubic"
    )

    ------------------------------------------------------------------
    -- Pixel format.
    --
    -- yuv420p is widely compatible with meme-video exports.
    ------------------------------------------------------------------

    table.insert(
        filters,
        "format=yuv420p"
    )

    local videoFilter = table.concat(filters, ",")

    ------------------------------------------------------------------
    -- Audio filters.
    ------------------------------------------------------------------

    local audioFilter = nil

    if monoAudio then
        audioFilter = "aresample=44100,aformat=channel_layouts=mono"
    else
        audioFilter = "aresample=44100"
    end

    ------------------------------------------------------------------
    -- Temporary output.
    ------------------------------------------------------------------

    local tempVideo = "low_quality_meme_stage1.mp4"

    ------------------------------------------------------------------
    -- FFmpeg command.
    --
    -- The effect deliberately uses a low CRF quality and low bitrate.
    ------------------------------------------------------------------

    local command =
        "-i \"" .. options.inputVideo .. "\" " ..
        "-vf \"" .. videoFilter .. "\" " ..
        "-af \"" .. audioFilter .. "\" " ..
        "-c:v libx264 " ..
        "-preset veryfast " ..
        "-tune film " ..
        "-b:v " .. tostring(videoBitrate) .. "k " ..
        "-maxrate " .. tostring(videoBitrate) .. "k " ..
        "-bufsize " .. tostring(videoBitrate * 2) .. "k " ..
        "-g " .. tostring(math.max(2, fps * 2)) .. " " ..
        "-pix_fmt yuv420p " ..
        "-c:a aac " ..
        "-b:a " .. tostring(audioBitrate) .. "k " ..
        "-ar 44100 " ..
        "-movflags +faststart " ..
        "-y \"" .. tempVideo .. "\""

    print("<[255,200,0]>Low Quality Meme Effect: rendering degraded video.")
    print("<[255,200,0]>Resolution: " ..
        tostring(lowWidth) .. "x" .. tostring(lowHeight))
    print("<[255,200,0]>FPS: " .. tostring(fps))
    print("<[255,200,0]>Video bitrate: " ..
        tostring(videoBitrate) .. "k")

    functions.runFFmpeg(command)

    commandIndex = 1

    ------------------------------------------------------------------
    -- Store settings for PostCommand.
    ------------------------------------------------------------------

    _G.LowQualityMemeState = {
        tempVideo = tempVideo,
        extraCrunch = extraCrunch,
        videoBitrate = videoBitrate,
        audioBitrate = audioBitrate
    }

    return true
end

----------------------------------------------------------------------
-- PostCommand
----------------------------------------------------------------------

function PostCommand(
    commandindex,
    outputResult,
    errorResult,
    options,
    pluginSettings,
    functions
)

    if commandindex ~= 1 then
        return
    end

    local state = _G.LowQualityMemeState

    if state == nil then
        print("<[255,0,0]>Low Quality Meme Effect: missing state.")
        return
    end

    ------------------------------------------------------------------
    -- Optional second encode.
    --
    -- This makes the result resemble a video that has been repeatedly
    -- uploaded/downloaded/re-encoded.
    ------------------------------------------------------------------

    if state.extraCrunch then

        local finalBitrate =
            math.max(24, math.floor(state.videoBitrate * 0.55))

        local finalAudioBitrate =
            math.max(16, math.floor(state.audioBitrate * 0.75))

        local command =
            "-i \"" .. state.tempVideo .. "\" " ..
            "-c:v libx264 " ..
            "-preset veryfast " ..
            "-b:v " .. tostring(finalBitrate) .. "k " ..
            "-maxrate " .. tostring(finalBitrate) .. "k " ..
            "-bufsize " .. tostring(finalBitrate * 2) .. "k " ..
            "-g 30 " ..
            "-pix_fmt yuv420p " ..
            "-c:a aac " ..
            "-b:a " .. tostring(finalAudioBitrate) .. "k " ..
            "-y \"" .. options.outputVideo .. "\""

        print("<[255,120,0]>Low Quality Meme Effect: applying extra re-encode.")

        functions.runFFmpeg(command)

        commandIndex = 2

        return
    end

    ------------------------------------------------------------------
    -- Normal path: move the first-stage output to the final output.
    ------------------------------------------------------------------

    functions.fileMove(
        state.tempVideo,
        options.outputVideo
    )

    print("<[0,255,0]>Low Quality Meme Effect: complete.")
end

----------------------------------------------------------------------
-- StopGeneration
----------------------------------------------------------------------

function StopGeneration(options, pluginSettings, functions)

    _G.LowQualityMemeState = nil
    commandIndex = 0

    return true
end