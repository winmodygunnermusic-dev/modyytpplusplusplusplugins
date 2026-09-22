-- Speed Ramp Effect
-- Nonsensical Video Generator v1.8.1.2
-- Workshop addon
--
-- File:
-- NonsensicalVideoGenerator\plugins\workshop\speed_ramp.lua
--
-- Description:
-- Dynamically changes playback speed throughout the clip using FFmpeg
-- time remapping. Audio is processed along with the video where possible.

local effectName = "Speed Ramp"

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
                ["value"] = "Gradually ramps video speed between slow and fast sections.",
                ["type"] = "label"
            },

            {
                ["name"] = "Ramp Mode",
                ["tooltip"] = "1=Slow-Fast, 2=Fast-Slow, 3=Slow-Fast-Slow, 4=Fast-Slow-Fast",
                ["value"] = "3",
                ["type"] = "int"
            },

            {
                ["name"] = "Slow Speed",
                ["tooltip"] = "Slowest playback speed. Recommended: 0.25 to 0.75.",
                ["value"] = "0.5",
                ["type"] = "float"
            },

            {
                ["name"] = "Fast Speed",
                ["tooltip"] = "Fastest playback speed. Recommended: 1.5 to 4.0.",
                ["value"] = "2.0",
                ["type"] = "float"
            },

            {
                ["name"] = "Ramp Strength",
                ["tooltip"] = "Overall strength of the speed-ramp effect from 0 to 100.",
                ["value"] = "100",
                ["type"] = "int"
            },

            {
                ["name"] = "Audio Pitch Compensation",
                ["tooltip"] = "Attempts to preserve normal audio pitch while changing speed.",
                ["value"] = "1",
                ["type"] = "bool"
            },

            {
                ["name"] = "Randomize Ramp",
                ["tooltip"] = "Randomly chooses a ramp mode each time the effect runs.",
                ["value"] = "0",
                ["type"] = "bool"
            }
        }
    }
end


-- Clamp helper
local function clamp(value, minimum, maximum)
    if value < minimum then
        return minimum
    end

    if value > maximum then
        return maximum
    end

    return value
end


-- Safely convert a plugin setting to a number.
local function numberSetting(pluginSettings, name, fallback)
    local value = tonumber(pluginSettings[name])

    if value == nil then
        return fallback
    end

    return value
end


-- Calculate effective speeds from the configured strength.
local function calculateSpeeds(pluginSettings)
    local slow = numberSetting(pluginSettings, "Slow Speed", 0.5)
    local fast = numberSetting(pluginSettings, "Fast Speed", 2.0)
    local strength = numberSetting(pluginSettings, "Ramp Strength", 100)

    slow = clamp(slow, 0.05, 4.0)
    fast = clamp(fast, 0.05, 8.0)
    strength = clamp(strength, 0, 100)

    -- 100% = configured values.
    -- 0% = normal 1x playback.
    local factor = strength / 100.0

    slow = 1.0 + ((slow - 1.0) * factor)
    fast = 1.0 + ((fast - 1.0) * factor)

    return slow, fast
end


-- Build a smooth-ish speed curve using FFmpeg's setpts expression.
--
-- The expression uses normalized frame number:
--
--   t < 1/3     -> first speed
--   t 1/3..2/3  -> transition
--   t > 2/3     -> final speed
--
-- A more practical implementation for NVG is to split the video into
-- sections and apply different speed factors to each section.
--
-- This function returns the setpts expression for one section.
local function videoPTS(speed)
    -- PTS is multiplied by 1/speed:
    -- 0.5x => 2x PTS duration
    -- 2.0x => 0.5x PTS duration
    return string.format("%.8f*PTS", 1.0 / speed)
end


-- Audio tempo filter.
--
-- FFmpeg's atempo accepts values from 0.5 to 2.0 per filter instance.
-- Chaining atempo filters allows us to support values outside that range.
local function audioTempo(speed)
    local filters = {}

    local remaining = speed

    -- Speed up/down in chunks so values outside 0.5..2.0 work.
    while remaining > 2.0 do
        table.insert(filters, "atempo=2.0")
        remaining = remaining / 2.0
    end

    while remaining < 0.5 do
        table.insert(filters, "atempo=0.5")
        remaining = remaining / 0.5
    end

    table.insert(filters, string.format("atempo=%.6f", remaining))

    return table.concat(filters, ",")
end


function StartGeneration(options, pluginSettings, functions)
    if not functions.ffmpegInstalled() then
        return false
    end

    local slowSpeed, fastSpeed = calculateSpeeds(pluginSettings)

    local mode = math.floor(
        numberSetting(pluginSettings, "Ramp Mode", 3)
    )

    mode = clamp(mode, 1, 4)

    if pluginSettings["Randomize Ramp"] == "1" then
        math.randomseed(os.time())
        mode = math.random(1, 4)
    end

    -- Store data for PostCommand.
    _G.speedRampState = {
        ["slow"] = slowSpeed,
        ["fast"] = fastSpeed,
        ["mode"] = mode,
        ["pitch"] = pluginSettings["Audio Pitch Compensation"] == "1"
    }

    -- The source is first normalized to a constant frame rate.
    --
    -- Using a temporary file lets the following FFmpeg command operate
    -- on a known intermediate file.
    local tempVideo = "speed_ramp_source.mp4"

    functions.runFFmpeg(
        "-i \"" .. options.inputVideo .. "\" " ..
        "-map 0:v:0? -map 0:a:0? " ..
        "-c:v libx264 -preset veryfast -crf 18 " ..
        "-c:a aac -b:a 192k " ..
        "-y \"" .. tempVideo .. "\""
    )

    return true
