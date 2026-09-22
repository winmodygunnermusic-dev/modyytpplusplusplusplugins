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
                ["value"] = "Sex O Phone Effect Addon",
                ["type"] = "label"
            },
            {
                ["name"] = "Description",
                ["value"] = "YTP-style NVG pixel effect with safe default parameters.",
                ["type"] = "label"
            },
        {
            ["name"] = "amount",
            ["value"] = 10,
            ["type"] = "number"
        },
        {
            ["name"] = "speed",
            ["value"] = 1,
            ["type"] = "number"
        },
        }
    }
end

-- Sex-O-Phone Effect Addon
-- Distorts pixels based on a sine wave to create a psychedelic phone-like effect

function run(state)
  local amount = getParam(state, "amount", 10)
  local speed = getParam(state, "speed", 1)

  local wave = math.sin((state.time * speed) + (state.x * 0.01))
  local distortion = wave * (amount / 100)

  local new_x = state.x + (distortion * state.width)
  local new_y = state.y

  -- boundary checking
  new_x = math.max(0, math.min(new_x, state.width - 1))
  new_y = math.max(0, math.min(new_y, state.height - 1))

  local src_r, src_g, src_b
  if new_x ~= state.x or new_y ~= state.y then
    -- get pixel at distorted position
    local distorted_state = state
    distorted_state.x = new_x
    distorted_state.y = new_y
    src_r, src_g, src_b = distorted_state.r, distorted_state.g, distorted_state.b
  else
    -- use original pixel if no distortion
    src_r, src_g, src_b = state.r, state.g, state.b
  end

  return {r = src_r, g = src_g, b = src_b}
end
