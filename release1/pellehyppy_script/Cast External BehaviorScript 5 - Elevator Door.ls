property mode, counter, name, VerholocZ
global gpShowSprites

on beginSprite me
  if voidp(gpShowSprites) then
    gpShowSprites = [:]
  end if
  setAt(gpShowSprites, name, me.spriteNum)
  sprite(me.spriteNum).locZ = VerholocZ
  mode = #still
  counter = 0
end

on mouseDown me
end

on fuseShow_Open me
  mode = #open
end

on fuseShow_close me
  mode = #close
end

on returnMode me
  return mode
end

on exitFrame me
  if mode = #still then
    return 
  end if
  counter = (counter + 1) mod 10
  if (counter mod 3) = 0 then
    mname = sprite(me.spriteNum).member.name
    ianim = integer(the last char in mname)
    if mode = #close then
      if ianim = 0 then
        mode = #still
      else
        newName = char 1 to mname.length - 1 of mname & ianim - 1
      end if
    else
      if mode = #open then
        if ianim >= 2 then
          mode = #still
          return 
        else
          newName = char 1 to mname.length - 1 of mname & ianim + 1
        end if
      end if
    end if
    if mode = #still then
      return 
    end if
    mnum = getmemnum(newName)
    sprite(me.spriteNum).castNum = mnum
  end if
end

on getPropertyDescriptionList me
  pList = [:]
  addProp(pList, #name, [#comment: "Name", #format: #string, #default: "discofloor"])
  addProp(pList, #VerholocZ, [#comment: "locZ", #format: #integer, #default: 0])
  return pList
end
