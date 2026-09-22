--[[
    SpaDinner.lua
    Nonsensical Video Generator v1.8.1.2
    Workshop Addon

    Effect: SpaDinner / Dinner-Spaghetti YTP style

    Style:
      - Rapid meme-style cuts
      - Repeated clips
      - Sentence-mixing feel
      - Rainbow/WMM flashes
      - Sudden zooms
      - Speed changes
      - Freeze frames
      - Reverse moments
      - Censor bleeps
      - Audio punch / distortion
      - Random visual chaos

    NOTE:
      The exact NVG 1.8.1.2 scripting API may differ between builds.
      The helper functions below isolate the effect logic so that
      API-specific calls can be mapped easily if necessary.
]]

local SpaDinner = {}

------------------------------------------------------------
-- ADDON INFORMATION
------------------------------------------------------------

SpaDinner.Name        = "SpaDinner"
SpaDinner.Id          = "spadinner"
SpaDinner.Version     = "1.0.0"
SpaDinner.Author      = "Generated NVG Workshop Addon"
SpaDinner.Description = "Classic chaotic SpaDinner / Dinner-Spaghetti YTP effect."

------------------------------------------------------------
-- DEFAULT SETTINGS
------------------------------------------------------------

SpaDinner.Settings = {
    intensity = 70,

    repeatChance       = 0.55,
    reverseChance      = 0.20,
    freezeChance       = 0.18,
    speedChance        = 0.45,
    zoomChance         = 0.45,
    rainbowChance      = 0.35,
    shakeChance        = 0.35,
    flashChance        = 0.30,
    censorChance       = 0.25,
    audioPunchChance   = 0.40,
    sentenceMixChance  = 0.35,

    minRepeat = 2,
    maxRepeat = 6,

    minSpeed = 0.35,
    maxSpeed = 2.80,

    maxZoom = 1.85,
    shakeAmount = 18,

    freezeMin = 0.08,
    freezeMax = 0.35,

    flashDuration = 0.08,

    rainbowOpacity = 0.55,

    audioGain = 1.8,

    chaos = true
}

------------------------------------------------------------
-- UTILITY
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

local function chance(probability)
    return math.random() < probability
end

local function randomRange(minimum, maximum)
    return minimum + math.random() * (maximum - minimum)
end

local function randomInt(minimum, maximum)
    return math.random(minimum, maximum)
end

local function scaleChance(value, intensity)
    return clamp(value * (intensity / 70), 0, 1)
end

------------------------------------------------------------
-- NVG API ADAPTERS
--
-- These wrappers keep the effect logic independent from
-- the exact NVG scripting function names.
------------------------------------------------------------

local function getClip(ctx)
    if ctx and ctx.clip then
        return ctx.clip
    end

    if ctx and ctx.source then
        return ctx.source
    end

    return nil
end

local function addRepeat(ctx, count)
    if ctx and ctx.repeatClip then
        ctx:repeatClip(count)
        return true
    end

    if ctx and ctx.duplicate then
        ctx:duplicate(count)
        return true
    end

    return false
end

local function addReverse(ctx)
    if ctx and ctx.reverse then
        ctx:reverse()
        return true
    end

    if ctx and ctx.addEffect then
        ctx:addEffect("reverse")
        return true
    end

    return false
end

local function addSpeed(ctx, speed)
    if ctx and ctx.speed then
        ctx:speed(speed)
        return true
    end

    if ctx and ctx.setSpeed then
        ctx:setSpeed(speed)
        return true
    end

    if ctx and ctx.addEffect then
        ctx:addEffect("speed", {
            value = speed
        })
        return true
    end

    return false
end

local function addFreeze(ctx, duration)
    if ctx and ctx.freeze then
        ctx:freeze(duration)
        return true
    end

    if ctx and ctx.addEffect then
        ctx:addEffect("freeze", {
            duration = duration
        })
        return true
    end

    return false
end

local function addZoom(ctx, amount)
    if ctx and ctx.zoom then
        ctx:zoom(amount)
        return true
    end

    if ctx and ctx.addEffect then
        ctx:addEffect("zoom", {
            amount = amount
        })
        return true
    end

    return false
end

local function addShake(ctx, amount)
    if ctx and ctx.shake then
        ctx:shake(amount)
        return true
    end

    if ctx and ctx.addEffect then
        ctx:addEffect("shake", {
            amount = amount
        })
        return true
    end

    return false
end

local function addRainbow(ctx, opacity)
    if ctx and ctx.rainbow then
        ctx:rainbow(opacity)
        return true
    end

    if ctx and ctx.addEffect then
        ctx:addEffect("rainbow", {
            opacity = opacity
        })
        return true
    end

    return false
