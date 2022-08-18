property num

on beginSprite me 
  sprite(me.spriteNum).visible = 0
end

on exitFrame me 
  if (getmyUnit(me) = void()) then
    sprite(me.spriteNum).visible = 0
  else
    sprite(me.spriteNum).visible = 1
  end if
end

on endSprite me 
  sprite(me.spriteNum).visible = 1
end

on getmyUnit me 
  if voidp(gUnits) then
    return()
  end if
  repeat while gUnits <= 1
    l = getAt(1, count(gUnits))
    if (num = getaProp(l, "num")) then
      return(l)
    end if
  end repeat
  return(void())
end

on mouseDown me 
  if voidp(gUnits) then
    return()
  end if
  unit = getmyUnit(me)
  if unit <> void() then
    host = getaProp(unit, "host")
    gChosenUnitIp = host.char[(offset("/", host) + 1)..host.length]
    gChosenUnitPort = getaProp(unit, "port")
    goUnit(getaProp(unit, "name"))
  end if
end

on getPropertyDescriptionList me 
  return([#num:[#comment:"Num", #format:#integer, #default:1]])
end
