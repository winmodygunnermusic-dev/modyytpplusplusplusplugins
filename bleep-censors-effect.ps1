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
                ["value"] = "Bleep Censors Effect",
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
            ["name"] = "size",
            ["value"] = 5,
            ["type"] = "number"
        },
        }
    }
end

-- Bleep Censors Effect
-- --------------------

-- Pixel "bleep" censor effect, randomly applies a box around pixels
function run(state)
  -- Tunable parameters
  -- amount: 0.0 (none) to 1.0 (all)
  local amount = getParam(state, "amount", 0.5)
  -- size: box size (default 5)
  local size = getParam(state, "size", 5)

  -- Determine if we should censor this pixel
  if math.random() < amount then
    -- Calculate box coordinates
    local box_x = math.floor(state.x / size) * size
    local box_y = math.floor(state.y / size) * size

    -- If pixel is within a box, censor it
    if box_x <= state.x and state.x < box_x + size and
       box_y <= state.y and state.y < box_y + size then
      -- Randomly pick a color for the censor
      local censor_r = math.random(0, 255)
      local censor_g = math.random(0, 255)
      local censor_b = math.random(0, 255)
      return {censor_r, censor_g, censor_b}
    end
  end

  -- Leave pixel unchanged if not censored
  return {skip=true}
end
