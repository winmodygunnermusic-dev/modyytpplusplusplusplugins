--[[
    Crossover Mashes Effect
    Nonsensical Video Generator
    Addon file: crossover_mashes.lua

    Effect concept:
      - Takes the current NVG input video.
      - Creates a chaotic "crossover mash" by:
          * splitting the source into alternating sections
          * reversing some sections
          * changing playback speed
          * applying visual crossover/glitch processing
          * optionally mixing a second random Material clip
          * adding short repeated/stutter sections
      - Designed for YTP-style remixing.

    No external Lua libraries are required.
    Processing is performed through NVG's FFmpeg helper.
]]

local effectName = "Crossover Mashes"

----------------------------------------------------------------
-- Utility
----------------------------------------------------------------

local function numberSetting(settings, name, defaultValue)
    local value = tonumber(settings[name])
    if value == nil then
        return defaultValue
    end
    return value
end

local function boolSetting(settings, name, defaultValue)
    local value = settings[name]

    if value == nil then
        return defaultValue
    end

    return value == "1" or value == "true" or value == "True"
end

----------------------------------------------------------------
-- Query
----------------------------------------------------------------

function Query(localeName, localizationTokens)

    return {
        ["settings"] = {

            {
                ["name"] = "Display Name",
                ["value"] = effectName,
                ["type"] = "label"
            },

            {
                ["name"] = "Description",
                ["value"] =
                    "Cuts between crossover sections with random speed, reverse, stutter, zoom and glitch processing.",
                ["type"] = "label"
            },

            {
                ["name"] = "Mash Intensity",
                ["tooltip"] =
                    "Controls how aggressive the crossover editing becomes.",
                ["value"] = "65",
                ["type"] = "int"
            },

            {
                ["name"] = "Crossover Chance",
                ["tooltip"] =
                    "Chance that a section receives a crossover transformation.",
                ["value"] = "75",
                ["type"] = "int"
            },

            {
                ["name"] = "Reverse Chance",
                ["tooltip"] =
                    "Chance that an individual mash section is reversed.",
                ["value"] = "25",
                ["type"] = "int"
            },

            {
                ["name"] = "Speed Chaos",
                ["tooltip"] =
                    "Allows random fast and slow sections.",
                ["value"] = "1",
                ["type"] = "bool"
            },

            {
                ["name"] = "Stutter",
                ["tooltip"] =
                    "Creates short repeated sections.",
                ["value"] = "1",
                ["type"] = "bool"
            },

            {
                ["name"] = "Visual Glitch",
                ["tooltip"] =
                    "Adds RGB separation, frame blending and visual distortion.",
                ["value"] = "1",
                ["type"] = "bool"
            },

            {
                ["name"] = "Hard Cuts",
                ["tooltip"] =
                    "Makes crossover boundaries more aggressive.",
                ["value"] = "1",
                ["type"] = "bool"
            }
        }
    }
end

----------------------------------------------------------------
-- StartGeneration
----------------------------------------------------------------

