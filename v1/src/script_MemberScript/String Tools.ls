on doSpecialCharConversion s
  global gConvList
  if voidp(gConvList) then
    initConversionList()
  end if
  repeat with i = count(gConvList) down to 1
    s = stringReplace(s, getPropAt(gConvList, i), getProp(gConvList, getPropAt(gConvList, i)))
  end repeat
  return s
end

on initConversionList
  global gConvList
  gConvList = [:]
  addProp(gConvList, "&auml;", "�")
  addProp(gConvList, "&ouml;", "�")
  if not (the platform contains "win") then
    addProp(gConvList, numToChar(228), "�")
    addProp(gConvList, numToChar(246), "�")
    addProp(gConvList, numToChar(196), "�")
    addProp(gConvList, numToChar(214), "�")
    addProp(gConvList, numToChar(229), "�")
    addProp(gConvList, numToChar(197), "�")
  end if
  if (the platform contains "win") then
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
  if (delim = VOID) then
    delim = ","
  end if
  the itemDelimiter = delim
  p = [:]
  repeat with i = 1 to the number of items in s
    pair = item i of s
    addProp(p, char 1 to (offset("=", pair) - 1) of pair, char (offset("=", pair) + 1) to s.length of pair)
  end repeat
  the itemDelimiter = oldDelim
  return p
end

on charReplace s, c0, c1
  if (c0 = c1) then
    return s
  end if
  repeat while (offset(c0, s) > 0)
    put c1 into char offset(c0, s) of s
  end repeat
  return s
end

on stringReplace s, s0, s1
  a = offset(s0, s)
  c = 1
  repeat while ((a > 0) and (c < 100))
    if (a > 1) then
      s = ((char 1 to (a - 1) of s & s1) & char (a + length(s0)) to length(s) of s)
    else
      s = (s1 & char (length(s0) + 1) to length(s) of s)
    end if
    a = offset(s0, s)
    c = (c + 1)
  end repeat
  return s
end
