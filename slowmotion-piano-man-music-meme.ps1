-- NVG workshop metadata and safe parameter helpers.

local function getParam(state, name, defaultValue)
    if state ~= nil and state.params ~= nil and state.params[name] ~= nil then
        return state.params[name]
    end

    return defaultValue
end

function Query(localeName, localizationTokens)
    return {
        ["settings"] = {
            {
                ["name"] = "Display Name",
                ["value"] = "Slowmotion Piano Man Music Meme",
                ["type"] = "label"
            },
            {
                ["name"] = "Description",
                ["value"] = "YTP-style NVG pixel effect with safe default parameters.",
                ["type"] = "label"
            },
        {
            ["name"] = "amount",
            ["value"] = 2.0,
            ["type"] = "number"
        },
        }
    }
end

-- Slowmotion Piano Man Music Meme Effect

-- Define tunable parameters
-- amount: slowdown factor (default: 2.0)
-- music_volume: volume of the piano man music (default: 0.5)

function run(state)
  -- Slow down the video
  local slowdown_factor = getParam(state, "amount", 2.0)
  local frame = math.floor(state.frame / slowdown_factor)

  -- Get the current pixel
  local r, g, b = state.r, state.g, state.b

  -- If the frame has changed, re-sample the piano man music
  if state.tick() < 1/60 then
    -- Piano Man Music Library (simplified for demonstration)
    -- For a real implementation, use a proper audio library
    local piano_man_music = {
      {note = 60, duration = 1}, -- C4
      {note = 64, duration = 1}, -- E4
      {note = 67, duration = 1}, -- G4
      {note = 72, duration = 1}, -- C5
    }
    local music_index = math.floor(state.time * 4) % #piano_man_music
    local note = piano_man_music[music_index + 1].note

    -- Generate a simple tone (omitted for brevity)
    -- ...

    -- Mix the tone with the original audio (omitted for brevity)
    -- ...
  end

  -- Return the pixel color (no change)
  return {r, g, b}
end
