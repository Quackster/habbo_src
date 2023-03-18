on prepareFrame me
  global MyfigurePartList, MyfigureColorList
  sprite(113).member = WhichMember(#fc)
  sprite(114).member = WhichMember(#ey)
  sprite(113).bgColor = getaProp(MyfigureColorList, #fc)
  sprite(114).bgColor = getaProp(MyfigureColorList, #ey)
  sprite(116).bgColor = getaProp(MyfigureColorList, #lh)
  sprite(120).bgColor = getaProp(MyfigureColorList, #ls)
end

on WhichMember whichPart
  global MyfigurePartList, MyfigureColorList
  memName = "h_" & "sml" & "_" & string(whichPart) & "_" & getaProp(MyfigurePartList, whichPart) & "_" & "3" & "_" & "0"
  memNum = the number of member memName
  return memNum
end
