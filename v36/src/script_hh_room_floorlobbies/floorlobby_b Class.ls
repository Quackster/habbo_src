property pBubbleList

on construct me 
  if not threadExists(#room) then
    return(error(me, "Room thread not found!!!", #construct))
  end if
  tRoomVis = getThread(#room).getInterface().getRoomVisualizer()
  if (tRoomVis = 0) then
    return(error(me, "Room visualizer not found!", #construct))
  end if
  tRoomVis.getSprById("floor").member.paletteRef = member(getmemnum("floorlobby_b palette"))
  i = 1
  repeat while 1
    tSpr = tRoomVis.getSprById("floor_" & i)
    if not tSpr then
    else
      tSpr.member.paletteRef = member(getmemnum("floorlobby_b palette"))
      i = (i + 1)
    end if
  end repeat
  tsprite = getThread(#room).getInterface().getRoomVisualizer().getSprById("lobby_window")
  tLocH = tsprite.locH
  pBubbleList = []
  i = 1
  repeat while i <= 8
    tObj = createObject(#temp, "Floor Bubble Win Class")
    tObj.define(tRoomVis.getSprById("bubble" & i), tLocH)
    pBubbleList.add(tObj)
    i = (1 + i)
  end repeat
  tsprite = getThread(#room).getInterface().getRoomVisualizer().getSprById("lobby_pipe")
  tLocH = tsprite.locH
  i = 9
  repeat while i <= 16
    tObj = createObject(#temp, "Floor Bubble Top Class")
    tObj.define(tRoomVis.getSprById("bubble" & i), tLocH)
    pBubbleList.add(tObj)
    i = (1 + i)
  end repeat
  i = 17
  repeat while i <= 23
    tObj = createObject(#temp, "Floor Bubble Bottom Class")
    tObj.define(tRoomVis.getSprById("bubble" & i), tLocH)
    pBubbleList.add(tObj)
    i = (1 + i)
  end repeat
  receiveUpdate(me.getID())
  return TRUE
end

on deconstruct me 
  removeUpdate(me.getID())
  pBubbleList = []
  return TRUE
end

on update me 
  call(#update, pBubbleList)
end
