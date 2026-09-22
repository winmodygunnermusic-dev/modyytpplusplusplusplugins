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
                ["value"] = "Boom Effect 3 Addon Type",
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

-- Boom Effect 3: A radial explosion effect
function run(state)
  -- params: 
  --   amount (default: 0.5) - explosion intensity
  --   speed (default: 100) - explosion speed
  local amount = getParam(state, "amount", 0.5)
  local speed = getParam(state, "speed", 100)

  -- distance from center of screen
  local dx = state.x - state.width / 2
  local dy = state.y - state.height / 2
  local dist = math.sqrt(dx * dx + dy * dy)

  -- explosion wave
  local wave = math.max(0, 1 - (dist / (speed * state.time)))

  -- boom color
  local r, g, b = 255, 128, 0  -- orange

  -- lerp color with wave
  local lerpedR, lerpedG, lerpedB = 
    math.floor(r * wave * amount),
    math.floor(g * wave * amount),
    math.floor(b * wave * amount)

  -- return pixel color
  if wave > 0 then
    return {lerpedR, lerpedG, lerpedB}
  else
    return {skip=true}
  end
end
