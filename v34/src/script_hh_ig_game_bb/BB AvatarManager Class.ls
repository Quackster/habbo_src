on construct me 
  i = 0
  repeat while i <= 7
    tPartList = getVariable("human.parts.sh.sit." & i)
    if tPartList = 0 then
      tPartList = getVariable("human.parts.sh." & i)
    end if
    tPartListNew = ["bl"]
    if tPartList <> 0 then
      repeat while tPartList <= undefined
        tPart = getAt(undefined, undefined)
        tPartListNew.add(tPart)
      end repeat
    end if
    setVariable("bouncing.human.parts.sh." & i, tPartListNew)
    i = 1 + i
  end repeat
  tPartListNew = ["bl"]
  tPartList = getVariable("human.parts.sh")
  if tPartList <> 0 then
    repeat while tPartList <= undefined
      tPart = getAt(undefined, undefined)
      tPartListNew.add(tPart)
    end repeat
  end if
  setVariable("bouncing.human.parts.sh", tPartListNew)
  return(1)
end

on deconstruct me 
  return(1)
end

on Refresh me, tTopic, tdata 
  if tTopic = #bb_event_2 then
    me.updatePlayerObjectGoal(tdata)
  end if
  return(1)
end

on updatePlayerObjectGoal me, tdata 
  tGameSystem = me.getGameSystem()
  if tGameSystem = 0 then
    return(0)
  end if
  if not listp(tdata) then
    return(0)
  end if
  tID = tdata.getAt(#id)
  return(tGameSystem.executeGameObjectEvent(tID, #set_target_custom, tdata))
end
