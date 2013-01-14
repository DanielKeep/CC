
--[[
    Waiting program.
    Written by Daniel Keep.

    Copyright 2012.
    Released under the MIT license.
  ]]

--[[
    Usage: wait-on CONDITION

    Where CONDITION is one or more of:

    - free-slot
  ]]

local args = {...}
local VERSION = 0.1

function main(args)
    local conds =
    {
        ["free-slot"] = false
    }

    local gotCond = false

    for i,arg in ipairs(args) do
        if conds[arg] == nil then
            error("invalid argument '"..arg.."'")
        end
        gotCond = true
        conds[arg] = true
    end

    local satisfied = false
    repeat
        os.sleep(0)
        satisfied = true
        if conds['free-slot'] and satisfied then
            local foundSpace = false
            for i=1,16 do
                if turtle.getItemCount(i) == 0 then
                    foundSpace = true
                    break
                end
                if not foundSpace then
                    satisfied = false
                end
            end
        end
    until satisfied
end

main(args)
