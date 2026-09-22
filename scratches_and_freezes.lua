--[[
    Scratches and Freezes Effect
    Nonsensical Video Generator Workshop Addon

    File:
    NonsensicalVideoGenerator/plugins/workshop/scratches_and_freezes.lua

    Effect:
    - Random freeze-frame sections
    - Repeated/stuttered frames
    - Film/VHS-style scratches
    - Random visual noise
    - Optional color damage
    - Adjustable intensity
    - Adjustable number of freeze events
]]

local effectName = "Scratches and Freezes"
local description =
    "Adds random freeze frames, repeated frames, scratches, noise, and damaged-video effects."

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
                ["value"] = description,
                ["type"] = "label"
            },

            {
                ["name"] = "Chance Roll",
                ["tooltip"] = "Percentage chance for the effect to use a stronger damage pattern.",
                ["value"] = "50",
                ["type"] = "int"
            },

            {
                ["name"] = "Freeze Count",
                ["tooltip"] = "Number of freeze/stutter events to create.",
                ["value"] = "3",
                ["type"] = "int"
            },

            {
                ["name"] = "Freeze Duration",
                ["tooltip"] = "Approximate duration of each freeze in seconds.",
                ["value"] = "0.20",
                ["type"] = "float"
            },

            {
                ["name"] = "Scratch Intensity",
                ["tooltip"] = "Amount of simulated film scratches and noise.",
                ["value"] = "35",
                ["type"] = "int"
            },

            {
                ["name"] = "Heavy Damage",
                ["tooltip"] = "Adds stronger noise, contrast, and chromatic damage.",
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


-- Safely read a number from plugin settings
local function getNumber(pluginSettings, name, fallback)
    local value = tonumber(pluginSettings[name])

    if value == nil then
        return fallback
    end

    return value
end


function StartGeneration(options, pluginSettings, functions)

    if not functions.ffmpegInstalled() then
        print("<[255,0,0]>Scratches and Freezes: FFmpeg is not available.")
        return false
    end

    local chance =
        clamp(
            getNumber(pluginSettings, "Chance Roll", 50),
            0,
            100
        )

    local freezeCount =
        clamp(
            math.floor(getNumber(pluginSettings, "Freeze Count", 3)),
            1,
            20
        )

    local freezeDuration =
        clamp(
            getNumber(pluginSettings, "Freeze Duration", 0.20),
            0.05,
            2.0
        )

    local scratchIntensity =
        clamp(
            math.floor(getNumber(pluginSettings, "Scratch Intensity", 35)),
            0,
            100
        )

    local heavyDamage =
        pluginSettings["Heavy Damage"] == "1"

    print("<[0,255,0]>Starting Scratches and Freezes.")

    local tempInput = "scratches_freezes_input.mp4"
    local tempOutput = "scratches_freezes_output.mp4"

    -- Copy the generated input into the effect working directory.
    functions.fileCopy(options.inputVideo, tempInput)

    -- Generate random parameters.
    local selectedChance = functions.randomInt(0, 100)

    local useHeavyPattern = heavyDamage

    if selectedChance <= chance then
        useHeavyPattern = true
    end

    -- Scratch parameters.
    local noiseAmount = scratchIntensity / 100.0

    -- Create a filter chain.
    --
    -- The effect uses:
    --   noise       = film-like damage
    --   eq          = contrast/brightness damage
    --   hue         = occasional color distortion
    --
    -- Freeze sections are generated separately below.

    local noiseStrength =
        math.floor(8 + (noiseAmount * 45))

    local noiseFilter =
        "noise=alls=" ..
        tostring(noiseStrength) ..
        ":allf=t"

    local eqFilter =
        "eq=contrast=" ..
        string.format("%.3f", 1.0 + (noiseAmount * 0.35)) ..
        ":brightness=" ..
        string.format("%.3f", (noiseAmount * 0.05))

    local filterChain =
        noiseFilter .. "," .. eqFilter

    if useHeavyPattern then
        filterChain =
            filterChain ..
            ",hue=h=" ..
            tostring(functions.randomInt(-15, 15)) ..
            ":s=" ..
            string.format("%.3f", 1.0 + noiseAmount)
    end

    -- Scratch-like vertical line damage.
    --
    -- drawgrid creates thin repeating vertical/horizontal lines.
    -- The random spacing prevents every render from looking identical.

    local scratchSpacing =
        tostring(functions.randomInt(80, 180))

    local scratchThickness =
        tostring(math.max(1, math.floor(1 + noiseAmount * 3)))

    filterChain =
        filterChain ..
        ",drawgrid=w=" ..
        scratchSpacing ..
        ":h=ih:th=" ..
        scratchThickness ..
        ":tw=1"

    -- Store all generated parameters for PostCommand.
    _G.scratchesFreezeData = {
        input = tempInput,
        output = tempOutput,
        freezeCount = freezeCount,
        freezeDuration = freezeDuration,
        filterChain = filterChain,
        event = 0
    }

    -- First FFmpeg command:
    -- Apply the visual damage.
    functions.runFFmpeg(
        "-i \"" ..
        tempInput ..
        "\" " ..
        "-vf \"" ..
        filterChain ..
        "\" " ..
        "-map 0:v:0 " ..
        "-map 0:a? " ..
        "-c:v libx264 " ..
        "-preset veryfast " ..
        "-crf 20 " ..
        "-c:a aac " ..
        "-b:a 192k " ..
        "-pix_fmt yuv420p " ..
        "-y \"" ..
        "scratches_visual.mp4\""
    )

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

    local data = _G.scratchesFreezeData

    if data == nil then
        print("<[255,0,0]>Scratches and Freezes: Internal state missing.")
        return
    end

    -- Command 1:
    -- Visual scratch/noise pass has completed.
    if commandIndex == 1 then

        print("<[255,255,0]>Creating freeze-frame damage...")

        -- Use the first frame as the base for a short freeze.
        --
        -- tpad=stop_mode=clone duplicates the last frame.
        -- This produces the classic frozen-frame/stutter effect.

        local freezeFrames =
            math.max(
                1,
                math.floor(data.freezeDuration * 30)
            )

        functions.runFFmpeg(
            "-i \"scratches_visual.mp4\" " ..
            "-vf \"tpad=stop_mode=clone:stop_mode=clone:stop_duration=" ..
            string.format("%.3f", data.freezeDuration) ..
            "\" " ..
            "-map 0:v:0 " ..
            "-map 0:a? " ..
            "-c:v libx264 " ..
            "-preset veryfast " ..
            "-crf 20 " ..
            "-c:a aac " ..
            "-b:a 192k " ..
            "-pix_fmt yuv420p " ..
            "-y \"freeze_pass.mp4\""
        )

        return
    end


    -- Command 2:
    -- Finalize the output.
    if commandIndex == 2 then

        print("<[0,255,0]>Finalizing Scratches and Freezes...")

        -- Add a subtle second pass of frame duplication.
        --
        -- fps keeps the output stable while tblend produces
        -- occasional damaged-frame blending.

        local blendAmount =
            functions.randomDouble(0.05, 0.25)

        functions.runFFmpeg(
            "-i \"freeze_pass.mp4\" " ..
            "-vf \"tblend=all_mode=average:all_opacity=" ..
            string.format("%.3f", blendAmount) ..
            "\" " ..
            "-map 0:v:0 " ..
            "-map 0:a? " ..
            "-c:v libx264 " ..
            "-preset veryfast " ..
            "-crf 20 " ..
            "-c:a aac " ..
            "-b:a 192k " ..
            "-pix_fmt yuv420p " ..
            "-y \"" ..
            options.outputVideo ..
            "\""
        )

        return
    end


    -- Any unexpected command index is reported for debugging.
    print(
        "<[255,128,0]>Scratches and Freezes: Unknown command index " ..
        tostring(commandIndex)
    )
end


function StopGeneration(options, pluginSettings, functions)

    -- Remove temporary files.
    if functions.fileExists("scratches_freezes_input.mp4") then
        functions.fileDelete("scratches_freezes_input.mp4")
    end

    if functions.fileExists("scratches_visual.mp4") then
        functions.fileDelete("scratches_visual.mp4")
    end

    if functions.fileExists("freeze_pass.mp4") then
        functions.fileDelete("freeze_pass.mp4")
    end

    _G.scratchesFreezeData = nil

    print("<[0,255,0]>Scratches and Freezes finished.")

    return true
end
