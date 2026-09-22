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
                ["value"] = "Recall Post Render Effect Settings",
                ["type"] = "label"
            },
            {
                ["name"] = "Description",
                ["value"] = "YTP-style NVG pixel effect with safe default parameters.",
                ["type"] = "label"
            },
        {
            ["name"] = "recallTime",
            ["value"] = 5,
            ["type"] = "number"
        },
        {
            ["name"] = "clipCount",
            ["value"] = 20,
            ["type"] = "number"
        },
        {
            ["name"] = "delay",
            ["value"] = 0,
            ["type"] = "number"
        },
        {
            ["name"] = "creationLength",
            ["value"] = 5,
            ["type"] = "number"
        },
        }
    }
end

-- Recall Post-Render Effect
-- Uses the "Recall" library.

function run(state)
  -- Check if it's time to recall
  local recallTime = getParam(state, "recallTime", 5)
  local clipCount = getParam(state, "clipCount", 20)
  local delay = getParam(state, "delay", 0)
  local creationLength = getParam(state, "creationLength", 5)

  -- Get current time
  local currentTime = state.time

  -- Check if recall is active
  if currentTime > delay and currentTime < delay + creationLength then
    -- Get source pixel
    local r, g, b = state.r, state.g, state.b

    -- Apply recall effect
    -- NOTE: Since the actual implementation of the "Recall" library is unknown,
    -- we'll assume it provides a function to get the recalled pixel.
    local recalledPixel = recall.getRecalledPixel(state.seed, state.x, state.y, state.frame)
    if recalledPixel then
      r, g, b = recalledPixel.r, recalledPixel.g, recalledPixel.b
    end

    -- Return the recalled pixel
    return {r, g, b}
  else
    -- Return the original pixel
    return {skip=true}
  end
end
