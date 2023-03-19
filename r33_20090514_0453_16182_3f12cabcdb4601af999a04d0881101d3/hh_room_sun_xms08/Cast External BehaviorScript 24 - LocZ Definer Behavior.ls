property locZ

on print me
  tsprite = sprite(me.spriteNum)
  put RETURN & "-- -- -- -- -- -- -- -- -- -- -- --" & RETURN & "locZ:      " && locZ & RETURN & "member:    " && tsprite.member.name & RETURN & "location:  " && tsprite.loc & RETURN & "-- -- -- -- -- -- -- -- -- -- -- --"
end

on getBehaviorDescription me
  return "Defines sprite's locZ in room visualizers..."
end

on getPropertyDescriptionList me
  tList = [:]
  tList[#locZ] = [#format: #integer, #default: 0, #comment: "locZ modifier:"]
  return tList
end
