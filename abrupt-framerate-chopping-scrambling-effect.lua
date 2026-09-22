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
                ["value"] = "Abrupt Framerate Chopping Scrambling Effect",
                ["type"] = "label"
            },
            {
                ["name"] = "Description",
                ["value"] = "YTP-style NVG pixel effect with safe default parameters.",
                ["type"] = "label"
            },
        {
            ["name"] = "amount",
            ["value"] = 5,
            ["type"] = "number"
        },
        {
            ["name"] = "speed",
            ["value"] = 10,
            ["type"] = "number"
        },
        }
    }
end

math.randomseed(12345)
local frame_skip_seed = math.random(1000)
local previous_frame = 0

function run(state)
  -- params: 
  --   amount (default=5): number of frames to randomly skip
  --   speed (default=10): speed of effect
  local skip_amount = getParam(state, "amount", 5)
  local speed = getParam(state, "speed", 10)

  if state.seed ~= frame_skip_seed then
    math.randomseed(state.seed)
    frame_skip_seed = state.seed
  end

  if state.frame ~= previous_frame then
    previous_frame = state.frame
    if math.random() < 0.1 then
      local skip = math.random(-skip_amount, skip_amount)
      local target_frame = state.frame + skip
      if target_frame < 0 then target_frame = 0 end

      -- output pixel color based on the original frame
      local r = state.r
      local g = state.g
      local b = state.b
      -- apply a simple color shift to visually distinguish skipped frames
      r = (r + (target_frame % 256)) % 256
      g = (g + (target_frame % 128)) % 256
      b = (b + (target_frame % 64)) % 256

      return {r, g, b}
    end
  end
  -- leave pixel unchanged on non-skipped frames
  return {skip=true}
end
