on construct me
  repeat with i = 0 to 7
    tPartList = getVariable("human.parts.sh.sit." & i)
    if tPartList = 0 then
      tPartList = getVariable("human.parts.sh." & i)
    end if
    tPartListNew = ["bl"]
    if tPartList <> 0 then
      repeat with tPart in tPartList
        tPartListNew.add(tPart)
      end repeat
    end if
    setVariable("bouncing.human.parts.sh." & i, tPartListNew)
  end repeat
  tPartListNew = ["bl"]
  tPartList = getVariable("human.parts.sh")
  if tPartList <> 0 then
    repeat with tPart in tPartList
      tPartListNew.add(tPart)
    end repeat
  end if
  setVariable("bouncing.human.parts.sh", tPartListNew)
  return 1
end

on deconstruct me
  return 1
end

on Refresh me, tTopic, tdata
  case tTopic of
    #bb_event_2:
      me.updatePlayerObjectGoal(tdata)
  end case
  return 1
end

on updatePlayerObjectGoal me, tdata
  tGameSystem = me.getGameSystem()
  if tGameSystem = 0 then
    return 0
  end if
  if not listp(tdata) then
    return 0
  end if
  tID = tdata[#id]
  return tGameSystem.executeGameObjectEvent(tID, #set_target_custom, tdata)
end
