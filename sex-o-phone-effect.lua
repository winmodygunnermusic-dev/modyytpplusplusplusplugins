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
                ["value"] = "Sex O Phone Effect",
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
            ["name"] = "frequency",
            ["value"] = 4,
            ["type"] = "number"
        },
        }
    }
end

function run(state)
  -- params: amount (default 10), frequency (default 4)
  local amount = getParam(state, "amount", 10)
  local frequency = getParam(state, "frequency", 4)
  local r, g, b = state.r, state.g, state.b
  local wave = math.sin((state.x + state.time * frequency) * math.pi / 180)
  local displacement = wave * amount
  local newX = state.x + displacement
  if newX < 0 or newX >= state.width then
    return {skip=true}
  end
  local newR, newG, newB = state.r, state.g, state.b
  if state.x < newX then
    -- Interpolate from black to original color
    local t = (state.x / newX)
    newR, newG, newB = 
      math.floor(r * t),
      math.floor(g * t),
      math.floor(b * t)
  elseif state.x > newX then
    -- Interpolate from original color to black
    local t = ((state.x - newX) / (state.width - newX))
    newR, newG, newB = 
      math.floor(r * (1-t)),
      math.floor(g * (1-t)),
      math.floor(b * (1-t))
  end
  return {newR, newG, newB}
end
