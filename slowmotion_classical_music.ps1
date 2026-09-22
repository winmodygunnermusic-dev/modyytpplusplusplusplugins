--[[
    Slowmotion Classical Music Effect
    Nonsensical Video Generator v1.8.1.2

    Suggested filename:
        slowmotion_classical_music.lua

    Folder:
        NonsensicalVideoGenerator\plugins\workshop\

    Effect:
        Slow-motion video combined with a supplied classical/music track.

    Notes:
        - The addon does NOT include copyrighted music.
        - Put your own/licensed music file in the configured music folder.
        - The implementation uses NVG's effect/audio command interface when
          available and falls back gracefully when a command is unavailable.
]]

local Effect = {}

Effect.Name = "Slowmotion Classical Music"
Effect.Id = "slowmotion_classical_music"
Effect.Version = "1.0.0"
Effect.Author = "Community Addon"
Effect.Description =
    "Creates dramatic slow-motion sequences with optional classical music, " ..
    "audio ducking, fades, and cinematic timing."

----------------------------------------------------------------
-- CONFIGURATION
----------------------------------------------------------------

Effect.Settings = {
    -- Video speed
    SlowFactor = 0.35,

    -- Strength of the effect
    Intensity = 0.80,

    -- Audio
    MusicVolume = 0.65,
    OriginalAudioVolume = 0.20,

    -- Fade lengths, seconds
    FadeIn = 0.75,
    FadeOut = 1.00,

    -- Whether the original audio is reduced while music plays
    DuckOriginalAudio = true,

    -- Optional looping
    LoopMusic = true,

    -- Randomly vary the slow-motion amount
    DynamicSpeed = true,
    MinSpeed = 0.22,
    MaxSpeed = 0.48,

    -- Optional visual treatment
    AddVignette = true,
    AddSoftBlur = false,
    AddLetterbox = false,

    -- Music directory relative to NVG
    MusicFolder = "plugins/workshop/music",

    -- Files are examples. Replace with your own licensed tracks.
    MusicFiles = {
        "classical_01.wav",
        "classical_02.wav",
        "dramatic_classical.wav"
    }
}

----------------------------------------------------------------
-- SAFE HELPERS
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

local function randomFloat(minimum, maximum)
    return minimum + math.random() * (maximum - minimum)
end

local function getSetting(name, fallback)
    if Effect.Settings[name] ~= nil then
        return Effect.Settings[name]
    end

    return fallback
end

local function log(message)
    if NVG and NVG.Log then
        NVG.Log("[Slowmotion Classical Music] " .. tostring(message))
    else
        print("[Slowmotion Classical Music] " .. tostring(message))
    end
end

----------------------------------------------------------------
-- NVG COMMAND WRAPPER
----------------------------------------------------------------

local function callNVG(functionName, ...)
    if NVG and type(NVG[functionName]) == "function" then
        local ok, result = pcall(NVG[functionName], ...)
        if ok then
            return result
        end

        log("NVG call failed: " .. functionName)
        return nil
    end

    return nil
end

----------------------------------------------------------------
-- MUSIC SELECTION
----------------------------------------------------------------

