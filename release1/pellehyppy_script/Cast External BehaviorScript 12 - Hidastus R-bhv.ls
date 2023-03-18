property anim, counter

on beginSprite me
  anim = [0, 1, 2, 3, 4, 5, 5, 4, 3, 2, 1, 0]
  counter = 1
end

on exitFrame me
  sprite(me.spriteNum).member = getmemnum("R_" & anim[counter])
  counter = counter + 1
  if counter > count(anim) then
    counter = 1
  end if
end
