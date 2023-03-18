property pSkillLevelList, pCreatedAvatarObjList

on construct me
  pSkillLevelList = [:]
  registerMessage(#create_user, me.getID(), #storeCreatedAvatarInfo)
  return 1
end

on deconstruct me
  unregisterMessage(#create_user, me.getID())
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
  tSkillStr = replaceChunks(getText("bb_user_skill"), "\x", tSkillLevel)
  tSkillStr = replaceChunks(tSkillStr, "\y", tSkillValue)
  tSkillStr = replaceChunks(tSkillStr, "\r", RETURN)
  tUserObj.pCustom = tSkillStr
  tUserObj.pInfoStruct[#custom] = tSkillStr
  return 1
end
