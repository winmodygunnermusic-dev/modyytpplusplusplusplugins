-- Random Sound Injection
-- Nonsensical Video Generator Workshop Effect
-- NVG v1.8.x
--
-- Randomly injects short sounds from the effect's Audio/SFX library
-- into the source video's audio track.
--
-- Library folder:
--   Audio/SFX/
--
-- The addon creates a randomized sequence of sound events and mixes
-- them into the original audio.

local injectionCount = 0
local commandState = 0
local workingInput = nil
local workingOutput = nil

------------------------------------------------------------
-- Query
------------------------------------------------------------

function Query(localeName, localizationTokens)

    return {
        ["settings"] = {
            {
                ["name"] = "Display Name",
                ["value"] = "Random Sound Injection",
                ["type"] = "label"
            },

            {
                ["name"] = "Description",
                ["value"] =
                    "Randomly injects sounds from the SFX library into the video's audio.",
                ["type"] = "label"
            },

            {
                ["name"] = "Chance Roll",
                ["tooltip"] =
                    "Percentage chance for the effect to activate.",
                ["value"] = "100",
                ["type"] = "int"
            },

            {
                ["name"] = "Maximum Sounds",
                ["tooltip"] =
                    "Maximum number of random sounds injected.",
                ["value"] = "8",
                ["type"] = "int"
            },

            {
                ["name"] = "Minimum Delay",
                ["tooltip"] =
                    "Minimum delay between injected sounds in seconds.",
                ["value"] = "1.0",
                ["type"] = "float"
            },

            {
                ["name"] = "Maximum Delay",
                ["tooltip"] =
                    "Maximum delay between injected sounds in seconds.",
                ["value"] = "8.0",
                ["type"] = "float"
            },

            {
                ["name"] = "Volume",
                ["tooltip"] =
                    "Volume multiplier for injected sounds.",
                ["value"] = "1.0",
                ["type"] = "float"
            },

            {
                ["name"] = "Random Pitch",
                ["tooltip"] =
                    "Randomly changes the pitch of injected sounds.",
                ["value"] = "1",
                ["type"] = "bool"
            },

            {
                ["name"] = "Pitch Variation",
                ["tooltip"] =
                    "Maximum pitch variation when Random Pitch is enabled.",
                ["value"] = "0.15",
                ["type"] = "float"
            }
        },

        ["libraries"] = {
            {
                ["name"] = "SFX",
                ["tooltip"] =
                    "Sound effects that can be randomly injected.",
                ["path"] = "sfx",
                ["type"] = "audio"
            }
        }
    }
end


------------------------------------------------------------
-- Utility
------------------------------------------------------------

local function getSetting(settings, name, defaultValue)

    if settings ~= nil and settings[name] ~= nil then
        return settings[name]
    end

    return defaultValue
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


------------------------------------------------------------
-- StartGeneration
------------------------------------------------------------

