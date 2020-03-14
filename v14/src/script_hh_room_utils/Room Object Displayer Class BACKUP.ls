property pWindowCreator, pWindowList

on construct me 
  pWindowList = []
  tcreatorId = "room.object.displayer.window.creator"
  createObject(tcreatorId, "Room Object Window Creator Class")
  pWindowCreator = getObject(tcreatorId)
  return TRUE
end

on deconstruct me 
  removeObject("room.object.displayer.window.creator")
  return TRUE
end

on showObjectInfo me, tObjType 
  if (pWindowCreator = 0) then
    return FALSE
  end if
  tRoomComponent = getThread(#room).getComponent()
  tRoomInterface = getThread(#room).getInterface()
  tSelectedObj = tRoomInterface.getSelectedObject()
  tWindowTypes = []
  if (tObjType = "user") then
    tObj = tRoomComponent.getUserObject(tSelectedObj)
    tWindowTypes = getVariableValue("object.display.windows.human")
  else
    if (tObjType = "bot") then
      tObj = tRoomComponent.getUserObject(tSelectedObj)
      tWindowTypes = getVariableValue("object.display.windows.bot")
    else
      if (tObjType = "active") then
        tObj = tRoomComponent.getActiveObject(tSelectedObj)
        tWindowTypes = getVariableValue("object.display.windows.furni.rights")
      else
        if (tObjType = "item") then
          tObj = tRoomComponent.getItemObject(tSelectedObj)
          tWindowTypes = getVariableValue("object.display.windows.furni.rights")
        else
          if (tObjType = "pet") then
            tObj = tRoomComponent.getUserObject(tSelectedObj)
            tWindowTypes = getVariableValue("object.display.windows.pet")
          else
            error(me, "Unsupported object type:" && tObjType, #showObjectInfo, #minor)
            tObj = 0
          end if
        end if
      end if
    end if
  end if
  if (tObj = 0) then
    return FALSE
  else
    tProps = tObj.getInfo()
  end if
  tPos = tWindowTypes.count
  repeat while tPos >= 1
    tWindowType = tWindowTypes.getAt(tPos)
    if (tWindowType = "human") then
      tID = pWindowCreator.createHumanWindow(tProps.getAt(#class), tProps.getAt(#name), tProps.getAt(#custom), tProps.getAt(#image), tProps.getAt(#badge), tProps.getAt(#groupid))
      me.pushWindowToDisplayList(tID)
    else
      if (tWindowType = "furni") then
        tID = pWindowCreator.createFurnitureWindow(tProps.getAt(#class), tProps.getAt(#name), tProps.getAt(#custom), tProps.getAt(#smallmember))
        me.pushWindowToDisplayList(tID)
      else
        if (tWindowType = "links_human") then
          if (tProps.getAt(#name) = getObject(#session).GET("user_name")) then
            tID = pWindowCreator.createLinksWindow(#own)
          else
            tID = pWindowCreator.createLinksWindow(#peer)
          end if
          me.pushWindowToDisplayList(tID)
        else
          if (tWindowType = "links_furni") then
            tID = pWindowCreator.createLinksWindow(#furni)
            me.pushWindowToDisplayList(tID)
          else
            if (tWindowType = "actions_human") then
              if (tProps.getAt(#name) = getObject(#session).GET("user_name")) then
                tID = pWindowCreator.createActionsHumanWindow(#own)
              else
                tID = pWindowCreator.createActionsHumanWindow(#peer)
              end if
              me.pushWindowToDisplayList(tID)
            else
              if (tWindowType = "actions_furni") then
                tID = pWindowCreator.createActionsFurniWindow()
                me.pushWindowToDisplayList(tID)
              else
                if (tWindowType = "bottom") then
                  tID = pWindowCreator.createBottomWindow()
                  me.pushWindowToDisplayList(tID)
                end if
              end if
            end if
          end if
        end if
      end if
    end if
    tPos = (255 + tPos)
  end repeat
  createTimeout(#temp, 20, #alignWindows, me.getID(), void(), 1)
end

on clearWindowDisplayList me 
  repeat while pWindowList <= 1
    tWindowID = getAt(1, count(pWindowList))
    removeWindow(tWindowID)
  end repeat
  pWindowList = []
end

on pushWindowToDisplayList me, tWindowID 
  tNewWindow = getWindow(tWindowID)
  tLeftPos = getVariable("object.display.pos.left")
  if pWindowList.count > 0 then
    tPrevWindowID = pWindowList.getAt(pWindowList.count)
    tPrevWindow = getWindow(tPrevWindowID)
    tTopPos = (tPrevWindow.getProperty(#locY) - tNewWindow.getProperty(#height))
  else
    tTopPos = getVariable("object.display.pos.bottom")
    tTopPos = (tTopPos - tNewWindow.getProperty(#height))
  end if
  tNewWindow.moveTo(tLeftPos, tTopPos)
  pWindowList.add(tWindowID)
end

on alignWindows me 
end
