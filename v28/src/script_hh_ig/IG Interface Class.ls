property pMainWindowWrapperId, pSideWindowWrapperId, pTooltipManager

on construct me 
  pActiveMode = "GameList"
  pMainWindowWrapperId = "ig_window_wrapper"
  pSideWindowWrapperId = "ig_window2_wrapper"
  registerMessage(#toggle_ig, me.getID(), #toggleWindow)
  registerMessage(#hide_ig, me.getID(), #hideWindow)
  registerMessage(#show_ig, me.getID(), #showWindow)
  registerMessage(#show_game_info, me.getID(), #showRecommended)
  registerMessage(#hide_game_info, me.getID(), #hideRecommended)
  registerMessage(#ig_show_game_rules, me.getID(), #showGameRules)
  registerMessage(#ig_hide_game_rules, me.getID(), #hideGameRules)
  return TRUE
end

on deconstruct me 
  me.removeTooltipManager()
  removeObject(pMainWindowWrapperId)
  removeObject(pSideWindowWrapperId)
  unregisterMessage(#toggle_ig, me.getID())
  unregisterMessage(#hide_ig, me.getID())
  unregisterMessage(#show_ig, me.getID())
  unregisterMessage(#show_game_info, me.getID())
  unregisterMessage(#hide_game_info, me.getID())
  return TRUE
end

on toggleWindow me 
  if me.getComponent().getSystemState() <> #ready then
    return TRUE
  end if
  if (me.getWindowVisible() = 0) then
    return(me.showWindow())
  else
    if (me.getWindowVisible() = 1) then
      return(me.resetToDefaultAndHide())
    end if
  end if
  return TRUE
end

on showWindow me, tMode, tPage 
  if (me.getComponent().getSystemState() = 0) then
    return TRUE
  end if
  tWrapObjRef = me.getMainWindowWrapper()
  if (tWrapObjRef = 0) then
    return FALSE
  end if
  tWrapObjRef.show()
  if (tMode = void()) then
    me.ChangeWindowView(me.getComponent().getActiveIGComponentId())
  else
    me.ChangeWindowView(tMode, tPage)
  end if
  return TRUE
end

on hideWindow me 
  tComponent = me.getComponent()
  tServiceId = tComponent.getActiveIGComponentId()
  if (tServiceId = "JoinedGame") then
    return FALSE
  end if
  tService = tComponent.getIGComponent("GameList")
  if tService.getJoinedGameId() > -1 then
    return(me.ChangeWindowView("JoinedGame"))
  end if
  tService = tComponent.getActiveIGComponent()
  if tService <> 0 then
    tService.setActiveFlag(0)
  end if
  tWrapObjRef = me.getMainWindowWrapper()
  if (tWrapObjRef = 0) then
    return FALSE
  end if
  return(tWrapObjRef.hide())
end

on showRecommended me 
  if (me.getComponent().getSystemState() = 0) then
    return TRUE
  end if
  tService = me.getComponent().getIGComponent("Recommended")
  if tService <> 0 then
    tService.show()
  end if
  return TRUE
end

on hideRecommended me 
  tService = me.getComponent().getIGComponent("Recommended")
  if tService <> 0 then
    tService.hide()
  end if
  return TRUE
end

on showGameRules me 
  if me.getComponent().IGComponentExists("GameRules") then
    return(me.hideGameRules())
  end if
  tService = me.getComponent().getIGComponent("GameData")
  if (tService = 0) then
    return FALSE
  end if
  if not tService.exists(#game_type) then
    return FALSE
  end if
  tGameType = tService.getProperty(#game_type)
  tService = me.getComponent().getIGComponent("GameRules")
  if (tService = 0) then
    return FALSE
  end if
  tRenderObj = tService.getRenderer(1)
  if tRenderObj <> 0 then
    tRenderObj.toggle(tGameType)
  end if
  return TRUE
end

on hideGameRules me 
  me.getComponent().removeIGComponent("GameRules")
end

on showArenaQueue me, tQueuePos 
  tService = me.getComponent().getIGComponent("ArenaQueue")
  if (tService = 0) then
    return FALSE
  end if
  tRenderObj = tService.getRenderer(1)
  if tRenderObj <> 0 then
    tRenderObj.render(tQueuePos)
  end if
  return TRUE
end

on hideArenaQueue me 
  return(me.getComponent().removeIGComponent("ArenaQueue"))
end

on ChangeWindowView me, tMode, tPage 
  if (me.getComponent().getSystemState() = 0) then
    return TRUE
  end if
  tComponent = me.getComponent()
  if (tComponent = 0) then
    return FALSE
  end if
  tService = tComponent.getActiveIGComponent()
  tServiceId = tComponent.getActiveIGComponentId()
  if tService <> 0 then
    tServiceActive = tService.getActiveFlag()
  end if
  if tServiceId <> tMode or not tServiceActive then
    if not me.getWindowVisible() then
      tComponent.setActiveIGComponent(tMode, #hold_updates)
      return TRUE
    else
      if (tMode = "GameList") then
        executeMessage(#sendTrackingPoint, "/game/ui")
      end if
      tComponent.setActiveIGComponent(tMode)
    end if
    me.resetWindowWrapper()
  end if
  tUIService = me.getActiveUI()
  if (tUIService = 0) then
    return FALSE
  end if
  if tPage <> void() then
    if tUIService.getViewMode() <> tPage then
      tUIService.setViewMode(tPage)
    end if
  else
    tUIService.renderSubComponents()
  end if
  return TRUE
end

on resetToDefaultAndHide me 
  tComponent = me.getComponent()
  tComponent.removeIGComponent("Prejoin")
  tComponent.removeIGComponent("Recommended")
  tComponent.removeIGComponent("AfterGame")
  tComponent.removeIGComponent("GameAssetImport")
  tComponent.removeIGComponent("RoomLoader")
  tComponent.removeIGComponent("PreGame")
  tComponent.removeIGComponent("GameChat")
  tComponent.removeIGComponent("GameTypes")
  tComponent.removeIGComponent("GameRules")
  tService = tComponent.getIGComponent("GameList")
  if (tService = 0) then
    return FALSE
  end if
  if (tService.getJoinedGameId() = -1) then
    tComponent.setActiveIGComponent("GameList", #hold_updates)
    me.hideWindow()
  else
    me.ChangeWindowView("JoinedGame")
  end if
  return TRUE
end

on getUI me, tMode 
  tService = me.getComponent().getIGComponent(tMode)
  if tService <> 0 then
    tService = tService.getRenderer()
  end if
  if (tService = 0) then
    return FALSE
  end if
  return(tService)
end

on getActiveUI me 
  return(me.getUI(me.getComponent().getActiveIGComponentId()))
end

on showBasicAlert me, tKey 
  return(executeMessage(#alert, [#Msg:getText(tKey)]))
end

on getWindowVisible me 
  tWrapObjRef = me.getMainWindowWrapper()
  if (tWrapObjRef = 0) then
    return FALSE
  end if
  return(tWrapObjRef.getProperty(#visible))
end

on getMainWindowWrapper me, tClientID 
  tWrapObjRef = getObject(pMainWindowWrapperId)
  if (tWrapObjRef = 0) then
    tWrapObjRef = me.createWindowWrapper(pMainWindowWrapperId, tClientID)
    if (tWrapObjRef = 0) then
      return FALSE
    end if
    tWrapObjRef.moveTo(90, 70)
    tWrapObjRef.moveZ(1000000)
  end if
  return(tWrapObjRef)
end

on createWindowWrapper me, tID, tClientID 
  tWrapObjRef = createObject(tID, "Multicomponent Window Wrapper Class")
  if (tWrapObjRef = 0) then
    return FALSE
  end if
  tWrapObjRef.hide()
  if (tClientID = void()) then
    tClientID = me.getID()
  end if
  tWrapObjRef.registerProcedure(#eventProcMouseDown, tClientID, #mouseDown)
  tWrapObjRef.registerProcedure(#eventProcMouseHover, tClientID, #mouseEnter)
  tWrapObjRef.registerProcedure(#eventProcMouseHover, tClientID, #mouseLeave)
  return(tWrapObjRef)
end

on resetWindowWrapper me 
  tWrapObj = me.getMainWindowWrapper()
  if (tWrapObj = 0) then
    return FALSE
  end if
  tWrapObj.removeAllParts()
  return TRUE
end

on getTooltipManager me 
  if objectp(pTooltipManager) then
    return(pTooltipManager)
  end if
  pTooltipManager = createObject(#temp, "IG TooltipManager Class")
  return(pTooltipManager)
end

on removeTooltipManager me 
  if not objectp(me.pTooltipManager) then
    return TRUE
  end if
  me.pTooltipManager.deconstruct()
  pTooltipManager = void()
  return TRUE
end

on eventProcMouseDown me, tEvent, tSprID, tParam, tWndID, tTargetID 
  tObject = getObject(pMainWindowWrapperId)
  if tObject <> 0 then
    tObject.Activate()
  end if
  if tSprID <> "creategame.button" then
    if (tSprID = "ig_link_startnew") then
      return(me.ChangeWindowView("LevelList"))
    else
      if tSprID <> "cancel.button" then
        if (tSprID = "create_cancel.button") then
          return(me.ChangeWindowView("GameList"))
        else
          if tSprID <> "startgame.button" then
            if (tSprID = "ig_startgame.button") then
              return(me.getHandler().send_START_GAME())
            else
              if (tSprID = "ig_close") then
                tService = me.getComponent().getIGComponent("GameList")
                if (tService = 0) then
                  return FALSE
                end if
                if (tService.getJoinedGameId() = -1) then
                  return(me.hideWindow())
                else
                  return(me.ChangeWindowView("JoinedGame", #mini))
                end if
              end if
            end if
            if voidp(tTargetID) then
              tService = me.getActiveUI()
            else
              tService = me.getUI(tTargetID)
            end if
            if (tService = 0) then
              return FALSE
            end if
            return(tService.eventProcMouseDown(tEvent, tSprID, tParam, tWndID))
          end if
        end if
      end if
    end if
  end if
end

on eventProcMouseHover me, tEvent, tSprID, tParam, tWndID, tTargetID 
  if voidp(tTargetID) then
    tService = me.getActiveUI()
  else
    tService = me.getUI(tTargetID)
  end if
  if (tService = 0) then
    return FALSE
  end if
  tResult = call(#eventProcMouseHover, [tService], tEvent, tSprID, tParam, tWndID)
  if (tResult = 1) then
    return TRUE
  end if
  tObject = me.getTooltipManager()
  if (tObject = 0) then
    return FALSE
  end if
  tObject.handleEvent(tEvent, tSprID, tWndID)
  return TRUE
end

on eventProcMouseDownIcon me, tEvent, tSprID, tParam, tWndID, tTargetID 
  tComponent = me.getComponent()
  if (tComponent.getSystemState() = 0) then
    return TRUE
  end if
  tService = tComponent.getIGComponent("GameList")
  if (tService = 0) then
    return FALSE
  end if
  tBreakOffset = offset("_", tSprID)
  if (tBreakOffset = 0) then
    return FALSE
  end if
  tGameId = integer(tSprID.getProp(#char, 1, (tBreakOffset - 1)))
  if not integerp(tGameId) then
    return FALSE
  end if
  tGameType = integer(tSprID.getProp(#char, (tBreakOffset + 1), tSprID.length))
  if not integerp(tGameType) then
    return FALSE
  end if
  if (tService.getJoinedGameId() = tGameId) then
    return TRUE
  end if
  tComponent.displayIGComponentEvent("Prejoin", #show, tGameId, 1)
  return TRUE
end

on eventProcRollOverIcon me, tEvent, tSprID, tParam, tWndID, tTargetID 
  if (me.getComponent().getSystemState() = 0) then
    return TRUE
  end if
  if (tEvent = #mouseEnter) then
    tBreakOffset = offset("_", tSprID)
    if (tBreakOffset = 0) then
      return FALSE
    end if
    tGameId = integer(tSprID.getProp(#char, 1, (tBreakOffset - 1)))
    if not integerp(tGameId) then
      return FALSE
    end if
    tGameType = integer(tSprID.getProp(#char, (tBreakOffset + 1), tSprID.length))
    if not integerp(tGameType) then
      return FALSE
    end if
    tService = me.getComponent().getIGComponent("GameList")
    if (tService = 0) then
      return FALSE
    end if
    if (tService.getJoinedGameId() = tGameId) then
      return(executeMessage(#setRollOverInfo, getText("ig_tooltip_game_joined")))
    end if
    executeMessage(#setRollOverInfo, getText("ig_tooltip_gametype_" & tGameType))
  else
    executeMessage(#setRollOverInfo, "")
  end if
  return TRUE
end
