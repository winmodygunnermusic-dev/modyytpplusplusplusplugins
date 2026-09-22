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
                ["value"] = "Stutter Loop Minus Effect",
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

-- Stutter Loop Minus Effect
-- Creates a stuttering loop effect where pixels are subtracted from the source
-- in a loop that appears to move backwards.

function run(state)
  -- Tunable parameters
  -- amount: controls the intensity of the subtraction (default: 50)
  -- speed: controls the speed of the loop (default: 10)
  local amount = getParam(state, "amount", 50)
  local speed = getParam(state, "speed", 10)

  -- Calculate the loop offset
  local loopOffset = math.floor(state.time * speed) % state.width

  -- Calculate the distance from the loop offset
  local dist = (state.x - loopOffset + state.width) % state.width

  -- If the distance is within the amount, subtract from the source pixel
  if dist < amount then
    return {
      r = state.r - (state.r * (dist / amount)),
      g = state.g - (state.g * (dist / amount)),
      b = state.b - (state.b * (dist / amount)),
    }
  else
    -- Otherwise, return the original pixel
    return {skip=true}
  end
end
