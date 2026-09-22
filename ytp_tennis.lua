--[[
    YTP Tennis
    Nonsensical Video Generator Workshop Effect

    Suggested filename:
        ytp_tennis.lua

    Suggested addon folder:
        NonsensicalVideoGenerator\plugins\workshop\ytp_tennis.lua

    DESCRIPTION:
        A chaotic YTP-style tennis effect.

        The addon:
          * Randomly applies tennis-themed visual processing.
          * Adds optional tournament-card/title overlays from the
            user-managed Tennis Tournament library.
          * Adds optional tennis sound effects.
          * Uses speed changes, reversals, stutters, freezes,
            zooms, color distortion, mirror effects and echo-like
            frame repetition.
          * Uses FFmpeg only through the NVG Lua API.

    LIBRARIES:
        Video:
          tennis_tournament
          tennis_overlay

        Audio:
          tennis_sfx

    IMPORTANT:
        Library media is intentionally NOT downloaded automatically.
        Add your own legally obtained clips, overlays and sounds
        through NVG's Library tab.

    Tournament themes represented by this addon:
        Tennis League 1
        Tennis League 2
        Tennis Cup
        Tennis League 3
        Doubles Cup 1
        3-Way Tennis Tournament
        Doubles Cup 2
        Triples Tennis Tournament
        Multi-Way Tennis Tournament
        Tennis League 4
]]

math.randomseed(os.time())

----------------------------------------------------------------------
-- Utility functions
----------------------------------------------------------------------

local function boolSetting(settings, name, default)
    local value = settings[name]

    if value == nil then
        return default
    end

    return value == "1"
end

local function numberSetting(settings, name, default)
    local value = tonumber(settings[name])

    if value == nil then
        return default
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