end

local function addFlash(ctx, duration)
    if ctx and ctx.flash then
        ctx:flash(duration)
        return true
    end

    if ctx and ctx.addEffect then
        ctx:addEffect("flash", {
            duration = duration
        })
        return true
    end

    return false
end

local function addAudioPunch(ctx, gain)
    if ctx and ctx.audioGain then
        ctx:audioGain(gain)
        return true
    end

    if ctx and ctx.addAudioEffect then
        ctx:addAudioEffect("gain", {
            gain = gain
        })
        return true
    end

    return false
end

local function addCensor(ctx)
    if ctx and ctx.censor then
        ctx:censor()
        return true
    end

    if ctx and ctx.addAudioEffect then
        ctx:addAudioEffect("bleep", {
            duration = 0.12
        })
        return true
    end

    return false
end

------------------------------------------------------------
-- SENTENCE MIXING
------------------------------------------------------------

local function sentenceMix(ctx)
    if not ctx then
        return
    end

    -- Prefer NVG's own sentence mixer when available.
    if ctx.sentenceMix then
        ctx:sentenceMix({
            slices = randomInt(2, 5),
            shuffle = true,
            repeatSlices = chance(0.6)
        })
        return
    end

    -- Generic effect fallback.
    if ctx.addEffect then
        ctx:addEffect("sentence_mix", {
            slices = randomInt(2, 5),
            shuffle = true,
            repeatSlices = chance(0.6)
        })
    end
end

------------------------------------------------------------
-- CLASSIC MEME PATTERN
------------------------------------------------------------

local function memeRepeat(ctx, settings)
    local repeats = randomInt(
        settings.minRepeat,
        settings.maxRepeat
    )

    addRepeat(ctx, repeats)

    -- Increase the chaos with a progressively faster repeat.
    if chance(0.45) then
        addSpeed(ctx, randomRange(1.15, 2.25))
    end

    if chance(0.35) then
        addZoom(
            ctx,
            randomRange(1.15, settings.maxZoom)
        )
    end
end

------------------------------------------------------------
-- RANDOM SPA DINNER EVENT
------------------------------------------------------------

