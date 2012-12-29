
--[[
    Multiple command execution program.
    Written by Daniel Keep.

    Copyright 2012.
    Released under the MIT license.
  ]]

--[[
    Usage: [[ COMMAND [;; COMMAND]... [;;;;]
  ]]

local args = {...}
local VERSION = 0.1

function main(args)
    local accum = {}
    local depth = 1

    local function flush()
        if #accum > 0 then
            if not shell.run(unpack(accum)) then
                error "failure in command"
            end
            accum = {}
        end
    end

    for i,arg in ipairs(args) do
        local skip = false

        if arg == '[[' then
            depth = depth + 1
            skip = true
        elseif arg == ';;;;' then
            depth = depth - 1
            skip = true
        end

        if depth == 0 then
            if i ~= #arg then
                error "got ';;;;' before end of arguments"
            end
            break
        end

        if not skip then
            if arg == ';;' then
                flush()
            else
                accum[#accum+1] = arg
            end
        end
    end

    if #accum > 0 then
        flush()
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
