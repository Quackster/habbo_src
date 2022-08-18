property pWallPatterns, pWallDefined, pWallModel, pFloorPatterns, pFloorDefined, pFloorModel, pLandscapeMngr

on construct me
  pWallPatterns = field("wallpattern_patterns")
  pFloorPatterns = field("floorpattern_patterns")
  pWallDefined = 0
  pFloorDefined = 0
  pWallModel = string(getVariable("room.default.wall", "201"))
  pFloorModel = string(getVariable("room.default.floor", "203"))
  pLandscapeMngr = createObject("landscape_manager", "Landscape Manager")
  registerMessage(#colorizeRoom, me.getID(), #renderRoomBackground)
  registerMessage(#setDimmerColor, me.getID(), #setRoomDimmerColor)
  me.setRoomDimmerColor(rgb(255, 255, 255))
  return 1
end

on deconstruct me
  if objectExists("landscape_manager") then
    removeObject("landscape_manager")
  end if
  unregisterMessage(#colorizeRoom, me.getID())
  unregisterMessage(#setDimmerColor, me.getID())
end

on prepare me
  tStamp = EMPTY
  repeat with tNo = 1 to 100
    tChar = numToChar((random(48) + 74))
    tStamp = (tStamp & tChar)
  end repeat
  tFuseReceipt = getSpecialServices().getReceipt(tStamp)
  tReceipt = []
  repeat with tCharNo = 1 to tStamp.length
    tChar = chars(tStamp, tCharNo, tCharNo)
    tChar = charToNum(tChar)
    tChar = ((tChar * tCharNo) + 309203)
    tReceipt[tCharNo] = tChar
  end repeat
  if (tReceipt <> tFuseReceipt) then
    error(me, "Invalid build structure", #prepare, #critical)
    createTimeout(#builddisconnect, 3000, #disconnect, getThread(#login).getComponent().getID(), VOID, 1)
  end if
  if not pWallDefined then
    me.setWallPaper(pWallModel)
  end if
  if not pFloorDefined then
    me.setFloorPattern(pFloorModel)
  end if
  return 1
end

on setProperty me, tKey, tValue
  case tKey of
    "wallpaper":
      return me.setWallPaper(tValue)
    "floor":
      return me.setFloorPattern(tValue)
  end case
end

on setWallPaper me, tIndex
  tField = pWallPatterns.line[integer(tIndex.char[1])]
  if (tField = EMPTY) then
    return error(me, ("Invalid wall color index:" && tIndex), #setWallPaper, #major)
  end if
  if not memberExists(tField) then
    error(me, ("Invalid wall color index:" && tIndex), #setWallPaper, #minor)
    return me.setWallPaper(string(getVariable("room.default.wall")))
  end if
  tmodel = field(tField)
  tPattern = tmodel.line[integer(tIndex.char[(length(string(tIndex)) - 1)])]
  if (tPattern = EMPTY) then
    return error(me, ("Invalid wall color index:" && tIndex), #setWallPaper, #major)
  end if
  tDelim = the itemDelimiter
  the itemDelimiter = ","
  ttype = tPattern.item[1]
  tPalette = tPattern.item[2]
  tR = integer(tPattern.item[3])
  tG = integer(tPattern.item[4])
  tB = integer(tPattern.item[5])
  tColor = rgb(tR, tG, tB)
  tColors = ["left": (tColor - rgb(16, 16, 16)), "right": tColor, "a": (tColor - rgb(16, 16, 16)), "b": tColor]
  the itemDelimiter = "_"
  tPieceList = getThread(#room).getComponent().getPassiveObject(#list)
  tObjPieceCount = 0
  repeat with tPiece in tPieceList
    tSprList = tPiece.getSprites()
    repeat with tSpr in tSprList
      tdir = tSpr.member.name.item[1]
      tName = tSpr.member.name.item[2]
      tdata = tSpr.member.name.char[(length(tSpr.member.name) - 7)]
      tColor = tdir
      if (tColor = "corner") then
        if (tdata.char[2] = "a") then
          tColor = "right"
        else
          tColor = "left"
        end if
      end if
      if memberExists((((((tdir & "_") & tName) & "_") & ttype) & tdata)) then
        tSpr.member = member(getmemnum((((((tdir & "_") & tName) & "_") & ttype) & tdata)))
        tSpr.bgColor = tColors[tColor]
        tSpr.member.paletteRef = member(getmemnum(tPalette))
        tObjPieceCount = (tObjPieceCount + 1)
        if (pWallDefined = 0) then
          tSpr.locZ = (tSpr.locZ - 975)
        end if
        if (tSpr.blend = 100) then
          tSpr.ink = 41
        end if
        next repeat
      end if
      error(me, (((((("Wall member not found:" && tdir) & "_") & tName) & "_") & ttype) & tdata), #setWallPaper, #minor)
    end repeat
  end repeat
  the itemDelimiter = tDelim
  tViz = me.getRoomVisualizer()
  if objectp(tViz) then
    tWrappedWallParts = tViz.getWrappedParts([#wallleft, #wallright])
    if (tWrappedWallParts.count > 0) then
      repeat with tWrapper in tWrappedWallParts
        tWrapper.setPartPattern(ttype, tPalette, tColors["left"], #wallleft)
        tWrapper.setPartPattern(ttype, tPalette, tColors["right"], #wallright)
        tWrappedWallPartsDefined = 1
      end repeat
    else
      tWrappedWallPartsDefined = 0
    end if
  end if
  if ((tPieceList.count = 0) and not tWrappedWallPartsDefined) then
    pWallModel = tIndex
    pWallDefined = 0
    return 0
  else
    pWallDefined = 1
    return 1
  end if
end

on setFloorPattern me, tIndex
  tField = pFloorPatterns.line[integer(tIndex.char[1])]
  if (tField = EMPTY) then
    return error(me, ("Invalid floor color index:" && tIndex), #setFloorPattern, #major)
  end if
  if not memberExists(tField) then
    error(me, ("Invalid floor color index:" && tIndex), #setFloorPatterns, #minor)
    return me.setFloorPattern(string(getVariable("room.default.floor")))
  end if
  tmodel = field(tField)
  tPattern = tmodel.line[integer(tIndex.char[(length(string(tIndex)) - 1)])]
  if (tPattern = EMPTY) then
    return error(me, ("Invalid floor color index:" && tIndex), #setFloorPattern, #major)
  end if
  tDelim = the itemDelimiter
  the itemDelimiter = ","
  ttype = tPattern.item[1]
  tPalette = tPattern.item[2]
  tR = integer(tPattern.item[3])
  tG = integer(tPattern.item[4])
  tB = integer(tPattern.item[5])
  tColor = rgb(tR, tG, tB)
  tVisualizer = me.getRoomVisualizer()
  if not objectp(tVisualizer) then
    pFloorModel = tIndex
    pFloorDefined = 0
    return 0
  end if
  tVisualizer = me.getRoomVisualizer()
  if not objectp(tVisualizer) then
    return 0
  end if
  tPieceId = 1
  tSpr = tVisualizer.getSprById(("floor" & tPieceId))
  tDelim = the itemDelimiter
  the itemDelimiter = "_"
  repeat while not (tSpr = 0)
    tMem = tSpr.member.name
    tClass = (((tMem.item[1] & "_") & tMem.item[2]) & "_")
    tLayer = (tMem.item[4] & "_")
    tObs1 = (tMem.item[5] & "_")
    tdir = (tMem.item[6] & "_")
    tObs2 = tMem.item[7]
    tNewMemName = ((((((tClass & ttype) & "_") & tLayer) & tObs1) & tdir) & tObs2)
    if memberExists(tNewMemName) then
      tSpr.member = member(tNewMemName)
    end if
    tSpr.bgColor = tColor
    tSpr.member.paletteRef = member(getmemnum(tPalette))
    tSpr.ink = 41
    tSpr.locZ = (tSpr.locZ - 1000000)
    tPieceId = (tPieceId + 1)
    tSpr = tVisualizer.getSprById(("floor" & tPieceId))
  end repeat
  the itemDelimiter = tDelim
  tWrappedParts = tVisualizer.getWrappedParts([#floor])
  repeat with tWrapper in tWrappedParts
    tWrapper.setPartPattern(ttype, tPalette, tColor, #floor)
  end repeat
  the itemDelimiter = tDelim
  pFloorDefined = 1
  return 1
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
    if (tComponent.getRoomID() = "private") then
      tVisualizer = getThread(#room).getInterface().getRoomVisualizer()
      if objectp(tVisualizer) then
        return tVisualizer
      end if
    end if
  end if
  return 0
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

on setLandscape me, tID, tScale
  if objectp(pLandscapeMngr) then
    pLandscapeMngr.setLandscape(tID, tScale)
  end if
end

on setLandscapeAnimation me, tID, tScale
  if objectp(pLandscapeMngr) then
    pLandscapeMngr.setLandscapeAnimation(tID, tScale)
  end if
end
