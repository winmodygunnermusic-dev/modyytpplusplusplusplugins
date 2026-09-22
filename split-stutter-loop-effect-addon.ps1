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
                ["value"] = "Split Stutter Loop Effect Addon",
                ["type"] = "label"
            },
            {
                ["name"] = "Description",
                ["value"] = "YTP-style NVG pixel effect with safe default parameters.",
                ["type"] = "label"
            },
        {
            ["name"] = "loopLength",
            ["value"] = 8,
            ["type"] = "number"
        },
        {
            ["name"] = "stutterAmount",
            ["value"] = 0.5,
            ["type"] = "number"
        },
        }
    }
end

function run(state)
  -- params: loop length in frames (default 8), stutter amount (default 0.5)
  local loopLength = getParam(state, "loopLength", 8)
  local stutterAmount = getParam(state, "stutterAmount", 0.5)

  -- calculate stutter offset
  local stutterOffset = math.floor(state.frame * stutterAmount) % loopLength

  -- check if we're in a stutter
  if stutterOffset < math.floor(loopLength * 0.5) then
    -- return original pixel color
    return {state.r, state.g, state.b}
  else
    -- displace pixel
    local newX = (state.x + stutterOffset) % state.width
    local newY = state.y
    -- sample from source at displaced coordinates
    local r, g, b = state.r, state.g, state.b
    -- implement displacement with pixel wrapping or border handling if needed
    -- here we are just reusing source pixel for demonstration
    return {r, g, b}
  end
end
