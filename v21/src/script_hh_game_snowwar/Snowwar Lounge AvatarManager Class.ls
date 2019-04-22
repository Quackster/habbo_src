property pSkillLevelList

on construct me 
  pSkillLevelList = [:]
  registerMessage(#create_user, me.getID(), #storeCreatedAvatarInfo)
  registerMessage(#userKeywordInput, me.getID(), #showScoresChooser)
  return(1)
end

on deconstruct me 
  unregisterMessage(#create_user, me.getID())
  unregisterMessage(#userKeywordInput, me.getID())
  return(1)
end

on Refresh me, tTopic, tdata 
  if tTopic = #users then
    return(1)
  else
    if tTopic = #gameplayerinfo then
      return(me.storeSkillLevels(tdata))
    end if
  end if
end

on storeCreatedAvatarInfo me, tName, tStrId 
  if pSkillLevelList.findPos(tStrId) <> 0 then
    return(me.showSkillLevel(pSkillLevelList.getAt(tStrId)))
  end if
  return(1)
end

on storeSkillLevels me, tdata 
  repeat while tdata <= undefined
    tuser = getAt(undefined, tdata)
    if not me.showSkillLevel(tuser) then
      pSkillLevelList.addProp(string(tuser.getAt(#id)), tuser)
    end if
  end repeat
  return(1)
end

on showSkillLevel me, tdata 
  tStrId = string(tdata.getAt(#id))
  tSkillValue = tdata.getAt(#skillvalue)
  tSkillLevel = tdata.getAt(#skilllevel)
  tRoomComponent = getObject(#room_component)
  if tRoomComponent = 0 then
    return(0)
  end if
  tUserObj = tRoomComponent.getUserObject(tStrId)
  if tUserObj = 0 then
    return(0)
  end if
  tSkillStr = replaceChunks(getText("sw_user_skill"), "\\x", tSkillLevel)
  tSkillStr = replaceChunks(tSkillStr, "\\y", tSkillValue)
  tSkillStr = replaceChunks(tSkillStr, "\\r", "\r")
  tUserObj.pCustom = tSkillStr
  tUserObj.setProp(#pInfoStruct, #custom, tSkillStr)
  return(1)
end

on showScoresChooser me, tKeyword 
  if tKeyword <> ":roomscore" then
    return(0)
  end if
  tString = ""
  tRoomComponent = getObject(#room_component)
  if tRoomComponent = 0 then
    return(0)
  end if
  repeat while pSkillLevelList <= undefined
    tItem = getAt(undefined, tKeyword)
    tUserObj = tRoomComponent.getUserObject(string(tItem.getAt(#id)))
    if tUserObj <> 0 then
      tString = tUserObj.getName() && ":" && tItem.getAt(#skillvalue) && " - " && tItem.getAt(#skilllevel) & "\r"
    end if
  end repeat
  executeMessage(#alert, tString)
  return(1)
end
