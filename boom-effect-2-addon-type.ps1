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
                ["value"] = "Boom Effect 2 Addon Type",
                ["type"] = "label"
            },
            {
                ["name"] = "Description",
                ["value"] = "YTP-style NVG pixel effect with safe default parameters.",
                ["type"] = "label"
            },
        {
            ["name"] = "amount",
            ["value"] = 0.5,
            ["type"] = "number"
        },
        {
            ["name"] = "speed",
            ["value"] = 1.0,
            ["type"] = "number"
        },
        }
    }
end

function run(state)
  local r, g, b = state.r, state.g, state.b
  local amount = getParam(state, "amount", 0.5)
  local speed = getParam(state, "speed", 1.0)
  local seed = state.seed

  -- Simple pixel boom effect
  local boom_t = math.sin(state.time * speed)
  boom_t = (boom_t + 1) / 2 -- Map to 0-1 range

  -- Apply boom effect
  r = r * (1 - amount * boom_t)
  g = g * (1 - amount * boom_t)
  b = b * (1 - amount * boom_t)

  return {r, g, b}
end
