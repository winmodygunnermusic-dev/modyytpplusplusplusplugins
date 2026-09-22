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
                ["value"] = "The Shut The Fuck Up",
                ["type"] = "label"
            },
            {
                ["name"] = "Description",
                ["value"] = "YTP-style NVG pixel effect with safe default parameters.",
                ["type"] = "label"
            },
        {
            ["name"] = "amount",
            ["value"] = 5,
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

function run(state)
  -- params: 
  --   amount (default: 5) - speed multiplier
  --   seed_offset (default: 0) - random seed offset

  local amount = getParam(state, "amount", 5)
  local seed_offset = getParam(state, "seed_offset", 0)

  local r, g, b = state.r, state.g, state.b
  local frame = state.frame
  local speed = state.tick()

  local sped_up_frame = math.floor(frame * amount)

  -- Add a tiny bit of randomness to prevent banding
  local noise = (math.sin((sped_up_frame + state.seed + seed_offset) * 12.9898) * 43758.5453) % 1
  noise = noise * 2 - 1

  -- Exaggerate the colors
  r = math.min(255, math.max(0, r + noise * 50))
  g = math.min(255, math.max(0, g + noise * 50))
  b = math.min(255, math.max(0, b + noise * 50))

  return {r, g, b}
end
