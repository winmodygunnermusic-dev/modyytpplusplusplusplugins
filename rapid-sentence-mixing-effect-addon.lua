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
                ["value"] = "Rapid Sentence Mixing Effect Addon",
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
            ["name"] = "seed_offset",
            ["value"] = 0,
            ["type"] = "number"
        },
        }
    }
end

-- Rapid Sentence Mixing Effect Addon

-- Define the effect function
function run(state)
  -- Tunable parameters
  -- amount: mix speed (default: 0.1)
  -- seed_offset: random seed offset (default: 0)
  local amount = getParam(state, "amount", 0.1)
  local seed_offset = getParam(state, "seed_offset", 0)

  -- Calculate a unique random seed for this pixel
  local seed = state.seed + seed_offset + state.x + state.y

  -- Rapidly mix the pixel's color with a random color
  local r, g, b = state.r, state.g, state.b
  local mix_r, mix_g, mix_b = math.random(0, 255), math.random(0, 255), math.random(0, 255)
  local mix_amount = math.random() * amount

  r = math.floor(r * (1 - mix_amount) + mix_r * mix_amount)
  g = math.floor(g * (1 - mix_amount) + mix_g * mix_amount)
  b = math.floor(b * (1 - mix_amount) + mix_b * mix_amount)

  -- Return the mixed color
  return {r, g, b}
end
