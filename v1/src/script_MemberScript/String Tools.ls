on doSpecialCharConversion s 
  if voidp(gConvList) then
    initConversionList()
  end if
  i = count(gConvList)
  repeat while i >= 1
    s = stringReplace(s, getPropAt(gConvList, i), getProp(gConvList, getPropAt(gConvList, i)))
    i = (65535 + i)
  end repeat
  return(s)
end

on initConversionList  
  gConvList = [:]
  addProp(gConvList, "&auml;", "�")
  addProp(gConvList, "&ouml;", "�")
  if not the platform contains "win" then
    addProp(gConvList, numToChar(228), "�")
    addProp(gConvList, numToChar(246), "�")
    addProp(gConvList, numToChar(196), "�")
    addProp(gConvList, numToChar(214), "�")
    addProp(gConvList, numToChar(229), "�")
    addProp(gConvList, numToChar(197), "�")
  end if
  if the platform contains "win" then
    addProp(gConvList, numToChar(138), numToChar(228))
    addProp(gConvList, numToChar(154), numToChar(246))
    addProp(gConvList, numToChar(128), numToChar(196))
    addProp(gConvList, numToChar(133), numToChar(214))
    addProp(gConvList, numToChar(140), numToChar(229))
    addProp(gConvList, numToChar(129), numToChar(197))
  end if
end

on keyValueToPropList s, delim 
  oldDelim = the itemDelimiter
  if (delim = void()) then
    delim = ","
  end if
  the itemDelimiter = delim
  p = [:]
  i = 1
  repeat while i <= the number of item in s
    pair = s.item[i]
    addProp(p, pair.char[1..(offset("=", pair) - 1)], pair.char[(offset("=", pair) + 1)..s.length])
    i = (1 + i)
  end repeat
  the itemDelimiter = oldDelim
  return(p)
end

on charReplace s, c0, c1 
  if (c0 = c1) then
    return(s)
  end if
  repeat while offset(c0, s) > 0
  end repeat
  return(s)
end

on stringReplace s, s0, s1 
  a = offset(s0, s)
  c = 1
  repeat while a > 0 and c < 100
    if a > 1 then
      s = s.char[1..(a - 1)] & s1 & s.char[(a + length(s0))..length(s)]
    else
      s = s1 & s.char[(length(s0) + 1)..length(s)]
    end if
    a = offset(s0, s)
    c = (c + 1)
  end repeat
  return(s)
end
