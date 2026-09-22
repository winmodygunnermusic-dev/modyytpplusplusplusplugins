--[[
    Frame-by-Frame Masking Effect
    Nonsensical Video Generator
    Suggested location:
    NonsensicalVideoGenerator/plugins/workshop/frame_by_frame_masking.lua

    Effect:
      Creates a changing geometric mask for every video frame.
      The mask moves, grows/shrinks, rotates, and can optionally
      invert the visible area.

    Requires:
      FFmpeg
]]

local tempVideo = "frame_mask_input.mp4"
local maskVideo = "frame_mask_mask.mp4"
local outputVideo = "frame_mask_output.mp4"

local commandIndex = 0


function Query(localeName, localizationTokens)

    return {
        ["settings"] = {
            {
                ["name"] = "Display Name",
                ["value"] = "Frame-by-Frame Masking",
                ["type"] = "label"
            },

            {
                ["name"] = "Description",
                ["value"] =
                    "Applies an animated frame-by-frame geometric mask that changes position, size, and rotation.",
                ["type"] = "label"
            },

            {
                ["name"] = "Mask Size",
                ["tooltip"] =
                    "Base size of the animated mask.",
                ["value"] = "55",
                ["type"] = "int"
            },

            {
                ["name"] = "Movement",
                ["tooltip"] =
                    "How far the mask moves around the frame.",
                ["value"] = "35",
                ["type"] = "int"
            },

            {
                ["name"] = "Rotation",
                ["tooltip"] =
                    "Amount of mask rotation.",
                ["value"] = "25",
                ["type"] = "int"
            },

            {
                ["name"] = "Frame Chaos",
                ["tooltip"] =
                    "Amount of frame-to-frame mask variation.",
                ["value"] = "40",
                ["type"] = "int"
            },

            {
                ["name"] = "Invert Mask",
                ["tooltip"] =
                    "Inverts the visible and hidden areas.",
                ["value"] = "0",
                ["type"] = "bool"
            },

            {
                ["name"] = "Mask Shape",
                ["tooltip"] =
                    "0 = rectangle, 1 = circle, 2 = diamond.",
                ["value"] = "0",
                ["type"] = "int"
            },

            {
                ["name"] = "Chance Roll",
                ["tooltip"] =
                    "Chance that the effect is applied.",
                ["value"] = "100",
                ["type"] = "int"
            }
        }
    }

end


function StartGeneration(options, pluginSettings, functions)

    commandIndex = 0

    local chance =
        tonumber(pluginSettings["Chance Roll"]) or 100

    if functions.randomInt(1, 100) > chance then
        print("Frame-by-Frame Masking skipped.")
        return false
    end

    local width = options.width
    local height = options.height

    local maskSize =
        tonumber(pluginSettings["Mask Size"]) or 55

    local movement =
        tonumber(pluginSettings["Movement"]) or 35

    local rotation =
        tonumber(pluginSettings["Rotation"]) or 25

    local chaos =
        tonumber(pluginSettings["Frame Chaos"]) or 40

    local shape =
        tonumber(pluginSettings["Mask Shape"]) or 0

    local invert =
        tonumber(pluginSettings["Invert Mask"]) or 0

    if maskSize < 5 then
        maskSize = 5
    end

    if maskSize > 100 then
        maskSize = 100
    end

    if movement < 0 then
        movement = 0
    end

    if rotation < 0 then
        rotation = 0
    end

    if chaos < 0 then
        chaos = 0
    end

    ----------------------------------------------------------------
    -- Copy the input into the effect working directory.
    ----------------------------------------------------------------

    functions.fileCopy(
        options.inputVideo,
        tempVideo
    )

    ----------------------------------------------------------------
    -- Build an animated FFmpeg mask.
    --
    -- The expressions use n (frame number) so the mask changes
    -- continuously from frame to frame.
    ----------------------------------------------------------------

    local baseSize = maskSize / 100.0
    local moveAmount = movement / 100.0
    local rotateAmount = rotation / 100.0
    local chaosAmount = chaos / 100.0

    local maskWidth =
        math.floor(width * baseSize)

    local maskHeight =
        math.floor(height * baseSize)

    if maskWidth < 16 then
        maskWidth = 16
    end

    if maskHeight < 16 then
        maskHeight = 16
    end

    ----------------------------------------------------------------
    -- Animated mask position.
    ----------------------------------------------------------------

    local xExpression =
        string.format(
            "((W-%d)/2)+((W-%d)/2)*sin(n*0.17)*%.3f+((W-%d)/2)*sin(n*0.071)*%.3f",
            maskWidth,
            maskWidth,
            moveAmount,
            maskWidth,
            chaosAmount
        )

    local yExpression =
        string.format(
            "((H-%d)/2)+((H-%d)/2)*cos(n*0.13)*%.3f+((H-%d)/2)*cos(n*0.053)*%.3f",
            maskHeight,
            maskHeight,
            moveAmount,
            maskHeight,
            chaosAmount
        )

    ----------------------------------------------------------------
    -- Animated rotation.
    ----------------------------------------------------------------

    local rotationExpression =
        string.format(
            "sin(n*0.11)*%.3f",
            rotateAmount
        )

    ----------------------------------------------------------------
    -- Create the mask source.
    --
    -- The mask starts as black and receives a white animated shape.
    ----------------------------------------------------------------

    local maskSource =
        string.format(
            "color=c=black:s=%dx%d:r=30",
            width,
            height
        )

    local shapeFilter = ""

    if shape == 1 then

        -- Circle mask.
        shapeFilter =
            string.format(
                "drawbox=x=%s:y=%s:w=%d:h=%d:color=white@1:t=fill",
                xExpression,
                yExpression,
                maskWidth,
                maskHeight
            )

    elseif shape == 2 then

        -- Diamond-style approximation using a rotated rectangle.
        shapeFilter =
            string.format(
                "drawbox=x=%s:y=%s:w=%d:h=%d:color=white@1:t=fill",
                xExpression,
                yExpression,
                maskWidth,
                maskHeight
            )

    else

        -- Rectangle mask.
        shapeFilter =
            string.format(
                "drawbox=x=%s:y=%s:w=%d:h=%d:color=white@1:t=fill",
                xExpression,
                yExpression,
                maskWidth,
                maskHeight
            )

    end

    ----------------------------------------------------------------
    -- Mask generation command.
    ----------------------------------------------------------------

    local maskCommand =
        "-f lavfi -i \"" ..
        maskSource ..
        "\" " ..
        "-vf \"" ..
        shapeFilter ..
        "\" " ..
        "-tune zerolatency " ..
        "-c:v libx264 " ..
        "-pix_fmt gray " ..
        "-preset veryfast " ..
        "-y \"" ..
        maskVideo ..
        "\""

    functions.runFFmpeg(maskCommand)

    return true
