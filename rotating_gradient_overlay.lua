-- Rotating Gradient Overlay Effect
-- Nonsensical Video Generator
-- Addon type: Effect
--
-- Applies a continuously rotating gradient overlay.
-- The gradient angle changes over time, producing a moving
-- rainbow/duotone-style wash over the rendered video.

local function clamp(value, minimum, maximum)
    if value < minimum then
        return minimum
    end

    if value > maximum then
        return maximum
    end

    return value
end

function Query()
    return {
        ["name"] = "Rotating Gradient Overlay",
        ["settings"] = {
            {
                ["name"] = "Display Name",
                ["value"] = "Rotating Gradient Overlay",
                ["type"] = "label"
            },
            {
                ["name"] = "Description",
                ["value"] = "Adds a continuously rotating colored gradient overlay.",
                ["type"] = "label"
            },
            {
                ["name"] = "Opacity",
                ["tooltip"] = "Strength of the gradient overlay.",
                ["value"] = "45",
                ["type"] = "int"
            },
            {
                ["name"] = "Rotation Speed",
                ["tooltip"] = "How quickly the gradient rotates.",
                ["value"] = "90",
                ["type"] = "int"
            },
            {
                ["name"] = "Gradient Width",
                ["tooltip"] = "Width of the gradient transition.",
                ["value"] = "1.0",
                ["type"] = "float"
            },
            {
                ["name"] = "Color 1",
                ["tooltip"] = "First gradient color in hexadecimal RGB format.",
                ["value"] = "FF00FF",
                ["type"] = "string"
            },
            {
                ["name"] = "Color 2",
                ["tooltip"] = "Second gradient color in hexadecimal RGB format.",
                ["value"] = "00FFFF",
                ["type"] = "string"
            }
        },

        ["libraries"] = {}
    }
end

-- Safely obtain a setting value.
local function getSetting(settings, name, default)
    if settings == nil then
        return default
    end

    local value = settings[name]

    if value == nil then
        return default
    end

    return value
end

-- Convert a hexadecimal color into normalized RGB.
local function hexToRGB(hex)
    hex = tostring(hex or ""):gsub("#", "")

    if #hex ~= 6 then
        return 1.0, 0.0, 1.0
    end

    local r = tonumber(hex:sub(1, 2), 16)
    local g = tonumber(hex:sub(3, 4), 16)
    local b = tonumber(hex:sub(5, 6), 16)

    if not r or not g or not b then
        return 1.0, 0.0, 1.0
    end

    return r / 255.0, g / 255.0, b / 255.0
end

-- Main effect.
--
-- The exact effect/FFmpeg command interface can vary between NVG
-- versions. This implementation uses the standard addon structure
-- and constructs the filter expression for the NVG render pipeline.
function Effect(context)
    local settings = context.settings or {}

    local opacity = tonumber(getSetting(settings, "Opacity", 45)) or 45
    local speed = tonumber(getSetting(settings, "Rotation Speed", 90)) or 90
    local width = tonumber(getSetting(settings, "Gradient Width", 1.0)) or 1.0

    opacity = clamp(opacity, 0, 100)
    speed = clamp(speed, -1000, 1000)
    width = math.max(width, 0.05)

    local color1 = getSetting(settings, "Color 1", "FF00FF")
    local color2 = getSetting(settings, "Color 2", "00FFFF")

    local r1, g1, b1 = hexToRGB(color1)
    local r2, g2, b2 = hexToRGB(color2)

    local alpha = opacity / 100.0

    -- Time-based rotation.
    --
    -- The angle changes continuously according to frame time.
    -- A 90-degree speed corresponds to approximately one quarter
    -- rotation per second.
    local rotationExpression =
        string.format(
            "(%0.6f*t)",
            speed * math.pi / 180.0
        )

    -- Build a dynamic radial-style gradient.
    --
    -- The expressions are deliberately kept independent of the
    -- source dimensions so the effect can work on arbitrary video
    -- resolutions.
    local xExpression =
        string.format(
            "(0.5+0.5*cos(atan2(Y-H/2,X-W/2)-%s))",
            rotationExpression
        )

    local mixExpression =
        string.format(
            "clip(%s/%0.6f,0,1)",
            xExpression,
            width
        )

    local red =
        string.format(
            "(%0.6f*(1-(%s)) + %0.6f*(%s))",
            r1,
            mixExpression,
            r2,
            mixExpression
        )

    local green =
        string.format(
            "(%0.6f*(1-(%s)) + %0.6f*(%s))",
            g1,
            mixExpression,
            g2,
            mixExpression
        )

    local blue =
        string.format(
            "(%0.6f*(1-(%s)) + %0.6f*(%s))",
            b1,
            mixExpression,
            b2,
            mixExpression
        )

    local filter =
        string.format(
            "format=rgba," ..
            "geq=" ..
            "r='r*(1-%0.6f)+255*(%s)*%0.6f':" ..
            "g='g*(1-%0.6f)+255*(%s)*%0.6f':" ..
            "b='b*(1-%0.6f)+255*(%s)*%0.6f':" ..
            "a='255'",
            alpha,
            red,
            alpha,
            alpha,
            green,
            alpha,
            alpha,
            blue,
            alpha
        )

    return {
        ["video"] = filter
    }
end