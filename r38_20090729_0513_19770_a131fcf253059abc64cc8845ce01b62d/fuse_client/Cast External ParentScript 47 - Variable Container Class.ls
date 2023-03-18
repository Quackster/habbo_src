on construct me
  me.pItemList = [:]
  me.pItemList.sort()
  return 1
end

on deconstruct me
  me.pItemList = [:]
  return 1
end

on create me, tVariable, tValue
  if not stringp(tVariable) and not symbolp(tVariable) then
    return error(me, "String or symbol expected:" && tVariable, #create, #major)
  end if
  setaProp(me.pItemList, tVariable, tValue)
  return 1
end

on set me, tVariable, tValue
  if not stringp(tVariable) and not symbolp(tVariable) then
    return error(me, "String or symbol expected:" && tVariable, #set, #major)
  end if
  setaProp(me.pItemList, tVariable, tValue)
  return 1
end

on GET me, tVariable, tDefault
  tValue = me.pItemList.getaProp(tVariable)
  if voidp(tValue) then
    tError = "Variable not found:" && QUOTE & tVariable & QUOTE
    if not voidp(tDefault) then
      tValue = tDefault
      tError = tError & RETURN & "Using given default:" && tDefault
    else
      tValue = 0
    end if
    error(me, tError, #GET, #minor)
  end if
  return tValue
end

on getInt me, tVariable, tDefault
  tValue = integer(me.pItemList.getaProp(tVariable))
  if not integerp(tValue) then
    tError = "Variable not found:" && QUOTE & tVariable & QUOTE
    if not voidp(tDefault) then
      tValue = tDefault
      tError = tError & RETURN & "Using given default:" && tDefault
    end if
    error(me, tError, #getInt, #minor)
  end if
  return tValue
end

on getString me, tVariable, tDefault
  tValue = EMPTY
  if me.pItemList.getaProp(tVariable) = VOID then
    tError = "Variable not found:" && QUOTE & tVariable & QUOTE
    if not voidp(tDefault) and stringp(tDefault) then
      tValue = tDefault
      tError = tError & RETURN & "Using given default:" && tDefault
    end if
    error(me, tError, #getString, #minor)
  else
    tValue = string(me.pItemList.getaProp(tVariable))
  end if
  return tValue
end

on getSymbol me, tVariable, tDefault
  tValue = EMPTY
  if me.pItemList.getaProp(tVariable) = VOID then
    tError = "Variable not found:" && QUOTE & tVariable & QUOTE
    if not voidp(tDefault) and stringp(tDefault) then
      tValue = tDefault
      tError = tError & RETURN & "Using given default:" && tDefault
    end if
    error(me, tError, #getString, #minor)
  else
    tValue = symbol(me.pItemList.getaProp(tVariable))
  end if
  return tValue
end

on GetValue me, tVariable, tDefault
  tValue = value(me.pItemList.getaProp(tVariable))
  if voidp(tValue) then
    tError = "Variable not found:" && QUOTE & tVariable & QUOTE
    if not voidp(tDefault) then
      tValue = tDefault
      tError = tError & RETURN & "Using given default:" && tDefault
    end if
    error(me, tError, #GetValue, #minor)
  end if
  if (ilk(tValue) = #list) or (ilk(tValue) = #propList) then
    return tValue.duplicate()
  else
    error(me, "Using getValue to get something other than list or proplist:" && tVariable, #GetValue, #minor)
  end if
  return tValue
end

on Remove me, tVariable
  return me.pItemList.deleteProp(tVariable)
end

on exists me, tVariable
  return not voidp(me.pItemList.getaProp(tVariable))
end

on dump me, tField, tDelimiter, tOverride
  tStr = field(tField)
  tDelim = the itemDelimiter
  if voidp(tDelimiter) then
    tDelimiter = RETURN
  end if
  the itemDelimiter = tDelimiter
  if voidp(tOverride) then
    tOverride = 1
  end if
  repeat with i = 1 to tStr.item.count
    tPair = tStr.item[i]
    if (tPair.word[1].char[1] <> "#") and (tPair <> EMPTY) then
      the itemDelimiter = "="
      tProp = tPair.item[1].word[1..tPair.item[1].word.count]
      tValue = tPair.item[2..tPair.item.count]
      tValue = tValue.word[1..tValue.word.count]
      if not (tValue contains SPACE) then
        if tValue.char[1] = "#" then
          tValue = symbol(chars(tValue, 2, length(tValue)))
        else
          if integerp(integer(tValue)) then
            if length(string(integer(tValue))) = length(tValue) then
              tValue = integer(tValue)
            end if
          end if
        end if
      else
        if floatp(float(tValue)) then
          tValue = float(tValue)
        end if
      end if
      if stringp(tValue) then
        repeat with j = 1 to length(tValue)
          case charToNum(tValue.char[j]) of
          end case
        end repeat
      end if
      tPos = me.pItemList.findPos(tProp)
      if tOverride or voidp(tPos) then
        setaProp(me.pItemList, tProp, tValue)
      end if
      the itemDelimiter = tDelimiter
    end if
  end repeat
  the itemDelimiter = tDelim
  return 1
end

on clear me
  me.pItemList = [:]
end
