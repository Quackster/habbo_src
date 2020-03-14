property pSkillLevelList

on construct me 
  pSkillLevelList = [:]
  registerMessage(#create_user, me.getID(), #storeCreatedAvatarInfo)
  registerMessage(#userKeywordInput, me.getID(), #showScoresChooser)
  return TRUE
end

on deconstruct me 
  unregisterMessage(#create_user, me.getID())
  unregisterMessage(#userKeywordInput, me.getID())
  return TRUE
end

on Refresh me, tTopic, tdata 
  if (tTopic = #users) then
    return TRUE
  else
    if (tTopic = #gameplayerinfo) then
      return(me.storeSkillLevels(tdata))
    end if
  end if
end

on storeCreatedAvatarInfo me, tName, tStrId 
  if pSkillLevelList.findPos(tStrId) <> 0 then
    return(me.showSkillLevel(pSkillLevelList.getAt(tStrId)))
  end if
  return TRUE
end

on storeSkillLevels me, tdata 
  repeat while tdata <= 1
    tuser = getAt(1, count(tdata))
    if not me.showSkillLevel(tuser) then
      pSkillLevelList.addProp(string(tuser.getAt(#id)), tuser)
    end if
  end repeat
  return TRUE
end

on showSkillLevel me, tdata 
  tStrId = string(tdata.getAt(#id))
  tSkillValue = tdata.getAt(#skillvalue)
  tSkillLevel = tdata.getAt(#skilllevel)
  tRoomComponent = getObject(#room_component)
  if (tRoomComponent = 0) then
    return FALSE
  end if
  tUserObj = tRoomComponent.getUserObject(tStrId)
  if (tUserObj = 0) then
    return FALSE
  end if
  tSkillStr = replaceChunks(getText("sw_user_skill"), "\\x", tSkillLevel)
  tSkillStr = replaceChunks(tSkillStr, "\\y", tSkillValue)
  tSkillStr = replaceChunks(tSkillStr, "\\r", "\r")
  tUserObj.pCustom = tSkillStr
  tUserObj.setProp(#pInfoStruct, #custom, tSkillStr)
  return TRUE
end

on showScoresChooser me, tKeyword 
  if tKeyword <> ":roomscore" then
    return FALSE
  end if
  tString = ""
  tRoomComponent = getObject(#room_component)
  if (tRoomComponent = 0) then
    return FALSE
  end if
  repeat while pSkillLevelList <= 1
    tItem = getAt(1, count(pSkillLevelList))
    tUserObj = tRoomComponent.getUserObject(string(tItem.getAt(#id)))
    if tUserObj <> 0 then
      tString = tUserObj.getName() && ":" && tItem.getAt(#skillvalue) && " - " && tItem.getAt(#skilllevel) & "\r"
    end if
  end repeat
  executeMessage(#alert, tString)
  return TRUE
end
