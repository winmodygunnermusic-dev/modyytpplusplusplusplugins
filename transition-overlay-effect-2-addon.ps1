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
                ["value"] = "Transition Overlay Effect 2 Addon",
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
        {
            ["name"] = "size",
            ["value"] = 0.2,
            ["type"] = "number"
        },
        }
    }
end

math.randomseed(12345)

function run(state)
  -- params: 
  --   amount (default=0.5): transition blend amount
  --   speed (default=1.0): transition speed
  --   size (default=0.2): transition overlay size
  local amount = getParam(state, "amount", 0.5)
  local speed = getParam(state, "speed", 1.0)
  local size = getParam(state, "size", 0.2)

  -- random seed for per-effect stability
  local seed = state.seed

  -- overlay center
  math.randomseed(seed)
  local ox = math.floor(state.width * (math.random() % 1))
  local oy = math.floor(state.height * (math.random() % 1))

  -- distance from overlay center
  local dx = state.x - ox
  local dy = state.y - oy
  local dist = math.sqrt(dx * dx + dy * dy)

  -- blend
  local t = (dist / (state.width * size)) 
  t = math.max(0, math.min(1, t))

  -- handle edge cases
  if t > 1 then 
    return {skip=true}
  end

  -- interpolate
  local r, g, b = state.r, state.g, state.b
  if t < amount then 
    -- transition from source
    local nr, ng, nb = state.r, state.g, state.b
    r = math.floor(nr * (1 - t / amount) + r * (t / amount))
    g = math.floor(ng * (1 - t / amount) + g * (t / amount))
    b = math.floor(nb * (1 - t / amount) + b * (t / amount))
  else 
    -- transition to target
    local tr, tg, tb = 255 - state.r, 255 - state.g, 255 - state.b
    r = math.floor(r * (1 - (t - amount) / (1 - amount)) + tr * ((t - amount) / (1 - amount)))
    g = math.floor(g * (1 - (t - amount) / (1 - amount)) + tg * ((t - amount) / (1 - amount)))
    b = math.floor(b * (1 - (t - amount) / (1 - amount)) + tb * ((t - amount) / (1 - amount)))
  end

  return {r, g, b}
end
