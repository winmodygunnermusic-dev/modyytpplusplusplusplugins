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
                ["value"] = "Mysterious Zoom Effect For Video",
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
            ["name"] = "speed",
            ["value"] = 1.0,
            ["type"] = "number"
        },
        }
    }
end

-- Mysterious Zoom Effect
-- A zooming effect that makes the video appear to zoom in and out.

-- Tunable parameters
--   * amount: zoom amount (default: 0.1)
--   * speed: zoom speed (default: 1.0)

function run(state)
  local amount = getParam(state, "amount", 0.1)
  local speed = getParam(state, "speed", 1.0)

  -- Calculate zoom factor
  local zoomFactor = 1 + math.sin(state.time * speed) * amount

  -- Calculate new pixel coordinates
  local px = state.x / zoomFactor + (state.width / 2) * (1 - 1 / zoomFactor)
  local py = state.y / zoomFactor + (state.height / 2) * (1 - 1 / zoomFactor)

  -- Get source pixel color
  local r, g, b
  if px >= 0 and px < state.width and py >= 0 and py < state.height then
    -- Sample the source pixel at the zoomed position
    local sampleState = {
      frame = state.frame,
      time = state.time,
      width = state.width,
      height = state.height,
      x = math.floor(px),
      y = math.floor(py),
      px = px,
      py = py,
      params = state.params,
      r = state.r,
      g = state.g,
      b = state.b,
      tick = state.tick,
      seed = state.seed
    }
    local result = run(sampleState)
    if result and not result.skip then
      r, g, b = result.r, result.g, result.b
    end
  else
    -- If out of bounds, use black
    r, g, b = 0, 0, 0
  end

  -- Return the pixel color
  return {r, g, b}
end
