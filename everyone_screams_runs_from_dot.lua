--[[
    Everyone Screams and Runs Away From Dot
    Nonsensical Video Generator Workshop Effect

    NVG addon:
        everyone_screams_runs_from_dot.lua

    Libraries:
        Video / Running Overlays
        Audio / Screaming

    The video library should contain green-screen clips of
    people/animals/characters running and screaming away from
    a small "dot" or other scary object.

    The audio library should contain scream/shout sound effects.

    Recommended overlay format:
        MP4/WebM
        Green background
        30 FPS or similar
        Short clips (1-5 seconds)
]]

local EFFECT_NAME = "Everyone Screams and Runs From Dot"
local DESCRIPTION =
    "Adds a ridiculous green-screen running/screaming overlay and random screaming audio."

----------------------------------------------------------------
-- QUERY
----------------------------------------------------------------

function Query(localeName, localizationTokens)

    return {
        ["settings"] = {
            {
                ["name"] = "Display Name",
                ["value"] = EFFECT_NAME,
                ["type"] = "label"
            },

            {
                ["name"] = "Description",
                ["value"] = DESCRIPTION,
                ["type"] = "label"
            },

            {
                ["name"] = "Overlay Chance",
                ["tooltip"] = "Chance that the running overlay is used.",
                ["value"] = "75",
                ["type"] = "int"
            },

            {
                ["name"] = "Scream Chance",
                ["tooltip"] = "Chance that a scream sound is added.",
                ["value"] = "85",
                ["type"] = "int"
            },

            {
                ["name"] = "Overlay Scale",
                ["tooltip"] = "Size of the green-screen character.",
                ["value"] = "100",
                ["type"] = "int"
            },

            {
                ["name"] = "Overlay Position",
                ["tooltip"] = "Randomize the overlay position.",
                ["value"] = "1",
                ["type"] = "bool"
            },

            {
                ["name"] = "Scream Volume",
                ["tooltip"] = "Volume of the screaming sound.",
                ["value"] = "1.25",
                ["type"] = "float"
            },

            {
                ["name"] = "Dot Panic",
                ["tooltip"] = "Makes the overlay appear larger and more chaotic.",
                ["value"] = "1",
                ["type"] = "bool"
            }
        },

        ["libraries"] = {
            {
                ["name"] = "Running Overlays",
                ["tooltip"] = "Green-screen people, animals, or characters running away.",
                ["path"] = "running_overlays",
                ["type"] = "video"
            },

            {
                ["name"] = "Screaming",
                ["tooltip"] = "Screams, shouting, panic noises, and running-away sounds.",
                ["path"] = "screaming",
                ["type"] = "audio"
            }
        }
    }
end

----------------------------------------------------------------
-- HELPERS
----------------------------------------------------------------

local function getNumber(value, defaultValue)
    local n = tonumber(value)

    if n == nil then
        return defaultValue
    end

    return n
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

local function chance(functions, percentage)
    percentage = clamp(percentage, 0, 100)

    return functions.randomDouble(0, 100) <= percentage
end

----------------------------------------------------------------
-- START GENERATION
----------------------------------------------------------------

