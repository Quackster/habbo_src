property pSkillLevelList, pCreatedAvatarObjList

on construct me
  pSkillLevelList = [:]
  registerMessage(#create_user, me.getID(), #storeCreatedAvatarInfo)
  registerMessage(#userKeywordInput, me.getID(), #showScoresChooser)
  return 1
end

on deconstruct me
  unregisterMessage(#create_user, me.getID())
  unregisterMessage(#userKeywordInput, me.getID())
  return 1
end

on Refresh me, tTopic, tdata
  case tTopic of
    #users:
      return 1
    #gameplayerinfo:
      return me.storeSkillLevels(tdata)
  end case
end

on storeCreatedAvatarInfo me, tName, tStrId
  if pSkillLevelList.findPos(tStrId) <> 0 then
    return me.showSkillLevel(pSkillLevelList[tStrId])
  end if
  return 1
end

on storeSkillLevels me, tdata
  repeat with tuser in tdata
    if not me.showSkillLevel(tuser) then
      pSkillLevelList.addProp(string(tuser[#id]), tuser)
    end if
  end repeat
  return 1
end

on showSkillLevel me, tdata
  tStrId = string(tdata[#id])
  tSkillValue = tdata[#skillvalue]
  tSkillLevel = tdata[#skilllevel]
  tRoomComponent = getObject(#room_component)
  if tRoomComponent = 0 then
    return 0
  end if
  tUserObj = tRoomComponent.getUserObject(tStrId)
  if tUserObj = 0 then
    return 0
  end if
  tSkillStr = replaceChunks(getText("sw_user_skill"), "\x", tSkillLevel)
  tSkillStr = replaceChunks(tSkillStr, "\y", tSkillValue)
  tSkillStr = replaceChunks(tSkillStr, "\r", RETURN)
  tUserObj.pCustom = tSkillStr
  tUserObj.pInfoStruct[#custom] = tSkillStr
  return 1
end

on showScoresChooser me, tKeyword
  if tKeyword <> ":roomscore" then
    return 0
  end if
  tString = EMPTY
  tRoomComponent = getObject(#room_component)
  if tRoomComponent = 0 then
    return 0
  end if
  repeat with tItem in pSkillLevelList
    tUserObj = tRoomComponent.getUserObject(string(tItem[#id]))
    if tUserObj <> 0 then
      tString = tUserObj.getName() && ":" && tItem[#skillvalue] && " - " && tItem[#skilllevel] & RETURN
    end if
  end repeat
  executeMessage(#alert, tString)
  return 1
end
