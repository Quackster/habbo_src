property sFrame, context

on mouseDown me 
  if not voidp(sFrame) and (sprite(me.spriteNum).blend = 100) then
    goContext(sFrame, context)
  end if
end

on getPropertyDescriptionList me 
  return([#sFrame:[#comment:"Marker", #format:#string, #default:""]])
end
