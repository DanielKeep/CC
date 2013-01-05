
--[[
    Exploratory tunnelling program.
    Written by Daniel Keep.

    Copyright 2012.
    Released under the MIT license.
  ]]

--[[
    Usage: ex-tunnel [LIMIT]
  ]]

local args = {...}
local VERSION = 0.1

function main(args)
    local limit = tonumber(args[1])
    local distance = 0
    while distance ~= limit do
        if not turtle.detect() then break end
        advance()
        if not turtle.detectDown() then break end
        if not turtle.detectUp() then break end
        turtle.digDown()
    end
    print('Distance dug: ', distance)
end

function advance()
    while not turtle.forward() do
        turtle.dig()
        os.sleep(YIELD_WAIT)
    end
end

main(args)
