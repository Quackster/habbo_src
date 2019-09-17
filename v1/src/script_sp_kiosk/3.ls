property obligatory, fieldName

on beginSprite me 
end

on checkValue me 
  if obligatory = 1 then
    if field(0).length < 2 then
      gpSplashOk = 0
    end if
  end if
  if fieldName contains "email" then
    s = field(0)
    if offset("@", s) < 3 then
      gpSplashOk = 0
    end if
  end if
  addProp("/SplashPlastic/formHandler/AnonymousCardOrderFormHandler." & fieldName, sprite(me.spriteNum).member, field(0))
  addProp(gpSplashForm, "_D:" & "/SplashPlastic/formHandler/AnonymousCardOrderFormHandler." & fieldName, "")
end

on getPropertyDescriptionList me 
  p = [:]
  addProp(p, #fieldName, [#comment:"Name[html]", #format:#string, #default:""])
  addProp(p, #realname, [#comment:"Name[visible]", #format:#string, #default:""])
  addProp(p, #obligatory, [#comment:"Obligatory", #format:#boolean, #default:1])
  return(p)
end
