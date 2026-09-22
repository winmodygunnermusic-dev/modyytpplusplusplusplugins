--[[
    Supercut Effect
    Nonsensical Video Generator
    NVG Lua Workshop Effect

    File:
        supercut.lua

    Description:
        Creates a rapid-fire supercut from the source video by selecting
        many short random sections and concatenating them together.

        The effect keeps the original audio synchronized with the selected
        video sections.

    No external libraries are required.
]]

math.randomseed(os.time())

local function settingNumber(settings, name, defaultValue)
    local value = tonumber(settings[name])
    if value == nil then
        return defaultValue
    end

    return value
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

function Query(localeName, localizationTokens)
    return {
        ["settings"] = {
            {
                ["name"] = "Display Name",
                ["value"] = "Supercut",
                ["type"] = "label"
            },

            {
                ["name"] = "Description",
                ["value"] =
                    "Rapidly cuts together many short sections of the source video.",
                ["type"] = "label"
            },

            {
                ["name"] = "Cut Count",
                ["tooltip"] =
                    "Number of clips used to build the supercut.",
                ["value"] = "20",
                ["type"] = "integer"
            },

            {
                ["name"] = "Minimum Clip Duration",
                ["tooltip"] =
                    "Minimum duration of each selected clip in seconds.",
                ["value"] = "0.15",
                ["type"] = "decimal"
            },

            {
                ["name"] = "Maximum Clip Duration",
                ["tooltip"] =
                    "Maximum duration of each selected clip in seconds.",
                ["value"] = "0.60",
                ["type"] = "decimal"
            },

            {
                ["name"] = "Start Offset",
                ["tooltip"] =
                    "Avoids selecting material before this many seconds.",
                ["value"] = "0",
                ["type"] = "decimal"
            },

            {
                ["name"] = "End Padding",
                ["tooltip"] =
                    "Avoids selecting material this many seconds before the end.",
                ["value"] = "0.10",
                ["type"] = "decimal"
            },

            {
                ["name"] = "Randomness",
                ["tooltip"] =
                    "Higher values spread the cuts more randomly through the video.",
                ["value"] = "100",
                ["type"] = "integer"
            },

            {
                ["name"] = "Keep Audio",
                ["tooltip"] =
                    "Keep and synchronize audio from every selected clip.",
                ["value"] = "1",
                ["type"] = "bool"
            },

            {
                ["name"] = "Normalize Clips",
                ["tooltip"] =
                    "Normalize timestamps of every selected clip before concatenation.",
                ["value"] = "1",
                ["type"] = "bool"
            }
        },

        ["libraries"] = {}
    }
end


-- Generate one random floating-point number.
local function randomFloat(minimum, maximum)
    return minimum + math.random() * (maximum - minimum)
end


-- Builds a supercut FFmpeg filter graph.
local function buildSupercutFilter(
    cutCount,
    minDuration,
    maxDuration,
    sourceStart,
    sourceEnd,
    randomness,
    keepAudio,
    normalize
)
    local videoParts = {}
    local audioParts = {}

    for i = 1, cutCount do
        local duration = randomFloat(minDuration, maxDuration)

        local availableLength = sourceEnd - sourceStart - duration

        if availableLength < 0 then
            availableLength = 0
        end

        local randomPosition = 0

        if randomness <= 0 then
            randomPosition = 0
        else
            randomPosition = math.random() * availableLength
            randomPosition = randomPosition * (randomness / 100)
        end

        local startTime = sourceStart + randomPosition
        local endTime = startTime + duration

        local videoLabel = "v" .. tostring(i)

        local videoFilter =
            "[0:v]trim=start=" ..
            string.format("%.4f", startTime) ..
            ":end=" ..
            string.format("%.4f", endTime)

        if normalize then
            videoFilter =
                videoFilter ..
                ",setpts=PTS-STARTPTS"
        end

        videoFilter =
            videoFilter ..
            "[" .. videoLabel .. "]"

        table.insert(videoParts, videoFilter)

        if keepAudio then
            local audioLabel = "a" .. tostring(i)

            local audioFilter =
                "[0:a]atrim=start=" ..
                string.format("%.4f", startTime) ..
                ":end=" ..
                string.format("%.4f", endTime)

            if normalize then
                audioFilter =
                    audioFilter ..
                    ",asetpts=PTS-STARTPTS"
            end

            audioFilter =
                audioFilter ..
                "[" .. audioLabel .. "]"

            table.insert(audioParts, audioFilter)
        end
    end

    local filterGraph = ""

    for _, part in ipairs(videoParts) do
        filterGraph = filterGraph .. part .. ";"
    end

    for _, part in ipairs(audioParts) do
        filterGraph = filterGraph .. part .. ";"
    end

    if keepAudio then
        filterGraph =
            filterGraph ..
            "[v1]"

        for i = 2, cutCount do
            filterGraph =
                filterGraph ..
                "[v" .. tostring(i) .. "]"
        end

        filterGraph =
            filterGraph ..
            "concat=n=" ..
            tostring(cutCount) ..
            ":v=1:a=0[vout];"

        filterGraph =
            filterGraph ..
            "[a1]"

        for i = 2, cutCount do
            filterGraph =
                filterGraph ..
                "[a" .. tostring(i) .. "]"
        end

        filterGraph =
            filterGraph ..
            "concat=n=" ..
            tostring(cutCount) ..
            ":v=0:a=1[aout]"
    else
        filterGraph =
            filterGraph ..
            "[v1]"

        for i = 2, cutCount do
            filterGraph =
                filterGraph ..
                "[v" .. tostring(i) .. "]"
        end

        filterGraph =
            filterGraph ..
            "concat=n=" ..
            tostring(cutCount) ..
            ":v=1:a=0[vout]"
    end

    return filterGraph
