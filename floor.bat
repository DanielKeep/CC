
#
# Floor cutting batch file.
# Written by Daniel Keep.
#
# Copyright 2012.
# Released under the MIT license.
#

#
# Usage: batch floor.bat WIDTH HEIGHT
# Place torches in the first few slots.  Place flooring in the last few slots.
#

rect $1 $2 -dig [[
  dig down up
  if $x~=1 and $x~=$1 and $y~=1 and $y~=$1 and $x%2==1 and ($x+$y-1)%4==1 then place -p down
]]
