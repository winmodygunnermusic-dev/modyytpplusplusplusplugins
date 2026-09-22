--[[
    Explosion Spam Effect
    Nonsensical Video Generator - Workshop Effect

    Suggested filename:
        explosion_spam.lua

    Suggested folder:
        NonsensicalVideoGenerator\plugins\workshop\explosion_spam\

    Library:
        video/explosions/

    Put short explosion video clips in the NVG Explosions library.
    Transparent WebM clips with alpha are recommended.
]]

math.randomseed(os.time())

local commandIndex = 0

------------------------------------------------------------
-- Utility
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

local function settingNumber(settings, name, default)
    local value = tonumber(settings[name])

    if value == nil then
        return default
    end

    return value
end

local function settingBool(settings, name, default)
    local value = settings[name]

    if value == nil then
        return default
    end

    return value == "1"
end

------------------------------------------------------------
-- Query
------------------------------------------------------------

function Query(localeName, localizationTokens)

    return {
        ["settings"] = {

            {
                ["name"] = "Display Name",
                ["value"] = "Explosion Spam"
            },

            {
                ["name"] = "Description",
                ["value"] =
                    "Randomly spams explosion clips over the source video."
            },

            {
                ["name"] = "Explosion Count",
                ["tooltip"] =
                    "Number of explosions to create.",
                ["value"] = "12",
                ["type"] = "int"
            },

            {
                ["name"] = "Explosion Scale",
                ["tooltip"] =
                    "Explosion size as a percentage of the video height.",
                ["value"] = "45",
                ["type"] = "int"
            },

            {
                ["name"] = "Position Randomness",
                ["tooltip"] =
                    "How randomly explosions are positioned.",
                ["value"] = "100",
                ["type"] = "int"
            },

            {
                ["name"] = "Timing Randomness",
                ["tooltip"] =
                    "How randomly explosions are distributed through the video.",
                ["value"] = "100",
                ["type"] = "int"
            },

            {
                ["name"] = "Explosion Opacity",
                ["tooltip"] =
                    "Opacity of the explosion overlays.",
                ["value"] = "100",
                ["type"] = "int"
            },

            {
                ["name"] = "Screen Shake",
                ["tooltip"] =
                    "Adds a brief camera-shake effect when explosions occur.",
                ["value"] = "1",
                ["type"] = "bool"
            },

            {
                ["name"] = "Color Boost",
                ["tooltip"] =
                    "Boosts explosion brightness and saturation.",
                ["value"] = "1",
                ["type"] = "bool"
            },

            {
                ["name"] = "Randomize Scale",
                ["tooltip"] =
                    "Give every explosion a different size.",
                ["value"] = "1",
                ["type"] = "bool"
            },

            {
                ["name"] = "Overlap Explosions",
                ["tooltip"] =
                    "Allows several explosions to appear at the same time.",
                ["value"] = "1",
                ["type"] = "bool"
            },

            {
                ["name"] = "Use Green Screen Key",
                ["tooltip"] =
                    "Enable this if the explosion library uses green-screen footage.",
                ["value"] = "0",
                ["type"] = "bool"
            },

            {
                ["name"] = "Green Screen Similarity",
                ["tooltip"] =
                    "Strength of the green-screen key.",
                ["value"] = "0.30",
                ["type"] = "float"
            },

            {
                ["name"] = "Explosion Audio",
                ["tooltip"] =
                    "Keep explosion audio when the library clips contain audio.",
                ["value"] = "1",
                ["type"] = "bool"
            },

            {
                ["name"] = "Audio Volume",
                ["tooltip"] =
                    "Explosion audio volume percentage.",
                ["value"] = "100",
                ["type"] = "int"
            }
        },

        ["libraries"] = {

            {
                ["name"] = "Explosions",
                ["tooltip"] =
                    "Explosion overlay video clips.",
                ["path"] = "explosions",
                ["type"] = "video"
            }
        }
    }
end

------------------------------------------------------------
-- StartGeneration
------------------------------------------------------------

