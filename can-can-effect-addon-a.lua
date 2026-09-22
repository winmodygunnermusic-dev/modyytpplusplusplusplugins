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
                ["value"] = "Can Can Effect Addon A",
                ["type"] = "label"
            },
            {
                ["name"] = "Description",
                ["value"] = "YTP-style NVG pixel effect with safe default parameters.",
                ["type"] = "label"
            },
        {
            ["name"] = "speed",
            ["value"] = 0.1,
            ["type"] = "number"
        },
        {
            ["name"] = "amount",
            ["value"] = 10,
            ["type"] = "number"
        },
        }
    }
end

-- Can Can Effect
-- A psychedelic swirling effect with audio-reactive color changes

local audio = {}
local tick = 0

function run(state)
  -- Tunable parameters
  -- state.params.speed (default: 0.1) - Effect speed
  -- state.params.amount (default: 10) - Effect amount
  local speed = getParam(state, "speed", 0.1)
  local amount = getParam(state, "amount", 10)

  -- Calculate color based on audio spectrum and time
  local r, g, b = 128, 128, 128
  if not audio[state.frame] then
    -- Simulate audio spectrum data (replace with actual audio data)
    audio[state.frame] = {
      low = math.sin(state.frame * 0.01) * 128 + 128,
      mid = math.sin(state.frame * 0.02) * 128 + 128,
      high = math.sin(state.frame * 0.03) * 128 + 128,
    }
  end

  -- Update tick
  tick = tick + state.tick()

  -- Color changes based on audio spectrum and time
  r = math.sin(tick * speed) * amount + audio[state.frame].low
  g = math.sin(tick * speed * 1.1) * amount + audio[state.frame].mid
  b = math.sin(tick * speed * 1.2) * amount + audio[state.frame].high

  -- Limit RGB values to valid range
  r = math.max(0, math.min(255, r))
  g = math.max(0, math.min(255, g))
  b = math.max(0, math.min(255, b))

  -- Return resulting color
  return {r, g, b}
end
