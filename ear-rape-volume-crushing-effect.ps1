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
                ["value"] = "Ear Rape Volume Crushing Effect",
                ["type"] = "label"
            },
            {
                ["name"] = "Description",
                ["value"] = "YTP-style NVG pixel effect with safe default parameters.",
                ["type"] = "label"
            },
        {
            ["name"] = "amount",
            ["value"] = 10,
            ["type"] = "number"
        },
        {
            ["name"] = "speed",
            ["value"] = 5,
            ["type"] = "number"
        },
        }
    }
end

-- Ear-Rape (Volume Crushing) Effect Addon
-- Crushes audio-like visuals by pulsing and distorting color.

function run(state)
  -- Tunable parameters
  -- amount: intensity of distortion (default: 10)
  -- speed: pulse speed (default: 5)
  local amount = getParam(state, "amount", 10)
  local speed = getParam(state, "speed", 5)

  -- Calculate pulse
  local pulse = math.sin(state.time * speed) * amount

  -- Distort RGB values
  local r = state.r + pulse
  local g = state.g + pulse / 2
  local b = state.b + pulse / 4

  -- Clamp RGB values
  r = math.max(0, math.min(255, r))
  g = math.max(0, math.min(255, g))
  b = math.max(0, math.min(255, b))

  -- Return distorted RGB
  return {r, g, b}
end
