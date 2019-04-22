on construct(me)
  pWriterIdPlain = getUniqueID()
  pWriterIdBold = getUniqueID()
  pWindowIdPrefix = "ig"
  pWindowID = ""
  return(me.construct())
  exit
end

on deconstruct(me)
  if pID = #modal then
    return(me.removeModalWindow())
  end if
  tWrapObjRef = me.getWindowWrapper()
  if tWrapObjRef = 0 then
    return(0)
  end if
  tWrapObjRef.removeMatchingSets(pWindowSetId)
  if writerExists(pWriterIdPlain) then
    removeWriter(pWriterIdPlain)
  end if
  if writerExists(pWriterIdBold) then
    removeWriter(pWriterIdBold)
  end if
  return(me.deconstruct())
  exit
end

on setID(me, tID)
  pID = tID
  exit
end

on addWindows(me)
  if pID = #modal then
    return(me.createModalWindow())
  end if
  return(1)
  exit
end

on render(me)
  exit
end

on update(me)
  exit
end

on getOwnPlayerName(me)
  tSession = getObject(#session)
  if tSession = 0 then
    return(0)
  end if
  if not tSession.exists(#user_name) then
    return(0)
  end if
  return(tSession.GET(#user_name))
  exit
end

on getOwnPlayerGameIndex(me)
  tSession = getObject(#session)
  if tSession = 0 then
    return(0)
  end if
  if not tSession.exists("user_game_index") then
    return(-1)
  end if
  tIndex = tSession.GET("user_game_index")
  return(tIndex)
  exit
end

on getPlainWriter(me)
  if writerExists(pWriterIdPlain) then
    return(getWriter(pWriterIdPlain))
  end if
  tPlainStruct = getStructVariable("struct.font.plain")
  createWriter(pWriterIdPlain, tPlainStruct)
  return(getWriter(pWriterIdPlain))
  exit
end

on getBoldWriter(me)
  if writerExists(pWriterIdBold) then
    return(getWriter(pWriterIdBold))
  end if
  tBoldStruct = getStructVariable("struct.font.bold")
  tBoldStruct.setaProp(#fontStyle, [#underline])
  createWriter(pWriterIdBold, tBoldStruct)
  return(getWriter(pWriterIdBold))
  exit
end

on alignIconImage(me, tImage, tWidth, tHeight)
  if tImage.ilk <> #image then
    return(0)
  end if
  tNewImage = image(tWidth, tHeight, tImage.depth)
  tOffsetX = tWidth - tImage.width / 2
  tOffsetY = tHeight - tImage.height
  tNewImage.copyPixels(tImage, tImage.rect + rect(tOffsetX, tOffsetY, tOffsetX, tOffsetY), tImage.rect)
  return(tNewImage)
  exit
end

on getHeadImage(me, tFigure, tsex, tWidth, tHeight)
  tFigureObj = getObject("Figure_Preview")
  if tFigureObj = 0 then
    return(0)
  end if
  if tFigure.ilk <> #propList then
    tParserObj = getObject("Figure_System")
    if tParserObj = 0 then
      return(0)
    end if
    tFigure = tParserObj.parseFigure(tFigure, tsex)
  end if
  tImage = tFigureObj.getHumanPartImg(#head, tFigure, 2, "sh")
  if voidp(tHeight) then
    return(tImage)
  else
    return(me.alignIconImage(tImage, tWidth, tHeight))
  end if
  exit
end

on getWindowWrapper(me)
  return(getObject(#ig_window_wrapper))
  exit
end

on getMainThread(me)
  return(getObject(me.pMainThreadId))
  exit
end

on getIGComponent(me, tID)
  tMainThreadRef = me.getMainThread()
  if not objectp(tMainThreadRef) then
    return(0)
  end if
  return(tMainThreadRef.getIGComponent(tID))
  exit
end

on getWindowId(me, tParam)
  if voidp(tParam) then
    return(pWindowIdPrefix & "_" & pWindowID)
  else
    return(pWindowIdPrefix & "_" & pWindowID & "_" & tParam)
  end if
  exit
end

on createModalWindow(me)
  if pModalSpr > 0 then
    return(1)
  end if
  pModalSpr = reserveSprite(me.getID())
  tsprite = sprite(pModalSpr)
  tsprite.member = member(getmemnum("null"))
  tsprite.blend = 70
  tsprite.rect = rect(0, 0, undefined.width, undefined.height)
  tVisualizer = getVisualizer("Room_visualizer")
  if tVisualizer <> 0 then
    -- UNK_80 1442
    -- UNK_2
  else
    -- UNK_80 2466
    -- UNK_2
  end if
  setEventBroker(tsprite.spriteNum, me.getID() & "_spr")
  return(1)
  exit
end

on removeModalWindow(me)
  if pModalSpr > 0 then
    releaseSprite(pModalSpr)
    pModalSpr = void()
  end if
  return(1)
  exit
end

on removeMatchingSets(me, tWindowSetId, tRender)
  if tWindowSetId = void() then
    return(0)
  end if
  tIdLength = tWindowSetId.length
  i = 1
  repeat while i <= me.count(#pSetIndex)
    tTestString = me.getProp(#pSetIndex, i)
    if tTestString.getProp(#char, 1, tIdLength) = tWindowSetId then
      me.removeSet(tTestString, tRender)
      next repeat
    end if
    i = i + 1
  end repeat
  return(1)
  exit
end

on eventProcMouseDown(me, tEvent, tSprID, tParam, tWndID)
  return(1)
  exit
end