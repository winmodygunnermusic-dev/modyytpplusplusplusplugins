-- Seed with os.time() at load time; tick() is only available during rendering.
math.randomseed(os.time())

-- Hateful Effect
function run(state)
    -- List of addons to apply
    local addons = {
        function(r, g, b) return g, b, r end, -- Dankify: Simple RGB Shift
        function(r, g, b)
            local gray = (r + g + b) / 3
            return r - gray, g - gray, b - gray
        end, -- G-Major: Simple Chroma Key
        function(r, g, b)
            local pixelateSize = 5
            return math.floor(r / pixelateSize) * pixelateSize,
                   math.floor(g / pixelateSize) * pixelateSize,
                   math.floor(b / pixelateSize) * pixelateSize
        end, -- Luig Group: Simple Pixelate
        function(r, g, b)
            r = r + math.random(-20, 20)
            g = g + math.random(-20, 20)
            b = b + math.random(-20, 20)
            return math.max(0, math.min(255, r)),
                   math.max(0, math.min(255, g)),
                   math.max(0, math.min(255, b))
        end  -- HyCam2 Effect: Simple Noise
    }

    -- Trim the material to be very short
    local params = state.params or {}
    local trimmedHeight = params.trim_height or 10
    local yRatio = state.y / state.height
    if yRatio > trimmedHeight / state.height then
        return {skip=true}
    end

    -- Select a random addon and apply it
    local addon = addons[math.random(1, #addons)]
    local r, g, b = addon(state.r, state.g, state.b)
    for i = 1, (params.iterations or 5) - 1 do
        r, g, b = addon(r, g, b)
    end

    return {r, g, b}
end
