
#
# Floor cutting batch file.
# Written by Daniel Keep.
#
# Copyright 2012.
# Released under the MIT license.
#

#
# Usage: batch floor.bat WIDTH HEIGHT
# Place torches in first slot.  Note that for large rooms, you will need to
# refuel the torches on the fly.
#

rect $1 $2 -dig [[
  dig down
  if $x~=1 and $x~=$1 and $y~=1 and $y~=$1 and $x%2==1 and ($x+$y-1)%4==1 then [[
    place down 1
  ]]
]]
