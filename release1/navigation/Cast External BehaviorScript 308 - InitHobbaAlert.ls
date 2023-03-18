on beginSprite me
  global HobbaAlertNum, CryHelp
  if HobbaAlertNum = VOID then
    HobbaAlertNum = 1
  end if
  HobbaAlertNum = CryHelp.count
  s = CryHelp.getaProp(string(HobbaAlertNum)).getaProp("cryinguser") & RETURN & CryHelp.getaProp(string(HobbaAlertNum)).getaProp("Unit")
  member(sprite(me.spriteNum).member.name).text = s
end
