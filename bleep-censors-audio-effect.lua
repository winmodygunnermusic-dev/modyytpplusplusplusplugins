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
                ["value"] = "Bleep Censors Audio Effect",
                ["type"] = "label"
            },
            {
                ["name"] = "Description",
                ["value"] = "YTP-style NVG pixel effect with safe default parameters.",
                ["type"] = "label"
            },
        {
            ["name"] = "amount",
            ["value"] = 50,
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

-- Bleep Censors Audio Effect (visual representation)
-- Replaces pixels with a "bleep" effect when audio would be censored

function run(state)
  -- params: 
  --   amount (0-100): intensity of bleep effect (default: 50)
  --   speed (1-100): speed of bleep effect (default: 10)
  local amount = getParam(state, "amount", 50)
  local speed = getParam(state, "speed", 10)

  -- Simple noise function for bleep effect
  local function noise(x, y, t)
    return (math.sin((x + y + t) * speed) * amount) / 100
  end

  -- Apply bleep effect
  local t = state.tick()
  local n = noise(state.x, state.y, t)
  if n > 0.5 then
    -- Bleep pixel
    return {255, 255, 255}
  else
    -- Leave pixel unchanged
    return {skip=true}
  end
end
