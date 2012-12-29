
--[[
    Digging program.
    Written by Daniel Keep.

    Copyright 2012.
    Released under the MIT license.
  ]]

--[[
    Usage: dig [OPTIONS] [front] [up] [down]
  ]]

local args = {...}
local VERSION = 0.1

local GRAVITY_WAIT = 0.4

local front = false
local up = false
local down = false
local gravity = false

if #args == 0 then
    front = true
end

for _,arg in ipairs(args) do
    if arg == 'up' or arg == 'u' then
        up = true
    elseif arg == 'down' or arg == 'd' then
        down = true
    elseif arg == 'front' or arg == 'f' then
        front = true
    elseif arg == '-gravity' or arg == '-g' then
        gravity = true
    else
        error "invalid argument"
    end
end

if down then
    if turtle.detectDown() then turtle.digDown() end
end

if up then
    while turtle.detectUp() do
        turtle.digUp()
        if gravity then
            os.sleep(GRAVITY_WAIT)
        end
    end
end

if front then
    while turtle.detect() do
        turtle.dig()
        if gravity then
            os.sleep(GRAVITY_WAIT)
        end
    end
end
