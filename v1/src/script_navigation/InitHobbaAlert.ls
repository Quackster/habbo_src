on beginSprite me 
  if (HobbaAlertNum = void()) then
    HobbaAlertNum = 1
  end if
  HobbaAlertNum = CryHelp.count
  s = CryHelp.getaProp(string(HobbaAlertNum)).getaProp("cryinguser") & "\r" & CryHelp.getaProp(string(HobbaAlertNum)).getaProp("Unit")
  member(sprite(me.spriteNum).member.name).text = s
end
