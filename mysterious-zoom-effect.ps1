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
                ["value"] = "Mysterious Zoom Effect",
                ["type"] = "label"
            },
            {
                ["name"] = "Description",
                ["value"] = "YTP-style NVG pixel effect with safe default parameters.",
                ["type"] = "label"
            },
        {
            ["name"] = "zoom",
            ["value"] = 0.5,
            ["type"] = "number"
        },
        {
            ["name"] = "centerX",
            ["value"] = 0.5,
            ["type"] = "number"
        },
        {
            ["name"] = "centerY",
            ["value"] = 0.5,
            ["type"] = "number"
        },
        }
    }
end

function run(state)
  -- params: zoom amount (0.0 - 1.0), zoom center (0.0 - 1.0)
  -- default: zoom = 0.5, centerX = 0.5, centerY = 0.5
  local zoom = getParam(state, "zoom", 0.5)
  local centerX = getParam(state, "centerX", 0.5)
  local centerY = getParam(state, "centerY", 0.5)

  local dx = (state.x / state.width) - centerX
  local dy = (state.y / state.height) - centerY

  local zoomedX = centerX + (dx * (1 - zoom))
  local zoomedY = centerY + (dy * (1 - zoom))

  if zoomedX < 0 or zoomedX >= 1 or zoomedY < 0 or zoomedY >= 1 then
    return {skip=true}
  end

  local zoomedX = math.floor(zoomedX * state.width)
  local zoomedY = math.floor(zoomedY * state.height)

  local r, g, b
  if zoomedX >= 0 and zoomedX < state.width and zoomedY >= 0 and zoomedY < state.height then
    -- NVG pixel callbacks only expose the current source pixel in this
    -- repository format, so keep the current color instead of recursively
    -- calling run() and overflowing the stack.
    r, g, b = state.r, state.g, state.b
  else
    r, g, b = 0, 0, 0
  end

  return {r = r or state.r, g = g or state.g, b = b or state.b}
end
