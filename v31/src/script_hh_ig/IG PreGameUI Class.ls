on construct me 
  me.ancestor.construct()
  me.pViewMode = #teams
  me.pViewModeComponents.setaProp(#teams, [#modal, "ProgressBar", "Teams", "Countdown"])
  me.pViewModeComponents.setaProp(#countdown, ["Countdown"])
  return TRUE
end

on deconstruct me 
  return(me.ancestor.deconstruct())
end

on displayPlayer me, tPlayerInfo 
  if me.pViewMode <> #teams then
    return TRUE
  end if
  tComponent = me.getSubComponent("Teams")
  if (tComponent = 0) then
    return FALSE
  end if
  return(tComponent.displayPlayer(tPlayerInfo))
end

on displayPlayerLeft me, tID 
  if me.pViewMode <> #teams then
    return TRUE
  end if
  tComponent = me.getSubComponent("Teams")
  if (tComponent = 0) then
    return FALSE
  end if
  return(tComponent.displayPlayerLeft(tID))
end

on displayProgress me, tProgress 
  tComponent = me.getSubComponent("ProgressBar")
  if (tComponent = 0) then
    return FALSE
  end if
  return(tComponent.render(tProgress))
end

on displayPlayerDone me, tID, tFigure, tsex 
  if me.pViewMode <> #teams then
    return TRUE
  end if
  tComponent = me.getSubComponent("Teams")
  if (tComponent = 0) then
    return FALSE
  end if
  return(tComponent.displayPlayerDone(tID, tFigure, tsex))
end

on displayCountdown me 
  me.pViewMode = #countdown
  return(me.renderSubComponents())
end

on update me 
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
  return TRUE
end

on getSubComponentClass me, tID 
  return(["IG TeamUI Subcomponent Class", "IG PreGameUI" && tID && "Class"])
end
