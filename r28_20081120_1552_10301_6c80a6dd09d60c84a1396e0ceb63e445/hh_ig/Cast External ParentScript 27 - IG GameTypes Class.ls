property pGameTypeObjectList

on construct me
  pGameTypeObjectList = [:]
  return 1
end

on deconstruct me
  pGameTypeObjectList = [:]
  return me.ancestor.deconstruct()
end

on getGameTypeCount me
  return 3
end

on convertGamePropsForCreate me, tGameType, tParams
  tFormat = me.getAction(tGameType, #get_create_defaults)
  if not listp(tFormat) then
    return 0
  end if
  if not listp(tParams) then
    return 0
  end if
  tOutputList = []
  repeat with i = 1 to tFormat.count
    tFormatItem = tFormat[i]
    tFormatKey = tFormat.getPropAt(i)
    tFormatIlk = tFormatItem.getaProp(#ilk)
    if tParams.findPos(tFormatKey) = 0 then
      return error(me, tFormatKey && "not defined!", #convertGamePropsForCreate)
    else
      tParamValue = tParams.getaProp(tFormatKey)
    end if
    if ilk(tParamValue) <> tFormatIlk then
      return error(me, tFormatKey && "type mismatch." && ilk(tParamValue) && tFormatIlk, #convertGamePropsForCreate)
    end if
    case tFormatIlk of
      #integer:
        tMax = tFormatItem.getaProp(#max)
        if not voidp(tMax) and (tParamValue > tMax) then
          return 0
        end if
        tMin = tFormatItem.getaProp(#min)
        if not voidp(tMin) and (tParamValue < tMin) then
          return 0
        end if
        tOutputList.append(tParamValue)
      #string:
        if tParamValue = EMPTY then
          return 0
        end if
        tOutputList.append(tParamValue)
      #list:
        if tParamValue = EMPTY then
          return 0
        end if
        tCount = tParamValue.count
        tOutputList.append(tCount)
        repeat with j = 1 to tCount
          tOutputList.append(tParamValue[j])
        end repeat
      #not_for_server:
        nothing()
    end case
  end repeat
  return tOutputList
end

on getAction me, tGameType, tKey, tParam1, tParam2
  tTypeObject = me.getGameTypeInformation(tGameType)
  if tTypeObject = 0 then
    return 0
  end if
  return tTypeObject.getAction(tKey, tParam1, tParam2)
end

on getGameTypeString me, tGameType
  case tGameType of
    0:
      return "Snowwar"
    1:
      return "BB"
    2:
      return "GemHunt"
  end case
  return 0
end

on getGameTypeInformation me, tGameType
  if voidp(tGameType) then
    return 0
  end if
  tTypeObject = pGameTypeObjectList.getaProp(tGameType)
  if objectp(tTypeObject) then
    return tTypeObject
  end if
  tClass = "IG" && me.getGameTypeString(tGameType) && "GameType Class"
  tTypeObject = createObject(#temp, tClass)
  if not objectp(tTypeObject) then
    return error(me, "Game type information class unavailable for game type:" && tGameType, #getGameTypeInformation)
  end if
  pGameTypeObjectList.setaProp(tGameType, tTypeObject)
  return tTypeObject
end