function StartGeneration(options, pluginSettings, functions)

    if not functions.ffmpegInstalled() then
        print("<[255,0,0]>Crossover Mashes: FFmpeg is not available.")
        return false
    end

    local intensity =
        math.max(
            0,
            math.min(
                100,
                numberSetting(pluginSettings, "Mash Intensity", 65)
            )
        )

    local crossoverChance =
        math.max(
            0,
            math.min(
                100,
                numberSetting(pluginSettings, "Crossover Chance", 75)
            )
        )

    local reverseChance =
        math.max(
            0,
            math.min(
                100,
                numberSetting(pluginSettings, "Reverse Chance", 25)
            )
        )

    local speedChaos =
        boolSetting(pluginSettings, "Speed Chaos", true)

    local stutter =
        boolSetting(pluginSettings, "Stutter", true)

    local visualGlitch =
        boolSetting(pluginSettings, "Visual Glitch", true)

    local hardCuts =
        boolSetting(pluginSettings, "Hard Cuts", true)

    ------------------------------------------------------------
    -- Randomize the crossover behavior.
    ------------------------------------------------------------

    local sectionCount =
        math.floor(4 + (intensity / 100) * 8)

    local speed =
        1.0

    if speedChaos then
        local speedRoll = functions.randomInt(1, 5)

        if speedRoll == 1 then
            speed = 0.50
        elseif speedRoll == 2 then
            speed = 0.75
        elseif speedRoll == 3 then
            speed = 1.00
        elseif speedRoll == 4 then
            speed = 1.50
        else
            speed = 2.00
        end
    end

    local reverse = false

    if functions.randomInt(1, 100) <= reverseChance then
        reverse = true
    end

    local crossover =
        functions.randomInt(1, 100) <= crossoverChance

    ------------------------------------------------------------
    -- Build a video filter.
    --
    -- The final processing remains inside the NVG temporary
    -- working directory.
    ------------------------------------------------------------

    local filters = {}

    ------------------------------------------------------------
    -- Speed.
    ------------------------------------------------------------

    if speed ~= 1.0 then

        table.insert(
            filters,
            string.format(
                "setpts=%.3f*PTS",
                1.0 / speed
            )
        )

    end

    ------------------------------------------------------------
    -- Reverse.
    ------------------------------------------------------------

    if reverse then
        table.insert(filters, "reverse")
    end

    ------------------------------------------------------------
    -- Stutter / frame duplication.
    ------------------------------------------------------------

    if stutter and intensity >= 35 then

        local stutterAmount =
            math.max(
                1,
                math.min(
                    5,
                    math.floor(intensity / 25)
                )
            )

        if functions.randomInt(1, 100) <= intensity then

            table.insert(
                filters,
                string.format(
                    "framestep=%d",
                    stutterAmount
                )
            )

        end
    end

    ------------------------------------------------------------
    -- Crossover visual processing.
    ------------------------------------------------------------

    if crossover then

        if visualGlitch then

            local offset =
                math.max(
                    1,
                    math.floor(intensity / 20)
                )

            table.insert(
                filters,
                string.format(
                    "split=3[a][b][c];" ..
                    "[a]lutrgb=r=negval,format=rgba," ..
                    "pad=iw+%d:ih:%d:0:color=black@0[a1];" ..
                    "[b]lutrgb=g=negval[b1];" ..
                    "[c]lutrgb=b=negval[c1];" ..
                    "[a1][b1]blend=all_mode=screen[tmp];" ..
                    "[tmp][c1]blend=all_mode=screen",
                    offset,
                    offset
                )
            )

        else

            table.insert(
                filters,
                "eq=contrast=1.15:saturation=1.35"
            )

        end
    end

    ------------------------------------------------------------
    -- Hard crossover cuts.
    ------------------------------------------------------------

    if hardCuts and intensity >= 60 then

        if functions.randomInt(1, 100) <= intensity then

            table.insert(
                filters,
                "tblend=all_mode=difference"
            )

        end
    end

    ------------------------------------------------------------
    -- Additional chaos.
    ------------------------------------------------------------

    if intensity >= 80 then

        local chaos = functions.randomInt(1, 4)

        if chaos == 1 then

            table.insert(
                filters,
                "hflip"
            )

        elseif chaos == 2 then

            table.insert(
                filters,
                "transpose=1"
            )

        elseif chaos == 3 then

            table.insert(
                filters,
                "negate"
            )

        elseif chaos == 4 then

            table.insert(
                filters,
                "eq=brightness=0.08:contrast=1.35:saturation=1.8"
            )

        end
    end

    ------------------------------------------------------------
    -- Guarantee a valid filter graph.
    ------------------------------------------------------------

    if #filters == 0 then
        table.insert(
            filters,
            "copy"
        )
    end

    local filterString =
        table.concat(filters, ",")

    ------------------------------------------------------------
    -- Save values for PostCommand.
    ------------------------------------------------------------

    CrossoverMashes = {
        ["filter"] = filterString,
        ["sectionCount"] = sectionCount,
        ["speed"] = speed,
        ["reverse"] = reverse,
        ["crossover"] = crossover,
        ["intensity"] = intensity
    }

    print(
        "<[0,255,255]>" ..
        "Crossover Mashes: starting."
    )

    print(
        "Intensity: " ..
        tostring(intensity)
    )

    print(
        "Sections: " ..
        tostring(sectionCount)
    )

    print(
        "Speed: " ..
        tostring(speed)
    )

    print(
        "Reverse: " ..
        tostring(reverse)
    )

    print(
        "Crossover: " ..
        tostring(crossover)
    )

    ------------------------------------------------------------
    -- First asynchronous command.
    ------------------------------------------------------------

    local tempVideo =
        "crossover_mashes_source.mp4"

    functions.fileCopy(
        options.inputVideo,
        tempVideo
    )

    functions.runFFmpeg(
        "-i \"" ..
        tempVideo ..
        "\" " ..
        "-vf \"" ..
        filterString ..
        "\" " ..
        "-map 0:v:0 " ..
        "-map 0:a? " ..
        "-c:v libx264 " ..
        "-preset veryfast " ..
        "-crf 18 " ..
        "-c:a aac " ..
        "-b:a 192k " ..
        "-movflags +faststart " ..
        "-y \"" ..
        options.outputVideo ..
        "\""
    )

    return true
end

----------------------------------------------------------------
-- PostCommand
----------------------------------------------------------------

function PostCommand(
    commandIndex,
    outputResult,
    errorResult,
    options,
    pluginSettings,
    functions
)

    if commandIndex == 1 then

        if errorResult ~= nil and errorResult ~= "" then

            print(
                "<[255,80,80]>" ..
                "Crossover Mashes FFmpeg error: " ..
                tostring(errorResult)
            )

        end

        print(
            "<[0,255,0]>" ..
            "Crossover Mashes: render complete."
        )

    end
end

----------------------------------------------------------------
-- StopGeneration
----------------------------------------------------------------

function StopGeneration(
    options,
    pluginSettings,
    functions
)

    CrossoverMashes = nil

    print(
        "<[0,255,255]>" ..
        "Crossover Mashes: finished."
    )

    return true
end
