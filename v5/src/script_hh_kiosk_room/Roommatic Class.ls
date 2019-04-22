on select me 
  if not threadExists(#room) then
    return(error(me, "Room thread not found!!!", #select))
  end if
  if not threadExists(#roomkiosk) then
    if FindCastNumber("habbo_kiosk_room") > 0 then
      initThread(FindCastNumber("habbo_kiosk_room"))
    else
      return(error(me, "Room kiosk cast not found!!!", #select))
    end if
  end if
  tUserObj = getThread(#room).getComponent().getUserObject(getObject(#session).get("user_name"))
  if not tUserObj then
    return(error(me, "User object not found:" && getObject(#session).get("user_name"), #select))
  end if
  if me.getProp(#pDirection, 1) = 4 then
    if me.pLocX = tUserObj.pLocX and me.pLocY - tUserObj.pLocY = -1 then
      me.useRoomKiosk()
    else
      getThread(#room).getComponent().getRoomConnection().send(#room, "Move" && me.pLocX && me.pLocY + 1)
    end if
  else
    if me.getProp(#pDirection, 1) = 0 then
      if me.pLocX = tUserObj.pLocX and me.pLocY - tUserObj.pLocY = 1 then
        me.useRoomKiosk()
      else
        getThread(#room).getComponent().getRoomConnection().send(#room, "Move" && me.pLocX && me.pLocY - 1)
      end if
    else
      if me.getProp(#pDirection, 1) = 2 then
        if me.pLocY = tUserObj.pLocY and me.pLocX - tUserObj.pLocX = -1 then
          me.useRoomKiosk()
        else
          getThread(#room).getComponent().getRoomConnection().send(#room, "Move" && me.pLocX + 1 && me.pLocY)
        end if
      else
        if me.getProp(#pDirection, 1) = 6 then
          if me.pLocY = tUserObj.pLocY and me.pLocX - tUserObj.pLocX = 1 then
            me.useRoomKiosk()
          else
            getThread(#room).getComponent().getRoomConnection().send(#room, "Move" && me.pLocX - 1 && me.pLocY)
          end if
        end if
      end if
    end if
  end if
  return(1)
end

on useRoomKiosk me 
  getThread(#room).getComponent().getRoomConnection().send(#room, "LOOKTO" && me.pLocX && me.pLocY)
  executeMessage(#open_roomkiosk)
end
