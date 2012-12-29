
--[[
    Conditional execution program.
    Written by Daniel Keep.

    Copyright 2012.
    Released under the MIT license.
  ]]

--[[
    Usage: if CONDITION then COMMAND [else COMMAND]
  ]]

local args = {...}
local VERSION = 0.2

local cond_fenv = {}

function cond_fenv.missing(value)
    return function(arg)
        if arg == nil then
            return value
        else
            return arg
        end
    end
end

function main(args)
    local condt = {}
    local tcmdt = nil
    local fcmdt = nil

    for i,arg in ipairs(args) do
        if tcmdt == nil then
            if arg == 'then' then
                tcmdt = {}
            else
                table.insert(condt, arg)
            end
        elseif fcmdt == nil then
            if arg == 'else' then
                fcmdt = {}
            else
                table.insert(tcmdt, arg)
            end
        else
            table.insert(fcmdt, arg)
        end
    end

    if #condt == 0 then
        error "expected condition"
    end

    if tcmdt == nil then
        error "expected 'then' clause"
    end

    local cond = table.concat(condt, ' ')
    local condfn = loadstring('return '..cond)
    if not condfn then
        error "invalid condition"
    end

    setfenv(condfn, cond_fenv)

    if condfn() then
        if #tcmdt > 0 then
            shell.run(unpack(tcmdt))
        end
    else
        if fcmdt ~= nil and #fcmdt > 0 then
            shell.run(unpack(fcmdt))
        end
    end
end

function unpack_tail(table, i)
    if i < #table then
        return table[i], unpack_tail(table, i+1)
    else
        return table[i]
    end
end

function unpack(table)
    return unpack_tail(table, 1)
end

main(args)
