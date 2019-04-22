on construct(me)
  pIcon = createObject("guide_tool_icon_object", "Guide Tool Icon Class")
  pUseAlertSound = 1
  pWindowID = "guide_tool_window_id"
  pGuideToolAnimTimeoutID = "guide_tool_anim_update_timeout_id"
  registerMessage(#toggleGuideTool, me.getID(), #toggleGuideTool)
  registerMessage(#gamesystem_constructed, me.getID(), #hideAll)
  registerMessage(#gamesystem_deconstructed, me.getID(), #update)
  return(1)
  exit
end

on deconstruct(me)
  removeObject(pIcon.getID())
  unregisterMessage(#toggleGuideTool, me.getID())
  unregisterMessage(#gamesystem_constructed, me.getID())
  unregisterMessage(#gamesystem_deconstructed, me.getID())
  if windowExists(pWindowID) then
    removeWindow(pWindowID)
  end if
  return(1)
  exit
end

on hideAll(me)
  me.hideGuideToolIcon()
  me.closeGuideTool()
  exit
end

on showGuideToolIcon(me)
  if objectp(pIcon) then
    pIcon.show()
  end if
  exit
end

on hideGuideToolIcon(me)
  if objectp(pIcon) then
    pIcon.hide()
  end if
  exit
end

on toggleGuideTool(me)
  if not windowExists(pWindowID) then
    return(me.openGuideTool())
  end if
  tWndObj = getWindow(pWindowID)
  if tWndObj.getProperty(#visible) then
    me.closeGuideTool()
  else
    me.openGuideTool()
  end if
  exit
end

on openGuideTool(me)
  if windowExists(pWindowID) then
    tWindow = getWindow(pWindowID)
    tWindow.show()
  else
    tstate = me.getComponent().getState()
    me.createGuideToolWindow(tstate)
  end if
  return(1)
  exit
end

on createGuideToolWindow(me, tstate)
  tUseDefaultLoc = 1
  if windowExists(pWindowID) then
    removeWindow(pWindowID)
    tUseDefaultLoc = 0
  end if
  if me = #disabled then
    return(0)
  else
    if me = #enabled then
      tLayout = "guide_tool_start.window"
    else
      if me = #waiting then
        tLayout = "guide_tool_waiting.window"
      else
        if me = #ready then
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
  if me = #waiting then
    createTimeout(pGuideToolAnimTimeoutID, 250, #updateGuideToolAnim, me.getID(), void(), 0)
  else
    if me = #ready then
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
  exit
end

on updateCheckbox(me)
  if not windowExists(pWindowID) then
    return(0)
  end if
  tWndObj = getWindow(pWindowID)
  if not tWndObj.elementExists("guide_tool_checkbox") then
    return(0)
  end if
  if not memberExists("button.checkbox.on") and memberExists("button.checkbox.off") then
    return(0)
  end if
  tImageOn = member(getmemnum("button.checkbox.on")).image
  tImageOff = member(getmemnum("button.checkbox.off")).image
  tElem = tWndObj.getElement("guide_tool_checkbox")
  if pUseAlertSound then
    tElem.feedImage(tImageOn)
  else
    tElem.feedImage(tImageOff)
  end if
  exit
end

on updateGuideToolAnim(me)
  if not windowExists(pWindowID) then
    return(0)
  end if
  tWndObj = getWindow(pWindowID)
  if not tWndObj.elementExists("guide_tool_progress_bar") then
    return(0)
  end if
  tElem = tWndObj.getElement("guide_tool_progress_bar")
  pAnimFrame = pAnimFrame + 1
  if pAnimFrame > 3 then
    pAnimFrame = 1
  end if
  tMemName = "nuh_search_" & pAnimFrame
  if memberExists(tMemName) then
    tElem.setProperty(#image, member(getmemnum(tMemName)).image)
  end if
  exit
end

on closeGuideTool(me)
  if windowExists(pWindowID) then
    tWndObj = getWindow(pWindowID)
    tWndObj.hide()
  end if
  exit
end

on update(me)
  tstate = me.getComponent().getState()
  me.updateIcon(tstate)
  me.updateToolWindow(tstate)
  exit
end

on isMinimized(me)
  if not windowExists(pWindowID) then
    return(1)
  end if
  tWndObj = getWindow(pWindowID)
  return(not tWndObj.getProperty(#visible))
  exit
end

on updateIcon(me, tstate)
  if tstate = #disabled then
    pIcon.hide()
  else
    pIcon.show()
  end if
  if tstate = #ready then
    pIcon.setFlashing(1)
  else
    pIcon.setFlashing(0)
  end if
  exit
end

on updateToolWindow(me, tstate)
  tIsMinimized = me.isMinimized()
  me.createGuideToolWindow(tstate)
  if tIsMinimized and windowExists(pWindowID) then
    tWndObj = getWindow(pWindowID)
    tWndObj.hide()
  end if
  exit
end

on eventProcGuideTool(me, tEvent, tSprID, tProp)
  if me = "guide_tool_start" then
    me.getComponent().startWaiting()
  else
    if me = "guide_tool_close" then
      me.closeGuideTool()
    else
      if me = "guide_tool_cancel" then
        me.getComponent().cancelWaiting()
        me.closeGuideTool()
      else
        if me = "guide_tool_accept" then
          me.getComponent().acceptInvitation()
          me.closeGuideTool()
        else
          if me = "guide_tool_reject" then
            me.getComponent().rejectInvitation()
            me.closeGuideTool()
          else
            if me <> "guide_tool_checkbox" then
              if me = "guide_tool_checkbox_text" then
                pUseAlertSound = not pUseAlertSound
                me.updateCheckbox()
              end if
              exit
            end if
          end if
        end if
      end if
    end if
  end if
end