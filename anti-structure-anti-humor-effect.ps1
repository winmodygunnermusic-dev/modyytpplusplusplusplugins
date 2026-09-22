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
                ["value"] = "Anti Structure Anti Humor Effect",
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
            ["value"] = 1,
            ["type"] = "number"
        },
        }
    }
end

-- Anti-Structure / Anti-Humor Effect Addon

-- params: 
--   amount (default: 0.5) controls the proportion of pixels to invert
--   speed (default: 1) controls how fast the inversion changes

function run(state)
  local r, g, b = state.r, state.g, state.b
  local amount = getParam(state, "amount", 0.5)
  local speed = getParam(state, "speed", 1)

  if state.tick() * speed % 1 < amount then
    -- Invert the pixel color
    r, g, b = 255 - r, 255 - g, 255 - b
  end

  return {r, g, b}
end