end


function PostCommand(commandIndex, outputResult, errorResult,
                     options, pluginSettings, functions)

    local state = _G.speedRampState

    if state == nil then
        return
    end

    ----------------------------------------------------------------
    -- COMMAND 1
    -- Build the actual ramp.
    ----------------------------------------------------------------
    if commandIndex == 1 then

        local slow = state.slow
        local fast = state.fast
        local mode = state.mode

        local videoFilter
        local audioFilter

        --
        -- Instead of attempting a complicated continuous timewarp,
        -- the effect uses three sections. Each section is processed
        -- independently, then concatenated.
        --

        local firstSpeed
        local middleSpeed
        local lastSpeed

        if mode == 1 then
            -- Slow -> Fast
            firstSpeed = slow
            middleSpeed = slow
            lastSpeed = fast

        elseif mode == 2 then
            -- Fast -> Slow
            firstSpeed = fast
            middleSpeed = fast
            lastSpeed = slow

        elseif mode == 3 then
            -- Slow -> Fast -> Slow
            firstSpeed = slow
            middleSpeed = fast
            lastSpeed = slow

        else
            -- Fast -> Slow -> Fast
            firstSpeed = fast
            middleSpeed = slow
            lastSpeed = fast
        end


        ----------------------------------------------------------------
        -- VIDEO
        --
        -- trim sections are intentionally kept simple and robust.
        -- The exact section duration is based on the input duration.
        --
        -- t=0..33%      section 1
        -- t=33..66%     section 2
        -- t=66..100%    section 3
        ----------------------------------------------------------------

        local vf =
            "split=3[v0][v1][v2];" ..

            "[v0]trim=start=0:end=33.333,setpts=" ..
            videoPTS(firstSpeed) ..
            "[s0];" ..

            "[v1]trim=start=33.333:end=66.666,setpts=" ..
            videoPTS(middleSpeed) ..
            "[s1];" ..

            "[v2]trim=start=66.666,setpts=" ..
            videoPTS(lastSpeed) ..
            "[s2];" ..

            "[s0][s1][s2]concat=n=3:v=1:a=0,setpts=N/FRAME_RATE/TB[v]"

        ----------------------------------------------------------------
        -- AUDIO
        --
        -- If pitch compensation is enabled, atempo keeps pitch closer
        -- to the original instead of simply changing sample rate.
        ----------------------------------------------------------------

        local af

        if state.pitch then

            af =
                "asplit=3[a0][a1][a2];" ..

                "[a0]atrim=start=0:end=33.333," ..
                audioTempo(firstSpeed) ..
                "[aa0];" ..

                "[a1]atrim=start=33.333:end=66.666," ..
                audioTempo(middleSpeed) ..
                "[aa1];" ..

                "[a2]atrim=start=66.666," ..
                audioTempo(lastSpeed) ..
                "[aa2];" ..

                "[aa0][aa1][aa2]concat=n=3:v=0:a=1[a]"

        else

            af =
                "asplit=3[a0][a1][a2];" ..

                "[a0]atrim=start=0:end=33.333," ..
                audioTempo(firstSpeed) ..
                "[aa0];" ..

                "[a1]atrim=start=33.333:end=66.666," ..
                audioTempo(middleSpeed) ..
                "[aa1];" ..

                "[a2]atrim=start=66.666," ..
                audioTempo(lastSpeed) ..
                "[aa2];" ..

                "[aa0][aa1][aa2]concat=n=3:v=0:a=1[a]"
        end


        local filterComplex =
            vf .. ";" .. af


        functions.runFFmpeg(
            "-i \"speed_ramp_source.mp4\" " ..
            "-filter_complex \"" .. filterComplex .. "\" " ..
            "-map \"[v]\" -map \"[a]\" " ..
            "-c:v libx264 " ..
            "-preset veryfast " ..
            "-crf 18 " ..
            "-pix_fmt yuv420p " ..
            "-c:a aac " ..
            "-b:a 192k " ..
            "-movflags +faststart " ..
            "-y \"speed_ramp_result.mp4\""
        )

    ----------------------------------------------------------------
    -- COMMAND 2
    -- Move the finished file into NVG's requested output path.
    ----------------------------------------------------------------
    elseif commandIndex == 2 then

        if functions.fileExists("speed_ramp_result.mp4") then
            functions.fileMove(
                "speed_ramp_result.mp4",
                options.outputVideo
            )
        end
    end
end


function StopGeneration(options, pluginSettings, functions)
    _G.speedRampState = nil
    return true
end
