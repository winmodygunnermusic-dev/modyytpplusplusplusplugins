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
                ["value"] = "Stutter Loop Plus Effect",
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
        {
            ["name"] = "offset",
            ["value"] = 0.5,
            ["type"] = "number"
        },
        }
    }
end

-- Stutter Loop Plus Effect
-- A stuttering loop effect with an additional "plus" offset.

function run(state)
  -- params: 
  --   amount (default=10): number of stutter steps
  --   speed (default=5): speed of stutter
  --   offset (default=0.5): plus offset
  local amount = getParam(state, "amount", 10)
  local speed = getParam(state, "speed", 5)
  local offset = getParam(state, "offset", 0.5)

  -- calculate stutter index
  local stutter_idx = math.floor(state.time * speed) % amount

  -- add plus offset
  local final_idx = (stutter_idx + math.floor(state.x * offset)) % amount

  -- map stutter index to color
  local r = math.sin(final_idx / amount * math.pi * 2) * 128 + 128
  local g = math.sin((final_idx + amount / 3) / amount * math.pi * 2) * 128 + 128
  local b = math.sin((final_idx + 2 * amount / 3) / amount * math.pi * 2) * 128 + 128

  return {r, g, b}
end
