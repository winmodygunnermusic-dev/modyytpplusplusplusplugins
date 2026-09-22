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
                ["value"] = "Sentence Mixing Effect Addon",
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

-- Sentence Mixing Effect Addon

-- Define the effect function
function run(state)
  -- Tunable parameters
  -- amount: mixing amount (default: 0.5)
  -- speed: mixing speed (default: 1.0)
  local amount = getParam(state, "amount", 0.5)
  local speed = getParam(state, "speed", 1.0)

  -- Calculate the mixed color
  local r = state.r
  local g = state.g
  local b = state.b
  if state.tick() * speed > amount then
    r = math.random(0, 255)
    g = math.random(0, 255)
    b = math.random(0, 255)
  end

  -- Return the mixed color
  return {r, g, b}
end
