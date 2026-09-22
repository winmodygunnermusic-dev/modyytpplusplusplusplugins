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
                ["value"] = "Wega Storm Effect Wega Storm",
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
            ["value"] = 100,
            ["type"] = "number"
        },
        }
    }
end

-- Wega Storm Effect
-- A chaotic storm of pixels

function run(state)
  -- Tunable parameters
  -- amount: storm intensity (default: 0.5)
  -- speed: storm speed (default: 100)
  local amount = getParam(state, "amount", 0.5)
  local speed = getParam(state, "speed", 100)

  -- Calculate storm offset
  local offset = math.sin(state.time * speed) * 10

  -- Randomize pixel coordinates
  local rand_x = state.seed + state.x * 57 + state.y * 133
  local rand_y = state.seed + state.x * 133 + state.y * 57
  local r_x = math.random(rand_x, rand_x + 100) - 50 + offset
  local r_y = math.random(rand_y, rand_y + 100) - 50

  -- Apply storm effect
  if math.random() < amount then
    local r, g, b = state.r, state.g, state.b
    -- Change color based on storm offset
    r = math.min(255, math.max(0, r + math.sin(state.time * speed + r_x) * 50))
    g = math.min(255, math.max(0, g + math.sin(state.time * speed + r_y) * 50))
    b = math.min(255, math.max(0, b + math.sin(state.time * speed + r_x + r_y) * 50))
    return {r, g, b}
  else
    -- Leave pixel unchanged
    return {skip=true}
  end
end
