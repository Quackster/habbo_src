property pIcon, pWindowID, pGuideToolAnimTimeoutID, pUseAlertSound, pAnimFrame

on construct me 
  pIcon = createObject("guide_tool_icon_object", "Guide Tool Icon Class")
  pUseAlertSound = 1
  pWindowID = "guide_tool_window_id"
  pGuideToolAnimTimeoutID = "guide_tool_anim_update_timeout_id"
  registerMessage(#toggleGuideTool, me.getID(), #toggleGuideTool)
  registerMessage(#gamesystem_constructed, me.getID(), #hideAll)
  registerMessage(#gamesystem_deconstructed, me.getID(), #update)
  return TRUE
end

on deconstruct me 
  removeObject(pIcon.getID())
  unregisterMessage(#toggleGuideTool, me.getID())
  unregisterMessage(#gamesystem_constructed, me.getID())
  unregisterMessage(#gamesystem_deconstructed, me.getID())
  if windowExists(pWindowID) then
    removeWindow(pWindowID)
  end if
  return TRUE
end

on hideAll me 
  me.hideGuideToolIcon()
  me.closeGuideTool()
end

on showGuideToolIcon me 
  if objectp(pIcon) then
    pIcon.show()
  end if
end

on hideGuideToolIcon me 
  if objectp(pIcon) then
    pIcon.hide()
  end if
end

on toggleGuideTool me 
  if not windowExists(pWindowID) then
    return(me.openGuideTool())
  end if
  tWndObj = getWindow(pWindowID)
  if tWndObj.getProperty(#visible) then
    me.closeGuideTool()
  else
    me.openGuideTool()
  end if
end

on openGuideTool me 
  if windowExists(pWindowID) then
    tWindow = getWindow(pWindowID)
    tWindow.show()
  else
    tstate = me.getComponent().getState()
    me.createGuideToolWindow(tstate)
  end if
  return TRUE
end

on createGuideToolWindow me, tstate 
  tUseDefaultLoc = 1
  if windowExists(pWindowID) then
    removeWindow(pWindowID)
    tUseDefaultLoc = 0
  end if
  if (tstate = #disabled) then
    return FALSE
  else
    if (tstate = #enabled) then
      tLayout = "guide_tool_start.window"
    else
      if (tstate = #waiting) then
        tLayout = "guide_tool_waiting.window"
      else
        if (tstate = #ready) then
          tLayout = "guide_tool_invite.window"
        end if
      end if
    end if
  end if
  createWindow(pWindowID, tLayout)
  tWndObj = getWindow(pWindowID)
  tWndObj.registerProcedure(#eventProcGuideTool, me.getID(), #mouseUp)
  if tUseDefaultLoc then
    tloc = value(getVariable("guidetool.window.loc"))
    tWndObj.moveTo(tloc.getAt(1), tloc.getAt(2))
  end if
  if timeoutExists(pGuideToolAnimTimeoutID) then
    removeTimeout(pGuideToolAnimTimeoutID)
  end if
  if (tstate = #waiting) then
    createTimeout(pGuideToolAnimTimeoutID, 250, #updateGuideToolAnim, me.getID(), void(), 0)
  else
    if (tstate = #ready) then
      if pUseAlertSound then
        tSoundMemName = getVariable("guidetool.alert.sound")
        playSound(tSoundMemName, #cut, [#loopCount:1, #infiniteloop:0, #volume:255])
      end if
      tInvitationData = me.getComponent().getInvitation()
      if tWndObj.elementExists("guide_tool_header") then
        tName = tInvitationData.getaProp(#name)
        tElem = tWndObj.getElement("guide_tool_header")
        tElem.setText(tName)
      end if
    end if
  end if
  me.updateCheckbox()
end

on updateCheckbox me 
  if not windowExists(pWindowID) then
    return FALSE
  end if
  tWndObj = getWindow(pWindowID)
  if not tWndObj.elementExists("guide_tool_checkbox") then
    return FALSE
  end if
  if not memberExists("button.checkbox.on") and memberExists("button.checkbox.off") then
    return FALSE
  end if
  tImageOn = member(getmemnum("button.checkbox.on")).image
  tImageOff = member(getmemnum("button.checkbox.off")).image
  tElem = tWndObj.getElement("guide_tool_checkbox")
  if pUseAlertSound then
    tElem.feedImage(tImageOn)
  else
    tElem.feedImage(tImageOff)
  end if
end

on updateGuideToolAnim me 
  if not windowExists(pWindowID) then
    return FALSE
  end if
  tWndObj = getWindow(pWindowID)
  if not tWndObj.elementExists("guide_tool_progress_bar") then
    return FALSE
  end if
  tElem = tWndObj.getElement("guide_tool_progress_bar")
  pAnimFrame = (pAnimFrame + 1)
  if pAnimFrame > 3 then
    pAnimFrame = 1
  end if
  tMemName = "nuh_search_" & pAnimFrame
  if memberExists(tMemName) then
    tElem.setProperty(#image, member(getmemnum(tMemName)).image)
  end if
end

on closeGuideTool me 
  if windowExists(pWindowID) then
    tWndObj = getWindow(pWindowID)
    tWndObj.hide()
  end if
end

on update me 
  tstate = me.getComponent().getState()
  me.updateIcon(tstate)
  me.updateToolWindow(tstate)
end

on isMinimized me 
  if not windowExists(pWindowID) then
    return TRUE
  end if
  tWndObj = getWindow(pWindowID)
  return(not tWndObj.getProperty(#visible))
end

on updateIcon me, tstate 
  if (tstate = #disabled) then
    pIcon.hide()
  else
    pIcon.show()
  end if
  if (tstate = #ready) then
    pIcon.setFlashing(1)
  else
    pIcon.setFlashing(0)
  end if
end

on updateToolWindow me, tstate 
  tIsMinimized = me.isMinimized()
  me.createGuideToolWindow(tstate)
  if tIsMinimized and windowExists(pWindowID) then
    tWndObj = getWindow(pWindowID)
    tWndObj.hide()
  end if
end

on eventProcGuideTool me, tEvent, tSprID, tProp 
  if (tSprID = "guide_tool_start") then
    me.getComponent().startWaiting()
  else
    if (tSprID = "guide_tool_close") then
      me.closeGuideTool()
    else
      if (tSprID = "guide_tool_cancel") then
        me.getComponent().cancelWaiting()
        me.closeGuideTool()
      else
        if (tSprID = "guide_tool_accept") then
          me.getComponent().acceptInvitation()
          me.closeGuideTool()
        else
          if (tSprID = "guide_tool_reject") then
            me.getComponent().rejectInvitation()
            me.closeGuideTool()
          else
            if tSprID <> "guide_tool_checkbox" then
              if (tSprID = "guide_tool_checkbox_text") then
                pUseAlertSound = not pUseAlertSound
                me.updateCheckbox()
              end if
            end if
          end if
        end if
      end if
    end if
  end if
end
