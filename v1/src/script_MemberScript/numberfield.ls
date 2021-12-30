property maxnum

on beginSprite me 
end

on keyDown me 
  if (the keyCode = 48) then
    pass()
  end if
  if (checkKey(me, the key) = 1) then
    pass()
  else
  end if
end

on checkKey me, x 
  fname = member(sprite(me.spriteNum).undefined).name
  if (x = "\b") or (charToNum(x) = 29) or (charToNum(x) = 28) then
    return TRUE
  end if
  if fname and (length(field(0)) = 0) then
    return FALSE
  end if
  if fname and integer(field(0) & x) <= maxnum then
    return TRUE
  end if
  return FALSE
end

on getPropertyDescriptionList me 
  pList = [:]
  addProp(pList, #maxnum, [#comment:"Max number", #format:#integer, #default:100])
  return(pList)
end