function StartGeneration(options, pluginSettings, functions)

    commandState = 0
    injectionCount = 0

    workingInput = options.inputVideo
    workingOutput = options.outputVideo

    if functions == nil then
        return false
    end

    if not functions.ffmpegInstalled() then
        return false
    end

    --------------------------------------------------------
    -- Chance roll
    --------------------------------------------------------

    local chance =
        tonumber(getSetting(pluginSettings, "Chance Roll", "100")) or 100

    chance = clamp(chance, 0, 100)

    if functions.randomDouble(0, 100) > chance then
        return false
    end

    --------------------------------------------------------
    -- Settings
    --------------------------------------------------------

    local maxSounds =
        tonumber(getSetting(pluginSettings, "Maximum Sounds", "8")) or 8

    local minDelay =
        tonumber(getSetting(pluginSettings, "Minimum Delay", "1.0")) or 1.0

    local maxDelay =
        tonumber(getSetting(pluginSettings, "Maximum Delay", "8.0")) or 8.0

    local volume =
        tonumber(getSetting(pluginSettings, "Volume", "1.0")) or 1.0

    local randomPitch =
        tonumber(getSetting(pluginSettings, "Random Pitch", "1")) or 1

    local pitchVariation =
        tonumber(getSetting(pluginSettings, "Pitch Variation", "0.15")) or 0.15

    maxSounds = math.max(0, math.floor(maxSounds))
    minDelay = math.max(0, minDelay)
    maxDelay = math.max(minDelay, maxDelay)
    volume = math.max(0, volume)
    pitchVariation = math.max(0, pitchVariation)

    if maxSounds <= 0 then
        return false
    end

    --------------------------------------------------------
    -- Get input duration
    --------------------------------------------------------

    -- First command obtains the duration of the source video.
    commandState = 1

    functions.runFFprobe(
        "-v error -show_entries format=duration " ..
        "-of default=noprint_wrappers=1:nokey=1 " ..
        "\"" .. workingInput .. "\""
    )

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

    --------------------------------------------------------
    -- Command 1:
    -- FFprobe returned the source duration.
    --------------------------------------------------------

    if commandIndex == 1 then

        local duration =
            tonumber(outputResult)

        if duration == nil then
            duration = 10
        end

        duration = math.max(duration, 0.1)

        local maxSounds =
            tonumber(getSetting(
                pluginSettings,
                "Maximum Sounds",
                "8"
            )) or 8

        local minDelay =
            tonumber(getSetting(
                pluginSettings,
                "Minimum Delay",
                "1.0"
            )) or 1.0

        local maxDelay =
            tonumber(getSetting(
                pluginSettings,
                "Maximum Delay",
                "8.0"
            )) or 8.0

        local volume =
            tonumber(getSetting(
                pluginSettings,
                "Volume",
                "1.0"
            )) or 1.0

        local randomPitch =
            tonumber(getSetting(
                pluginSettings,
                "Random Pitch",
                "1"
            )) or 1

        local pitchVariation =
            tonumber(getSetting(
                pluginSettings,
                "Pitch Variation",
                "0.15"
            )) or 0.15

        maxSounds = math.max(0, math.floor(maxSounds))
        minDelay = math.max(0, minDelay)
        maxDelay = math.max(minDelay, maxDelay)

        ----------------------------------------------------
        -- Build random sound list.
        ----------------------------------------------------

        local soundInputs = {}
        local filterParts = {}

        local currentTime = 0

        for i = 1, maxSounds do

            ------------------------------------------------
            -- Random injection position.
            ------------------------------------------------

            local delay =
                functions.randomDouble(
                    minDelay,
                    maxDelay
                )

            currentTime = currentTime + delay

            if currentTime >= duration then
                break
            end

            ------------------------------------------------
            -- Pick random sound from SFX library.
            ------------------------------------------------

            local sound =
                functions.getRandomLibraryFile(
                    "audio",
                    "sfx"
                )

            if sound ~= nil and sound ~= "" then

                local pitch = 1.0

                if randomPitch == 1 then

                    pitch =
                        functions.randomDouble(
                            1.0 - pitchVariation,
                            1.0 + pitchVariation
                        )

                end

                pitch = math.max(0.1, pitch)

                ------------------------------------------------
                -- Generate an audio input.
                --
                -- The placeholder returned by
                -- getRandomLibraryFile() is intentionally passed
                -- directly to FFmpeg.
                ------------------------------------------------

                table.insert(
                    soundInputs,
                    "-i \"" .. sound .. "\""
                )

                ------------------------------------------------
                -- Delay the sound and adjust volume/pitch.
                ------------------------------------------------

                local delayMilliseconds =
                    math.floor(currentTime * 1000)

                local filter =
                    "[" ..
                    tostring(i) ..
                    ":a]" ..
                    "adelay=" ..
                    tostring(delayMilliseconds) ..
                    ":all=1," ..
                    "volume=" ..
                    tostring(volume)

                ------------------------------------------------
                -- Optional pitch shifting.
                --
                -- atempo keeps the resulting audio duration
                -- manageable when pitch changes are used.
                ------------------------------------------------

                if randomPitch == 1 then

                    filter =
                        filter ..
                        ",asetrate=44100*" ..
                        string.format("%.5f", pitch) ..
                        ",aresample=44100"

                end

                filter =
                    filter ..
                    "[snd" .. tostring(i) .. "]"

                table.insert(
                    filterParts,
                    filter
                )

                injectionCount =
                    injectionCount + 1
            end
        end

        ----------------------------------------------------
        -- Nothing to inject.
        ----------------------------------------------------

        if injectionCount == 0 then

            functions.runFFmpeg(
                "-i \"" .. workingInput .. "\" " ..
                "-c:v copy -c:a aac -y " ..
                "\"" .. workingOutput .. "\""
            )

            commandState = 2

            return
        end

        ----------------------------------------------------
        -- Build FFmpeg filter graph.
        ----------------------------------------------------

        local filterComplex = ""

        for i = 1, #filterParts do

            filterComplex =
                filterComplex ..
                filterParts[i] ..
                ";"
        end

        ----------------------------------------------------
        -- Original audio.
        ----------------------------------------------------

        filterComplex =
            filterComplex ..
            "[0:a]aresample=44100[original];"

        ----------------------------------------------------
        -- Mix original + injected sounds.
        ----------------------------------------------------

        local mixInputs = "[original]"

        for i = 1, injectionCount do

            mixInputs =
                mixInputs ..
                "[snd" .. tostring(i) .. "]"
        end

        filterComplex =
            filterComplex ..
            mixInputs ..
            "amix=inputs=" ..
            tostring(injectionCount + 1) ..
            ":duration=first:" ..
            "dropout_transition=0" ..
            "[mixed]"

        ----------------------------------------------------
        -- Execute final render.
        ----------------------------------------------------

        local command =
            "-i \"" .. workingInput .. "\" " ..
            table.concat(soundInputs, " ") ..
            " -filter_complex \"" ..
            filterComplex ..
            "\" " ..
            "-map 0:v? " ..
            "-map \"[mixed]\" " ..
            "-c:v copy " ..
            "-c:a aac " ..
            "-b:a 192k " ..
            "-shortest " ..
            "-y \"" ..
            workingOutput ..
            "\""

        functions.runFFmpeg(command)

        commandState = 2

        return
    end


    --------------------------------------------------------
    -- Command 2:
    -- Final FFmpeg render completed.
    --------------------------------------------------------

    if commandIndex == 2 then

        return
    end
end


------------------------------------------------------------
-- StopGeneration
------------------------------------------------------------

function StopGeneration(options, pluginSettings, functions)

    injectionCount = 0
    commandState = 0
    workingInput = nil
    workingOutput = nil

    return true
end
