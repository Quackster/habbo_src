property maxlines

on exitFrame me 
  name = member(sprite(me.spriteNum).undefined).name
  if the number of line in field(0) > maxlines then
  end if
end

on getPropertyDescriptionList me 
  pList = [:]
  addProp(pList, #maxlines, [#comment:"Max number of lines", #format:#integer, #default:2])
  return(pList)
end
