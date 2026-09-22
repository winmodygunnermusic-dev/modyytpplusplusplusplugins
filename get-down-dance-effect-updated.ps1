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
                ["value"] = "Get Down Dance Effect Updated",
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
            ["value"] = 2,
            ["type"] = "number"
        },
        }
    }
end

-- Get Down Dance Effect
-- Inspired by 'Japanese Horse WTF!?!!?' video on YouTube

-- Tunable parameters
-- amount: dance intensity (default: 10)
-- speed: dance speed (default: 2)

function run(state)
  local amount = getParam(state, "amount", 10)
  local speed = getParam(state, "speed", 2)
  local frame = state.frame
  local x, y = state.x, state.y
  local r, g, b = state.r, state.g, state.b

  -- Calculate dance offset
  local offsetX = math.sin((frame * speed) + (x * 0.01)) * amount
  local offsetY = math.sin((frame * speed) + (y * 0.01)) * amount

  -- Apply dance effect
  local newR = r + math.sin((frame * speed) + (x * 0.01) + (y * 0.01)) * 50
  local newG = g + math.sin((frame * speed) + (x * 0.01) + (y * 0.01) * 1.1) * 50
  local newB = b + math.sin((frame * speed) + (y * 0.01) + (x * 0.01) * 1.2) * 50

  -- Clamp color values
  newR = math.max(0, math.min(255, newR))
  newG = math.max(0, math.min(255, newG))
  newB = math.max(0, math.min(255, newB))

  return {r = newR, g = newG, b = newB}
end
