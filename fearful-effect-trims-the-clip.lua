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
                ["value"] = "Fearful Effect Trims The Clip",
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
            ["name"] = "offset_x",
            ["value"] = 0,
            ["type"] = "number"
        },
        {
            ["name"] = "offset_y",
            ["value"] = 0,
            ["type"] = "number"
        },
        }
    }
end

function run(state)
  -- Configurable parameters
  -- amount: controls the intensity of the fear expression (default: 0.5)
  -- offset_x: horizontal offset of the fear expression (default: 0)
  -- offset_y: vertical offset of the fear expression (default: 0)
  local amount = getParam(state, "amount", 0.5)
  local offset_x = getParam(state, "offset_x", 0)
  local offset_y = getParam(state, "offset_y", 0)

  -- Fear expression pixels (simple triangle for eyes and a curve for mouth)
  local eye_radius = 5
  local mouth_curve = function(x) return 10 * math.sin(x * math.pi) end

  -- Draw fear expression
  local r, g, b = state.r, state.g, state.b
  if state.x > state.width / 2 - 50 + offset_x and state.x < state.width / 2 + 50 + offset_x then
    if state.y > state.height / 2 - 30 + offset_y and state.y < state.height / 2 - 10 + offset_y then
      -- Left eye
      local dx = state.x - (state.width / 2 - 20 + offset_x)
      local dy = state.y - (state.height / 2 - 20 + offset_y)
      if dx * dx + dy * dy < eye_radius * eye_radius then
        r, g, b = 255, 255, 255
      end
    elseif state.y > state.height / 2 + 10 + offset_y and state.y < state.height / 2 + 30 + offset_y then
      -- Right eye
      local dx = state.x - (state.width / 2 + 20 + offset_x)
      local dy = state.y - (state.height / 2 - 20 + offset_y)
      if dx * dx + dy * dy < eye_radius * eye_radius then
        r, g, b = 255, 255, 255
      end
    elseif state.y > state.height / 2 + 40 + offset_y and state.y < state.height / 2 + 60 + offset_y then
      -- Mouth
      local mouth_x = (state.x - (state.width / 2 + offset_x)) / 30
      if math.abs(mouth_x) < 1 and state.y > state.height / 2 + 40 + offset_y + mouth_curve(mouth_x) then
        r, g, b = 255, 0, 0
      end
    end
  end

  -- Apply fear expression with given amount
  local result_r = r * (1 - amount) + 128 * amount
  local result_g = g * (1 - amount) + 128 * amount
  local result_b = b * (1 - amount) + 128 * amount
  return {result_r, result_g, result_b}
end
