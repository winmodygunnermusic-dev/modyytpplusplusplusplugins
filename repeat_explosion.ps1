-- Repeat Explosion Effect
-- Nonsensical Video Generator
-- Repeats short segments of the source video with an explosive,
-- stuttering impact using FFmpeg.

local tempVideo = "repeat_explosion_temp.mp4"

function Query(localeName, localizationTokens)
    return {
        ["settings"] = {
            {
                ["name"] = "Display Name",
                ["value"] = "Repeat Explosion",
                ["type"] = "label"
            },
            {
                ["name"] = "Description",
                ["value"] = "Repeatedly punches and repeats short video segments with explosive impact.",
                ["type"] = "label"
            },
            {
                ["name"] = "Explosion Count",
                ["tooltip"] = "Number of repeated explosion hits.",
                ["value"] = "4",
                ["type"] = "int"
            },
            {
                ["name"] = "Explosion Duration",
                ["tooltip"] = "Approximate duration of each repeated hit in seconds.",
                ["value"] = "0.18",
                ["type"] = "float"
            },
            {
                ["name"] = "Intensity",
                ["tooltip"] = "Controls how strongly the repeated hits are emphasized.",
                ["value"] = "75",
                ["type"] = "int"
            },
            {
                ["name"] = "Randomize",
                ["tooltip"] = "Randomizes the timing of each explosion hit.",
                ["value"] = "1",
                ["type"] = "bool"
            }
        }
    }
end

function StartGeneration(options, pluginSettings, functions)
    if not functions.ffmpegInstalled() then
        print("Repeat Explosion: FFmpeg is not installed.")
        return false
    end

    local count = tonumber(pluginSettings["Explosion Count"]) or 4
    local duration = tonumber(pluginSettings["Explosion Duration"]) or 0.18
    local intensity = tonumber(pluginSettings["Intensity"]) or 75
    local randomize = tonumber(pluginSettings["Randomize"]) or 1

    count = math.max(1, math.min(count, 12))
    duration = math.max(0.05, math.min(duration, 1.0))
    intensity = math.max(0, math.min(intensity, 100))

    -- Convert the intensity into a small visual punch.
    local zoom = 1.0 + (intensity / 100.0) * 0.18
    local saturation = 1.0 + (intensity / 100.0) * 0.35

    local seed = os.time()
    math.randomseed(seed)

    -- Create a temporary processed copy.
    local filter = string.format(
        "scale=iw*%.3f:ih*%.3f," ..
        "crop=iw/%.3f:ih/%.3f:(iw-iw/%.3f)/2:(ih-ih/%.3f)/2," ..
        "eq=saturation=%.3f",
        zoom,
        zoom,
        zoom,
        zoom,
        zoom,
        zoom,
        saturation
    )

    -- The base pass creates the visual punch.
    functions.runFFmpeg(
        "-i \"" .. options.inputVideo .. "\" " ..
        "-vf \"" .. filter .. "\" " ..
        "-an -c:v libx264 -preset veryfast -pix_fmt yuv420p " ..
        "-y \"" .. tempVideo .. "\""
    )

    -- Store settings for PostCommand.
    _repeatExplosionCount = count
    _repeatExplosionDuration = duration
    _repeatExplosionRandomize = randomize

    return true
end

function PostCommand(commandIndex, outputResult, errorResult, options, pluginSettings, functions)

    if commandIndex == 1 then

        local count = _repeatExplosionCount or 4
        local duration = _repeatExplosionDuration or 0.18
        local randomize = _repeatExplosionRandomize or 1

        local parts = {}

        -- Original video is included first.
        table.insert(parts, "[0:v]")

        -- Build repeated short sections.
        --
        -- Each iteration extracts the beginning of the temporary clip
        -- and loops it for a short explosion-like burst.
        for i = 1, count do
            local startTime = 0

            if randomize == 1 then
                -- Keep the random offset small so the effect remains usable.
                startTime = math.random(0, 70) / 100
            end

            local label = "e" .. tostring(i)

            table.insert(parts,
                string.format(
                    "[0:v]trim=start=%.2f:duration=%.3f," ..
                    "setpts=PTS-STARTPTS[%s]",
                    startTime,
                    duration,
                    label
                )
            )
        end

        -- Build a concat sequence.
        local concatInputs = {}

        -- Use the original video as the first segment.
        table.insert(concatInputs, "[0:v]")

        for i = 1, count do
            table.insert(concatInputs, "[e" .. tostring(i) .. "]")
            table.insert(concatInputs, "[0:v]")
        end

        local concat = table.concat(concatInputs, "")

        local filterComplex =
            table.concat(parts, ";") ..
            ";" ..
            concat ..
            string.format(
                "concat=n=%d:v=1:a=0[outv]",
                1 + (count * 2)
            )

        functions.runFFmpeg(
            "-i \"" .. options.inputVideo .. "\" " ..
            "-filter_complex \"" .. filterComplex .. "\" " ..
            "-map \"[outv]\" " ..
            "-an -c:v libx264 -preset veryfast -pix_fmt yuv420p " ..
            "-y \"" .. options.outputVideo .. "\""
        )

    elseif commandIndex == 2 then
        -- Cleanup temporary file if it exists.
        if functions.fileExists(tempVideo) then
            functions.fileDelete(tempVideo)
        end
    end
end

function StopGeneration(options, pluginSettings, functions)
    if functions.fileExists(tempVideo) then
        functions.fileDelete(tempVideo)
    end

    return true
end
