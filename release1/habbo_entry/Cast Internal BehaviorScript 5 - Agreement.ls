property readAgreement

on beginSprite me
  if member("Agreement_field").text = "1" then
    set the member of sprite the spriteNum of me to "checkbox on"
    readAgreement = 1
  else
    set the member of sprite the spriteNum of me to "checkbox off"
    readAgreement = 0
    put readAgreement into field "Agreement_field"
  end if
end

on mouseDown me
  doSwitch(me)
end

on doSwitch me
  if readAgreement then
    set the member of sprite the spriteNum of me to "checkbox off"
    readAgreement = 0
  else
    set the member of sprite the spriteNum of me to "checkbox on"
    readAgreement = 1
  end if
  put readAgreement into field "Agreement_field"
end