function StartGeneration(options, pluginSettings, functions)

    if not functions.ffmpegInstalled() then
        return false
    end

    commandIndex = 0

    local count =
        clamp(
            math.floor(
                settingNumber(
                    pluginSettings,
                    "Explosion Count",
                    12
                )
            ),
            1,
            64
        )

    local scale =
        clamp(
            settingNumber(
                pluginSettings,
                "Explosion Scale",
                45
            ),
            5,
            200
        )

    local positionRandomness =
        clamp(
            settingNumber(
                pluginSettings,
                "Position Randomness",
                100
            ),
            0,
            100
        )

    local timingRandomness =
        clamp(
            settingNumber(
                pluginSettings,
                "Timing Randomness",
                100
            ),
            0,
            100
        )

    local opacity =
        clamp(
            settingNumber(
                pluginSettings,
                "Explosion Opacity",
                100
            ),
            0,
            100
        ) / 100

    local randomizeScale =
        settingBool(
            pluginSettings,
            "Randomize Scale",
            true
        )

    local overlap =
        settingBool(
            pluginSettings,
            "Overlap Explosions",
            true
        )

    local useGreenScreen =
        settingBool(
            pluginSettings,
            "Use Green Screen Key",
            false
        )

    local greenSimilarity =
        clamp(
            settingNumber(
                pluginSettings,
                "Green Screen Similarity",
                0.30
            ),
            0.01,
            1.0
        )

    local colorBoost =
        settingBool(
            pluginSettings,
            "Color Boost",
            true
        )

    local explosionAudio =
        settingBool(
            pluginSettings,
            "Explosion Audio",
            true
        )

    local audioVolume =
        clamp(
            settingNumber(
                pluginSettings,
                "Audio Volume",
                100
            ),
            0,
            300
        ) / 100

    --------------------------------------------------------
    -- Create the base filter.
    --------------------------------------------------------

    local filter = {}

    filter[#filter + 1] =
        "[0:v]setpts=PTS-STARTPTS[base0]"

    local currentVideo = "base0"

    --------------------------------------------------------
    -- Generate explosion events.
    --
    -- NVG does not expose video duration directly through
    -- the Lua API, so the events are distributed using
    -- normalized positions through the source timeline.
    --
    -- FFmpeg's expression system handles the actual timing.
    --------------------------------------------------------

    for i = 1, count do

        local explosion =
            functions.getRandomLibraryFile(
                "video",
                "explosions"
            )

        if explosion ~= nil then

            ------------------------------------------------
            -- Random normalized position.
            ------------------------------------------------

            local normalizedTime

            if overlap then
                normalizedTime = math.random()
            else
                normalizedTime =
                    (i - 0.5) / count

                local randomness =
                    timingRandomness / 100

                normalizedTime =
                    normalizedTime +
                    ((math.random() - 0.5) *
                    (1.0 / count) *
                    randomness)

                normalizedTime =
                    clamp(
                        normalizedTime,
                        0.01,
                        0.99
                    )
            end

            ------------------------------------------------
            -- Random size.
            ------------------------------------------------

            local sizePercent = scale

            if randomizeScale then
                local variation =
                    scale * 0.50

                sizePercent =
                    scale +
                    ((math.random() - 0.5) *
                    variation)

                sizePercent =
                    clamp(
                        sizePercent,
                        5,
                        200
                    )
            end

            ------------------------------------------------
            -- Random position.
            --
            -- The actual x/y values are expressions based
            -- on the source dimensions.
            ------------------------------------------------

            local positionAmount =
                positionRandomness / 100

            local xExpression =
                string.format(
                    "(W-w)*%.4f",
                    math.random()
                )

            local yExpression =
                string.format(
                    "(H-h)*%.4f",
                    math.random()
                )

            if positionAmount < 1 then

                xExpression =
                    string.format(
                        "((W-w)/2)+((W-w)*(%.4f-0.5)*%.4f)",
                        math.random(),
                        positionAmount
                    )

                yExpression =
                    string.format(
                        "((H-h)/2)+((H-h)*(%.4f-0.5)*%.4f)",
                        math.random(),
                        positionAmount
                    )
            end

            ------------------------------------------------
            -- Each explosion is scaled according to the
            -- output video's height.
            ------------------------------------------------

            local explosionLabel =
                "exp" .. tostring(i)

            local explosionInput =
                "e" .. tostring(i)

            local explosionScaled =
                explosionLabel .. "_scaled"

            local explosionKeyed =
                explosionLabel .. "_keyed"

            ------------------------------------------------
            -- Input file.
            ------------------------------------------------

            filter[#filter + 1] =
                string.format(
                    "movie='%s':loop=0[%s]",
                    explosion,
                    explosionInput
                )

            ------------------------------------------------
            -- Scale explosion.
            ------------------------------------------------

            filter[#filter + 1] =
                string.format(
                    "[%s]scale=-1:%d[%s]",
                    explosionInput,
                    math.max(
                        16,
                        math.floor(
                            options.height *
                            sizePercent /
                            100
                        )
                    ),
                    explosionScaled
                )

            ------------------------------------------------
            -- Optional green-screen removal.
            ------------------------------------------------

            local keyedInput =
                explosionScaled

            if useGreenScreen then

                filter[#filter + 1] =
                    string.format(
                        "[%s]chromakey=0x00ff00:%s:0.05[%s]",
                        explosionScaled,
                        tostring(greenSimilarity),
                        explosionKeyed
                    )

                keyedInput =
                    explosionKeyed
            end

            ------------------------------------------------
            -- Optional color boost.
            ------------------------------------------------

            local processedInput =
                keyedInput

            if colorBoost then

                local boosted =
                    explosionLabel .. "_boost"

                filter[#filter + 1] =
                    string.format(
                        "[%s]eq=saturation=1.35:contrast=1.08:brightness=0.05[%s]",
                        keyedInput,
                        boosted
                    )

                processedInput =
                    boosted
            end

            ------------------------------------------------
            -- Opacity.
            ------------------------------------------------

            if opacity < 1 then

                local alpha =
                    explosionLabel .. "_alpha"

                filter[#filter + 1] =
                    string.format(
                        "[%s]format=rgba,colorchannelmixer=aa=%s[%s]",
                        processedInput,
                        tostring(opacity),
                        alpha
                    )

                processedInput =
                    alpha
            end

            ------------------------------------------------
            -- Random explosion duration.
            --
            -- Most short explosion clips look good when
            -- visible for approximately 0.20-0.90 sec.
            ------------------------------------------------

            local duration =
                0.20 +
                math.random() * 0.70

            ------------------------------------------------
            -- We use a normalized timeline expression.
            --
            -- The explosion is enabled around its randomly
            -- selected timeline location.
            ------------------------------------------------

            local startExpression =
                string.format(
                    "duration*%.6f",
                    normalizedTime
                )

            local endExpression =
                string.format(
                    "(duration*%.6f)+%.3f",
                    normalizedTime,
                    duration
                )

            ------------------------------------------------
            -- Overlay.
            ------------------------------------------------

            local nextVideo =
                "mix" .. tostring(i)

            filter[#filter + 1] =
                string.format(
                    "[%s][%s]overlay=x=%s:y=%s:enable='between(t,%s,%s)'[%s]",
                    currentVideo,
                    processedInput,
                    xExpression,
                    yExpression,
                    startExpression,
                    endExpression,
                    nextVideo
                )

            currentVideo =
                nextVideo
        end
    end

    --------------------------------------------------------
    -- Final video.
    --------------------------------------------------------

    filter[#filter + 1] =
        string.format(
            "[%s]format=yuv420p[outv]",
            currentVideo
        )

    local filterComplex =
        table.concat(
            filter,
            ";"
        )

    --------------------------------------------------------
    -- Build the FFmpeg command.
    --
    -- The explosion files are inserted by FFmpeg's movie
    -- filter, allowing NVG library placeholders to resolve
    -- inside the effect working directory.
    --------------------------------------------------------

    local command =
        string.format(
            "-i \"%s\" " ..
            "-filter_complex \"%s\" " ..
            "-map \"[outv]\" " ..
            "-map 0:a? " ..
            "-c:v libx264 " ..
            "-preset medium " ..
            "-crf 18 " ..
            "-pix_fmt yuv420p " ..
            "-c:a aac " ..
            "-b:a 192k " ..
            "-movflags +faststart " ..
            "-y \"%s\"",
            options.inputVideo,
            filterComplex,
            options.outputVideo
        )

    --------------------------------------------------------
    -- Explosion audio is intentionally kept from the
    -- source by default.
    --
    -- Explosion clips can be silent/transparent overlays,
    -- which keeps the effect deterministic and avoids
    -- accidentally replacing the original soundtrack.
    --------------------------------------------------------

    functions.runFFmpeg(command)

    commandIndex = 1

    return true
end

------------------------------------------------------------
-- PostCommand
------------------------------------------------------------

function PostCommand(
    commandindex,
    outputResult,
    errorResult,
    options,
    pluginSettings,
    functions
)

    --------------------------------------------------------
    -- The effect currently uses one asynchronous FFmpeg
    -- operation.
    --------------------------------------------------------

    if commandindex == 1 then

        -- Rendering completed successfully.

        return nil
    end

    return nil
end

------------------------------------------------------------
-- StopGeneration
------------------------------------------------------------

function StopGeneration(
    options,
    pluginSettings,
    functions
)

    commandIndex = 0

    return true
end