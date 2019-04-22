property pScrollList, pScrollStep, pLocX, pItemList, pLocY, pPropsList

on construct me 
  pItemList = [:]
  pPropsList = [:]
  pScrollList = []
  pScrollStep = -1
  return(1)
end

on deconstruct me 
  me.clearSet()
  return(1)
end

on update me 
  if pScrollList.count = 0 then
    return(0)
  end if
  i = 1
  repeat while i <= pScrollList.count
    tWindowID = pScrollList.getAt(i)
    tWndObj = getWindow(tWindowID)
    tWindowX = tWndObj.getProperty(#locX)
    if pScrollStep > 0 then
      tScrollActive = tWindowX + pScrollStep < pLocX
      if tScrollActive then
        tLocX = tWindowX + pScrollStep
      end if
    else
      tScrollActive = pLocX - tWindowX / 2 >= 1
      if tScrollActive then
        tLocX = tWindowX + pLocX - tWindowX / 2
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
  return(1)
end

on define me, tSetID 
  pID = tSetID
  return(1)
end

on show me 
  repeat while pItemList <= undefined
    tID = getAt(undefined, undefined)
    tWndObj = getWindow(tID)
    if tWndObj <> 0 then
      tWndObj.show()
    end if
  end repeat
  return(1)
end

on hide me 
  repeat while pItemList <= undefined
    tID = getAt(undefined, undefined)
    tWndObj = getWindow(tID)
    if tWndObj <> 0 then
      tWndObj.hide()
    end if
  end repeat
  return(1)
end

on Activate me 
  tWndMgr = getWindowManager()
  if tWndMgr = 0 then
    return(0)
  end if
  repeat while pItemList <= undefined
    tID = getAt(undefined, undefined)
    tWndMgr.Activate(tID)
  end repeat
  return(1)
end

on addOneWindow me, tPartId, tOrderNum, tProps 
  me.setaProp(tOrderNum, tPartId)
  me.sort()
  me.setaProp(tPartId, tProps)
  return(1)
end

on removeOneWindow me, tPartId 
  if tPartId = void() then
    return(0)
  end if
  if not removeWindow(tPartId) then
    error(me, "Problems removing window" && tPartId, #removeOneWindow)
  end if
  i = 1
  repeat while i <= me.count(#pItemList)
    tItemID = me.getProp(#pItemList, i)
    if tItemID = tPartId then
      me.deleteAt(i)
    else
      i = 1 + i
    end if
  end repeat
  me.deleteProp(tPartId)
  return(1)
end

on getItems me 
  return(me.pItemList)
end

on getCount me 
  return(me.count(#pItemList))
end

on getHighestIndex me 
  tMaxIndex = -1
  i = 1
  repeat while i <= me.count(#pItemList)
    tOrderNum = me.getPropAt(i)
    if tOrderNum > tMaxIndex then
      tMaxIndex = tOrderNum
    end if
    i = 1 + i
  end repeat
  return(tMaxIndex)
end

on getProperty me, tKey 
  if tKey = #height then
    return(me.getAllWindowProperty(#height, #total) + me.getAllDefinitionProperty(#spaceBottom, #total))
  else
    if tKey = #width then
      return(me.getAllWindowProperty(#width, #max))
    else
      if tKey = #locX then
        return(me.pLocX)
      else
        if tKey = #locY then
          return(me.pLocY)
        else
          if tKey = #span_all_columns then
            return(me.getAllDefinitionProperty(#span_all_columns))
          end if
        end if
      end if
    end if
  end if
  return(0)
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
  repeat while pItemList <= tMaxHeight
    tWindowID = getAt(tMaxHeight, tMaxWidth)
    tWndObj = getWindow(tWindowID)
    if tWndObj = 0 then
      return(0)
    end if
    tProps = me.getaProp(tWindowID)
    if tProps <> void() then
      j = 1
      repeat while j <= tProps.count
        tKey = tProps.getPropAt(j)
        tValue = tProps.getAt(j)
        if pItemList = #scaleV then
          tHeightD = tMaxHeight - tOwnHeight
          tWndObj.resizeBy(0, tHeightD)
        else
          if pItemList = #scrollFromLocX then
            if not pScrollList.findPos(tWindowID) then
              pScrollList.append(tWindowID)
              tBoundary = tWndObj.getProperty(#boundary).duplicate()
              tBoundary.setAt(1, tValue)
              tWndObj.setProperty(#boundary, tBoundary)
              tWndObj.moveTo(tValue, tWndObj.getProperty(#locY))
            end if
          end if
        end if
        j = 1 + j
      end repeat
    end if
  end repeat
  return(1)
end

on clearSet me 
  repeat while pItemList <= undefined
    tPartId = getAt(undefined, undefined)
    if not removeWindow(tPartId) then
      error(me, "Unable to remove window" && tPartId, #deconstruct)
    end if
  end repeat
  pItemList = [:]
  pPropsListList = [:]
  return(1)
end

on getElement me, tElemID 
  tCount = pItemList.count
  repeat while pItemList <= undefined
    tWindowID = getAt(undefined, tElemID)
    tWndObj = getWindow(tWindowID)
    if tWndObj = 0 then
      return(0)
    end if
    tElem = tWndObj.getElement(tElemID)
    if objectp(tElem) then
      return(tElem)
    end if
  end repeat
  return(0)
end

on moveZ me, tZ 
  repeat while pItemList <= undefined
    tWindowID = getAt(undefined, tZ)
    tWndObj = getWindow(tWindowID)
    if tWndObj = 0 then
      return(0)
    end if
    tWndObj.moveZ(tZ)
    tZ = tZ + 1
  end repeat
  return(1)
end

on moveTo me, tLocX, tLocY 
  pLocX = tLocX
  pLocY = tLocY
  repeat while pItemList <= tLocY
    tWindowID = getAt(tLocY, tLocX)
    tWndObj = getWindow(tWindowID)
    if tWndObj = 0 then
      return(0)
    end if
    tProps = me.getaProp(tWindowID)
    tLocX = pLocX
    tFixed = 0
    tSpaceBottom = 0
    if tProps <> void() then
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
  return(1)
end

on getRealLocation me 
  if pItemList.count = 0 then
    return(point(pLocX, pLocY))
  end if
  tWindowID = pItemList.getAt(1)
  tProps = me.getaProp(tWindowID)
  if listp(tProps) then
    if tProps.findPos(#scrollFromLocX) then
      return(point(pLocX, pLocY))
    end if
  end if
  tWndObj = getWindow(tWindowID)
  if tWndObj = 0 then
    return(0)
  end if
  return(point(tWndObj.getProperty(#locX), tWndObj.getProperty(#locY)))
end

on getAllDefinitionProperty me, tKey, tMode, tResult 
  tCount = pPropsList.count
  i = 1
  repeat while i <= tCount
    tList = pPropsList.getAt(i)
    if listp(tList) then
      if tList.findPos(tKey) then
        tValue = tList.getaProp(tKey)
        if tMode = #total then
          tResult = tResult + tValue
        else
          if tMode = #max then
            if tValue > tResult then
              tResult = tValue
            end if
          else
            return(tValue)
          end if
        end if
      end if
    end if
    i = 1 + i
  end repeat
  return(tResult)
end

on getAllWindowProperty me, tKey, tMode, tResult 
  tCount = pItemList.count
  i = 1
  repeat while i <= tCount
    tWindowID = pItemList.getAt(i)
    tWndObj = getWindow(tWindowID)
    if tWndObj = 0 then
      return(0)
    end if
    tValue = tWndObj.getProperty(tKey)
    if tMode = #total then
      tResult = tResult + tValue
    else
      if tMode = #max then
        if tValue > tResult then
          tResult = tValue
        end if
      else
        return(tValue)
      end if
    end if
    i = 1 + i
  end repeat
  return(tResult)
end
