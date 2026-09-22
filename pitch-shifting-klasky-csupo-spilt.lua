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
                ["value"] = "Pitch Shifting Klasky Csupo Spilt",
                ["type"] = "label"
            },
            {
                ["name"] = "Description",
                ["value"] = "YTP-style NVG pixel effect with safe default parameters.",
                ["type"] = "label"
            },
        {
            ["name"] = "amount",
            ["value"] = 0.1,
            ["type"] = "number"
        },
        {
            ["name"] = "speed",
            ["value"] = 10,
            ["type"] = "number"
        },
        }
    }
end

function run(state)
  -- Pitch shifting / Klasky Csupo Spilt effect
  -- params: 
  --   amount (default: 0.1) - intensity of the effect
  --   speed (default: 10) - speed of the effect

  local amount = getParam(state, "amount", 0.1)
  local speed = getParam(state, "speed", 10)

  local r, g, b = state.r, state.g, state.b
  local t = state.time * speed
  local p = math.sin(t) * amount

  -- shift red and blue channels
  local r_shifted = math.floor(r * (1 + p))
  local b_shifted = math.floor(b * (1 - p))

  -- clamp values
  r_shifted = math.max(0, math.min(r_shifted, 255))
  b_shifted = math.max(0, math.min(b_shifted, 255))

  return {r_shifted, g, b_shifted}
end
