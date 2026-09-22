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
                ["value"] = "Sentence Mixing Effect 2",
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
            ["value"] = 1.0,
            ["type"] = "number"
        },
        }
    }
end

function run(state)
  -- params: amount (default 0.5), speed (default 1.0)
  -- amount: mix intensity (0 = no mix, 1 = full mix)
  -- speed: mix speed (higher = faster mix)
  local amount = getParam(state, "amount", 0.5)
  local speed = getParam(state, "speed", 1.0)

  -- get source and destination pixel colors
  local r1, g1, b1 = state.r, state.g, state.b
  local r2, g2, b2 = state.seed % 256, (state.seed * 13) % 256, (state.seed * 37) % 256

  -- calculate mix factor
  local t = math.sin((state.time * speed) + state.seed) * 0.5 + 0.5
  t = t * amount

  -- mix pixel colors
  local r = math.floor(r1 * (1 - t) + r2 * t)
  local g = math.floor(g1 * (1 - t) + g2 * t)
  local b = math.floor(b1 * (1 - t) + b2 * t)

  return {r, g, b}
end
