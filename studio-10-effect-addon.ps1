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
                ["value"] = "Studio 10 Effect Addon",
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

-- Studio 10 Effect: Pixelate and displace pixels with a soft sine wave
function run(state)
  local x, y = state.x, state.y
  local px, py = state.px, state.py
  local r, g, b = state.r, state.g, state.b
  
  -- Tunable parameters
  -- amount: pixelate size (default=10)
  -- speed: wave speed (default=1)
  local amount = getParam(state, "amount", 10)
  local speed = getParam(state, "speed", 1)

  -- Pixelate
  local pixelX = math.floor(x / amount) * amount
  local pixelY = math.floor(y / amount) * amount
  local dx = (x - pixelX) / amount
  local dy = (y - pixelY) / amount

  -- Displace with sine wave
  local waveOffset = state.tick() * speed
  local waveAmp = amount / 2
  local displaceX = math.sin((pixelX + waveOffset) / 10) * waveAmp
  local displaceY = math.cos((pixelY + waveOffset) / 10) * waveAmp
  local displacedX = pixelX + displaceX
  local displacedY = pixelY + displaceY

  -- Sample from displaced position
  local ir, ig, ib
  if displacedX >= 0 and displacedX < state.width and displacedY >= 0 and displacedY < state.height then
    local sampleX = math.floor(displacedX)
    local sampleY = math.floor(displacedY)
    local sx = displacedX - sampleX
    local sy = displacedY - sampleY

    -- Bilinear interpolation
    local r00, g00, b00 = state.r, state.g, state.b
    if sampleX > 0 then
      r00, g00, b00 = state.r, state.g, state.b
    end
    local r10, g10, b10 = state.r, state.g, state.b
    if sampleX < state.width - 1 then
      r10, g10, b10 = state.r, state.g, state.b
    end
    local r01, g01, b01 = state.r, state.g, state.b
    if sampleY > 0 then
      r01, g01, b01 = state.r, state.g, state.b
    end
    local r11, g11, b11 = state.r, state.g, state.b
    if sampleX < state.width - 1 and sampleY > 0 then
      r11, g11, b11 = state.r, state.g, state.b
    end

    ir = r00 * (1 - sx) * (1 - sy) + r10 * sx * (1 - sy) + r01 * (1 - sx) * sy + r11 * sx * sy
    ig = g00 * (1 - sx) * (1 - sy) + g10 * sx * (1 - sy) + g01 * (1 - sx) * sy + g11 * sx * sy
    ib = b00 * (1 - sx) * (1 - sy) + b10 * sx * (1 - sy) + b01 * (1 - sx) * sy + b11 * sx * sy
  else
    ir, ig, ib = r, g, b
  end

  return {math.floor(ir), math.floor(ig), math.floor(ib)}
end
