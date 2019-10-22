property pGameTypeObjectList

on construct me 
  pGameTypeObjectList = [:]
  return TRUE
end

on deconstruct me 
  pGameTypeObjectList = [:]
  return(me.ancestor.deconstruct())
end

on getGameTypeCount me 
  return(3)
end

on convertGamePropsForCreate me, tGameType, tParams 
  tFormat = me.getAction(tGameType, #get_create_defaults)
  if not listp(tFormat) then
    return FALSE
  end if
  if not listp(tParams) then
    return FALSE
  end if
  tOutputList = []
  i = 1
  repeat while i <= tFormat.count
    tFormatItem = tFormat.getAt(i)
    tFormatKey = tFormat.getPropAt(i)
    tFormatIlk = tFormatItem.getaProp(#ilk)
    if (tParams.findPos(tFormatKey) = 0) then
      return(error(me, tFormatKey && "not defined!", #convertGamePropsForCreate))
    else
      tParamValue = tParams.getaProp(tFormatKey)
    end if
    if ilk(tParamValue) <> tFormatIlk then
      return(error(me, tFormatKey && "type mismatch." && ilk(tParamValue) && tFormatIlk, #convertGamePropsForCreate))
    end if
    if (tFormatIlk = #integer) then
      tMax = tFormatItem.getaProp(#max)
      if not voidp(tMax) and tParamValue > tMax then
        return FALSE
      end if
      tMin = tFormatItem.getaProp(#min)
      if not voidp(tMin) and tParamValue < tMin then
        return FALSE
      end if
      tOutputList.append(tParamValue)
    else
      if (tFormatIlk = #string) then
        if (tParamValue = "") then
          return FALSE
        end if
        tOutputList.append(tParamValue)
      else
        if (tFormatIlk = #list) then
          if (tParamValue = "") then
            return FALSE
          end if
          tCount = tParamValue.count
          tOutputList.append(tCount)
          j = 1
          repeat while j <= tCount
            tOutputList.append(tParamValue.getAt(j))
            j = (1 + j)
          end repeat
          exit repeat
        end if
        if (tFormatIlk = #not_for_server) then
          nothing()
        end if
      end if
    end if
    i = (1 + i)
  end repeat
  return(tOutputList)
end

on getAction me, tGameType, tKey, tParam1, tParam2 
  tTypeObject = me.getGameTypeInformation(tGameType)
  if (tTypeObject = 0) then
    return FALSE
  end if
  return(tTypeObject.getAction(tKey, tParam1, tParam2))
end

on getGameTypeString me, tGameType 
  if (tGameType = 0) then
    return("Snowwar")
  else
    if (tGameType = 1) then
      return("BB")
    else
      if (tGameType = 2) then
        return("GemHunt")
      end if
    end if
  end if
  return FALSE
end

on getGameTypeInformation me, tGameType 
  if voidp(tGameType) then
    return FALSE
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
end
