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
                ["value"] = "Sex Jokes Ytp Effect",
                ["type"] = "label"
            },
            {
                ["name"] = "Description",
                ["value"] = "YTP-style NVG pixel effect with safe default parameters.",
                ["type"] = "label"
            },
        {
            ["name"] = "speed",
            ["value"] = 1.0,
            ["type"] = "number"
        },
        {
            ["name"] = "amount",
            ["value"] = 10,
            ["type"] = "number"
        },
        }
    }
end

-- Sex Jokes YTP Effect
-- A simple effect that changes the color of pixels based on their position and time

function run(state)
  -- params: 
  --  .speed (default: 1.0) - speed of color change
  --  .amount (default: 10) - amount of color change

  local speed = getParam(state, "speed", 1.0)
  local amount = getParam(state, "amount", 10)

  local r, g, b = state.r, state.g, state.b
  local t = state.time * speed

  -- red oscillates
  r = math.sin(t + state.x * 0.01) * amount + (r - 128) + 128
  -- green stays same
  -- blue oscillates
  b = math.sin(t + state.y * 0.01) * amount + (b - 128) + 128

  -- Constrain to 0..255
  r = math.max(0, math.min(255, r))
  b = math.max(0, math.min(255, b))

  return {r, g, b}
end
