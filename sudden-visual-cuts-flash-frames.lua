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
                ["value"] = "Sudden Visual Cuts Flash Frames",
                ["type"] = "label"
            },
            {
                ["name"] = "Description",
                ["value"] = "YTP-style NVG pixel effect with safe default parameters.",
                ["type"] = "label"
            },
        {
            ["name"] = "amount",
            ["value"] = 0.1,
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

-- Sudden Visual Cuts & Flash Frames Addon

-- Effect: Randomly flash a pixel to a random color
function run(state)
  -- params: 
  --   amount (0-1): chance of flashing (default: 0.1)
  --   speed (1-100): flash frequency (default: 10)
  local amount = getParam(state, "amount", 0.1)
  local speed = getParam(state, "speed", 10)

  -- Randomly flash pixel
  if math.random() < amount * (1 / (speed * state.tick() / 100)) then
    -- Generate random color
    local r = math.random(0, 255)
    local g = math.random(0, 255)
    local b = math.random(0, 255)
    return {r, g, b}
  end
  -- Leave pixel unchanged
  return {skip=true}
end
