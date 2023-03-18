global MyfigurePartList, MyfigureColorList, figurePartList, figureColorList

on prepareFrame me
  global gPopUpContext, gPopUpContext2, PurseAndHelpContext
  gPopUpContext = VOID
  gPopUpContext2 = VOID
  PurseAndHelpContext = VOID
  sprite(219).member = WhichMember(#hd)
  sprite(220).member = WhichMember(#fc)
  sprite(221).member = WhichMember(#ey)
  sprite(222).member = WhichMember(#hr)
  sprite(219).bgColor = getaProp(MyfigureColorList, #hd)
  sprite(220).bgColor = getaProp(MyfigureColorList, #fc)
  sprite(221).bgColor = getaProp(MyfigureColorList, #ey)
  sprite(222).bgColor = getaProp(MyfigureColorList, #hr)
end

on WhichMember whichPart
  global MyfigurePartList, MyfigureColorList
  memName = "h_" & "std" & "_" & string(whichPart) & "_" & getaProp(MyfigurePartList, whichPart) & "_" & "3" & "_" & 0
  memNum = the number of member memName
  return memNum
end
