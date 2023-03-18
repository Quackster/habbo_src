property selected
global gPoker

on beginSprite me
  select(me, 0)
  register(gPoker, me)
end

on setCard me, card
  sprite(me.spriteNum).castNum = getmemnum(card)
end

on mouseDown me
  if gPoker.changed = 0 then
    select(me, not selected)
  end if
end

on select me, s
  selected = s
  sprite(me.spriteNum + 1).visible = selected
end
