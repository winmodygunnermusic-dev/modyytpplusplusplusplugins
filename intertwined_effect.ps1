--[[
    Intertwined Effect
    Nonsensical Video Generator
    Generated NVG Workshop Effect

    Effect:
        Intertwines two horizontally shifted versions of the
        source video to create a warped / woven / twisted look.

    File:
        intertwined_effect.lua

    Suggested folder:
        NonsensicalVideoGenerator\plugins\workshop\intertwined_effect\
]]

local effectName = "Intertwined"

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
                ["value"] = "Creates an intertwined woven effect by blending horizontally shifted copies of the video.",
                ["type"] = "label"
            },

            {
                ["name"] = "Shift",
                ["tooltip"] = "Horizontal pixel displacement used to intertwine the image.",
                ["value"] = "18",
                ["type"] = "int"
            },

            {
                ["name"] = "Blend",
                ["tooltip"] = "Blend strength between the original and shifted image.",
                ["value"] = "0.50",
                ["type"] = "float"
            },

            {
                ["name"] = "Wave",
                ["tooltip"] = "Amount of vertical wave distortion.",
                ["value"] = "10",
                ["type"] = "int"
            },

            {
                ["name"] = "Wave Length",
                ["tooltip"] = "Length of the horizontal wave pattern.",
                ["value"] = "90",
                ["type"] = "int"
            },

            {
                ["name"] = "Mirror",
                ["tooltip"] = "Adds a mirrored copy to the intertwined image.",
                ["value"] = "0",
                ["type"] = "bool"
            }
        }
    }
end


function StartGeneration(options, pluginSettings, functions)

    local input = options.inputVideo
    local output = options.outputVideo

    local shift = tonumber(pluginSettings["Shift"]) or 18
    local blend = tonumber(pluginSettings["Blend"]) or 0.50
    local wave = tonumber(pluginSettings["Wave"]) or 10
    local waveLength = tonumber(pluginSettings["Wave Length"]) or 90

    if shift < 0 then
        shift = 0
    end

    if blend < 0 then
        blend = 0
    end

    if blend > 1 then
        blend = 1
    end

    if wave < 0 then
        wave = 0
    end

    if waveLength < 1 then
        waveLength = 1
    end

    local mirror = pluginSettings["Mirror"] == "1"

    -- Keep generated intermediate files inside the NVG effect
    -- working directory.
    local intertwined = "intertwined_intermediate.mp4"

    -- Build the displacement expression.
    --
    -- Two copies are created:
    --   1. original
    --   2. horizontally shifted/waved copy
    --
    -- They are then blended together.
    local waveExpression =
        "x+" ..
        tostring(shift) ..
        "*sin(y/" ..
        tostring(waveLength) ..
        "*6.28318)"

    local filter

    if mirror then

        filter =
            "[0:v]split=3[a][b][c];" ..
            "[a]format=rgba[base];" ..
            "[b]hflip,format=rgba[mir];" ..
            "[c]format=rgba," ..
            "geq=" ..
            "lum='lum(X,Y)':" ..
            "cb='cb(X,Y)':" ..
            "cr='cr(X,Y)'[wave];" ..
            "[wave]geq=" ..
            "lum='lum(" .. waveExpression .. ",Y)':" ..
            "cb='cb(" .. waveExpression .. ",Y)':" ..
            "cr='cr(" .. waveExpression .. ",Y)'[shifted];" ..
            "[base][shifted]blend=all_mode=addition:" ..
            "all_opacity=" .. tostring(blend) .. "[mix];" ..
            "[mix][mir]blend=all_mode=screen:" ..
            "all_opacity=0.25," ..
            "format=yuv420p[out]"

    else

        filter =
            "[0:v]split=2[base][wave];" ..
            "[wave]format=rgba," ..
            "geq=" ..
            "lum='lum(" .. waveExpression .. ",Y)':" ..
            "cb='cb(" .. waveExpression .. ",Y)':" ..
            "cr='cr(" .. waveExpression .. ",Y)'[shifted];" ..
            "[base][shifted]blend=all_mode=addition:" ..
            "all_opacity=" .. tostring(blend) .. "," ..
            "format=yuv420p[out]"
    end

    local command =
        "-i \"" .. input .. "\" " ..
        "-filter_complex \"" .. filter .. "\" " ..
        "-map \"[out]\" " ..
        "-map 0:a? " ..
        "-c:v libx264 " ..
        "-preset veryfast " ..
        "-crf 18 " ..
        "-c:a aac " ..
        "-b:a 192k " ..
        "-shortest " ..
        "-y \"" .. output .. "\""

    functions.runFFmpeg(command)

    return true
end


function PostCommand(commandIndex, outputResult, errorResult,
                     options, pluginSettings, functions)

    if commandIndex == 1 then

        if errorResult ~= nil and errorResult ~= "" then
            print("<[255,80,80]>Intertwined Effect FFmpeg error:")
            print(errorResult)
        else
            print("<[100,255,150]>Intertwined Effect finished successfully.")
        end

    end

    return nil
end


function StopGeneration(options, pluginSettings, functions)

    print("<[150,200,255]>Intertwined Effect stopped.")

    return true
end
