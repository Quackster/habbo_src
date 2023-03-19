property pActivePostItId, pText, pcolor, pWindowID, pLocX, pLocY, pIsController, pChanged, pIsOwner, pCanRemoveStickies

on construct me
  pWindowID = #postit_window
  registerMessage(#leaveRoom, me.getID(), #close)
  registerMessage(#changeRoom, me.getID(), #close)
  return 1
end

on deconstruct me
  unregisterMessage(#leaveRoom, me.getID())
  unregisterMessage(#changeRoom, me.getID())
  return 1
end

on open me, tID, tColor, tLocX, tLocY
  pcolor = tColor
  pLocX = tLocX
  pLocY = tLocY
  if windowExists(pWindowID) then
    removeWindow(pWindowID)
  end if
  registerMessage(symbol("itemdata_received" & tID), #postit_manager, #setItemData)
  getThread(#room).getComponent().getRoomConnection().send("G_IDATA", [#integer: integer(tID)])
  pIsController = getObject(#session).GET("room_controller")
  if getObject(#session).GET("user_rights").getOne("fuse_any_room_controller") then
    pIsController = 1
  end if
  pIsOwner = getObject(#session).GET("room_owner")
  pCanRemoveStickies = getObject(#session).GET("user_rights").getOne("fuse_remove_stickies")
end

on close me
  if pActivePostItId > 0 then
    tColorHex = pcolor.hexString()
    tWindow = getWindow(pWindowID)
    if tWindow = 0 then
      return 0
    end if
    tStickieText = tWindow.getElement("stickies_text_field").getText()
    tStickieText = convertSpecialChars(tStickieText, 1)
    tdata = tColorHex.char[2..length(tColorHex)] && tStickieText
    if pChanged = 1 then
      getThread(#room).getComponent().getRoomConnection().send("SETITEMDATA", [#integer: integer(pActivePostItId), #string: tdata])
    end if
  end if
  if windowExists(pWindowID) then
    removeWindow(pWindowID)
  end if
end

on delete me
  if windowExists(pWindowID) then
    removeWindow(pWindowID)
  end if
  getThread(#room).getComponent().getRoomConnection().send("REMOVEITEM", [#integer: integer(pActivePostItId)])
end

on setItemData me, tMsg
  tID = tMsg[#id]
  ttype = tMsg[#type]
  tText = tMsg[#text].word[2..tMsg[#text].word.count]
  unregisterMessage(symbol("itemdata_received" & tID), #postit_manager)
  if windowExists(pWindowID) then
    removeWindow(pWindowID)
  end if
  pActivePostItId = tID
  pText = tText
  tObject = getThread(#room).getComponent().getItemObject(string(pActivePostItId))
  if tObject = 0 then
    return error(me, "Couldn't find stickie:" && pActivePostItId, #setItemData, #major)
  end if
  if tObject.getClass() = "post.it.vd" then
    tWndType = "habbo_stickie_vd.window"
    ttype = "FFFFFF"
  else
    tWndType = "habbo_stickies.window"
  end if
  createWindow(pWindowID, tWndType)
  tWindow = getWindow(pWindowID)
  if not tWindow then
    return 0
  end if
  if pLocX > ((the stage).image.width - tWindow.getProperty(#width)) then
    pLocX = (the stage).image.width - tWindow.getProperty(#width)
  end if
  if pLocY < 100 then
    pLocY = 100
  end if
  me.setColor(rgb(ttype))
  tWindow.moveTo(pLocX, pLocY)
  tWindow.getElement("stickies_text_field").getProperty(#sprite).ink = 36
  tWindow.getElement("stickies_text_field").setText(pText)
  tWindow.registerProcedure(#eventProcMouseUp, me.getID(), #mouseUp)
  tWindow.registerProcedure(#eventProcKeyDown, me.getID(), #keyDown)
  if tWndType = "habbo_stickies.window" then
    if pIsOwner or pCanRemoveStickies then
      tWindow.getElement("stickies_delete_button").setProperty(#blend, 100)
    else
      tWindow.getElement("stickies_delete_button").setProperty(#cursor, 0)
    end if
    if pIsController then
      tWindow.getElement("stickies_color1_button").setProperty(#blend, 100)
      tWindow.getElement("stickies_color2_button").setProperty(#blend, 100)
      tWindow.getElement("stickies_color3_button").setProperty(#blend, 100)
      tWindow.getElement("stickies_color4_button").setProperty(#blend, 100)
    else
      tWindow.getElement("stickies_color1_button").setProperty(#cursor, 0)
      tWindow.getElement("stickies_color2_button").setProperty(#cursor, 0)
      tWindow.getElement("stickies_color3_button").setProperty(#cursor, 0)
      tWindow.getElement("stickies_color4_button").setProperty(#cursor, 0)
    end if
  else
    if tWndType = "habbo_stickies_vd.window" then
      if pIsOwner or pCanRemoveStickies then
        tWindow.getElement("stickies_delete_button").setProperty(#blend, 100)
      else
        tWindow.getElement("stickies_delete_button").setProperty(#cursor, 0)
      end if
    end if
  end if
  pChanged = 0
end

on setColor me, tColor, tByUser
  if tByUser then
    pChanged = 1
  end if
  pcolor = tColor
  tBgElem = getWindow(pWindowID).getElement("stickies_bg")
  if tBgElem = 0 then
    return 
  end if
  tBgElem.getProperty(#sprite).bgColor = pcolor
  tItemObject = getThread(#room).getComponent().getItemObject(string(pActivePostItId))
  if objectp(tItemObject) then
    tItemObject.setColor(pcolor)
  end if
end

on eventProcMouseUp me, tEvent, tElemID, tParam, tWndID
  if getWindow(tWndID).getElement(tElemID).getProperty(#blend) = 100 then
    case tElemID of
      "stickies_close_button":
        me.close()
      "stickies_color4_button":
        if pIsController then
          me.setColor(rgb(156, 206, 255), 1)
        end if
      "stickies_color3_button":
        if pIsController then
          me.setColor(rgb(255, 156, 255), 1)
        end if
      "stickies_color2_button":
        if pIsController then
          me.setColor(rgb(156, 255, 156), 1)
        end if
      "stickies_color1_button":
        if pIsController then
          me.setColor(rgb(255, 255, 51), 1)
        end if
      "stickies_delete_button":
        if pIsOwner or pCanRemoveStickies then
          delete me
        end if
    end case
  end if
  return 1
end

on eventProcKeyDown me, tEvent, tSprID, tParam
  if tSprID = "stickies_text_field" then
    if (the selStart < length(pText)) and (pIsController = 0) then
      error(me, "Cannot edit postIts - only add!", #eventProcKeyDown, #minor)
      return 1
    end if
    pChanged = 1
  end if
end
