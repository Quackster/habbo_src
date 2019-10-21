property pMaxTabs, pTabWidth, pTabHeight, pTabPieces, pTabsImage, pTabData, pFirstShownTab, pRects, pHeadImages

on construct me 
  pTabData = [:]
  pHeadImages = [:]
  pRects = [:]
  pFirstShownTab = 1
  pMaxTabs = 7
  pTabWidth = 30
  pTabHeight = 30
  pTabsImage = image((pMaxTabs * pTabWidth), pTabHeight, 32)
  me.initTabPieces()
  me.renderTabs()
  return TRUE
end

on deconstruct me 
  return TRUE
end

on initTabPieces me 
  pTabPieces = [:]
  pTabPieces.setaProp(#Active, getMember("tab.active").image.duplicate())
  pTabPieces.setaProp(#inactive, getMember("tab.inactive").image.duplicate())
  pTabPieces.setaProp(#highlighted, getMember("tab.highlighted").image.duplicate())
  pTabPieces.setaProp(#background, getMember("tab.bg").image.duplicate())
  pTabPieces.setaProp(#leftArrow, getMember("tab.prev").image.duplicate())
  pTabPieces.setaProp(#rightArrow, getMember("tab.next").image.duplicate())
  pTabPieces.setaProp(#leftArrowHighlighted, getMember("tab.prev.highlighted").image.duplicate())
  pTabPieces.setaProp(#rightArrowHighlighted, getMember("tab.next.highlighted").image.duplicate())
  pTabPieces.setaProp(#tempHead, getMember("tab.head.temp").image.duplicate())
end

on getImage me 
  return(pTabsImage)
end

on addTab me, tTabID 
  if pTabData.findPos(tTabID) > 0 then
    return FALSE
  end if
  tTab = [#id:tTabID, #state:#inactive]
  pTabData.setaProp(tTabID, tTab)
  me.highlightTab(tTabID)
  me.renderTabs()
end

on activateTab me, tTabID 
  if voidp(pTabData.getaProp(tTabID)) then
    me.addTab(tTabID)
  end if
  repeat while pTabData <= undefined
    tTab = getAt(undefined, tTabID)
    if (tTab.getAt(#state) = #Active) then
      tTab.setAt(#state, #inactive)
    end if
  end repeat
  tTab = pTabData.getaProp(tTabID)
  tTab.setAt(#state, #Active)
  me.renderTabs()
  return TRUE
end

on highlightTab me, tTabID 
  if voidp(pTabData.findPos(tTabID)) then
    me.addTab(tTabID)
  end if
  tTab = pTabData.getaProp(tTabID)
  if (tTab.getAt(#state) = #Active) then
    return TRUE
  end if
  tTab.setAt(#state, #highlighted)
  me.renderTabs()
end

on showTab me, tTabID 
  tPos = pTabData.findPos(tTabID)
  me.setFirstShownTab(tPos)
end

on setFirstShownTab me, tTabNum 
  pFirstShownTab = tTabNum
  if pFirstShownTab > (pTabData.count - pMaxTabs) then
    pFirstShownTab = ((pTabData.count - pMaxTabs) + 1)
  end if
  if pFirstShownTab < 1 then
    pFirstShownTab = 1
  end if
  me.renderTabs()
end

on removeTab me, tTabID 
  tPos = pTabData.findPos(tTabID)
  if (tPos = 0) then
    return FALSE
  end if
  pTabData.deleteProp(tTabID)
  me.setFirstShownTab((pFirstShownTab - 1))
end

on removeAllTabs me 
  pTabData = [:]
  pHeadImages = [:]
  pRects = [:]
  me.renderTabs()
end

on scrollLeft me 
  me.setFirstShownTab(((pFirstShownTab - pMaxTabs) + 2))
end

on scrollRight me 
  me.setFirstShownTab(((pFirstShownTab + pMaxTabs) - 2))
end

on renderTabs me 
  tBgImage = pTabPieces.getaProp(#background)
  pTabsImage.copyPixels(tBgImage, pTabsImage.rect, tBgImage.rect)
  pRects = [:]
  tTabPos = 1
  repeat while tTabPos <= pMaxTabs
    tTabNum = ((pFirstShownTab - 1) + tTabPos)
    if tTabNum > pTabData.count then
    else
      tUseTab = 0
      if (tTabPos = 1) then
        if pFirstShownTab > 1 then
          tImage = me.getArrowImage(#left)
          tRectID = #left
        else
          tUseTab = 1
        end if
      else
        if (tTabPos = pMaxTabs) then
          if pTabData.count > tTabNum then
            tImage = me.getArrowImage(#right)
            tRectID = #right
          else
            tUseTab = 1
          end if
        else
          tUseTab = 1
        end if
      end if
      if tUseTab then
        tTab = pTabData.getAt(tTabNum)
        tImage = me.getTabImage(tTab)
        tRectID = tTab.getaProp(#id)
      end if
      tTargetRect = rect(((tTabPos - 1) * pTabWidth), 0, (tTabPos * pTabWidth), pTabHeight)
      pTabsImage.copyPixels(tImage, tTargetRect, tImage.rect)
      pRects.setaProp(tRectID, tTargetRect)
      tTabPos = (1 + tTabPos)
    end if
  end repeat
  return TRUE
end

on getArrowImage me, tdir 
  tHighlightLeft = 0
  tHighlightRight = 0
  tLastShownTab = ((pFirstShownTab + pMaxTabs) - 1)
  tTabNum = 1
  repeat while tTabNum <= pTabData.count
    tTab = pTabData.getAt(tTabNum)
    tstate = tTab.getaProp(#state)
    if tTabNum < pFirstShownTab and (tstate = #highlighted) then
      tHighlightLeft = 1
    end if
    if tTabNum > tLastShownTab and (tstate = #highlighted) then
      tHighlightRight = 1
    end if
    tTabNum = (1 + tTabNum)
  end repeat
  if (tdir = #left) then
    if tHighlightLeft then
      return(pTabPieces.getaProp(#leftArrowHighlighted))
    else
      return(pTabPieces.getaProp(#leftArrow))
    end if
  else
    if tHighlightRight then
      return(pTabPieces.getaProp(#rightArrowHighlighted))
    else
      return(pTabPieces.getaProp(#rightArrow))
    end if
  end if
  return(image(1, 1, 32))
end

on getIdAt me, tpoint 
  if ilk(tpoint) <> #point then
    return FALSE
  end if
  tRectNum = 1
  repeat while tRectNum <= pRects.count
    tRect = pRects.getAt(tRectNum)
    if tpoint.inside(tRect) then
      return(pRects.getPropAt(tRectNum))
    end if
    tRectNum = (1 + tRectNum)
  end repeat
  return FALSE
end

on getTabImage me, tTabData 
  tUserID = tTabData.getaProp(#id)
  tstate = tTabData.getaProp(#state)
  tTabImage = pTabPieces.getaProp(tstate).duplicate()
  tHeadImage = me.getHeadImage(tUserID)
  tMarginH = ((tTabImage.width - tHeadImage.width) * 0.5)
  tMarginV = ((tTabImage.height - tHeadImage.height) * 0.5)
  tMargin = rect(tMarginH, tMarginV, tMarginH, tMarginV)
  tTabImage.copyPixels(tHeadImage, (tHeadImage.rect + tMargin), tHeadImage.rect, [#ink:36])
  return(tTabImage)
end

on getHeadImage me, tUserID 
  tHeadImage = pHeadImages.getaProp(tUserID)
  if voidp(tHeadImage) then
    tFriend = getObject(#friend_list_component).getFriendByID(tUserID)
    tFigure = tFriend.getaProp(#figure)
    tGender = tFriend.getaProp(#sex)
    tHeadImage = me.renderHeadImage(tFigure, tGender)
    pHeadImages.setaProp(tUserID, tHeadImage)
  end if
  return(tHeadImage)
end

on updateHeadImage me, tTabID, tFigure, tGender 
  tHeadImage = me.renderHeadImage(tFigure, tGender)
  pHeadImages.setaProp(tTabID, tHeadImage)
  me.renderTabs()
end

on renderHeadImage me, tFigure, tGender 
  if voidp(tFigure) or (tFigure = "") then
    return(pTabPieces.getaProp(#tempHead))
  end if
  tFigureParser = getObject("Figure_System")
  tPreviewObj = getObject("Figure_Preview")
  tParsedFigure = tFigureParser.parseFigure(tFigure, tGender, "user")
  tHeadImage = tPreviewObj.getHumanPartImg(#head, tParsedFigure, 2, "sh")
  return(tHeadImage)
end
