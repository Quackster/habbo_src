property obligatory, fieldName, realname
global gpSplashForm, gpSplashOk

on beginSprite me
end

on checkValue me
  if (obligatory = 1) then
    if (field(sprite(me.spriteNum).member).length < 2) then
      gpSplashOk = 0
    end if
  end if
  if (fieldName contains "email") then
    s = field(sprite(me.spriteNum).member)
    if (offset("@", s) < 3) then
      gpSplashOk = 0
    end if
  end if
  addProp(gpSplashForm, ("/SplashPlastic/formHandler/AnonymousCardOrderFormHandler." & fieldName), field(sprite(me.spriteNum).member))
  addProp(gpSplashForm, (("_D:" & "/SplashPlastic/formHandler/AnonymousCardOrderFormHandler.") & fieldName), EMPTY)
end

on getPropertyDescriptionList me
  p = [:]
  addProp(p, #fieldName, [#comment: "Name[html]", #format: #string, #default: EMPTY])
  addProp(p, #realname, [#comment: "Name[visible]", #format: #string, #default: EMPTY])
  addProp(p, #obligatory, [#comment: "Obligatory", #format: #boolean, #default: 1])
  return p
end
