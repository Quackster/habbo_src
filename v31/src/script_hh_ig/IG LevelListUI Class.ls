on construct me 
  me.ancestor.construct()
  me.pViewModeComponents = [#info:["List", "Details"], #highscore:["List", "Highscore"]]
  return TRUE
end

on deconstruct me 
  return(me.ancestor.deconstruct())
end

on renderProperty me, tKey, tValue 
  if me.pViewMode <> #info then
    return TRUE
  end if
  tComponent = me.getSubComponent("Details", 0)
  if (tComponent = 0) then
    return FALSE
  end if
  return(tComponent.renderProperty(tKey, tValue))
end

on getGameTypeHandlerClass me, tGameType 
  tGameTypeService = me.getIGComponent("GameTypes")
  if (tGameTypeService = 0) then
    return FALSE
  end if
  tTypeStr = tGameTypeService.getGameTypeString(tGameType)
  tMemName = "IG LevelListUI" && tTypeStr && "Class"
  if not memberExists(tMemName) then
    tClass = "IG LevelListUI Details Class"
  else
    tClass = ["IG LevelListUI Details Class", tMemName]
  end if
  return(tClass)
end

on getSubComponent me, tID, tAddIfMissing 
  tObject = me.pSubComponentList.getaProp(tID)
  if tObject <> 0 then
    return(tObject)
  end if
  if not tAddIfMissing then
    return FALSE
  end if
  if tID <> "Details" then
    tClass = ["IG LevelListUI Details Class", "IG LevelListUI" && tID && "Class"]
  else
    tService = me.getMasterIGComponent()
    if (tService = 0) then
      return FALSE
    end if
    tItemRef = tService.getSelectedLevel()
    if (tItemRef = 0) then
      return FALSE
    end if
    tClass = me.getGameTypeHandlerClass(tItemRef.getProperty(#game_type))
  end if
  return(me.initializeSubComponent(tID, tClass))
end

on eventProcMouseDown me, tEvent, tSprID, tParam, tWndID 
  tService = me.getMasterIGComponent()
  if (tService = 0) then
    return FALSE
  end if
  tItemRef = tService.getSelectedLevel()
  tMultiplier = 1
  tIntParam = 0
  repeat while integerp(integer(tSprID.getProp(#char, tSprID.length)))
    tIntParam = (tIntParam + (tMultiplier * integer(tSprID.getProp(#char, tSprID.length))))
    tSprID = tSprID.getProp(#char, 1, (tSprID.length - 1))
    tMultiplier = (tMultiplier * 10)
  end repeat
  if (tSprID.getProp(#char, tSprID.length) = "_") then
    tSprID = tSprID.getProp(#char, 1, (tSprID.length - 1))
  end if
  if (tSprID = "ig_gamelist") then
    if ilk(tParam) <> #point then
      return FALSE
    end if
    tComponent = me.getSubComponent("List")
    if (tComponent = 0) then
      return FALSE
    end if
    tIndex = tComponent.getItemIndexFromPoint(tParam)
    tID = tService.getListIdByIndex(tIndex)
    if tService.getSelectedLevelId() <> tID and tID > -1 then
      return(tService.selectLevel(tID, 1))
    end if
    return FALSE
  else
    if (tSprID = "ig_icon_team_amount") then
      return(tService.setProperty(#number_of_teams, tIntParam))
    else
      if (tSprID = "ig_game_availability") then
        return(tService.setProperty(#private, tIntParam))
      else
        if (tSprID = "create_confirmation.button") then
          return(tService.createGame())
        else
          if (tSprID = "create_cancel.button") then
            return(tService.selectLevel(-1, 1))
          else
            if (tSprID = "ig_tab_highscores") then
              return(me.setViewMode(#highscore))
            else
              if tSprID <> "ig_level_name" then
                if (tSprID = "ig_tab_gameinfo") then
                  return(me.setViewMode(#info))
                end if
                if me.pViewMode <> #info then
                  return FALSE
                end if
                tComponent = me.getSubComponent("Details")
                if (tComponent = 0) then
                  return FALSE
                end if
                if tItemRef <> void() then
                  return(tComponent.eventProcMouseDown(tEvent, tSprID, tParam, tWndID, tIntParam))
                end if
                return FALSE
              end if
            end if
          end if
        end if
      end if
    end if
  end if
end

on eventProcMouseHover me, tEvent, tSprID, tParam, tWndID 
  tComponent = me.getSubComponent("Details", 0)
  if tComponent <> 0 then
    return(call(#eventProcMouseHover, [tComponent], tEvent, tSprID, tParam, tWndID))
  end if
  return FALSE
end
