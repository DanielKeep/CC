
--[[
    Wall movement program.
    Written by Daniel Keep.

    Copyright 2013.
    Released under the MIT license.
  ]]

--[[
    Usage: wall WIDTH HEIGHT [OPTIONS] [--] COMMAND [; COMMAND ...]
  ]]

local args = {...}
local VERSION = 0.7

local YIELD_WAIT = 0.01

function main(args)
    if #args == 0 then
        showHelp()
        return
    end

    local flags =
    {
        dig = false,
        ltr = false,
        rtl = false,
        up = false,
        down = false,
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

            elseif #pargs < 2 then

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

    if #pargs ~= 2 then
        error "expected WIDTH and HEIGHT"
    end

    if #commands == 0 then
        print "Warning: no commands given."
    end

    local w = tonumber(pargs[1])
    local h = tonumber(pargs[2])

    if not w then
        error "invalid width"
    end

    if not h then
        error "invalid height"
    end

    local dig = flags.dig or false

    local xa,xb,xd      = 1,w,1
    local ya,yb,yd,ydo  = 1,h,1,-1

    local turnDir = 'turnRight'
    local turnDir_alt = 'turnLeft'

    if flags.rtl then
        turnDir,turnDir_alt = turnDir_alt,turnDir
        xa,xb,xd = xb,xa,-1
    end

    if flags.down then
        ya,yb,yd,ydo = yb,ya,-1,1
    end

    local function adv()
        advance(dig)
    end

    local function nextY()
        if yd == 1 then
            -- Going up
            while not turtle.up() do
                if dig then turtle.digUp() end
                os.sleep(YIELD_WAIT)
            end
        else
            -- Going down
            while not turtle.down() do
                if dig then turtle.digDown() end
                os.sleep(YIELD_WAIT)
            end
        end
    end

    local function turn()
        turtle[turnDir]()
        turnDir,turnDir_alt = turnDir_alt,turnDir
    end

    for x=xa,xb,xd do
        for y=ya,yb,yd do
            os.sleep(YIELD_WAIT)
            local vars =
            {
                x = x,
                y = y,
                w = w,
                h = h,
                a = w*h,
                i = ((x-1) + (y-1)*w)+1,
            }
            if not doCommands(commands, vars) then
                return
            end

            if y ~= yb then
                nextY()
            end
        end

        if x ~= xb then
            turn()
            adv()
            turn()
        end

        --turnDir,turnDir_alt = turnDir_alt,turnDir
        ya,yb,yd,ydo = yb,ya,ydo,yd
    end
end

function advance(dig)
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
    print('rect v', VERSION)
    print [[Usage: rect W H [OPTIONS] [--] COMMAND [; COMMAND]*
Options:
  -dig          Digs out blocks in order to proceed.  Default is to stop
                at obstructions.
  -ltr          Move left-to-right (default).
  -rtl          Move right-to-left.]]
end

main(args)