local function chooseMusic()
    local files = getSetting("MusicFiles", {})

    if #files == 0 then
        return nil
    end

    local index = math.random(1, #files)
    local filename = files[index]

    return getSetting("MusicFolder", "plugins/workshop/music")
        .. "/"
        .. filename
end

----------------------------------------------------------------
-- SPEED CALCULATION
----------------------------------------------------------------

local function calculateSpeed()
    local intensity = clamp(
        getSetting("Intensity", 0.80),
        0.0,
        1.0
    )

    local baseSpeed = getSetting("SlowFactor", 0.35)

    if getSetting("DynamicSpeed", true) then
        local minimum = getSetting("MinSpeed", 0.22)
        local maximum = getSetting("MaxSpeed", 0.48)

        baseSpeed = randomFloat(minimum, maximum)
    end

    -- Higher intensity makes the slow-motion more pronounced.
    local speed = baseSpeed - (intensity * 0.08)

    return clamp(speed, 0.10, 1.0)
end

----------------------------------------------------------------
-- VIDEO EFFECT
----------------------------------------------------------------

local function applySlowMotion(context)
    local speed = calculateSpeed()

    log("Applying slow motion: " .. string.format("%.3f", speed))

    -- Preferred NVG API
    if callNVG("SetPlaybackSpeed", speed) ~= nil then
        return
    end

    -- Generic effect API fallback
    if context and context.SetSpeed then
        pcall(context.SetSpeed, context, speed)
        return
    end

    if context and context.Speed then
        context.Speed = speed
        return
    end

    log("No playback-speed API detected; storing requested speed only.")

    if context then
        context.SlowmotionClassicalMusicSpeed = speed
    end
end

----------------------------------------------------------------
-- AUDIO
----------------------------------------------------------------

local function applyMusic(context)
    local music = chooseMusic()

    if not music then
        log("No music file configured.")
        return
    end

    local musicVolume = clamp(
        getSetting("MusicVolume", 0.65),
        0.0,
        1.0
    )

    local originalVolume = clamp(
        getSetting("OriginalAudioVolume", 0.20),
        0.0,
        1.0
    )

    local fadeIn = math.max(
        0,
        getSetting("FadeIn", 0.75)
    )

    local fadeOut = math.max(
        0,
        getSetting("FadeOut", 1.0)
    )

    local loopMusic = getSetting("LoopMusic", true)

    log("Selected music: " .. music)

    -- Preferred NVG music API
    local played = callNVG(
        "AddMusic",
        music,
        musicVolume,
        fadeIn,
        fadeOut,
        loopMusic
    )

    if played ~= nil then
        if getSetting("DuckOriginalAudio", true) then
            callNVG(
                "SetOriginalAudioVolume",
                originalVolume
            )
        end

        return
    end

    -- Generic context fallback
    if context then
        if context.AddMusic then
            pcall(
                context.AddMusic,
                context,
                music,
                musicVolume,
                fadeIn,
                fadeOut,
                loopMusic
            )
        end

        if getSetting("DuckOriginalAudio", true) then
            if context.SetAudioVolume then
                pcall(
                    context.SetAudioVolume,
                    context,
                    originalVolume
                )
            else
                context.OriginalAudioVolume = originalVolume
            end
        end

        context.ClassicalMusicFile = music
        context.ClassicalMusicVolume = musicVolume
    end
end

----------------------------------------------------------------
-- OPTIONAL VISUAL TREATMENT
----------------------------------------------------------------

local function applyVisualTreatment(context)
    local intensity = clamp(
        getSetting("Intensity", 0.80),
        0.0,
        1.0
    )

    if getSetting("AddVignette", true) then
        callNVG(
            "AddVisualEffect",
            "vignette",
            intensity * 0.35
        )

        if context and context.AddVisualEffect then
            pcall(
                context.AddVisualEffect,
                context,
                "vignette",
                intensity * 0.35
            )
        end
    end

    if getSetting("AddSoftBlur", false) then
        callNVG(
            "AddVisualEffect",
            "soft_blur",
            intensity * 0.15
        )
    end

    if getSetting("AddLetterbox", false) then
        callNVG(
            "AddVisualEffect",
            "letterbox",
            intensity * 0.25
        )
    end
end

----------------------------------------------------------------
-- EFFECT LIFECYCLE
----------------------------------------------------------------

function Effect:Init()
    math.randomseed(os.time())

    log("Initialized.")
end

function Effect:Apply(context)
    log("Starting effect.")

    applySlowMotion(context)
    applyMusic(context)
    applyVisualTreatment(context)

    if context then
        context.SlowmotionClassicalMusic = true
        context.SlowmotionClassicalMusicIntensity =
            getSetting("Intensity", 0.80)
    end

    log("Effect applied.")
end

function Effect:Reset(context)
    log("Resetting effect.")

    callNVG("SetPlaybackSpeed", 1.0)
    callNVG("SetOriginalAudioVolume", 1.0)
    callNVG("StopMusic")

    if context then
        if context.SetSpeed then
            pcall(context.SetSpeed, context, 1.0)
        else
            context.Speed = 1.0
        end

        if context.SetAudioVolume then
            pcall(context.SetAudioVolume, context, 1.0)
        else
            context.OriginalAudioVolume = 1.0
        end

        context.SlowmotionClassicalMusic = false
    end

    log("Reset complete.")
end

----------------------------------------------------------------
-- OPTIONAL RANDOMIZED VARIANT
----------------------------------------------------------------

function Effect:ApplyRandom(context)
    local oldDynamic = self.Settings.DynamicSpeed

    self.Settings.DynamicSpeed = true

    applySlowMotion(context)
    applyMusic(context)
    applyVisualTreatment(context)

    self.Settings.DynamicSpeed = oldDynamic

    log("Randomized slow-motion classical variant applied.")
end

----------------------------------------------------------------
-- NVG REGISTRATION
----------------------------------------------------------------

if NVG and NVG.RegisterEffect then
    NVG.RegisterEffect(Effect)
else
    -- Some NVG addon loaders simply inspect the returned table.
    log("NVG.RegisterEffect unavailable; returning addon table.")
end

return Effect
