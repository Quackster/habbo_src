property percentNow, timeCount

on beginSprite me
  percentNow = 0
  timeCount = the timer + 30
end

on ProgresBar me, f
  percentNow = f
  s = sprite(me.spriteNum)
  s.rect = rect(s.left, s.top, s.left + (s.member.width * percentNow), s.bottom)
end

on exitFrame me
  global gConnectionOk, gConnectionInstance
  checkLoad()
  s = sprite(me.spriteNum)
  s.rect = rect(s.left, s.top, s.left + (s.member.width * percentNow), s.bottom)
  if the timer > timeCount then
    if (gConnectionOk = 1) and objectp(gConnectionInstance) then
      sendFuseMsg("STATUSOK")
    end if
    timeCount = the timer + 30
  end if
end
