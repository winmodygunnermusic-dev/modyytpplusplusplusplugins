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
                ["value"] = "Spadinner Effect Settings Min Delay",
                ["type"] = "label"
            },
            {
                ["name"] = "Description",
                ["value"] = "YTP-style NVG pixel effect with safe default parameters.",
                ["type"] = "label"
            },
        {
            ["name"] = "minDelay",
            ["value"] = 0.1,
            ["type"] = "number"
        },
        {
            ["name"] = "maxDelay",
            ["value"] = 0.75,
            ["type"] = "number"
        },
        {
            ["name"] = "minSFXCount",
            ["value"] = 5,
            ["type"] = "number"
        },
        {
            ["name"] = "maxSFXCount",
            ["value"] = 10,
            ["type"] = "number"
        },
        {
            ["name"] = "useSpadinnerLibrary",
            ["value"] = 1,
            ["type"] = "number"
        },
        }
    }
end

function run(state)
  -- Settings
  local minDelay = getParam(state, "minDelay", 0.1)
  local maxDelay = getParam(state, "maxDelay", 0.75)
  local minSFXCount = getParam(state, "minSFXCount", 5)
  local maxSFXCount = getParam(state, "maxSFXCount", 10)
  local useSpadinnerLibrary = getParam(state, "useSpadinnerLibrary", 1)

  -- Simple color shift for demonstration
  local r, g, b = state.r, state.g, state.b
  if state.tick() < minDelay then
    r = math.sin(state.time * 2) * 128 + 128
    g = math.sin(state.time * 3) * 128 + 128
    b = math.sin(state.time * 4) * 128 + 128
  end

  return {r, g, b}
end
