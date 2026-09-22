--[[
    Trailing Reverses Effect
    Nonsensical Video Generator v1.8.1.2
    Workshop Addon

    Effect:
      Creates a trailing reverse-video echo behind the current frame.
      Recent frames are sampled backwards and blended behind the main frame.

    Intended for:
      Meme edits
      YTP-style videos
      Glitch edits
      Motion trails
      Rewind / reverse transitions

    Note:
      This addon is written as a self-contained NVG-style effect definition.
      If your NVG build uses different workshop callback names, adapt the
      registration/render functions to that API.
]]

local Effect = {}

Effect.Name = "Trailing Reverses Effect"
Effect.ID = "trailing_reverses"
Effect.Version = "1.0.0"
Effect.Author = "Generated NVG Workshop Addon"
Effect.Description =
    "Leaves progressively reversed frame echoes trailing behind the current frame."

------------------------------------------------------------
-- Default settings
------------------------------------------------------------

Effect.Settings = {
    TrailLength = 5,
    TrailSpacing = 2,
    ReverseAmount = 1.0,
    TrailOpacity = 0.55,
    Fade = true,
    BlendMode = "screen",
    Jitter = 0.0,
    PingPong = false,
    FreezeMainFrame = false
}

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

local function safeNumber(value, fallback)
    value = tonumber(value)

    if value == nil then
        return fallback
    end

    return value
end

------------------------------------------------------------
-- Settings
------------------------------------------------------------

function Effect:GetSettings()
    return {
        {
            id = "TrailLength",
            name = "Trail Length",
            type = "slider",
            min = 1,
            max = 16,
            default = 5
        },

        {
            id = "TrailSpacing",
            name = "Reverse Trail Spacing",
            type = "slider",
            min = 1,
            max = 12,
            default = 2
        },

        {
            id = "ReverseAmount",
            name = "Reverse Amount",
            type = "slider",
            min = 0,
            max = 1,
            default = 1.0
        },

        {
            id = "TrailOpacity",
            name = "Trail Opacity",
            type = "slider",
            min = 0,
            max = 1,
            default = 0.55
        },

        {
            id = "Fade",
            name = "Fade Trail",
            type = "checkbox",
            default = true
        },

        {
            id = "BlendMode",
            name = "Blend Mode",
            type = "dropdown",
            options = {
                "normal",
                "screen",
                "add",
                "lighten"
            },
            default = "screen"
        },

        {
            id = "Jitter",
            name = "Trail Jitter",
            type = "slider",
            min = 0,
            max = 20,
            default = 0
        },

        {
            id = "PingPong",
            name = "Ping-Pong Reverse",
            type = "checkbox",
            default = false
        },

        {
            id = "FreezeMainFrame",
            name = "Freeze Main Frame",
            type = "checkbox",
            default = false
        }
    }
end

------------------------------------------------------------
-- Frame index calculation
------------------------------------------------------------

local function getReverseFrameIndex(currentFrame, offset, totalFrames)
    local index = currentFrame - offset

    if index >= 0 then
        return index
    end

    -- Wrap around so the effect also works on short clips.
    if totalFrames > 0 then
        index = index % totalFrames
    end

    return index
end

------------------------------------------------------------
-- Main effect
------------------------------------------------------------

function Effect:Process(context, settings)

    settings = settings or self.Settings

    local currentFrame =
        safeNumber(context.currentFrame, 0)

    local totalFrames =
        safeNumber(context.totalFrames, 1)

    local trailLength =
        math.floor(
            clamp(
                safeNumber(settings.TrailLength, 5),
                1,
                16
            )
        )

    local spacing =
        math.floor(
            clamp(
                safeNumber(settings.TrailSpacing, 2),
                1,
                12
            )
        )

    local reverseAmount =
        clamp(
            safeNumber(settings.ReverseAmount, 1.0),
            0,
            1
        )

    local opacity =
        clamp(
            safeNumber(settings.TrailOpacity, 0.55),
            0,
            1
        )

    local jitter =
        clamp(
            safeNumber(settings.Jitter, 0),
            0,
            20
        )

    --------------------------------------------------------
    -- Keep the current frame as the base.
    --------------------------------------------------------

    local mainFrame

    if settings.FreezeMainFrame and context.GetPreviousOutput then
        mainFrame = context:GetPreviousOutput()
    else
        mainFrame = context:GetFrame(currentFrame)
    end

    if not mainFrame then
        return context:GetFrame(currentFrame)
    end

    --------------------------------------------------------
    -- Create reverse trails.
    --------------------------------------------------------

    local output = mainFrame

    for trail = 1, trailLength do

        local offset = trail * spacing

        local reverseIndex =
            getReverseFrameIndex(
                currentFrame,
                offset,
                totalFrames
            )

        ----------------------------------------------------
        -- Optional ping-pong behavior.
        ----------------------------------------------------

        if settings.PingPong then
            if trail % 2 == 0 then
                reverseIndex =
                    getReverseFrameIndex(
                        currentFrame,
                        offset * 2,
                        totalFrames
                    )
            end
        end

        local reverseFrame =
            context:GetFrame(reverseIndex)

        if reverseFrame then

            ------------------------------------------------
            -- Older trails become increasingly transparent.
            ------------------------------------------------

            local trailAlpha = opacity

            if settings.Fade then
                trailAlpha =
                    opacity *
                    (1 - ((trail - 1) / trailLength))
            end

            trailAlpha =
                clamp(trailAlpha, 0, 1)

            ------------------------------------------------
            -- Apply reverse amount.
            ------------------------------------------------

            trailAlpha =
                trailAlpha * reverseAmount

            ------------------------------------------------
            -- Optional spatial jitter.
            ------------------------------------------------

            local offsetX = 0
            local offsetY = 0

            if jitter > 0 then
                offsetX =
                    math.random(
                        -math.floor(jitter),
                        math.floor(jitter)
                    )

                offsetY =
                    math.random(
                        -math.floor(jitter),
                        math.floor(jitter)
                    )
            end

            ------------------------------------------------
            -- Blend reversed frame behind current output.
            ------------------------------------------------

            if context.BlendFrame then

                output =
                    context:BlendFrame(
                        output,
                        reverseFrame,
                        trailAlpha,
                        settings.BlendMode or "screen",
                        offsetX,
                        offsetY
                    )

            elseif context.Composite then

                output =
                    context:Composite(
                        output,
                        reverseFrame,
                        trailAlpha,
                        offsetX,
                        offsetY
                    )
            end
        end
    end

    return output
end

------------------------------------------------------------
-- Optional frame-by-frame callback
------------------------------------------------------------

function Effect:OnFrame(context, settings)
    return self:Process(context, settings)
end

------------------------------------------------------------
-- Workshop registration
------------------------------------------------------------

if NVG and NVG.RegisterEffect then

    NVG:RegisterEffect({
        id = Effect.ID,
        name = Effect.Name,
        version = Effect.Version,
        author = Effect.Author,
        description = Effect.Description,
        settings = Effect:GetSettings(),

        process = function(context, settings)
            return Effect:Process(context, settings)
        end,

        onFrame = function(context, settings)
            return Effect:OnFrame(context, settings)
        end
    })

end

return Effect