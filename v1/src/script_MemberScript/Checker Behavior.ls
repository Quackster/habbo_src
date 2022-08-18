property checked, f

on beginSprite me 
  check(me, checked)
end

on check me, b 
  checked = b
  s = member(sprite(me.spriteNum).undefined).name
  sprite(me.spriteNum).undefined = s.word[1] && b
  if b then
  else
  end if
end

on mouseDown me 
  check(me, not checked)
end

on getPropertyDescriptionList me 
  pList = [:]
  addProp(pList, #checked, [#comment:"Checked?", #format:#boolean, #default:1])
  addProp(pList, #f, [#comment:"field", #format:#string, #default:"x"])
  return(pList)
end
