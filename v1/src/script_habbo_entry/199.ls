on prepareFrame me
  global MyfigurePartList, MyfigureColorList, gMyName
  put gMyName into field "oplogo.dispname"
  sprite(127).member = WhichMember(#hd, 1)
  sprite(128).member = WhichMember(#hr, 1)
  sprite(129).member = WhichMember(#fc, 1)
  sprite(130).member = WhichMember(#ey, 1)
end
