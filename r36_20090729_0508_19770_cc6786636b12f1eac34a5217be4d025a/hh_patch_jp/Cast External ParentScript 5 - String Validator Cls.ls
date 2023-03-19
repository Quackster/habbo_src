property pProhibitedCharCodes, pLastFailedCharacter

on construct me
  if not memberExists("prohibited_name_chars") then
    error(me, "Resource containing prohibited chars not found!", #construct)
    removeObject(me.getID())
  end if
  pProhibitedCharCodes = []
  pLastFailedCharacter = EMPTY
  tCharCodeList = member(getmemnum("prohibited_name_chars")).text
  repeat with i = 1 to tCharCodeList.line.count
    pProhibitedCharCodes.add(integer(tCharCodeList.line[i]))
  end repeat
  sort(pProhibitedCharCodes)
  return 1
end

on validateString me, tString
  if tString.ilk <> #string then
    return error(me, "String expected:" && tString, #validate)
  end if
  pLastFailedCharacter = EMPTY
  repeat with i = 1 to length(tString)
    tChar = char i of tString
    if pProhibitedCharCodes.getOne(charToNum(tChar)) then
      pLastFailedCharacter = tChar
      return 0
      exit repeat
    end if
  end repeat
  return 1
end

on getFailedChar me
  return pLastFailedCharacter
end
