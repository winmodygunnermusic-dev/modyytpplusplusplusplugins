--[[
    Sentence Mixing Effect
    Nonsensical Video Generator
    File: sentence_mixing.lua

    YTP-style sentence mixing:
      - Randomly cuts the source audio into chunks
      - Rearranges the chunks
      - Optional reverse chunks
      - Optional stutter/repeat chunks
      - Configurable chaos amount
      - Keeps the original video stream
]]

function Query(localeName, localizationTokens)
    return {
        ["settings"] = {
            {
                ["name"] = "Display Name",
                ["value"] = "Sentence Mixing",
                ["type"] = "label"
            },
            {
                ["name"] = "Description",
                ["value"] = "Cuts, rearranges, reverses and stutters parts of the source audio for chaotic YTP-style sentence mixing.",
                ["type"] = "label"
            },

            {
                ["name"] = "Chunk Count",
                ["tooltip"] = "Number of audio chunks to create.",
                ["value"] = "8",
                ["type"] = "int"
            },

            {
                ["name"] = "Chaos",
                ["tooltip"] = "How aggressively the chunks are randomized.",
                ["value"] = "70",
                ["type"] = "int"
            },

            {
                ["name"] = "Reverse Chance",
                ["tooltip"] = "Chance for an individual chunk to play backwards.",
                ["value"] = "15",
                ["type"] = "int"
            },

            {
                ["name"] = "Stutter Chance",
                ["tooltip"] = "Chance for an individual chunk to repeat.",
                ["value"] = "20",
                ["type"] = "int"
            },

            {
                ["name"] = "Stutter Repeats",
                ["tooltip"] = "Maximum number of times a selected chunk can repeat.",
                ["value"] = "3",
                ["type"] = "int"
            },

            {
                ["name"] = "Minimum Chunk",
                ["tooltip"] = "Minimum chunk duration in seconds.",
                ["value"] = "0.12",
                ["type"] = "float"
            },

            {
                ["name"] = "Maximum Chunk",
                ["tooltip"] = "Maximum chunk duration in seconds.",
                ["value"] = "0.85",
                ["type"] = "float"
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


-- Safely convert a plugin setting to a number
local function settingNumber(pluginSettings, name, defaultValue)
    local value = tonumber(pluginSettings[name])

    if value == nil then
        return defaultValue
    end

    return value
end


function StartGeneration(options, pluginSettings, functions)

    -- Check FFmpeg availability.
    if not functions.ffmpegInstalled() then
        print("<[255,0,0]>Sentence Mixing: FFmpeg is not installed.")
        return false
    end

    local chunkCount =
        math.floor(settingNumber(pluginSettings, "Chunk Count", 8))

    local chaos =
        clamp(
            settingNumber(pluginSettings, "Chaos", 70),
            0,
            100
        )

    local reverseChance =
        clamp(
            settingNumber(pluginSettings, "Reverse Chance", 15),
            0,
            100
        )

    local stutterChance =
        clamp(
            settingNumber(pluginSettings, "Stutter Chance", 20),
            0,
            100
        )

    local stutterRepeats =
        math.floor(
            clamp(
                settingNumber(pluginSettings, "Stutter Repeats", 3),
                1,
                8
            )
        )

    local minimumChunk =
        clamp(
            settingNumber(pluginSettings, "Minimum Chunk", 0.12),
            0.02,
            10
        )

    local maximumChunk =
        clamp(
            settingNumber(pluginSettings, "Maximum Chunk", 0.85),
            minimumChunk,
            10
        )

    chunkCount = clamp(chunkCount, 2, 64)

    -- Store information for PostCommand.
    _sentenceMix = {
        chunkCount = chunkCount,
        chaos = chaos,
        reverseChance = reverseChance,
        stutterChance = stutterChance,
        stutterRepeats = stutterRepeats,
        minimumChunk = minimumChunk,
        maximumChunk = maximumChunk,

        chunks = {},
        order = {},

        input = options.inputVideo,
        output = options.outputVideo
    }

    print("<[0,255,0]>Sentence Mixing: starting effect.")
    print("Chunks: " .. tostring(chunkCount))
    print("Chaos: " .. tostring(chaos) .. "%")

    -- First command:
    -- Probe the source duration.
    functions.runFFprobe(
        "-v error -show_entries format=duration " ..
        "-of default=noprint_wrappers=1:nokey=1 " ..
        "\"" .. options.inputVideo .. "\""
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

    if _sentenceMix == nil then
        print("<[255,0,0]>Sentence Mixing: internal state missing.")
        return
    end


    ------------------------------------------------------------
    -- COMMAND 1
    -- FFprobe returned the duration.
    ------------------------------------------------------------
    if commandIndex == 1 then

        local duration = tonumber(outputResult)

        if duration == nil or duration <= 0 then
            print("<[255,0,0]>Sentence Mixing: unable to determine duration.")
            print(errorResult or "")
            return
        end

        _sentenceMix.duration = duration

        local s = _sentenceMix

        print(
            "<[0,255,0]>Sentence Mixing: source duration = " ..
            string.format("%.3f", duration) ..
            " seconds."
        )


        --------------------------------------------------------
        -- Generate random chunk boundaries.
        --------------------------------------------------------

        local chunkCount = s.chunkCount

        -- Create random cut points.
        local cutPoints = {}

        cutPoints[1] = 0
        cutPoints[chunkCount + 1] = duration

        for i = 2, chunkCount do

            local point = functions.randomDouble(
                0,
                duration
            )

            cutPoints[i] = point
        end

        -- Sort cut points.
        table.sort(cutPoints)


        --------------------------------------------------------
        -- Create usable chunks.
        --------------------------------------------------------

        local chunks = {}

        for i = 1, chunkCount do

            local startTime = cutPoints[i]
            local endTime = cutPoints[i + 1]

            local chunkDuration = endTime - startTime

            -- Reject extremely tiny chunks.
            if chunkDuration >= s.minimumChunk then

                if chunkDuration > s.maximumChunk then
                    chunkDuration = s.maximumChunk
                end

                table.insert(
                    chunks,
                    {
                        index = #chunks + 1,
                        start = startTime,
                        duration = chunkDuration
                    }
                )
            end
        end


        -- If random boundaries produced too few chunks,
        -- fall back to evenly spaced chunks.
        if #chunks < 2 then

            chunks = {}

            local fallbackDuration =
                duration / chunkCount

            for i = 1, chunkCount do

                local startTime =
                    (i - 1) * fallbackDuration

                local chunkDuration =
                    math.min(
                        fallbackDuration,
                        s.maximumChunk
                    )

                if chunkDuration >= s.minimumChunk then

                    table.insert(
                        chunks,
                        {
                            index = i,
                            start = startTime,
                            duration = chunkDuration
                        }
                    )
                end
            end
        end


        s.chunks = chunks


        --------------------------------------------------------
        -- Build randomized order.
        --------------------------------------------------------

        local order = {}

        for i = 1, #chunks do
            order[i] = i
        end


        -- Fisher-Yates shuffle.
        for i = #order, 2, -1 do

            -- Chaos controls how often we actually swap.
            local swapChance =
                s.chaos / 100

            if functions.randomDouble(0, 1) <= swapChance then

                local j =
                    functions.randomInt(1, i)

                order[i], order[j] =
                    order[j], order[i]
            end
        end

        s.order = order


        --------------------------------------------------------
        -- Create each temporary chunk.
        --------------------------------------------------------

        local firstChunk = chunks[1]

        if firstChunk == nil then
            print("<[255,0,0]>Sentence Mixing: no valid chunks.")
            return
        end


        local chunk = firstChunk

        functions.runFFmpeg(
            "-ss " ..
            string.format("%.6f", chunk.start) ..

            " -i \"" ..
            options.inputVideo ..

            "\" -t " ..
            string.format("%.6f", chunk.duration) ..

            " -vn -acodec pcm_s16le -y " ..
            "\"sentence_chunk_1.wav\""
        )

        return
    end


    ------------------------------------------------------------
    -- COMMANDS 2..N
    -- Extract remaining chunks.
    ------------------------------------------------------------

    local s = _sentenceMix

    local chunkCount = #s.chunks

    if commandIndex >= 2 and
       commandIndex <= chunkCount then

        local chunkNumber =
            commandIndex

        local chunk =
            s.chunks[chunkNumber]

        functions.runFFmpeg(
            "-ss " ..
            string.format("%.6f", chunk.start) ..

            " -i \"" ..
            options.inputVideo ..

            "\" -t " ..
            string.format("%.6f", chunk.duration) ..

            " -vn -acodec pcm_s16le -y " ..

            "\"sentence_chunk_" ..
            tostring(chunkNumber) ..
            ".wav\""
        )

        return
    end


    ------------------------------------------------------------
    -- After all chunks have been extracted:
    -- construct the filter graph.
    ------------------------------------------------------------

    local extractionEnd =
        1 + chunkCount - 1

    if commandIndex == extractionEnd then

        local inputs = {}
        local filters = {}
        local concatInputs = {}

        local filterIndex = 0


        for outputPosition = 1, #s.order do

            local sourceIndex =
                s.order[outputPosition]

            local sourceChunk =
                s.chunks[sourceIndex]

            if sourceChunk ~= nil then

                local inputIndex =
                    sourceIndex - 1

                local filterName =
                    "mix" .. tostring(filterIndex)

                local filter =

                    "[" ..
                    tostring(inputIndex) ..
                    ":a]"

                ------------------------------------------------
                -- Optional reverse.
                ------------------------------------------------

                local doReverse =
                    functions.randomInt(1, 100)
                    <= s.reverseChance

                if doReverse then
                    filter =
                        filter ..
                        "areverse,"
                end


                ------------------------------------------------
                -- Optional stutter.
                ------------------------------------------------

                local repeatCount = 1

                if functions.randomInt(1, 100)
                    <= s.stutterChance then

                    repeatCount =
                        functions.randomInt(
                            2,
                            s.stutterRepeats
                        )
                end


                if repeatCount > 1 then

                    filter =
                        filter ..
                        "aloop=loop=" ..
                        tostring(repeatCount - 1) ..
                        ":size=2e+09,"
                end


                filter =
                    filter ..
                    "asetpts=N/SR/TB" ..
                    "[" ..
                    filterName ..
                    "]"

                table.insert(
                    filters,
                    filter
                )

                table.insert(
                    concatInputs,
                    "[" ..
                    filterName ..
                    "]"
                )

                filterIndex =
                    filterIndex + 1
            end
        end


        --------------------------------------------------------
        -- Build FFmpeg input arguments.
        --------------------------------------------------------

        local ffmpegInputs = ""

        for i = 1, #s.chunks do

            ffmpegInputs =
                ffmpegInputs ..
                "-i \"sentence_chunk_" ..
                tostring(i) ..
                ".wav\" "
        end


        if #concatInputs == 0 then

            print(
                "<[255,0,0]>Sentence Mixing: " ..
                "filter graph is empty."
            )

            return
        end


        local filterComplex =
            table.concat(filters, ";") ..
            ";" ..
            table.concat(concatInputs, "") ..

            "concat=n=" ..
            tostring(#concatInputs) ..

            ":v=0:a=1[outa]"


        --------------------------------------------------------
        -- Final render.
        --
        -- Video is copied from the source.
        -- Mixed audio replaces the original audio.
        --------------------------------------------------------

        local command =

            ffmpegInputs ..

            "-i \"" ..
            options.inputVideo ..
            "\" " ..

            "-filter_complex \"" ..
            filterComplex ..
            "\" " ..

            "-map 0:v:0 " ..
            "-map \"[outa]\" " ..

            "-c:v copy " ..
            "-c:a aac " ..
            "-b:a 192k " ..

            "-shortest " ..
            "-y \"" ..
            options.outputVideo ..
            "\""


        print(
            "<[0,255,0]>Sentence Mixing: rendering mixed audio..."
        )

        functions.runFFmpeg(command)

        return
    end


    ------------------------------------------------------------
    -- Final command completed.
    ------------------------------------------------------------

    local finalCommandIndex =
        1 + chunkCount

    if commandIndex == finalCommandIndex then

        print(
            "<[0,255,0]>Sentence Mixing: complete!"
        )

        return
    end

end


function StopGeneration(options, pluginSettings, functions)

    _sentenceMix = nil

    return true
end
