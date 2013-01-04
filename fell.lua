
--[[
    Tree felling program.
    Written by Daniel Keep.

    Copyright 2013.
    Released under the MIT license.
  ]]

--[[
    Usage: fell [-advance]
  ]]

local args = {...}
local VERSION = 0.2
local turtle = { base = turtle }
setmetatable(turtle, { __index = turtle.base })

function turtle.smartRefuel(quantity, fuel)
    fuel = fuel or 1
    if turtle.getFuelLevel() >= fuel then
        return true
    end
    quantity = quantity or 1
    while turtle.getFuelLevel() < fuel do
        for i=1,16 do
            turtle.select(i)
            if turtle.refuel(quantity) then
                break
            end
        end
        return false
    end
    return true
end

function turtle.refuel_before(fn)
    turtle[fn] = function(...)
        turtle.smartRefuel()
        return turtle.base[fn](...)
    end
end

turtle.refuel_before "dig"
turtle.refuel_before "digUp"
turtle.refuel_before "forward"
turtle.refuel_before "up"
turtle.refuel_before "down"

local advance = false

for i,arg in ipairs(args) do
    if arg == '-a' or arg == '-adv' or arg == '-advance' then
        advance = true
    else
        print('Usage: fell [-a|-adv|-advance]')
        error "invalid argument"
    end
end

function start(initial_state)
    local next_state = initial_state

    while next_state ~= nil do
        next_state = next_state()
    end
end

function fell_tree()
    if not turtle.detect() then
        print('Nothing to fell!')
        if advance then
            turtle.forward()
        end
        return
    end

    turtle.dig()
    turtle.forward()

    local elevation = 0
    while turtle.detectUp() do
        turtle.digUp()
        turtle.up()
        elevation = elevation + 1
    end
    while elevation > 0 do
        elevation = elevation - 1
        turtle.down()
    end

    -- Look for nearby trees
    for i=1,4 do
        turtle.turnLeft()
        if turtle.detect() then
            return fell_tree
        end
    end

    return nil
end

start(fell_tree)
