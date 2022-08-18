on beginSprite me 
  gFlatQueryButtonSpr = me.spriteNum
end

on mouseUp me 
  if field(0).length > 1 and (sprite(me.spriteNum).blend = 100) then
    put(field(0))
    sendSprite(gTop10SearchSprite, #disable)
    sendEPFuseMsg(0 & null & "%")
  end if
end

on disable me 
  sprite(me.spriteNum).blend = 30
end

on enable me 
  sprite(me.spriteNum).blend = 100
end
