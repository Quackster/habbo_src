property pWindowCreator, pWindowList

on construct me
  pWindowList = []
  tcreatorId = "room.object.displayer.window.creator"
  createObject(tcreatorId, "Room Object Window Creator Class")
  pWindowCreator = getObject(tcreatorId)
  return 1
end

on deconstruct me
  removeObject("room.object.displayer.window.creator")
  return 1
end

on showObjectInfo me, tObjType
  if pWindowCreator = 0 then
    return 0
  end if
  tRoomComponent = getThread(#room).getComponent()
  tRoomInterface = getThread(#room).getInterface()
  tSelectedObj = tRoomInterface.getSelectedObject()
  tWindowTypes = []
  case tObjType of
    "user":
      tObj = tRoomComponent.getUserObject(tSelectedObj)
      tWindowTypes = getVariableValue("object.display.windows.human")
    "bot":
      tObj = tRoomComponent.getUserObject(tSelectedObj)
      tWindowTypes = getVariableValue("object.display.windows.bot")
    "active":
      tObj = tRoomComponent.getActiveObject(tSelectedObj)
      tWindowTypes = getVariableValue("object.display.windows.furni.rights")
    "item":
      tObj = tRoomComponent.getItemObject(tSelectedObj)
      tWindowTypes = getVariableValue("object.display.windows.furni.rights")
    "pet":
      tObj = tRoomComponent.getUserObject(tSelectedObj)
      tWindowTypes = getVariableValue("object.display.windows.pet")
    otherwise:
      error(me, "Unsupported object type:" && tObjType, #showObjectInfo, #minor)
      tObj = 0
  end case
  if tObj = 0 then
    return 0
  else
    tProps = tObj.getInfo()
  end if
  repeat with tPos = tWindowTypes.count down to 1
    tWindowType = tWindowTypes[tPos]
    case tWindowType of
      "human":
        tID = pWindowCreator.createHumanWindow(tProps[#class], tProps[#name], tProps[#custom], tProps[#image], tProps[#badge], tProps[#groupid])
        me.pushWindowToDisplayList(tID)
      "furni":
        tID = pWindowCreator.createFurnitureWindow(tProps[#class], tProps[#name], tProps[#custom], tProps[#smallmember])
        me.pushWindowToDisplayList(tID)
      "links_human":
        if tProps[#name] = getObject(#session).GET("user_name") then
          tID = pWindowCreator.createLinksWindow(#own)
        else
          tID = pWindowCreator.createLinksWindow(#peer)
        end if
        me.pushWindowToDisplayList(tID)
      "links_furni":
        tID = pWindowCreator.createLinksWindow(#furni)
        me.pushWindowToDisplayList(tID)
      "actions_human":
        if tProps[#name] = getObject(#session).GET("user_name") then
          tID = pWindowCreator.createActionsHumanWindow(#own)
        else
          tID = pWindowCreator.createActionsHumanWindow(#peer)
        end if
        me.pushWindowToDisplayList(tID)
      "actions_furni":
        tID = pWindowCreator.createActionsFurniWindow()
        me.pushWindowToDisplayList(tID)
      "bottom":
        tID = pWindowCreator.createBottomWindow()
        me.pushWindowToDisplayList(tID)
    end case
  end repeat
  createTimeout(#temp, 20, #alignWindows, me.getID(), VOID, 1)
end

on clearWindowDisplayList me
  repeat with tWindowID in pWindowList
    removeWindow(tWindowID)
  end repeat
  pWindowList = []
end

on pushWindowToDisplayList me, tWindowID
  tNewWindow = getWindow(tWindowID)
  tLeftPos = getVariable("object.display.pos.left")
  if pWindowList.count > 0 then
    tPrevWindowID = pWindowList[pWindowList.count]
    tPrevWindow = getWindow(tPrevWindowID)
    tTopPos = tPrevWindow.getProperty(#locY) - tNewWindow.getProperty(#height)
  else
    tTopPos = getVariable("object.display.pos.bottom")
    tTopPos = tTopPos - tNewWindow.getProperty(#height)
  end if
  tNewWindow.moveTo(tLeftPos, tTopPos)
  pWindowList.add(tWindowID)
end

on alignWindows me
end
