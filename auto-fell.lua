
--[[
    Automated tree felling.
    Written by Daniel Keep.

    Copyright 2013.
    Released under the MIT license.
  ]]

--[[
    Usage: auto-fell

    Chest with bone meal or sulphur goo should be behind the turtle,
    a chest with saplings to the right, and the chest for logs to the left.
    The dirt block on which to grow trees should be in front of the turtle.
  ]]

local args = {...}
local VERSION = 0.1

local BONEMEAL_SLOT = 1
local SAPLING_SLOT = 2
local SAMPLE_SLOT = 3
local STORAGE_RANGE = {3,16}
local FUEL_SLOT = 16


local FUEL_MINIMUM = 2 * 32

function main(...)
    while true do
        checkFuel()
        plantTree()
        dumpInventory()

        turtle.select(SAMPLE_SLOT)
        turtle.dig()
        goForward()

        while logAbove() do
            yield()
            turtle.digUp()
            goUp()
        end

        while not turtle.detectDown() do
            yield()
            goDown()
        end

        goBack()
        dumpInventory()
    end
end

function yield()
    os.sleep(0)
end

function checkFuel()
    if turtle.getFuelLevel() < FUEL_MINIMUM then
        print('Please insert fuel into slot 16.')
        repeat
            yield()
            turtle.select(FUEL_SLOT)
            turtle.refuel()
        until turtle.getFuelLevel() >= FUEL_MINIMUM
    end
end

function plantTree()
    if turtle.getItemCount(SAPLING_SLOT) < 2 then
        yield()
        turtle.turnRight()
        turtle.select(SAPLING_SLOT)
        turtle.suck()
        turtle.turnLeft()
    end
    turtle.select(SAPLING_SLOT)
    turtle.place()
    repeat
        yield()
        if turtle.getItemCount(BONEMEAL_SLOT) == 0 then
            yield()
            turtle.turnRight()
            turtle.turnRight()
            turtle.select(BONEMEAL_SLOT)
            turtle.suck()
            turtle.turnLeft()
            turtle.turnLeft()
        end
        turtle.select(BONEMEAL_SLOT)
        turtle.place()
        turtle.select(SAPLING_SLOT)
    until not turtle.compare()
end

function dumpInventory()
    for i=STORAGE_RANGE[1],STORAGE_RANGE[2] do
        yield()
        if turtle.getItemCount(i) > 0 then
            turtle.select(i)
            if turtle.compareTo(SAPLING_SLOT) then
                yield()
                turtle.turnRight()
                turtle.drop()
                turtle.turnLeft()
            elseif turtle.compareTo(BONEMEAL_SLOT) then
                yield()
                turtle.turnRight()
                turtle.turnRight()
                turtle.drop()
                turtle.turnLeft()
                turtle.turnLeft()
            else
                yield()
                turtle.turnLeft()
                turtle.drop()
                turtle.turnRight()
            end
        end
    end
end

function goForward()
    while not turtle.forward() do
        yield()
    end
end

function goBack()
    while not turtle.back() do
        yield()
    end
end

function goUp()
    while not turtle.up() do
        yield()
    end
end

function goDown()
    while not turtle.down() do
        yield()
    end
end

function logAbove()
    turtle.select(SAMPLE_SLOT)
    return turtle.compareUp()
end

main(args)
