property pID, pItemList, pPropsList, pScrollStep, pScrollList, pLocX, pLocY

on construct me
  pItemList = [:]
  pPropsList = [:]
  pScrollList = []
  pScrollStep = -1
  return 1
end

on deconstruct me
  me.clearSet()
  return 1
end

on update me
  if pScrollList.count = 0 then
    return 0
  end if
  i = 1
  repeat while i <= pScrollList.count
    tWindowID = pScrollList[i]
    tWndObj = getWindow(tWindowID)
    tWindowX = tWndObj.getProperty(#locX)
    if pScrollStep > 0 then
      tScrollActive = (tWindowX + pScrollStep) < pLocX
      if tScrollActive then
        tLocX = tWindowX + pScrollStep
      end if
    else
      tScrollActive = ((pLocX - tWindowX) / 2) >= 1
      if tScrollActive then
        tLocX = tWindowX + ((pLocX - tWindowX) / 2)
      end if
    end if
    if tScrollActive then
      i = i + 1
    else
      tLocX = pLocX
      pScrollList.deleteOne(tWindowID)
    end if
    tWndObj.moveBy(tLocX - tWindowX, 0)
  end repeat
  return 1
end

on define me, tSetID
  pID = tSetID
  return 1
end

on show me
  repeat with tID in pItemList
    tWndObj = getWindow(tID)
    if tWndObj <> 0 then
      tWndObj.show()
    end if
  end repeat
  return 1
end

on hide me
  repeat with tID in pItemList
    tWndObj = getWindow(tID)
    if tWndObj <> 0 then
      tWndObj.hide()
    end if
  end repeat
  return 1
end

on Activate me
  tWndMgr = getWindowManager()
  if tWndMgr = 0 then
    return 0
  end if
  repeat with tID in pItemList
    tWndMgr.Activate(tID)
  end repeat
  return 1
end

on addOneWindow me, tPartId, tOrderNum, tProps
  me.pItemList.setaProp(tOrderNum, tPartId)
  me.pItemList.sort()
  me.pPropsList.setaProp(tPartId, tProps)
  return 1
end

on removeOneWindow me, tPartId
  if tPartId = VOID then
    return 0
  end if
  if not removeWindow(tPartId) then
    error(me, "Problems removing window" && tPartId, #removeOneWindow)
  end if
  repeat with i = 1 to me.pItemList.count
    tItemID = me.pItemList[i]
    if tItemID = tPartId then
      me.pItemList.deleteAt(i)
      exit repeat
    end if
  end repeat
  me.pPropsList.deleteProp(tPartId)
  return 1
end

on getItems me
  return me.pItemList
end

on getCount me
  return me.pItemList.count
end

on getHighestIndex me
  tMaxIndex = -1
  repeat with i = 1 to me.pItemList.count
    tOrderNum = me.pItemList.getPropAt(i)
    if tOrderNum > tMaxIndex then
      tMaxIndex = tOrderNum
    end if
  end repeat
  return tMaxIndex
end

on getProperty me, tKey
  case tKey of
    #height:
      return me.getAllWindowProperty(#height, #total) + me.getAllDefinitionProperty(#spaceBottom, #total)
    #width:
      return me.getAllWindowProperty(#width, #max)
    #locX:
      return me.pLocX
    #locY:
      return me.pLocY
    #span_all_columns:
      return me.getAllDefinitionProperty(#span_all_columns)
  end case
  return 0
end

on render me, tMaxWidth, tMaxHeight
  tCount = pItemList.count
  tOwnWidth = me.getProperty(#width, #total)
  if tMaxWidth < 1 then
    tMaxWidth = tOwnWidth
  end if
  tOwnHeight = me.getProperty(#height, #total)
  if tMaxHeight < 1 then
    tMaxHeight = tOwnHeight
  end if
  repeat with tWindowID in pItemList
    tWndObj = getWindow(tWindowID)
    if tWndObj = 0 then
      return 0
    end if
    tProps = me.pPropsList.getaProp(tWindowID)
    if tProps <> VOID then
      repeat with j = 1 to tProps.count
        tKey = tProps.getPropAt(j)
        tValue = tProps[j]
        case tKey of
          #scaleV:
            tHeightD = tMaxHeight - tOwnHeight
            tWndObj.resizeBy(0, tHeightD)
          #scrollFromLocX:
            if not pScrollList.findPos(tWindowID) then
              pScrollList.append(tWindowID)
              tBoundary = tWndObj.getProperty(#boundary).duplicate()
              tBoundary[1] = tValue
              tWndObj.setProperty(#boundary, tBoundary)
              tWndObj.moveTo(tValue, tWndObj.getProperty(#locY))
            end if
        end case
      end repeat
    end if
  end repeat
  return 1
end

on clearSet me
  repeat with tPartId in pItemList
    if not removeWindow(tPartId) then
      error(me, "Unable to remove window" && tPartId, #deconstruct)
    end if
  end repeat
  pItemList = [:]
  pPropsListList = [:]
  return 1
end

on getElement me, tElemID
  tCount = pItemList.count
  repeat with tWindowID in pItemList
    tWndObj = getWindow(tWindowID)
    if tWndObj = 0 then
      return 0
    end if
    tElem = tWndObj.getElement(tElemID)
    if objectp(tElem) then
      return tElem
    end if
  end repeat
  return 0
end

on moveZ me, tZ
  repeat with tWindowID in pItemList
    tWndObj = getWindow(tWindowID)
    if tWndObj = 0 then
      return 0
    end if
    tWndObj.moveZ(tZ)
    tZ = tZ + 1
  end repeat
  return 1
end

on moveTo me, tLocX, tLocY
  pLocX = tLocX
  pLocY = tLocY
  repeat with tWindowID in pItemList
    tWndObj = getWindow(tWindowID)
    if tWndObj = 0 then
      return 0
    end if
    tProps = me.pPropsList.getaProp(tWindowID)
    tLocX = pLocX
    tFixed = 0
    tSpaceBottom = 0
    if tProps <> VOID then
      if tProps.findPos(#locY) then
        tFixed = 1
        tLocY = tProps.getaProp(#locY)
      end if
      if tProps.findPos(#scrollFromLocX) then
        tLocX = tWndObj.getProperty(#locX)
      end if
      if tProps.findPos(#spaceBottom) then
        tSpaceBottom = tProps.getaProp(#spaceBottom)
      end if
    end if
    if tFixed = 0 then
      tWndObj.moveTo(tLocX, tLocY)
    end if
    tLocY = tLocY + tWndObj.getProperty(#height) + tSpaceBottom
  end repeat
  return 1
end

on getRealLocation me
  if pItemList.count = 0 then
    return point(pLocX, pLocY)
  end if
  tWindowID = pItemList[1]
  tProps = me.pPropsList.getaProp(tWindowID)
  if listp(tProps) then
    if tProps.findPos(#scrollFromLocX) then
      return point(pLocX, pLocY)
    end if
  end if
  tWndObj = getWindow(tWindowID)
  if tWndObj = 0 then
    return 0
  end if
  return point(tWndObj.getProperty(#locX), tWndObj.getProperty(#locY))
end

on getAllDefinitionProperty me, tKey, tMode, tResult
  tCount = pPropsList.count
  repeat with i = 1 to tCount
    tList = pPropsList[i]
    if listp(tList) then
      if tList.findPos(tKey) then
        tValue = tList.getaProp(tKey)
        case tMode of
          #total:
            tResult = tResult + tValue
          #max:
            if tValue > tResult then
              tResult = tValue
            end if
          otherwise:
            return tValue
        end case
      end if
    end if
  end repeat
  return tResult
end

on getAllWindowProperty me, tKey, tMode, tResult
  tCount = pItemList.count
  repeat with i = 1 to tCount
    tWindowID = pItemList[i]
    tWndObj = getWindow(tWindowID)
    if tWndObj = 0 then
      return 0
    end if
    tValue = tWndObj.getProperty(tKey)
    case tMode of
      #total:
        tResult = tResult + tValue
      #max:
        if tValue > tResult then
          tResult = tValue
        end if
      otherwise:
        return tValue
    end case
  end repeat
  return tResult
end
