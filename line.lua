
--[[
    Line movement program.
    Written by Daniel Keep.

    Copyright 2012.
    Released under the MIT license.
  ]]

--[[
    Usage: line LENGTH [OPTIONS] [--] COMMAND [; COMMAND ...]
  ]]

local args = {...}
local VERSION = 0.5

local GRAVITY_WAIT = 0.4
local YIELD_WAIT = 0.01

function main(args)
    if #args == 0 then
        showHelp()
        return
    end

    local flags =
    {
        dig = false,
        g = false,
        gravity = false,
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

            elseif #pargs < 1 then

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

    if #pargs ~= 1 then
        error "expected LENGTH"
        return
    end

    if #commands == 0 then
        print "Warning: no commands given."
    end

    local length = tonumber(pargs[1])

    if not length then
        error "invalid length"
    end

    local dig = flags.dig or false
    local gravity = flags.gravity or flags.g or false

    local function adv()
        advance(dig, gravity)
    end

    for x=1,length do
        os.sleep(YIELD_WAIT)
        local vars = { x=x, l=length, length=length }
        if not doCommands(commands, vars) then
            return
        end

        if x ~= length then
            adv()
        end
    end
end

function advance(dig, gravity)
    if dig then
        while turtle.detect() do
            turtle.dig()
            if gravity then
                os.sleep(GRAVITY_WAIT)
            else
                os.sleep(YIELD_WAIT)
            end
        end
    end
    ensure(turtle.forward)
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

    local parts = {}
    for i,part in ipairs(parts) do
        local part = string.gsub(part, "[$]([a-zA-Z_][a-zA-Z_0-9]*)", sub_var)
        parts[i] = part
    end

    return parts
end

function showHelp()
    print('line v', VERSION)
    print [[Usage: line LENGTH [OPTIONS] [--] COMMAND [; COMMAND]*
Options:
  -dig          Digs out blocks in order to proceed.  Default is to stop
                at obstructions.
  -gravity      When digging, waits for gravity blocks to fall.]]
end

main(args)
