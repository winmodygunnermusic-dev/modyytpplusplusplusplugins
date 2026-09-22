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
                ["value"] = "Extreme Pitch Shifting G Major",
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
            ["value"] = 10,
            ["type"] = "number"
        },
        }
    }
end

-- Strobe & Shake Effect Addon

-- Tunable parameters
-- amount: strobe intensity (default: 0.5)
-- speed: shake speed (default: 10)

function run(state)
  local amount = getParam(state, "amount", 0.5)
  local speed = getParam(state, "speed", 10)

  -- strobe
  local strobe = math.sin(state.time * speed) > 0
  if not strobe then
    return {skip=true}
  end

  -- shake
  local shake_x = math.floor(math.sin(state.time * speed * 1.1) * 5)
  local shake_y = math.floor(math.cos(state.time * speed * 1.1) * 5)
  local r, g, b = state.r, state.g, state.b

  -- apply shake
  local px, py = state.px + shake_x, state.py + shake_y
  if px >= 0 and px < state.width and py >= 0 and py < state.height then
    r, g, b = state.r, state.g, state.b
  else
    -- if pixel is out of bounds, return black
    r, g, b = 0, 0, 0
  end

  -- apply strobe intensity
  r, g, b = math.floor(r * amount), math.floor(g * amount), math.floor(b * amount)

  return {r, g, b}
end
