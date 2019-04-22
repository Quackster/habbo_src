property locZ

on print me 
  tsprite = sprite(me.spriteNum)
  put(tsprite && member.name & "\r" & "location:  " && tsprite.loc & "\r" & "-- -- -- -- -- -- -- -- -- -- -- --")
end

on getBehaviorDescription me 
  return("Defines sprite's locZ in room visualizers...")
end

on getPropertyDescriptionList me 
  tList = [:]
  tList.setAt(#locZ, [#format:#integer, #default:0, #comment:"locZ modifier:"])
  return(tList)
end
