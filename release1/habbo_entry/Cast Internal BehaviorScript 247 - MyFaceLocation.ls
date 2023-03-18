property spriteNum
global MyfigurePartList

on prepareFrame me
  if getaProp(MyfigurePartList, #hr) = "004" then
    put "xxx" && getaProp(MyfigurePartList, #hr)
    repeat with f = 219 to 222
      sprite(f).locV = sprite(f).locV + 5
    end repeat
  end if
end
