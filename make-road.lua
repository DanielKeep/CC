
--[[
    TwelveCraft make road.
    Written by Daniel Keep.

    Copyright 2013.
    Released under the MIT license.
  ]]

--[[
    Usage: make-road [-gravity] [-floor] [LENGTH]

    Note: LENGTH can also be a negative number indicating that the road should
    be the default length *minus* a given distance.  Useful for resuming an
    aborted run.
  ]]

local args = {...}
local VERSION = 0.6

local DEFAULT_LENGTH = 31
local CHECK_FLOOR = false

local EDGE_SLOT = 1
local PAVE_SLOT = 2
local FLOOR_SLOT = 15
local FUEL_SLOT = 16
local SEARCH_SLOT_FIRST = 3
local SEARCH_SLOT_LAST = 15

local GRAVITY_WAIT = 0
local YIELD_WAIT = 0.01
local DEFAULT_GRAVITY_WAIT = 0.4

local FORWARD = 0
local RIGHT = 1
local BACK = 2
local LEFT = 3

local t = turtle
local heading = 0

local length = DEFAULT_LENGTH

for i,arg in ipairs(args) do
    if arg == "-gravity" then
        GRAVITY_WAIT = DEFAULT_GRAVITY_WAIT
    elseif arg == "-floor" then
        CHECK_FLOOR = true
    elseif tonumber(arg) ~= nil then
        local n = tonumber(arg)
        if n < 0 then
            length = length + n
        else
            length = tonumber(arg)
        end
    else
        print("Usage: make-road [-gravity] [-floor] [LENGTH]")
        return
    end
end

print("make-road v", VERSION)

do
    local abort = false

    local fuelNeeded = 2 + length*5
    if CHECK_FLOOR then
        fuelNeeded = fuelNeeded + length*5*2
    end
    t.select(FUEL_SLOT)
    while t.getFuelLevel() < fuelNeeded do
        if not t.refuel(1) then
            print(string.format("Need fuel level of %d; currently have %d.",
                fuelNeeded, t.getFuelLevel()))
            abort = true
        end
    end

    local edgeNeeded = 2*length
    local edgeGot = t.getItemCount(EDGE_SLOT)
    t.select(EDGE_SLOT)
    for i=SEARCH_SLOT_FIRST, SEARCH_SLOT_LAST do
        if t.compareTo(i) then
            edgeGot = edgeGot + t.getItemCount(i)
        end
    end
    if edgeGot < edgeNeeded then
        print(string.format("Need %d edge blocks, have %d.",
            edgeNeeded, edgeGot))
        abort = true
    end

    local paveNeeded = 3*length
    local paveGot = t.getItemCount(PAVE_SLOT)
    t.select(PAVE_SLOT)
    for i=SEARCH_SLOT_FIRST, SEARCH_SLOT_LAST do
        if t.compareTo(i) then
            paveGot = paveGot + t.getItemCount(i)
        end
    end
    if paveGot < paveNeeded then
        print(string.format("Need %d paving blocks, have %d.",
            paveNeeded, paveGot))
        abort = true
    end

    if CHECK_FLOOR then
        local floorNeeded = 5*length
        local floorGot = t.getItemCount(FLOOR_SLOT)
        t.select(FLOOR_SLOT)
        for i=SEARCH_SLOT_FIRST, SEARCH_SLOT_LAST do
            if t.compareTo(i) then
                floorGot = floorGot + t.getItemCount(i)
            end
        end
        if floorGot < floorNeeded then
            print(string.format("WARNING: may need up to %d flooring blocks, "
                .. "have %d.", floorNeeded, floorGot))
            if floorGot == 0 then
                abort = true
            end
        end
    end

    if abort then return end
end

local function ccw()
    t.turnLeft()
    heading = (heading - 1) % 4
end

local function cw()
    t.turnRight()
    heading = (heading + 1) % 4
end

local function face(h)
    h = h % 4
    local diff = h - heading
    local dir = cw
    if (diff < 0 and diff >= -2) or diff == 3 then
        dir = ccw
    end
    while heading ~= h do dir() end
end

local function faceLeft()
    face(LEFT)
end

local function faceRight()
    face(RIGHT)
end

local function faceForward()
    face(FORWARD)
end

local function ensure(fn, ...)
    while not fn(...) do
        os.sleep(YIELD_WAIT)
    end
end

local function forward(dontClearDown)
    local noDown = dontClearDown or false
    while t.detect() do
        t.dig()
        os.sleep(GRAVITY_WAIT)
    end
    ensure(t.forward)
    while t.detectUp() do
        t.digUp()
        os.sleep(GRAVITY_WAIT)
    end
    if t.detectDown() and not dontClearDown then
        t.digDown()
    end
end

local function placeFromSlot(testSlot, dir)
    local slot = testSlot
    t.select(testSlot)
    for i=SEARCH_SLOT_FIRST, SEARCH_SLOT_LAST do
        if t.compareTo(i) then
            slot = i
            break
        end
    end
    t.select(slot)
    if t.compareDown() then
        -- Nothing to do
        return
    end
    if dir ~= nil then
        face(dir)
    end
    ensure(t.placeDown)
end

local function floor()
    if not CHECK_FLOOR then return end
    t.down()
    if not t.detectDown() then
        placeFromSlot(FLOOR_SLOT)
    end
    t.up()
end

local function edge(h)
    floor()
    placeFromSlot(EDGE_SLOT, h)
end

local function pave()
    floor()
    placeFromSlot(PAVE_SLOT)
end

local function times(n, fn, ...)
    for i=1,n do fn(...) end
end

faceLeft()
times(2, forward)

local dir = RIGHT

for i=1,length do
    os.sleep(YIELD_WAIT)
    t.digDown()
    edge(-dir)
    face(dir)
    times(3, function()
        forward()
        pave()
    end)
    forward()
    edge(dir)
    faceForward()
    forward(true)
    dir = -dir
end

face(dir)
times(2, forward, true)
faceForward()
