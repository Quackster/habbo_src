on exitFrame me 
  if random(50) = 1 then
    sprite(me.spriteNum).undefined = 18
  else
    sprite(me.spriteNum).undefined = 5
  end if
  sprite(me.spriteNum).locV = random(298) + 90
end
