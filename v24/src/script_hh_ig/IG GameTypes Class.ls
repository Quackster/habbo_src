on construct(me)
  pGameTypeObjectList = []
  return(1)
  exit
end

on deconstruct(me)
  pGameTypeObjectList = []
  return(me.deconstruct())
  exit
end

on getGameTypeCount(me)
  return(3)
  exit
end

on convertGamePropsForCreate(me, tGameType, tParams)
  tFormat = me.getAction(tGameType, #get_create_defaults)
  if not listp(tFormat) then
    return(0)
  end if
  if not listp(tParams) then
    return(0)
  end if
  tOutputList = []
  i = 1
  repeat while i <= tFormat.count
    tFormatItem = tFormat.getAt(i)
    tFormatKey = tFormat.getPropAt(i)
    tFormatIlk = tFormatItem.getaProp(#ilk)
    if tParams.findPos(tFormatKey) = 0 then
      return(error(me, tFormatKey && "not defined!", #convertGamePropsForCreate))
    else
      tParamValue = tParams.getaProp(tFormatKey)
    end if
    if ilk(tParamValue) <> tFormatIlk then
      return(error(me, tFormatKey && "type mismatch." && ilk(tParamValue) && tFormatIlk, #convertGamePropsForCreate))
    end if
    if me = #integer then
      tMax = tFormatItem.getaProp(#max)
      if not voidp(tMax) and tParamValue > tMax then
        return(0)
      end if
      tMin = tFormatItem.getaProp(#min)
      if not voidp(tMin) and tParamValue < tMin then
        return(0)
      end if
      tOutputList.append(tParamValue)
    else
      if me = #string then
        if tParamValue = "" then
          return(0)
        end if
        tOutputList.append(tParamValue)
      else
        if me = #list then
          if tParamValue = "" then
            return(0)
          end if
          tCount = tParamValue.count
          tOutputList.append(tCount)
          j = 1
          repeat while j <= tCount
            tOutputList.append(tParamValue.getAt(j))
            j = 1 + j
          end repeat
          exit repeat
        end if
        if me = #not_for_server then
          nothing()
        end if
      end if
    end if
    i = 1 + i
  end repeat
  return(tOutputList)
  exit
end

on getAction(me, tGameType, tKey, tParam1, tParam2)
  tTypeObject = me.getGameTypeInformation(tGameType)
  if tTypeObject = 0 then
    return(0)
  end if
  return(tTypeObject.getAction(tKey, tParam1, tParam2))
  exit
end

on getGameTypeString(me, tGameType)
  if me = 0 then
    return("Snowwar")
  else
    if me = 1 then
      return("BB")
    else
      if me = 2 then
        return("GemHunt")
      end if
    end if
  end if
  return(0)
  exit
end

on getGameTypeInformation(me, tGameType)
  if voidp(tGameType) then
    return(0)
  end if
  tTypeObject = pGameTypeObjectList.getaProp(tGameType)
  if objectp(tTypeObject) then
    return(tTypeObject)
  end if
  tClass = "IG" && me.getGameTypeString(tGameType) && "GameType Class"
  tTypeObject = createObject(#temp, tClass)
  if not objectp(tTypeObject) then
    return(error(me, "Game type information class unavailable for game type:" && tGameType, #getGameTypeInformation))
  end if
  pGameTypeObjectList.setaProp(tGameType, tTypeObject)
  return(tTypeObject)
  exit
end