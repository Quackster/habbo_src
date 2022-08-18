on enterFrame me 
  t = member(sprite(0).number)
  if ((member(t).charPosToLoc(member(t).text.length).locV + sprite((me.spriteNum - 1)).top) + 1) < sprite((me.spriteNum - 1)).bottom then
    sprite(me.spriteNum).rect = rect(sprite((me.spriteNum - 1)).left, ((member(t).charPosToLoc(member(t).text.length).locV + sprite((me.spriteNum - 1)).top) + 1), sprite((me.spriteNum - 1)).right, sprite((me.spriteNum - 1)).bottom)
  else
    sprite(me.spriteNum).rect = rect(sprite((me.spriteNum - 1)).left, sprite((me.spriteNum - 1)).bottom, sprite((me.spriteNum - 1)).right, sprite((me.spriteNum - 1)).bottom)
  end if
end
