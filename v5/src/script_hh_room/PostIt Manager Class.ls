property pWindowID, pActivePostItId, pcolor, pChanged, pLocX, pLocY, pText, pIsController

on construct me 
  pWindowID = #postit_window
  registerMessage(#leaveRoom, me.getID(), #close)
  registerMessage(#changeRoom, me.getID(), #close)
  return(1)
end

on deconstruct me 
  unregisterMessage(#leaveRoom, me.getID())
  unregisterMessage(#changeRoom, me.getID())
  return(1)
end

on open me, tid, tColor, tLocX, tLocY 
  pcolor = tColor
  pLocX = tLocX
  pLocY = tLocY
  if windowExists(pWindowID) then
    removeWindow(pWindowID)
  end if
  registerMessage(symbol("itemdata_received" & tid), #postit_manager, #setItemData)
  getThread(#room).getComponent().getRoomConnection().send(#room, "G_IDATA /" & tid)
  pIsController = getObject(#session).get("room_controller")
end

on close me 
  if pActivePostItId > 0 then
    tColorHex = pcolor.hexString()
    tWindow = getWindow(pWindowID)
    if tWindow = 0 then
      return(0)
    end if
    tdata = tColorHex.getProp(#char, 2, length(tColorHex)) && tWindow.getElement("stickies_text_field").getText()
    if pChanged = 1 then
      getThread(#room).getComponent().getRoomConnection().send(#room, "SETITEMDATA /" & pActivePostItId & "/" & tdata)
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
  getThread(#room).getComponent().getRoomConnection().send(#room, "REMOVEITEM /" & pActivePostItId)
end

on setItemData me, tMsg 
  tid = tMsg.getAt(#id)
  tText = tMsg.getAt(#text).getProp(#word, 2, tMsg.getAt(#text).count(#word))
  unregisterMessage(symbol("itemdata_received" & tid), #postit_manager)
  if windowExists(pWindowID) then
    removeWindow(pWindowID)
  end if
  pActivePostItId = tid
  pText = tText
  tObject = getThread(#room).getComponent().getItemObject(string(pActivePostItId))
  if tObject = 0 then
    return(error(me, "Couldn't find stickie:" && pActivePostItId, #setItemData))
  end if
  if tObject.getClass() = "post.it.vd" then
    tWndType = "habbo_stickie_vd.window"
  else
    tWndType = "habbo_stickies.window"
  end if
  createWindow(pWindowID, tWndType)
  tWindow = getWindow(pWindowID)
  if the stage > image.width - tWindow.getProperty(#width) then
    pLocX = image.width - tWindow.getProperty(#width)
  end if
  if pLocY < 100 then
    pLocY = 100
  end if
  me.setColor(pcolor)
  tWindow.moveTo(pLocX, pLocY)
  tWindow.getElement("stickies_text_field").getProperty(#sprite).ink = 36
  tWindow.getElement("stickies_text_field").setText(pText)
  tWindow.registerProcedure(#eventProcMouseDown, me.getID(), #mouseDown)
  tWindow.registerProcedure(#eventProcKeyDown, me.getID(), #keyDown)
  tWindow.getElement("stickies_delete_button").setProperty(#blend, 100)
  if tWndType = "habbo_stickies.window" then
    if pIsController then
      tWindow.getElement("stickies_color1_button").setProperty(#blend, 100)
      tWindow.getElement("stickies_color2_button").setProperty(#blend, 100)
      tWindow.getElement("stickies_color3_button").setProperty(#blend, 100)
      tWindow.getElement("stickies_color4_button").setProperty(#blend, 100)
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
    return()
  end if
  tBgElem.getProperty(#sprite).bgColor = pcolor
  tItemObject = getThread(#room).getComponent().getItemObject(string(pActivePostItId))
  if objectp(tItemObject) then
    tItemObject.setColor(pcolor)
  end if
end

on eventProcMouseDown me, tEvent, tSprID, tParam 
  if tSprID = "stickies_close_button" then
    me.close()
  else
    if tSprID = "stickies_color4_button" then
      if pIsController then
        me.setColor(rgb(156, 206, 255), 1)
      end if
    else
      if tSprID = "stickies_color3_button" then
        if pIsController then
          me.setColor(rgb(255, 156, 255), 1)
        end if
      else
        if tSprID = "stickies_color2_button" then
          if pIsController then
            me.setColor(rgb(156, 255, 156), 1)
          end if
        else
          if tSprID = "stickies_color1_button" then
            if pIsController then
              me.setColor(rgb(255, 255, 51), 1)
            end if
          else
            if tSprID = "stickies_delete_button" then
              if pIsController then
                me.delete()
              end if
            end if
          end if
        end if
      end if
    end if
  end if
  return(1)
end

on eventProcKeyDown me, tEvent, tSprID, tParam 
  if tSprID = "stickies_text_field" then
    if the selStart < length(pText) and pIsController = 0 then
      error(me, "Cannot edit postIts - only add!", #eventProcKeyDown)
      return(1)
    end if
    pChanged = 1
  end if
end