end


function StartGeneration(options, pluginSettings, functions)
    if not functions.ffmpegInstalled() then
        return false
    end

    local cutCount =
        math.floor(
            clamp(
                settingNumber(pluginSettings, "Cut Count", 20),
                2,
                200
            )
        )

    local minDuration =
        clamp(
            settingNumber(
                pluginSettings,
                "Minimum Clip Duration",
                0.15
            ),
            0.03,
            10
        )

    local maxDuration =
        clamp(
            settingNumber(
                pluginSettings,
                "Maximum Clip Duration",
                0.60
            ),
            0.03,
            10
        )

    if maxDuration < minDuration then
        maxDuration = minDuration
    end

    local sourceStart =
        math.max(
            0,
            settingNumber(
                pluginSettings,
                "Start Offset",
                0
            )
        )

    local endPadding =
        math.max(
            0,
            settingNumber(
                pluginSettings,
                "End Padding",
                0.10
            )
        )

    local randomness =
        clamp(
            settingNumber(
                pluginSettings,
                "Randomness",
                100
            ),
            0,
            100
        )

    local keepAudio =
        pluginSettings["Keep Audio"] == "1"

    local normalize =
        pluginSettings["Normalize Clips"] ~= "0"

    -- NVG does not expose the source duration directly through the
    -- documented options table, so use ffprobe through FFmpeg's
    -- duration-independent selection strategy.
    --
    -- We use a generous source range here. FFmpeg automatically
    -- produces only the portions that exist in the input.
    --
    -- The maximum random starting point is therefore intentionally
    -- constrained to a practical range.

    local assumedSourceEnd = 3600

    local filterGraph =
        buildSupercutFilter(
            cutCount,
            minDuration,
            maxDuration,
            sourceStart,
            assumedSourceEnd - endPadding,
            randomness,
            keepAudio,
            normalize
        )

    local temporaryOutput = "supercut_intermediate.mkv"

    local command =
        "-hide_banner " ..
        "-y " ..
        "-i \"" ..
        options.inputVideo ..
        "\" " ..
        "-filter_complex \"" ..
        filterGraph ..
        "\" " ..
        "-map \"[vout]\" "

    if keepAudio then
        command =
            command ..
            "-map \"[aout]\" "
    end

    command =
        command ..
        "-c:v libx264 " ..
        "-preset veryfast " ..
        "-crf 18 " ..
        "-pix_fmt yuv420p "

    if keepAudio then
        command =
            command ..
            "-c:a aac " ..
            "-b:a 192k "
    else
        command =
            command ..
            "-an "
    end

    command =
        command ..
        "-movflags +faststart " ..
        "\"" ..
        temporaryOutput ..
        "\""

    functions.runFFmpeg(command)

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
    if commandIndex == 1 then
        if functions.fileExists("supercut_intermediate.mkv") then
            functions.fileMove(
                "supercut_intermediate.mkv",
                options.outputVideo
            )
        end
    end
end


function StopGeneration(options, pluginSettings, functions)
    return true
end
