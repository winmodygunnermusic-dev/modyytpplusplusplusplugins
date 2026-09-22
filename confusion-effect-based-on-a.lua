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
                ["value"] = "Confusion Effect Based On A",
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
        }
    }
end

-- Confusion Effect
-- Applies an inverted mirror effect

function run(state)
  -- params: 
  --   amount (0-100): intensity of the effect (default: 50)
  local amount = getParam(state, "amount", 50)
  
  -- Calculate pixel coordinates
  local x, y = state.x, state.y
  local width, height = state.width, state.height
  
  -- Mirror and invert
  local mx = width - x - 1
  local my = height - y - 1
  
  -- Blend original and mirrored pixels
  local r, g, b = state.r, state.g, state.b
  if amount > 0 then
    local mr, mg, mb = state.px < mx and state.py < my 
                      and state.rgbs[mx + my * width].r 
                      or 0, 
                      state.px < mx and state.py < my 
                      and state.rgbs[mx + my * width].g 
                      or 0, 
                      state.px < mx and state.py < my 
                      and state.rgbs[mx + my * width].b 
                      or 0
    r = (r + mr * (amount / 100)) / (1 + amount / 100)
    g = (g + mg * (amount / 100)) / (1 + amount / 100)
    b = (b + mb * (amount / 100)) / (1 + amount / 100)
  end
  
  -- Clamp and return
  r = math.floor(math.max(0, math.min(r, 255)))
  g = math.floor(math.max(0, math.min(g, 255)))
  b = math.floor(math.max(0, math.min(b, 255)))
  return {r, g, b}
end
