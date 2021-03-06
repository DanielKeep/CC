
--[[
    Inline Lua execution.
    Written by Daniel Keep.

    Copyright 2012.
    Released under the MIT license.
  ]]

--[[
    Usage: do EXPRESSION
  ]]

local args = {...}
local VERSION = 0.1

local expr_fenv =
{
    math = math,
    turtle = turtle,
    os = os,
    redstone = redstone,
}

for k,v in pairs(math) do
    expr_fenv[k] = v
end

for k,v in pairs(turtle) do
    expr_fenv[k] = v
end

function expr_fenv.missing(value)
    return function(arg)
        if arg == nil then
            return value
        else
            return arg
        end
    end
end

function main(args)
    local expr = table.concat(args, ' ')
    if string.sub(expr, 1, 1) == '=' then
        expr = 'return '..string.sub(expr, 2)
    end
    local exprfn = loadstring(expr)
    if not exprfn then
        error "invalid code"
    end

    setfenv(exprfn, expr_fenv)

    local rs = pack(exprfn())
    local rss = {}
    for i,r in ipairs(rs) do
        table.insert(rss, tostring(r))
    end
    print(table.concat(rss, ', '))
end

function pack(...)
    return {...}
end

main(args)
