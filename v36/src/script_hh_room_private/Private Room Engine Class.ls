property pWallDefined, pWallModel, pFloorDefined, pFloorModel, pWallPatterns, pFloorPatterns, pLandscapeMngr

on construct me 
  pWallPatterns = field(0)
  pFloorPatterns = field(0)
  pWallDefined = 0
  pFloorDefined = 0
  pWallModel = string(getVariable("room.default.wall", "201"))
  pFloorModel = string(getVariable("room.default.floor", "203"))
  pLandscapeMngr = createObject("landscape_manager", "Landscape Manager")
  registerMessage(#colorizeRoom, me.getID(), #renderRoomBackground)
  registerMessage(#setDimmerColor, me.getID(), #setRoomDimmerColor)
  me.setRoomDimmerColor(rgb(255, 255, 255))
  return(1)
end

on deconstruct me 
  if objectExists("landscape_manager") then
    removeObject("landscape_manager")
  end if
  unregisterMessage(#colorizeRoom, me.getID())
  unregisterMessage(#setDimmerColor, me.getID())
end

on prepare me 
  tStamp = ""
  tNo = 1
  repeat while tNo <= 100
    tChar = numToChar(random(48) + 74)
    tStamp = tStamp & tChar
    tNo = 1 + tNo
  end repeat
  tFuseReceipt = getSpecialServices().getReceipt(tStamp)
  tReceipt = []
  tCharNo = 1
  repeat while tCharNo <= tStamp.length
    tChar = chars(tStamp, tCharNo, tCharNo)
    tChar = charToNum(tChar)
    tChar = (tChar * tCharNo) + 309203
    tReceipt.setAt(tCharNo, tChar)
    tCharNo = 1 + tCharNo
  end repeat
  if tReceipt <> tFuseReceipt then
    error(me, "Invalid build structure", #prepare, #critical)
    createTimeout(#builddisconnect, 3000, #disconnect, getThread(#login).getComponent().getID(), void(), 1)
  end if
  if not pWallDefined then
    me.setWallPaper(pWallModel)
  end if
  if not pFloorDefined then
    me.setFloorPattern(pFloorModel)
  end if
  return(1)
end

on setProperty me, tKey, tValue 
  if tKey = "wallpaper" then
    return(me.setWallPaper(tValue))
  else
    if tKey = "floor" then
      return(me.setFloorPattern(tValue))
    end if
  end if
end

on setWallPaper me, tIndex 
  tField = pWallPatterns.getProp(#line, integer(tIndex.getProp(#char, 1, length(tIndex) - 2)))
  if tField = "" then
    return(error(me, "Invalid wall color index:" && tIndex, #setWallPaper, #major))
  end if
  if not memberExists(tField) then
    error(me, "Invalid wall color index:" && tIndex, #setWallPaper, #minor)
    return(me.setWallPaper(string(getVariable("room.default.wall"))))
  end if
  tmodel = field(0)
  tPattern = tmodel.getProp(#line, integer(tIndex.getProp(#char, length(string(tIndex)) - 1, length(string(tIndex)))))
  if tPattern = "" then
    return(error(me, "Invalid wall color index:" && tIndex, #setWallPaper, #major))
  end if
  tDelim = the itemDelimiter
  the itemDelimiter = ","
  ttype = tPattern.getProp(#item, 1)
  tPalette = tPattern.getProp(#item, 2)
  tR = integer(tPattern.getProp(#item, 3))
  tG = integer(tPattern.getProp(#item, 4))
  tB = integer(tPattern.getProp(#item, 5))
  tColor = rgb(tR, tG, tB)
  tColors = ["left":tColor - rgb(16, 16, 16), "right":tColor, "a":tColor - rgb(16, 16, 16), "b":tColor]
  the itemDelimiter = "_"
  tPieceList = getThread(#room).getComponent().getPassiveObject(#list)
  tObjPieceCount = 0
  repeat while tField <= undefined
    tPiece = getAt(undefined, tIndex)
    tSprList = tPiece.getSprites()
    repeat while tField <= undefined
      tSpr = getAt(undefined, tIndex)
      tdir = name.getProp(#item, 1)
      tName = name.getProp(#item, 2)
      tdata = tSpr.getProp(length(member.name) - 7, tSpr, length(member.name))
      tColor = tdir
      if tColor = "corner" then
        if tdata.getProp(#char, 2) = "a" then
          tColor = "right"
        else
          tColor = "left"
        end if
      end if
      if memberExists(tdir & "_" & tName & "_" & ttype & tdata) then
        tSpr.member = member(getmemnum(tdir & "_" & tName & "_" & ttype & tdata))
        tSpr.bgColor = tColors.getAt(tColor)
        member.paletteRef = member(getmemnum(tPalette))
        tObjPieceCount = tObjPieceCount + 1
        if pWallDefined = 0 then
          tSpr.locZ = tSpr.locZ - 975
        end if
        if tSpr.blend = 100 then
          tSpr.ink = 41
        end if
      else
        error(me, "Wall member not found:" && tdir & "_" & tName & "_" & ttype & tdata, #setWallPaper, #minor)
      end if
    end repeat
  end repeat
  the itemDelimiter = tDelim
  tViz = me.getRoomVisualizer()
  if objectp(tViz) then
    tWrappedWallParts = tViz.getWrappedParts([#wallleft, #wallright])
    if tWrappedWallParts.count > 0 then
      repeat while tField <= undefined
        tWrapper = getAt(undefined, tIndex)
        tWrapper.setPartPattern(ttype, tPalette, tColors.getAt("left"), #wallleft)
        tWrapper.setPartPattern(ttype, tPalette, tColors.getAt("right"), #wallright)
        tWrappedWallPartsDefined = 1
      end repeat
    else
      tWrappedWallPartsDefined = 0
    end if
  end if
  if tPieceList.count = 0 and not tWrappedWallPartsDefined then
    pWallModel = tIndex
    pWallDefined = 0
    return(0)
  else
    pWallDefined = 1
    return(1)
  end if
end

on setFloorPattern me, tIndex 
  tField = pFloorPatterns.getProp(#line, integer(tIndex.getProp(#char, 1, length(tIndex) - 2)))
  if tField = "" then
    return(error(me, "Invalid floor color index:" && tIndex, #setFloorPattern, #major))
  end if
  if not memberExists(tField) then
    error(me, "Invalid floor color index:" && tIndex, #setFloorPatterns, #minor)
    return(me.setFloorPattern(string(getVariable("room.default.floor"))))
  end if
  tmodel = field(0)
  tPattern = tmodel.getProp(#line, integer(tIndex.getProp(#char, length(string(tIndex)) - 1, length(string(tIndex)))))
  if tPattern = "" then
    return(error(me, "Invalid floor color index:" && tIndex, #setFloorPattern, #major))
  end if
  tDelim = the itemDelimiter
  the itemDelimiter = ","
  ttype = tPattern.getProp(#item, 1)
  tPalette = tPattern.getProp(#item, 2)
  tR = integer(tPattern.getProp(#item, 3))
  tG = integer(tPattern.getProp(#item, 4))
  tB = integer(tPattern.getProp(#item, 5))
  tColor = rgb(tR, tG, tB)
  tVisualizer = me.getRoomVisualizer()
  if not objectp(tVisualizer) then
    pFloorModel = tIndex
    pFloorDefined = 0
    return(0)
  end if
  tVisualizer = me.getRoomVisualizer()
  if not objectp(tVisualizer) then
    return(0)
  end if
  tPieceId = 1
  tSpr = tVisualizer.getSprById("floor" & tPieceId)
  tDelim = the itemDelimiter
  the itemDelimiter = "_"
  repeat while not tSpr = 0
    tMem = member.name
    tClass = tMem.getProp(#item, 1) & "_" & tMem.getProp(#item, 2) & "_"
    tLayer = tMem.getProp(#item, 4) & "_"
    tObs1 = tMem.getProp(#item, 5) & "_"
    tdir = tMem.getProp(#item, 6) & "_"
    tObs2 = tMem.getProp(#item, 7)
    tNewMemName = tClass & ttype & "_" & tLayer & tObs1 & tdir & tObs2
    if memberExists(tNewMemName) then
      tSpr.member = member(tNewMemName)
    end if
    tSpr.bgColor = tColor
    member.paletteRef = member(getmemnum(tPalette))
    tSpr.ink = 41
    tSpr.locZ = tSpr.locZ - 1000000
    tPieceId = tPieceId + 1
    tSpr = tVisualizer.getSprById("floor" & tPieceId)
  end repeat
  the itemDelimiter = tDelim
  tWrappedParts = tVisualizer.getWrappedParts([#floor])
  repeat while tField <= undefined
    tWrapper = getAt(undefined, tIndex)
    tWrapper.setPartPattern(ttype, tPalette, tColor, #floor)
  end repeat
  the itemDelimiter = tDelim
  pFloorDefined = 1
  return(1)
end

on renderRoomBackground me, tColor 
  tVisualizer = me.getRoomVisualizer()
  if objectp(tVisualizer) then
    tVisualizer.renderWrappedParts(tColor)
  end if
end

on setRoomDimmerColor me, tColor 
  tVisualizer = me.getRoomVisualizer()
  if objectp(tVisualizer) then
    tVisualizer.setDimmerColor(tColor)
  end if
end

on getRoomVisualizer me 
  if threadExists(#room) then
    tInterface = getThread(#room).getInterface()
    tComponent = getThread(#room).getComponent()
    if tComponent.getRoomID() = "private" then
      tVisualizer = getThread(#room).getInterface().getRoomVisualizer()
      if objectp(tVisualizer) then
        return(tVisualizer)
      end if
    end if
  end if
  return(0)
end

on insertWallMaskItem me, tID, tClassID, tloc, tdir, tSize 
  if objectp(pLandscapeMngr) then
    pLandscapeMngr.insertWallMaskItem(tID, tClassID, tloc, tdir, tSize)
  end if
end

on removeWallMaskItem me, tID 
  if objectp(pLandscapeMngr) then
    pLandscapeMngr.removeWallMaskItem(tID)
  end if
end

on setLandscape me, ttype, tScale 
  if objectp(pLandscapeMngr) then
    pLandscapeMngr.setLandscape(ttype, tScale)
  end if
end

on setLandscapeAnimation me, tID, tScale 
  if objectp(pLandscapeMngr) then
    pLandscapeMngr.setLandscapeAnimation(tID, tScale)
  end if
end

on getWallMaskCount me 
  if objectp(pLandscapeMngr) then
    return(pLandscapeMngr.getWallMaskCount())
  end if
end
