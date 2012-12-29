
--[[
    Echo program.
    Written by Daniel Keep.

    Copyright 2012.
    Released under the MIT license.
  ]]

--[[
    Usage: echo ARGS...
  ]]

local __args__ = {...}
local VERSION = 0.1

print(table.concat(__args__, " "))
