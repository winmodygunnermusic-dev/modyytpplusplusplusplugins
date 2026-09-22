--[[
    Boom Effect
    Nonsensical Video Generator
    Generated Workshop Effect

    Effect:
      - Random BOOM impact moments
      - Short zoom punch
      - Camera shake
      - Brightness/contrast flash
      - Optional color punch
      - Audio impact support
      - Designed as a meme / YTP-style effect

    File:
      boom_effect.lua
]]

local addon = {}

addon.name = "Boom Effect"
addon.author = "Generated NVG Addon"
addon.description = "Adds explosive BOOM-style visual and audio impact moments."

----------------------------------------------------------------
-- Configuration
----------------------------------------------------------------

local settings = {
    chance = 50,          -- Chance out of 100
    intensity = 75,       -- Overall effect strength
    shake = 80,           -- Camera shake
    zoom = 70,            -- Zoom punch
    flash = 65,           -- Brightness flash
    contrast = 60,        -- Contrast punch
    audio = 80,           -- Audio impact strength
    duration = 0.18,      -- Approximate impact duration
    randomize = true
}

----------------------------------------------------------------
-- Utility
----------------------------------------------------------------

local function clamp(value, minimum, maximum)
    if value < minimum then
        return minimum
    end

    if value > maximum then
        return maximum
    end

    return value
end

local function randomRange(minimum, maximum)
    return minimum + math.random() * (maximum - minimum)
end

local function randomSign()
    if math.random(0, 1) == 0 then
        return -1
    end

    return 1
end

----------------------------------------------------------------
-- Query
--
-- NVG Workshop effects can expose their required libraries and
-- settings through Query().
----------------------------------------------------------------

function addon.Query()
    return {
        name = addon.name,
        description = addon.description,

        -- Boom Effect does not require an external NVG library.
        libraries = {},

        settings = {
            {
                name = "Chance Roll",
                type = "number",
                default = settings.chance,
                minimum = 0,
                maximum = 100
            },

            {
                name = "Intensity",
                type = "number",
                default = settings.intensity,
                minimum = 0,
                maximum = 100
            },

            {
                name = "Shake",
                type = "number",
                default = settings.shake,
                minimum = 0,
                maximum = 100
            },

            {
                name = "Zoom",
                type = "number",
                default = settings.zoom,
                minimum = 0,
                maximum = 100
            },

            {
                name = "Flash",
                type = "number",
                default = settings.flash,
                minimum = 0,
                maximum = 100
            },

            {
                name = "Contrast",
                type = "number",
                default = settings.contrast,
                minimum = 0,
                maximum = 100
            },

            {
                name = "Audio",
                type = "number",
                default = settings.audio,
                minimum = 0,
                maximum = 100
            }
        }
    }
end

----------------------------------------------------------------
-- Create a BOOM impact description
----------------------------------------------------------------

local function createBoom(level)
    local strength = level / 100

    local boom = {
        intensity = strength,

        zoom = 1.0 + (0.04 * strength),

        shakeX =
            randomSign() *
            randomRange(0.005, 0.035) *
            strength,

        shakeY =
            randomSign() *
            randomRange(0.005, 0.035) *
            strength,

        rotation =
            randomSign() *
            randomRange(0.2, 1.8) *
            strength,

        flash =
            1.0 + (0.45 * strength),

        contrast =
            1.0 + (0.65 * strength),

        saturation =
            1.0 + (0.30 * strength),

        duration = settings.duration
    }

    return boom
end

----------------------------------------------------------------
-- Apply Boom Effect
--
-- The exact frame/filter helper names can vary between NVG
-- versions/templates. This function keeps the effect logic
-- isolated so it can be adapted to the generated NVG template.
----------------------------------------------------------------

function addon.Apply(context)
    if context == nil then
        return context
    end

    local chance = clamp(settings.chance, 0, 100)

    if math.random(1, 100) > chance then
        return context
    end

    local level = clamp(settings.intensity, 0, 100)

    if settings.randomize then
        level = clamp(
            level + randomRange(-15, 15),
            0,
            100
        )
    end

    local boom = createBoom(level)

    ------------------------------------------------------------
    -- Visual impact
    ------------------------------------------------------------

    if context.video then
        context.video.zoom =
            (context.video.zoom or 1.0) *
            boom.zoom

        context.video.offsetX =
            (context.video.offsetX or 0) +
            boom.shakeX *
            (settings.shake / 100)

        context.video.offsetY =
            (context.video.offsetY or 0) +
            boom.shakeY *
            (settings.shake / 100)

        context.video.rotation =
            (context.video.rotation or 0) +
            boom.rotation *
            (settings.shake / 100)

        context.video.brightness =
            (context.video.brightness or 1.0) +
            (boom.flash - 1.0) *
            (settings.flash / 100)

        context.video.contrast =
            (context.video.contrast or 1.0) *
            (
                1.0 +
                (boom.contrast - 1.0) *
                (settings.contrast / 100)
            )

        context.video.saturation =
            (context.video.saturation or 1.0) *
            boom.saturation
    end

    ------------------------------------------------------------
    -- Audio impact
    ------------------------------------------------------------

    if context.audio then
        context.audio.gain =
            (context.audio.gain or 1.0) *
            (
                1.0 +
                (settings.audio / 100) * 0.65
            )

        context.audio.boom =
            true

        context.audio.boomIntensity =
            level / 100
    end

    ------------------------------------------------------------
    -- Metadata for templates / render stages
    ------------------------------------------------------------

    context.boomEffect = {
        enabled = true,
        intensity = level,
        duration = boom.duration,
        zoom = boom.zoom,
        shakeX = boom.shakeX,
        shakeY = boom.shakeY,
        rotation = boom.rotation,
        flash = boom.flash,
        contrast = boom.contrast,
        saturation = boom.saturation
    }

    return context
end

----------------------------------------------------------------
-- Optional helper for template-based NVG integrations
----------------------------------------------------------------

function addon.GetBoomParameters()
    local level = clamp(settings.intensity, 0, 100)

    return createBoom(level)
end

----------------------------------------------------------------
-- Effect entry point
----------------------------------------------------------------

function addon.Run(context)
    return addon.Apply(context)
end

return addon
