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
                ["value"] = "Random Cuts Effect",
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

-- Random Cuts Effect
-- Generates a video with randomly cut frames.

function run(state)
  -- params: 
  --   amount (default: 0.5) - proportion of pixels to cut
  --   speed (default: 10) - speed of cutting (higher = faster)
  local amount = getParam(state, "amount", 0.5)
  local speed = getParam(state, "speed", 10)

  -- Calculate probability of cutting a pixel
  local prob = amount * (state.tick() * speed)

  -- Randomly decide if pixel should be cut
  if math.random() < prob then
    -- Cut pixel: return black
    return {r = 0, g = 0, b = 0}
  else
    -- Don't cut pixel: return original color
    return {r = state.r, g = state.g, b = state.b}
  end
end
