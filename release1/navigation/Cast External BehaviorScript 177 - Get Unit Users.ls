property unitNum
global gUnits

on mouseDown
  if not listp(gUnits) then
    return 
  end if
  l = gUnits.getPropAt(unitNum)
  sendEPFuseMsg("GETUNITUSERS /" & l)
  put "GETUNITUSERS /" & l
  put l && "-" && AddTextToField("indoors") into field "unit users head"
  put field("unit users head")
end

on getPropertyDescriptionList me
  return [#unitNum: [#comment: "Unit no", #default: 1, #format: #integer]]
end
