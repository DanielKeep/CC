
--[[
    Line movement program.
    Written by Daniel Keep.

    Copyright 2012.
    Released under the MIT license.
  ]]

--[[
    Usage: place [OPTIONS] [front] [up] [down] [RANGE]
  ]]

local args = {...}
local VERSION = 0.3

local GRAVITY_WAIT = 0.4

local front = false
local up = false
local down = false
local dig = false
local gravity = false
local preserve = false
local range = {1,16}
local reverse = false

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
    elseif arg == '-dig' or arg == '-d' then
        dig = true
    elseif arg == '-gravity' or arg == '-g' then
        gravity = true
    elseif arg == '-preserve' or arg == '-p' then
        preserve = true
    elseif arg == '-reverse' or arg == '-r' then
        reverse = true
    elseif tonumber(arg) then
        local n = tonumber(arg)
        range = {n,n}
    else
        local newRange = nil
        string.gsub(arg, '^(1?[0-9])$',
            function(c)
                local n = tonumber(c)
                newRange = {n,n}
            end)
        string.gsub(arg, '^(1?[0-9])-(1?[0-9])$',
            function(ca, cb)
                local na = tonumber(ca)
                local nb = tonumber(cb)
                newRange = {na,nb}
            end)

        if newRange == nil then
            error "invalid argument"
        end

        if newRange[1] < 1 or newRange[1] > 16
            or newRange[2] < 1 or newRange[2] > 16
            or newRange[1] > newRange[2] then
            error "invalid inventory slot range"
        end

        range = newRange
    end
end

function findPlaceSlotThen(fn)
    local reqNum = 0
    if preserve then reqNum = 1 end
    local a,b,d = range[1],range[2],1
    if reverse then
        a,b,d = b,a,-1
    end
    for i=a,b,d do
        if turtle.getItemCount(i) > reqNum then
            turtle.select(i)
            fn()
            return
        end
    end
    error "no blocks to place"
end

if down then
    findPlaceSlotThen(function()
            if dig and turtle.detectDown() then turtle.digDown() end
            turtle.placeDown()
        end)
end

if up then
    findPlaceSlotThen(function()
            if dig then
                while turtle.detectUp() do
                    turtle.digUp()
                    if gravity then
                        os.sleep(GRAVITY_WAIT)
                    end
                end
            end
            turtle.placeUp()
        end)
end

if front then
    findPlaceSlotThen(function()
            if dig then
                while turtle.detect() do
                    turtle.dig()
                    if gravity then
                        os.sleep(GRAVITY_WAIT)
                    end
                end
            end
            turtle.place()
        end)
end