local function applyEvent(ctx, settings)
    local events = {}

    if chance(scaleChance(settings.repeatChance, settings.intensity)) then
        table.insert(events, "repeat")
    end

    if chance(scaleChance(settings.reverseChance, settings.intensity)) then
        table.insert(events, "reverse")
    end

    if chance(scaleChance(settings.freezeChance, settings.intensity)) then
        table.insert(events, "freeze")
    end

    if chance(scaleChance(settings.speedChance, settings.intensity)) then
        table.insert(events, "speed")
    end

    if chance(scaleChance(settings.zoomChance, settings.intensity)) then
        table.insert(events, "zoom")
    end

    if chance(scaleChance(settings.rainbowChance, settings.intensity)) then
        table.insert(events, "rainbow")
    end

    if chance(scaleChance(settings.shakeChance, settings.intensity)) then
        table.insert(events, "shake")
    end

    if chance(scaleChance(settings.flashChance, settings.intensity)) then
        table.insert(events, "flash")
    end

    if chance(scaleChance(settings.censorChance, settings.intensity)) then
        table.insert(events, "censor")
    end

    if chance(scaleChance(settings.audioPunchChance, settings.intensity)) then
        table.insert(events, "audio")
    end

    if chance(scaleChance(settings.sentenceMixChance, settings.intensity)) then
        table.insert(events, "sentence")
    end

    if #events == 0 then
        return
    end

    -- Apply between one and several effects.
    local numberOfEvents = 1

    if settings.chaos then
        numberOfEvents = randomInt(
            1,
            math.min(4, #events)
        )
    end

    for i = 1, numberOfEvents do
        local index = randomInt(1, #events)
        local event = table.remove(events, index)

        if event == "repeat" then
            memeRepeat(ctx, settings)

        elseif event == "reverse" then
            addReverse(ctx)

        elseif event == "freeze" then
            addFreeze(
                ctx,
                randomRange(
                    settings.freezeMin,
                    settings.freezeMax
                )
            )

        elseif event == "speed" then
            addSpeed(
                ctx,
                randomRange(
                    settings.minSpeed,
                    settings.maxSpeed
                )
            )

        elseif event == "zoom" then
            addZoom(
                ctx,
                randomRange(
                    1.05,
                    settings.maxZoom
                )
            )

        elseif event == "rainbow" then
            addRainbow(
                ctx,
                settings.rainbowOpacity
            )

        elseif event == "shake" then
            addShake(
                ctx,
                settings.shakeAmount *
                (settings.intensity / 70)
            )

        elseif event == "flash" then
            addFlash(
                ctx,
                settings.flashDuration
            )

        elseif event == "censor" then
            addCensor(ctx)

        elseif event == "audio" then
            addAudioPunch(
                ctx,
                randomRange(
                    1.1,
                    settings.audioGain
                )
            )

        elseif event == "sentence" then
            sentenceMix(ctx)
        end
    end
end

------------------------------------------------------------
-- MAIN EFFECT
------------------------------------------------------------

function SpaDinner.Apply(ctx, parameters)
    local settings = {}

    -- Copy defaults.
    for key, value in pairs(SpaDinner.Settings) do
        settings[key] = value
    end

    -- Override with user parameters.
    if parameters then
        for key, value in pairs(parameters) do
            settings[key] = value
        end
    end

    math.randomseed(
        os.time() +
        math.floor(os.clock() * 100000)
    )

    local clip = getClip(ctx)

    if not clip and not ctx then
        return false
    end

    --------------------------------------------------------
    -- Opening hit
    --------------------------------------------------------

    if chance(0.55) then
        addZoom(ctx, randomRange(1.15, 1.45))
    end

    if chance(0.30) then
        addFlash(ctx, 0.05)
    end

    --------------------------------------------------------
    -- Main chaos
    --------------------------------------------------------

    applyEvent(ctx, settings)

    --------------------------------------------------------
    -- Classic SpaDinner repeat
    --------------------------------------------------------

    if chance(0.35) then
        memeRepeat(ctx, settings)
    end

    --------------------------------------------------------
    -- Ending punch
    --------------------------------------------------------

    if chance(0.40) then
        addShake(
            ctx,
            settings.shakeAmount *
            (settings.intensity / 70)
        )
    end

    if chance(0.25) then
        addAudioPunch(
            ctx,
            settings.audioGain
        )
    end

    return true
end

------------------------------------------------------------
-- NVG WORKSHOP REGISTRATION
------------------------------------------------------------

function SpaDinner.Register(nvg)
    if not nvg then
        return false
    end

    -- Common registration patterns.
    if nvg.registerEffect then
        nvg:registerEffect(
            SpaDinner.Id,
            SpaDinner.Name,
            SpaDinner.Apply,
            SpaDinner.Settings
        )

        return true
    end

    if nvg.registerAddon then
        nvg:registerAddon({
            id = SpaDinner.Id,
            name = SpaDinner.Name,
            version = SpaDinner.Version,
            description = SpaDinner.Description,
            apply = SpaDinner.Apply,
            settings = SpaDinner.Settings
        })

        return true
    end

    return false
end

------------------------------------------------------------
-- PRESETS
------------------------------------------------------------

SpaDinner.Presets = {

    Classic = {
        intensity = 65,
        repeatChance = 0.60,
        reverseChance = 0.15,
        freezeChance = 0.12,
        speedChance = 0.40,
        zoomChance = 0.35,
        rainbowChance = 0.30,
        shakeChance = 0.25,
        flashChance = 0.20,
        censorChance = 0.25,
        audioPunchChance = 0.35,
        sentenceMixChance = 0.30,
        chaos = true
    },

    Maximum = {
        intensity = 100,
        repeatChance = 0.90,
        reverseChance = 0.60,
        freezeChance = 0.50,
        speedChance = 0.80,
        zoomChance = 0.80,
        rainbowChance = 0.70,
        shakeChance = 0.75,
        flashChance = 0.70,
        censorChance = 0.50,
        audioPunchChance = 0.85,
        sentenceMixChance = 0.75,
        minRepeat = 3,
        maxRepeat = 9,
        maxZoom = 2.5,
        shakeAmount = 30,
        chaos = true
    },

    OldSchool = {
        intensity = 55,
        repeatChance = 0.70,
        reverseChance = 0.10,
        freezeChance = 0.08,
        speedChance = 0.30,
        zoomChance = 0.25,
        rainbowChance = 0.45,
        shakeChance = 0.15,
        flashChance = 0.20,
        censorChance = 0.40,
        audioPunchChance = 0.30,
        sentenceMixChance = 0.50,
        minRepeat = 2,
        maxRepeat = 5,
        chaos = false
    }
}

------------------------------------------------------------
-- OPTIONAL PRESET HELPER
------------------------------------------------------------

function SpaDinner.ApplyPreset(ctx, presetName)
    local preset = SpaDinner.Presets[presetName]

    if not preset then
        preset = SpaDinner.Presets.Classic
    end

    return SpaDinner.Apply(ctx, preset)
end

------------------------------------------------------------
-- RETURN ADDON
------------------------------------------------------------

return SpaDinner