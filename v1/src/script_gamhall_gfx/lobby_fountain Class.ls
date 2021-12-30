property pCounter

on beginSprite me 
  pCounter = 0
end

on exitFrame me 
  pCounter = (pCounter + 1)
  if (pCounter mod 2) then
    mname = sprite(me.spriteNum).member.name
    newMName = mname.char[1..(mname.length - 1)] & random(7)
    if getmemnum(newMName) > 0 then
      sprite(me.spriteNum).castNum = getmemnum(newMName)
    end if
  end if
end
