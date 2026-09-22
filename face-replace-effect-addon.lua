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
                ["value"] = "Face Replace Effect Addon",
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

-- Face-Replace Effect Addon
-- Replaces a face with a playful, oscillating pattern.

function run(state)
  -- Tunable parameters
  -- amount: face detection sensitivity (default: 0.5)
  -- speed: oscillation speed (default: 1.0)
  local amount = getParam(state, "amount", 0.5)
  local speed = getParam(state, "speed", 1.0)

  -- Load face detection model (simplified for demonstration purposes)
  -- In a real implementation, use a library like OpenCV or a face detection API
  local faceDetected = (state.x + state.y) % 100 < 50

  if faceDetected then
    -- Oscillating pattern
    local oscillation = math.sin((state.time * speed) + (state.x * 0.01) + (state.y * 0.01))
    local r = math.floor((oscillation + 1) / 2 * 255)
    local g = math.floor((oscillation * 0.5 + 0.5) * 255)
    local b = math.floor((1 - oscillation) / 2 * 255)

    return {r, g, b}
  else
    -- Leave non-face pixels unchanged
    return {skip=true}
  end
end
