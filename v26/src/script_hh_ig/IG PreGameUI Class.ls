on construct(me)
  me.construct()
  me.pViewMode = #teams
  me.setaProp(#teams, [#modal, "ProgressBar", "Teams", "Countdown"])
  me.setaProp(#countdown, ["Countdown"])
  return(1)
  exit
end

on deconstruct(me)
  return(me.deconstruct())
  exit
end

on displayPlayer(me, tPlayerInfo)
  if me.pViewMode <> #teams then
    return(1)
  end if
  tComponent = me.getSubComponent("Teams")
  if tComponent = 0 then
    return(0)
  end if
  return(tComponent.displayPlayer(tPlayerInfo))
  exit
end

on displayPlayerLeft(me, tID)
  if me.pViewMode <> #teams then
    return(1)
  end if
  tComponent = me.getSubComponent("Teams")
  if tComponent = 0 then
    return(0)
  end if
  return(tComponent.displayPlayerLeft(tID))
  exit
end

on displayProgress(me, tProgress)
  tComponent = me.getSubComponent("ProgressBar")
  if tComponent = 0 then
    return(0)
  end if
  return(tComponent.render(tProgress))
  exit
end

on displayPlayerDone(me, tID, tFigure, tsex)
  if me.pViewMode <> #teams then
    return(1)
  end if
  tComponent = me.getSubComponent("Teams")
  if tComponent = 0 then
    return(0)
  end if
  return(tComponent.displayPlayerDone(tID, tFigure, tsex))
  exit
end

on displayCountdown(me)
  me.pViewMode = #countdown
  return(me.renderSubComponents())
  exit
end

on update(me)
  tComponent = me.getSubComponent("ProgressBar")
  if tComponent <> 0 then
    tComponent.update()
  end if
  tComponent = me.getSubComponent("Countdown")
  if tComponent <> 0 then
    tComponent.render()
  end if
  tComponent = me.getSubComponent("Teams")
  if tComponent <> 0 then
    tComponent.update()
  end if
  return(1)
  exit
end

on getSubComponentClass(me, tID)
  return(["IG TeamUI Subcomponent Class", "IG PreGameUI" && tID && "Class"])
  exit
end