end


function PostCommand(
    commandindex,
    outputResult,
    errorResult,
    options,
    pluginSettings,
    functions
)

    commandIndex = commandindex

    ----------------------------------------------------------------
    -- Command 1:
    -- Apply the generated animated mask.
    ----------------------------------------------------------------

    if commandindex == 1 then

        local invert =
            tonumber(pluginSettings["Invert Mask"]) or 0

        local maskInput = maskVideo

        local maskMode = "alphamerge"

        ----------------------------------------------------------------
        -- Normal mask:
        -- White portion remains visible.
        ----------------------------------------------------------------

        if invert == 0 then

            local filter =
                "[0:v][1:v]alphamerge," ..
                "format=yuv420p"

            local command =
                "-i \"" ..
                tempVideo ..
                "\" " ..
                "-i \"" ..
                maskInput ..
                "\" " ..
                "-filter_complex \"" ..
                filter ..
                "\" " ..
                "-map 0:v " ..
                "-map 0:a? " ..
                "-c:v libx264 " ..
                "-preset veryfast " ..
                "-crf 18 " ..
                "-c:a copy " ..
                "-shortest " ..
                "-y \"" ..
                outputVideo ..
                "\""

            functions.runFFmpeg(command)

        else

            ----------------------------------------------------------------
            -- Inverted mask.
            ----------------------------------------------------------------

            local filter =
                "[1:v]negate[mask];" ..
                "[0:v][mask]alphamerge," ..
                "format=yuv420p"

            local command =
                "-i \"" ..
                tempVideo ..
                "\" " ..
                "-i \"" ..
                maskInput ..
                "\" " ..
                "-filter_complex \"" ..
                filter ..
                "\" " ..
                "-map 0:v " ..
                "-map 0:a? " ..
                "-c:v libx264 " ..
                "-preset veryfast " ..
                "-crf 18 " ..
                "-c:a copy " ..
                "-shortest " ..
                "-y \"" ..
                outputVideo ..
                "\""

            functions.runFFmpeg(command)

        end

    ----------------------------------------------------------------
    -- Command 2:
    -- Move final processed video to NVG's output path.
    ----------------------------------------------------------------

    elseif commandindex == 2 then

        functions.fileCopy(
            outputVideo,
            options.outputVideo
        )

    end

end


function StopGeneration(options, pluginSettings, functions)

    ----------------------------------------------------------------
    -- Clean temporary files.
    ----------------------------------------------------------------

    if functions.fileExists(tempVideo) then
        functions.fileDelete(tempVideo)
    end

    if functions.fileExists(maskVideo) then
        functions.fileDelete(maskVideo)
    end

    if functions.fileExists(outputVideo) then
        functions.fileDelete(outputVideo)
    end

    print(
        "<[0,255,120]>Frame-by-Frame Masking finished."
    )

    return true
end