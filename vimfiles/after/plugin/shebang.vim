if !exists(":AddShebangPattern")
  finish
endif

AddShebangPattern! applescript ^#!.*\s\+osascript\>
AddShebangPattern! applescript ^#!.*[s]\?bin/osascript\>
