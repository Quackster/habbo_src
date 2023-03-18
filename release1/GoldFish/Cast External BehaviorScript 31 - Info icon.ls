global gInfofieldIconSprite

on beginSprite me
  gInfofieldIconSprite = me.spriteNum
  sprite(me.spriteNum).visible = 0
  sprite(me.spriteNum).castNum = getmemnum("puppetSprite")
end

on setIcon me, memberPrefix
  mnum = getmemnum(memberPrefix & "_small")
  if mnum > 0 then
    sprite(me.spriteNum).castNum = mnum
    sprite(me.spriteNum).visible = 1
    sprite(726).locH = 2000
  else
    sprite(me.spriteNum).visible = 0
    sprite(me.spriteNum).castNum = getmemnum("puppetSprite")
  end if
end