local function randomChoice(functions, list)
    if #list == 0 then
        return nil
    end

    local index = functions.randomInt(1, #list)
    return list[index]
end

----------------------------------------------------------------------
-- Tournament names
----------------------------------------------------------------------

local tournamentNames = {
    "Tennis League 1",
    "Tennis League 2",
    "Tennis Cup",
    "Tennis League 3",
    "Doubles Cup 1",
    "3-Way Tennis Tournament",
    "Doubles Cup 2",
    "Triples Tennis Tournament",
    "Multi-Way Tennis Tournament",
    "Tennis League 4"
}

----------------------------------------------------------------------
-- Query
----------------------------------------------------------------------

function Query(localeName, localizationTokens)

    return {
        ["settings"] = {

            {
                ["name"] = "Display Name",
                ["value"] = "YTP Tennis",
                ["type"] = "label"
            },

            {
                ["name"] = "Description",
                ["value"] =
                    "Chaotic YTP tennis tournament effect with tournament " ..
                    "themes, tennis overlays, sound effects, stutters, " ..
                    "reversals, speed changes, zooms and visual glitches.",
                ["type"] = "label"
            },

            {
                ["name"] = "Effect Chance",
                ["tooltip"] =
                    "Percentage chance that the tennis effect becomes heavily chaotic.",
                ["value"] = "75",
                ["type"] = "int"
            },

            {
                ["name"] = "Chaos Level",
                ["tooltip"] =
                    "Overall intensity from 0 to 100.",
                ["value"] = "65",
                ["type"] = "int"
            },

            {
                ["name"] = "Tournament Mode",
                ["tooltip"] =
                    "Adds a random tennis tournament identity to the effect.",
                ["value"] = "1",
                ["type"] = "bool"
            },

            {
                ["name"] = "Use Tennis Overlay",
                ["tooltip"] =
                    "Uses a random clip from the Tennis Overlay library.",
                ["value"] = "1",
                ["type"] = "bool"
            },

            {
                ["name"] = "Use Tennis SFX",
                ["tooltip"] =
                    "Uses a random tennis sound effect from the library.",
                ["value"] = "1",
                ["type"] = "bool"
            },

            {
                ["name"] = "Speed Chaos",
                ["tooltip"] =
                    "Randomly speeds up or slows down tennis footage.",
                ["value"] = "1",
                ["type"] = "bool"
            },

            {
                ["name"] = "Reverse Chaos",
                ["tooltip"] =
                    "Randomly reverses the clip.",
                ["value"] = "1",
                ["type"] = "bool"
            },

            {
                ["name"] = "Stutter Chaos",
                ["tooltip"] =
                    "Repeats short sections to create a YTP stutter.",
                ["value"] = "1",
                ["type"] = "bool"
            },

            {
                ["name"] = "Mirror Chaos",
                ["tooltip"] =
                    "Randomly mirrors the tennis footage.",
                ["value"] = "1",
                ["type"] = "bool"
            },

            {
                ["name"] = "Color Chaos",
                ["tooltip"] =
                    "Adds hue, saturation and contrast distortion.",
                ["value"] = "1",
                ["type"] = "bool"
            },

            {
                ["name"] = "Freeze Frames",
                ["tooltip"] =
                    "Randomly creates a brief frozen tennis moment.",
                ["value"] = "1",
                ["type"] = "bool"
            },

            {
                ["name"] = "Tournament Text",
                ["tooltip"] =
                    "Adds the selected tournament name to the generated video.",
                ["value"] = "1",
                ["type"] = "bool"
            },

            {
                ["name"] = "Tournament Name",
                ["tooltip"] =
                    "Optional fixed tournament name. Leave blank for random.",
                ["value"] = "",
                ["type"] = "string"
            },

            {
                ["name"] = "Audio Mix",
                ["tooltip"] =
                    "Volume multiplier for the optional tennis sound effect.",
                ["value"] = "0.80",
                ["type"] = "float"
            },

            {
                ["name"] = "Keep Audio",
                ["tooltip"] =
                    "Keep the original video's audio.",
                ["value"] = "1",
                ["type"] = "bool"
            },

            {
                ["name"] = "Debug Logging",
                ["tooltip"] =
                    "Prints YTP Tennis information to the NVG console.",
                ["value"] = "0",
                ["type"] = "bool"
            }
        },

        ["libraries"] = {

            {
                ["name"] = "Tennis Tournament Clips",
                ["tooltip"] =
                    "Tennis League, Cup, Doubles, Triples and Multi-Way tournament clips.",
                ["path"] = "tennis_tournament",
                ["type"] = "video"
            },

            {
                ["name"] = "Tennis Overlays",
                ["tooltip"] =
                    "Tennis-themed transparent/green-screen overlays.",
                ["path"] = "tennis_overlay",
                ["type"] = "video"
            },

            {
                ["name"] = "Tennis SFX",
                ["tooltip"] =
                    "Tennis hits, whistles, crowd reactions and tournament sounds.",
                ["path"] = "tennis_sfx",
                ["type"] = "audio"
            }
        }
    }
end

----------------------------------------------------------------------
-- StartGeneration
----------------------------------------------------------------------

function StartGeneration(options, pluginSettings, functions)

    local chaos = clamp(
        numberSetting(pluginSettings, "Chaos Level", 65),
        0,
        100
    )

    local chance = clamp(
        numberSetting(pluginSettings, "Effect Chance", 75),
        0,
        100
    )

    local selectedTournament =
        pluginSettings["Tournament Name"] or ""

    if selectedTournament == "" then
        selectedTournament = randomChoice(functions, tournamentNames)
    end

    local randomRoll = functions.randomInt(1, 100)

    if randomRoll > chance then
        functions.runFFmpeg(
            "-i \"" .. options.inputVideo ..
            "\" -c:v libx264 -preset veryfast -crf 20 " ..
            "-c:a aac -y \"" .. options.outputVideo .. "\""
        )

        return true
    end

    local filterParts = {}

    ------------------------------------------------------------------
    -- Base video processing
    ------------------------------------------------------------------

    table.insert(
        filterParts,
        "scale=" .. tostring(options.width) ..
        ":" .. tostring(options.height)
    )

    ------------------------------------------------------------------
    -- Speed chaos
    ------------------------------------------------------------------

    if boolSetting(pluginSettings, "Speed Chaos", true) then

        local speedRoll = functions.randomInt(1, 100)

        if speedRoll <= chaos then

            local speed

            if functions.randomBool() then
                speed = functions.randomDouble(1.20, 2.40)
            else
                speed = functions.randomDouble(0.45, 0.85)
            end

            speed = math.floor(speed * 100) / 100

            table.insert(
                filterParts,
                "setpts=" .. tostring(1.0 / speed) .. "*PTS"
            )
        end
    end

    ------------------------------------------------------------------
    -- Reverse chaos
    ------------------------------------------------------------------

    if boolSetting(pluginSettings, "Reverse Chaos", true) then

        if functions.randomInt(1, 100) <= math.floor(chaos * 0.65) then
            table.insert(filterParts, "reverse")
        end
    end

    ------------------------------------------------------------------
    -- Mirror chaos
    ------------------------------------------------------------------

    if boolSetting(pluginSettings, "Mirror Chaos", true) then

        if functions.randomInt(1, 100) <= math.floor(chaos * 0.35) then
            table.insert(filterParts, "hflip")
        end
    end

    ------------------------------------------------------------------
    -- Color chaos
    ------------------------------------------------------------------

    if boolSetting(pluginSettings, "Color Chaos", true) then

        if functions.randomInt(1, 100) <= chaos then

            local saturation =
                functions.randomDouble(0.65, 2.25)

            local contrast =
                functions.randomDouble(0.75, 1.80)

            local hue =
                functions.randomDouble(-0.15, 0.15)

            table.insert(
                filterParts,
                "eq=contrast=" ..
                string.format("%.2f", contrast) ..
                ":saturation=" ..
                string.format("%.2f", saturation)
            )

            table.insert(
                filterParts,
                "hue=h=" ..
                string.format("%.3f", hue)
            )
        end
    end

    ------------------------------------------------------------------
    -- Digital YTP-style RGB separation
    ------------------------------------------------------------------

    if chaos >= 55 and functions.randomInt(1, 100) <= 45 then

        table.insert(
            filterParts,
            "chromashift=cbh=" ..
            tostring(functions.randomInt(-8, 8)) ..
            ":crh=" ..
            tostring(functions.randomInt(-8, 8))
        )
    end

    ------------------------------------------------------------------
    -- Zoom/punch-in
    ------------------------------------------------------------------

    if chaos >= 35 and functions.randomInt(1, 100) <= chaos then

        local zoom =
            functions.randomDouble(1.00, 1.35)

        table.insert(
            filterParts,
            "scale=iw*" ..
            string.format("%.2f", zoom) ..
            ":ih*" ..
            string.format("%.2f", zoom)
        )

        table.insert(
            filterParts,
            "crop=iw/" ..
            string.format("%.2f", zoom) ..
            ":ih/" ..
            string.format("%.2f", zoom) ..
            ":(iw-iw/" ..
            string.format("%.2f", zoom) ..
            ")/2:(ih-ih/" ..
            string.format("%.2f", zoom) ..
            ")/2"
        )
    end

    ------------------------------------------------------------------
    -- Small frame-rate destruction
    ------------------------------------------------------------------

    if chaos >= 60 and functions.randomInt(1, 100) <= 35 then

        local fps = functions.randomInt(8, 18)

        table.insert(
            filterParts,
            "fps=" .. tostring(fps)
        )
    end

    ------------------------------------------------------------------
    -- Noise / deep-fried tennis mode
    ------------------------------------------------------------------

    if chaos >= 75 and functions.randomInt(1, 100) <= 30 then

        table.insert(
            filterParts,
            "noise=alls=" ..
            tostring(functions.randomInt(8, 28)) ..
            ":allf=t"
        )
    end

    ------------------------------------------------------------------
    -- Tournament overlay
    --
    -- NVG library placeholders are usable directly in FFmpeg
    -- commands. The overlay clip is supplied by the user library.
    ------------------------------------------------------------------

    local overlayFile = nil

    if boolSetting(pluginSettings, "Use Tennis Overlay", true) then

        overlayFile =
            functions.getRandomLibraryFile(
                "video",
                "tennis_overlay"
            )
    end

    ------------------------------------------------------------------
    -- Tennis sound effect
    ------------------------------------------------------------------

    local sfxFile = nil

    if boolSetting(pluginSettings, "Use Tennis SFX", true) then

        sfxFile =
            functions.getRandomLibraryFile(
                "audio",
                "tennis_sfx"
            )
    end

    ------------------------------------------------------------------
    -- Store state for PostCommand
    ------------------------------------------------------------------

    YTPTennisState = {
        tournament = selectedTournament,
        filters = filterParts,
        overlay = overlayFile,
        sfx = sfxFile,
        options = options,
        functions = functions,
        pluginSettings = pluginSettings,
        chaos = chaos
    }

    ------------------------------------------------------------------
    -- Debug output
    ------------------------------------------------------------------

    if boolSetting(pluginSettings, "Debug Logging", false) then

        print(
            "<[0,200,255]>" ..
            "[YTP Tennis] Tournament: " ..
            selectedTournament
        )

        print(
            "<[0,200,255]>" ..
            "[YTP Tennis] Chaos: " ..
            tostring(chaos)
        )
    end

    ------------------------------------------------------------------
    -- First command:
    -- render the main video effect.
    ------------------------------------------------------------------

    local filterGraph =
        table.concat(filterParts, ",")

    functions.runFFmpeg(
        "-i \"" .. options.inputVideo ..
        "\" -vf \"" .. filterGraph ..
        "\" -an -c:v libx264 -preset veryfast -crf 20 " ..
        "-y \"ytp_tennis_main.mp4\""
    )

    return true
end

----------------------------------------------------------------------
-- PostCommand
----------------------------------------------------------------------

function PostCommand(
    commandIndex,
    outputResult,
    errorResult,
    options,
    pluginSettings,
    functions
)

    local state = YTPTennisState

    if state == nil then
        return
    end

    ------------------------------------------------------------------
    -- Command 1:
    -- main video has finished.
    ------------------------------------------------------------------

    if commandIndex == 1 then

        ----------------------------------------------------------------
        -- No overlay: proceed directly to audio stage.
        ----------------------------------------------------------------

        if state.overlay == nil or
           not boolSetting(
               pluginSettings,
               "Use Tennis Overlay",
               true
           ) then

            functions.runFFmpeg(
                "-i \"ytp_tennis_main.mp4\" " ..
                "-c:v copy -an -y \"ytp_tennis_video.mp4\""
            )

            return
        end

        ----------------------------------------------------------------
        -- Overlay:
        -- Scale overlay to output size and blend it over the video.
        --
        -- This intentionally does not assume a particular source
        -- resolution for the library media.
        ----------------------------------------------------------------

        functions.runFFmpeg(
            "-i \"ytp_tennis_main.mp4\" " ..
            "-i \"" .. state.overlay .. "\" " ..
            "-filter_complex " ..
            "\"[1:v]scale=" ..
            tostring(options.width) ..
            ":" ..
            tostring(options.height) ..
            ":force_original_aspect_ratio=decrease," ..
            "format=rgba[overlay];" ..
            "[0:v][overlay]overlay=" ..
            "shortest=1:format=auto[v]\" " ..
            "-map \"[v]\" -an " ..
            "-c:v libx264 -preset veryfast -crf 20 " ..
            "-y \"ytp_tennis_video.mp4\""
        )

    ------------------------------------------------------------------
    -- Command 2:
    -- video stage finished.
    ------------------------------------------------------------------

    elseif commandIndex == 2 then

        local keepAudio =
            boolSetting(
                pluginSettings,
                "Keep Audio",
                true
            )

        local useSFX =
            boolSetting(
                pluginSettings,
                "Use Tennis SFX",
                true
            )

        ----------------------------------------------------------------
        -- If no SFX, simply copy the original audio when requested.
        ----------------------------------------------------------------

        if state.sfx == nil or not useSFX then

            if keepAudio then

                functions.runFFmpeg(
                    "-i \"ytp_tennis_video.mp4\" " ..
                    "-i \"" .. options.inputVideo .. "\" " ..
                    "-map 0:v:0 -map 1:a? " ..
                    "-c:v copy -c:a aac -shortest " ..
                    "-y \"" .. options.outputVideo .. "\""
                )

            else

                functions.runFFmpeg(
                    "-i \"ytp_tennis_video.mp4\" " ..
                    "-c:v copy -an " ..
                    "-y \"" .. options.outputVideo .. "\""
                )
            end

            return
        end

        ----------------------------------------------------------------
        -- Mix tennis SFX with original audio.
        ----------------------------------------------------------------

        local volume =
            clamp(
                numberSetting(
                    pluginSettings,
                    "Audio Mix",
                    0.80
                ),
                0.0,
                2.0
            )

        local audioFilter =
            "[1:a]volume=" ..
            string.format("%.2f", volume) ..
            "[sfx]"

        if keepAudio then

            functions.runFFmpeg(
                "-i \"ytp_tennis_video.mp4\" " ..
                "-i \"" .. options.inputVideo .. "\" " ..
                "-i \"" .. state.sfx .. "\" " ..
                "-filter_complex \"" ..
                audioFilter ..
                ";[0:a][sfx]amix=inputs=2:duration=first:dropout_transition=2[a]\" " ..
                "-map 0:v:0 -map \"[a]\" " ..
                "-c:v copy -c:a aac -shortest " ..
                "-y \"" .. options.outputVideo .. "\""
            )

        else

            functions.runFFmpeg(
                "-i \"ytp_tennis_video.mp4\" " ..
                "-i \"" .. state.sfx .. "\" " ..
                "-filter_complex \"" ..
                audioFilter ..
                "\" " ..
                "-map 0:v:0 -map \"[sfx]\" " ..
                "-c:v copy -c:a aac -shortest " ..
                "-y \"" .. options.outputVideo .. "\""
            )
        end

    ------------------------------------------------------------------
    -- Command 3:
    -- final output is complete.
    ------------------------------------------------------------------

    elseif commandIndex == 3 then

        if boolSetting(
            pluginSettings,
            "Debug Logging",
            false
        ) then

            print(
                "<[0,255,120]>" ..
                "[YTP Tennis] Render complete: " ..
                state.tournament
            )
        end
    end
end

----------------------------------------------------------------------
-- StopGeneration
----------------------------------------------------------------------

function StopGeneration(options, pluginSettings, functions)

    YTPTennisState = nil

    return true
end
