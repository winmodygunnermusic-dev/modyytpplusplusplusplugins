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
                ["value"] = "Windows Xp Remix Effect",
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

-- Windows XP Remix Effect
-- A psychedelic blend of Windows XP's default wallpaper and a color gradient.

function run(state)
  -- Tunable parameters
  -- amount: 0.0 - 1.0, default 0.5 (blending amount)
  -- speed: 0.0 - 10.0, default 1.0 (gradient speed)
  local amount = getParam(state, "amount", 0.5)
  local speed = getParam(state, "speed", 1.0)
  
  -- Calculate gradient color based on pixel coordinates and time
  local gradientHue = (state.x + state.y + state.tick()) * speed
  local r, g, b = 128 + 127 * math.sin(gradientHue), 
                  128 + 127 * math.sin(gradientHue + 2 * math.pi / 3), 
                  128 + 127 * math.sin(gradientHue + 4 * math.pi / 3)
  r, g, b = math.floor(r), math.floor(g), math.floor(b)
  
  -- Blend source pixel with gradient color
  local blendedR = math.floor(state.r * (1 - amount) + r * amount)
  local blendedG = math.floor(state.g * (1 - amount) + g * amount)
  local blendedB = math.floor(state.b * (1 - amount) + b * amount)
  
  -- Return blended pixel color
  return {blendedR, blendedG, blendedB}
end
