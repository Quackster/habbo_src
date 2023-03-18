property counter

on beginSprite me
  disable(me)
end

on disable me
  sprite(me.spriteNum).visible = 0
end

on exitFrame me
  global gMessageManager
  counter = (counter + 1) mod 3
  if counter = 2 then
    if objectp(gMessageManager) then
      if getMessageCount(gMessageManager) > 0 then
        sprite(me.spriteNum).visible = not sprite(me.spriteNum).visible
      else
        disable(me)
      end if
    end if
  end if
end