function StartGeneration(options, pluginSettings, functions)

    if not functions.ffmpegInstalled() then
        print("<[255,0,0]>FFmpeg is required for Everyone Screams and Runs From Dot.")

        return false
    end

    local overlayChance =
        getNumber(pluginSettings["Overlay Chance"], 75)

    local screamChance =
        getNumber(pluginSettings["Scream Chance"], 85)

    local scale =
        getNumber(pluginSettings["Overlay Scale"], 100)

    local screamVolume =
        getNumber(pluginSettings["Scream Volume"], 1.25)

    local randomPosition =
        pluginSettings["Overlay Position"] == "1"

    local dotPanic =
        pluginSettings["Dot Panic"] == "1"

    overlayChance = clamp(overlayChance, 0, 100)
    screamChance = clamp(screamChance, 0, 100)
    scale = clamp(scale, 25, 300)
    screamVolume = clamp(screamVolume, 0, 5)

    ------------------------------------------------------------
    -- Pick media
    ------------------------------------------------------------

    local overlay = nil
    local scream = nil

    if chance(functions, overlayChance) then
        overlay = functions.getRandomLibraryFile(
            "video",
            "running_overlays"
        )
    end

    if chance(functions, screamChance) then
        scream = functions.getRandomLibraryFile(
            "audio",
            "screaming"
        )
    end

    ------------------------------------------------------------
    -- Nothing selected
    ------------------------------------------------------------

    if overlay == nil and scream == nil then
        print("Everyone Screams effect: no random media selected.")

        functions.fileCopy(
            options.inputVideo,
            options.outputVideo
        )

        return true
    end

    ------------------------------------------------------------
    -- Build temporary filenames
    ------------------------------------------------------------

    local workingVideo = "everyone_screams_base.mp4"
    local workingAudio = "everyone_screams_audio.m4a"
    local workingOutput = "everyone_screams_final.mp4"

    ------------------------------------------------------------
    -- Position
    ------------------------------------------------------------

    local overlayX = "(W-w)/2"
    local overlayY = "(H-h)/2"

    if randomPosition then

        local positionChoice =
            functions.randomInt(1, 6)

        if positionChoice == 1 then
            overlayX = "20"
            overlayY = "20"

        elseif positionChoice == 2 then
            overlayX = "W-w-20"
            overlayY = "20"

        elseif positionChoice == 3 then
            overlayX = "20"
            overlayY = "H-h-20"

        elseif positionChoice == 4 then
            overlayX = "W-w-20"
            overlayY = "H-h-20"

        elseif positionChoice == 5 then
            overlayX = "(W-w)/2"
            overlayY = "20"

        else
            overlayX = "(W-w)/2"
            overlayY = "(H-h)/2"
        end
    end

    ------------------------------------------------------------
    -- Dot Panic
    ------------------------------------------------------------

    local finalScale = scale

    if dotPanic then
        finalScale = finalScale +
            functions.randomInt(0, 40)
    end

    ------------------------------------------------------------
    -- VIDEO + OVERLAY
    ------------------------------------------------------------

    if overlay ~= nil then

        local overlayScale =
            "scale=iw*" ..
            tostring(finalScale / 100) ..
            ":ih*" ..
            tostring(finalScale / 100) ..
            ":force_original_aspect_ratio=decrease"

        local filter =
            "[1:v]" ..
            overlayScale ..
            ",chromakey=0x00FF00:0.22:0.08[runner];" ..
            "[0:v][runner]overlay=" ..
            overlayX ..
            ":" ..
            overlayY ..
            ":shortest=1[v]"

        local command =
            "-i \"" ..
            options.inputVideo ..
            "\" " ..
            "-i \"" ..
            overlay ..
            "\" " ..
            "-filter_complex \"" ..
            filter ..
            "\" " ..
            "-map \"[v]\" " ..
            "-map 0:a? " ..
            "-c:v libx264 " ..
            "-preset veryfast " ..
            "-pix_fmt yuv420p " ..
            "-c:a aac " ..
            "-y \"" ..
            workingVideo ..
            "\""

        functions.runFFmpeg(command)

        return true
    end

    ------------------------------------------------------------
    -- NO VIDEO OVERLAY
    ------------------------------------------------------------

    functions.fileCopy(
        options.inputVideo,
        workingVideo
    )

    ------------------------------------------------------------
    -- AUDIO + SCREAM
    ------------------------------------------------------------

    if scream ~= nil then

        local audioCommand =
            "-i \"" ..
            workingVideo ..
            "\" " ..
            "-stream_loop -1 " ..
            "-i \"" ..
            scream ..
            "\" " ..
            "-filter_complex \"" ..
            "[1:a]volume=" ..
            tostring(screamVolume) ..
            "[scream];" ..
            "[0:a][scream]amix=inputs=2:" ..
            "duration=first:" ..
            "dropout_transition=0[a]\"" ..
            " -map 0:v " ..
            "-map \"[a]\" " ..
            "-c:v copy " ..
            "-c:a aac " ..
            "-shortest " ..
            "-y \"" ..
            workingOutput ..
            "\""

        functions.runFFmpeg(audioCommand)

        return true
    end

    ------------------------------------------------------------
    -- OVERLAY + AUDIO
    --
    -- If both were selected, the overlay command above needs
    -- to continue here instead of stopping after the video.
    ------------------------------------------------------------

    if overlay ~= nil and scream ~= nil then
        return true
    end

    ------------------------------------------------------------
    -- ONLY OVERLAY
    ------------------------------------------------------------

    functions.fileMove(
        workingVideo,
        options.outputVideo
    )

    return true
end

----------------------------------------------------------------
-- POST COMMAND
----------------------------------------------------------------

function PostCommand(
    commandIndex,
    outputResult,
    errorResult,
    options,
    pluginSettings,
    functions
)

    print(
        "<[0,255,0]>" ..
        "Everyone Screams: completed command " ..
        tostring(commandIndex)
    )

    if errorResult ~= nil and errorResult ~= "" then
        print(
            "<[255,180,0]>" ..
            "Everyone Screams FFmpeg: " ..
            errorResult
        )
    end

    ------------------------------------------------------------
    -- The first FFmpeg command created workingVideo.
    -- The second command can add the scream.
    ------------------------------------------------------------

    if commandIndex == 1 then

        local screamChance =
            getNumber(pluginSettings["Scream Chance"], 85)

        if chance(functions, screamChance) then

            local scream =
                functions.getRandomLibraryFile(
                    "audio",
                    "screaming"
                )

            if scream ~= nil then

                local screamVolume =
                    getNumber(
                        pluginSettings["Scream Volume"],
                        1.25
                    )

                local command =
                    "-i \"everyone_screams_base.mp4\" " ..
                    "-stream_loop -1 " ..
                    "-i \"" ..
                    scream ..
                    "\" " ..
                    "-filter_complex \"" ..
                    "[1:a]volume=" ..
                    tostring(screamVolume) ..
                    "[scream];" ..
                    "[0:a][scream]" ..
                    "amix=inputs=2:" ..
                    "duration=first:" ..
                    "dropout_transition=0[a]\"" ..
                    " -map 0:v " ..
                    "-map \"[a]\" " ..
                    "-c:v copy " ..
                    "-c:a aac " ..
                    "-shortest " ..
                    "-y \"everyone_screams_final.mp4\""

                functions.runFFmpeg(command)

                return
            end
        end

        functions.fileCopy(
            "everyone_screams_base.mp4",
            options.outputVideo
        )

    elseif commandIndex == 2 then

        functions.fileMove(
            "everyone_screams_final.mp4",
            options.outputVideo
        )

    end
end

----------------------------------------------------------------
-- STOP GENERATION
----------------------------------------------------------------

function StopGeneration(options, pluginSettings, functions)

    print(
        "<[0,255,0]>" ..
        "Everyone Screams and Runs From Dot: finished!"
    )

    return true
end