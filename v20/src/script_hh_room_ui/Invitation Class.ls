property pWindowID

on construct me 
  pWindowID = #invitationWindowID
  registerMessage(#hideInvitation, me.getID(), #close)
  registerMessage(#enterRoom, me.getID(), #close)
  registerMessage(#leaveRoom, me.getID(), #close)
  registerMessage(#changeRoom, me.getID(), #close)
  return TRUE
end

on deconstruct me 
  if windowExists(pWindowID) then
    removeWindow(pWindowID)
  end if
  return TRUE
end

on close me 
  return(removeObject(me.getID()))
end

on align me, tWindowID, tElemID 
  if not windowExists(tWindowID) then
    return FALSE
  end if
  tTargetWindow = getWindow(tWindowID)
  if not tTargetWindow.elementExists(tElemID) then
    return FALSE
  end if
  tElem = tTargetWindow.getElement(tElemID)
  if not tElem.getProperty(#visible) then
    return FALSE
  end if
  createWindow(pWindowID, "popup_bg_white.window")
  tWindow = getWindow(pWindowID)
  tWindow.merge("invitation.window")
  tWindow.registerProcedure(#eventProcInvitation, me.getID(), #mouseUp)
  tWindow.hide()
  tWinLocX = tTargetWindow.getProperty(#locX)
  tWinLocY = tTargetWindow.getProperty(#locY)
  tElemLocX = tElem.getProperty(#locX)
  tElemLocY = tElem.getProperty(#locY)
  tElemWidth = tElem.getProperty(#width)
  tInvitationWindow = getWindow(pWindowID)
  tOwnWidth = tInvitationWindow.getProperty(#width)
  tOwnHeight = tInvitationWindow.getProperty(#height)
  tLocX = (((tWinLocX + tElemLocX) + (tElemWidth / 2)) - (tOwnWidth / 2))
  tLocY = ((tWinLocY + tElemLocY) - tOwnHeight)
  tOffset = ((tLocX + tOwnWidth) - the stage.rect.width)
  if tOffset > 0 then
    tLocX = (tLocX - tOffset)
    tPointerElem = tInvitationWindow.getElement("pointer")
    tPointerElem.moveBy(tOffset, 0)
  end if
  tInvitationWindow.moveTo(tLocX, tLocY)
  return TRUE
end

on show me, tdata, tWindowID, tElemID 
  if tdata.ilk <> #propList then
    return FALSE
  end if
  if voidp(tdata.findPos(#name)) then
    return FALSE
  end if
  pData = tdata
  if not me.align(tWindowID, tElemID) then
    return FALSE
  end if
  if not windowExists(pWindowID) then
    return FALSE
  end if
  tWindow = getWindow(pWindowID)
  tHeader = tdata.getAt(#name)
  tWindow.getElement("invitation_header").setText(tHeader)
  tText = getText("receive_invitation_text")
  tWindow.getElement("invitation_text").setText(tText)
  tYes = getText("yes")
  tWindow.getElement("invitation_button_accept_text").setText(tYes)
  tNo = getText("no")
  tWindow.getElement("invitation_button_deny_text").setText(tNo)
  tWindow.show()
end

on eventProcInvitation me, tEvent, tSprID 
  if tSprID <> "invitation_button_accept" then
    if (tSprID = "invitation_button_accept_text") then
      executeMessage(#acceptInvitation)
      me.close()
    else
      if tSprID <> "invitation_button_deny" then
        if (tSprID = "invitation_button_deny_text") then
          executeMessage(#rejectInvitation)
          me.close()
        else
          if (tSprID = "popup_button_close") then
            me.close()
          end if
        end if
      end if
    end if
  end if
end
