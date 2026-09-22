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
                ["value"] = "Middle Cut Effect",
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
        }
    }
end

function run(state)
  -- params: 
  --   amount (0-1): cut position (default: 0.5)
  local amount = getParam(state, "amount", 0.5)

  if state.y < state.height * amount then
    return {r = state.r, g = state.g, b = state.b}
  else
    return {skip = true}
  end
end
