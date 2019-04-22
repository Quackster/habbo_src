on construct me 
  me.pItemList = [:]
  me.sort()
  return(1)
end

on deconstruct me 
  me.pItemList = [:]
  return(1)
end

on create me, tVariable, tValue 
  if not stringp(tVariable) and not symbolp(tVariable) then
    return(error(me, "String or symbol expected:" && tVariable, #create, #major))
  end if
  setaProp(me.pItemList, tVariable, tValue)
  return(1)
end

on set me, tVariable, tValue 
  if not stringp(tVariable) and not symbolp(tVariable) then
    return(error(me, "String or symbol expected:" && tVariable, #set, #major))
  end if
  setaProp(me.pItemList, tVariable, tValue)
  return(1)
end

on GET me, tVariable, tDefault 
  tValue = me.getaProp(tVariable)
  if voidp(tValue) then
    tError = "Variable not found:" && "\"" & tVariable & "\""
    if not voidp(tDefault) then
      tValue = tDefault
      tError = tError & "\r" & "Using given default:" && tDefault
    else
      tValue = 0
    end if
    error(me, tError, #GET, #minor)
  end if
  return(tValue)
end

on getInt me, tVariable, tDefault 
  tValue = integer(me.getaProp(tVariable))
  if not integerp(tValue) then
    tError = "Variable not found:" && "\"" & tVariable & "\""
    if not voidp(tDefault) then
      tValue = tDefault
      tError = tError & "\r" & "Using given default:" && tDefault
    end if
    error(me, tError, #getInt, #minor)
  end if
  return(tValue)
end

on getString me, tVariable, tDefault 
  tValue = ""
  if me.getaProp(tVariable) = void() then
    tError = "Variable not found:" && "\"" & tVariable & "\""
    if not voidp(tDefault) and stringp(tDefault) then
      tValue = tDefault
      tError = tError & "\r" & "Using given default:" && tDefault
    end if
    error(me, tError, #getString, #minor)
  else
    tValue = string(me.getaProp(tVariable))
  end if
  return(tValue)
end

on getSymbol me, tVariable, tDefault 
  tValue = ""
  if me.getaProp(tVariable) = void() then
    tError = "Variable not found:" && "\"" & tVariable & "\""
    if not voidp(tDefault) and stringp(tDefault) then
      tValue = tDefault
      tError = tError & "\r" & "Using given default:" && tDefault
    end if
    error(me, tError, #getString, #minor)
  else
    tValue = symbol(me.getaProp(tVariable))
  end if
  return(tValue)
end

on GetValue me, tVariable, tDefault 
  tValue = value(me.getaProp(tVariable))
  if voidp(tValue) then
    tError = "Variable not found:" && "\"" & tVariable & "\""
    if not voidp(tDefault) then
      tValue = tDefault
      tError = tError & "\r" & "Using given default:" && tDefault
    end if
    error(me, tError, #GetValue, #minor)
  end if
  if ilk(tValue) = #list or ilk(tValue) = #propList then
    return(tValue.duplicate())
  else
    error(me, "Using getValue to get something other than list or proplist:" && tVariable, #GetValue, #minor)
  end if
  return(tValue)
end

on Remove me, tVariable 
  return(me.deleteProp(tVariable))
end

on exists me, tVariable 
  return(not voidp(me.getaProp(tVariable)))
end

on dump me, tField, tDelimiter, tOverride 
  tStr = field(0)
  tDelim = the itemDelimiter
  if voidp(tDelimiter) then
    tDelimiter = "\r"
  end if
  the itemDelimiter = tDelimiter
  if voidp(tOverride) then
    tOverride = 1
  end if
  i = 1
  repeat while i <= tStr.count(#item)
    tPair = tStr.getProp(#item, i)
    if tPair.getPropRef(#word, 1).getProp(#char, 1) <> "#" and tPair <> "" then
      the itemDelimiter = "="
      tProp = tPair.getPropRef(#item, 1).getProp(#word, 1, tPair.getPropRef(#item, 1).count(#word))
      tValue = tPair.getProp(#item, 2, tPair.count(#item))
      tValue = tValue.getProp(#word, 1, tValue.count(#word))
      if not tValue contains space() then
        if tValue.getProp(#char, 1) = "#" then
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
        j = 1
        repeat while j <= length(tValue)
          j = 1 + j
        end repeat
      end if
      tPos = me.findPos(tProp)
      if tOverride or voidp(tPos) then
        setaProp(me.pItemList, tProp, tValue)
      end if
      the itemDelimiter = tDelimiter
    end if
    i = 1 + i
  end repeat
  the itemDelimiter = tDelim
  return(1)
end

on clear me 
  me.pItemList = [:]
end
