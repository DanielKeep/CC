
--[[
    Rectangular prism movement program.
    Written by Daniel Keep.

    Copyright 2012.
    Released under the MIT license.
  ]]

--[[
    Usage: prism WIDTH HEIGHT DEPTH [OPTIONS] [--] COMMAND [; COMMAND ...]
  ]]

local args = {...}
local VERSION = 0.6

local YIELD_WAIT = 0.01

local function log(s) end

function main(args)
    if #args == 0 then
        showHelp()
        return
    end

    local flags =
    {
        dig = false,
        l = false,
        left = false,
        r = false,
        right = false,
        d = false,
        down = false,
        u = false,
        up = false,
        log = false,
    }
    local pargs = {}
    local command = nil
    local commands = {}

    local inCmd = false
    for i,arg in ipairs(args) do
        local argDone = false
        if not inCmd then
            if arg == '--' then

                inCmd = true
                argDone = true

            elseif string.sub(arg, 1, 1) == '-' then

                local name = string.sub(arg, 2)
                if flags[name] == nil then
                    error("invalid option '"..name.."'")
                end
                flags[name] = true
                argDone = true

            elseif #pargs < 3 then

                pargs[#pargs+1] = tonumber(arg)
                argDone = true

            else

                inCmd = true

            end
        end

        if inCmd and not argDone then

            if arg == ';' then
                if command ~= nil then
                    commands[#commands+1] = command
                    command = nil
                end
            else
                command = command or {}
                command[#command+1] = arg
            end

        end
    end

    if command ~= nil then
        commands[#commands+1] = command
        command = nil
    end

    if #pargs ~= 3 then
        error "expected WIDTH, HEIGHT and DEPTH"
    end

    if #commands == 0 then
        print "Warning: no commands given."
    end

    if flags.log then
        local logFile = io.open('prism.log', 'w')
        log = function(s)
            logFile:write(s)
            logFile:flush()
        end
    end

    local w = tonumber(pargs[1])
    local h = tonumber(pargs[2])
    local d = tonumber(pargs[3])

    if not w then
        error "invalid width"
    end

    if not h then
        error "invalid height"
    end

    if not d then
        error "invalid depth"
    end

    local dig = flags.dig or false

    local turnDir = 'turnRight'
    local turnDir_alt = 'turnLeft'

    local yDir = 'up'
    local yDig = 'digUp'
    local yDet = 'detectUp'

    local function adv()
        advance(dig)
    end

    local function turn()
        log('t' .. string.sub(turnDir, 5,5))
        turtle[turnDir]()
    end

    local function nextLevel()
        log('n')
        while not turtle[yDir]() do
            if dig then turtle[yDig]() end
            os.sleep(YIELD_WAIT)
        end
        turn()
        turn()
    end

    local xa,xb,xd,xdo = 1,w,1,-1
    local ya,yb,yd = 1,h,1
    local za,zb,zd,zdo = 1,d,1,-1

    if flags.rtl then
        turnDir,turnDir_alt = turnDir_alt,turnDir
        xa,xb,xd,xdo = xb,xa,-1,1
    end

    if flags.d or flags.down then
        yDir = 'down'
        yDig = 'digDown'
        yDet = 'detectDown'
        ya,yb,yd = yb,ya,-1
    end

    for y=ya,yb,yd do
        log('y' .. tostring(y))
        for x=xa,xb,xd do
            log('x' .. tostring(x))
            for z=za,zb,zd do
                log('z' .. tostring(z))
                os.sleep(YIELD_WAIT)
                local vars =
                {
                    x = x,
                    y = y,
                    z = z,
                    w = w,
                    h = h,
                    d = d,
                    v = w*h*d,
                    i = ((z-1) + (x-1)*d + (y-1)*w*d)+1,
                }
                if not doCommands(commands, vars) then
                    return
                end

                if z ~= zb then
                    adv()
                end
            end

            if x ~= xb then
                turn()
                adv()
                turn()
            end

            turnDir,turnDir_alt = turnDir_alt,turnDir
            za,zb,zd,zdo = zb,za,zdo,zd
        end

        xa,xb,xd,xdo = xb,xa,xdo,xd

        if y ~= yb then
            turnDir,turnDir_alt = turnDir_alt,turnDir
            nextLevel()
        end
    end
end

function advance(dig)
    log('a')
    while not turtle.forward() do
        if dig then turtle.dig() end
        os.sleep(YIELD_WAIT)
    end
end

function ensure(fn, ...)
    while not fn(...) do
        os.sleep(YIELD_WAIT)
    end
end

function doCommands(commands, vars)
    log('d')
    for _,cmd in ipairs(commands) do
        local cmd = replace_vars(cmd, vars)
        local success = shell.run(unpack(cmd))
        if not success then
            return false
        end
    end
    return true
end

function unpack(table)
    local n = #table
    local function tail(i)
        if i < n then
            return table[i], tail(i+1)
        else
            return table[i]
        end
    end
    return tail(1)
end

function replace_vars(parts, vars)
    local function sub_var(c)
        if vars[c] ~= nil then
            return tostring(vars[c])
        end
        return false
    end

    local result = {}
    for i,part in ipairs(parts) do
        local part = string.gsub(part, "[$]([a-zA-Z_][a-zA-Z_0-9]*)", sub_var)
        result[i] = part
    end

    return result
end

function showHelp()
    print('prism v', VERSION)
    print [[Usage: prism W H D [OPTIONS] [--] COMMAND [; COMMAND]*
Options:
  -dig          Digs out blocks in order to proceed.  Default is to stop
                at obstructions.
  -ltr          Move left-to-right (default).
  -rtl          Move right-to-left.
  -u | -up      Moves up the prism (default).
  -d | -down    Moves down the prism.]]
end

main(args)
