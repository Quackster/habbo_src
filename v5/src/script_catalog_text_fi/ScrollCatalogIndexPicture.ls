property sFrame, context

on beginSprite me 
  if openCatalog = 1 then
    openCatalog = 0
    oldItemLimiter = the itemDelimiter
    the itemDelimiter = ","
    activeButton = 1
    ButtonWidth = member(member("CatalogPage_index").getPropRef(#line, 1).getProp(#item, 1) & "_inactive").width
    ButtonHeigth = member(member("CatalogPage_index").getPropRef(#line, 1).getProp(#item, 1) & "_inactive").height
    Pages = member("CatalogPage_index").count(#line)
    indexWidth = (ButtonWidth * Pages)
    myImage = image(indexWidth, ButtonHeigth, 32)
    member("catalogIndexPic").image = myImage
    links = []
    previousEndPoint = point(0, 0)
    f = 1
    repeat while f <= Pages
      if f = 1 then
        Pic = member(member("CatalogPage_index").getPropRef(#line, f).getProp(#item, 1) & "_active")
      else
        Pic = member(member("CatalogPage_index").getPropRef(#line, f).getProp(#item, 1) & "_inactive")
      end if
      StartPoint = previousEndPoint
      EndPoint = point(Pic.width, Pic.height) + StartPoint
      previousEndPoint = point(EndPoint.locH, 0)
      targetRect = rect(StartPoint, EndPoint)
      sourseRect = Pic.rect
      member("catalogIndexPic").image.copyPixels(Pic.image, targetRect, sourseRect)
      links.append(member("CatalogPage_index").getPropRef(#line, f).getProp(#item, 2))
      f = 1 + f
    end repeat
    updateStage()
    CropToVisibleArea(me, point(0, 0))
    the itemDelimiter = oldItemLimiter
  end if
end

on ScrollCatalogIndex me, direction 
  scroll = 1
  if direction = "left" then
    repeat while scroll
      scrollTime = the ticks + 25
      f = ((whichIsFirstNow - 1 * ButtonWidth) / 7)
      repeat while f >= ((whichIsFirstNow - 2 * ButtonWidth) / 7)
        if the ticks > scrollTime then
        else
          CropToVisibleArea(me, point((f * 7), 0))
          updateStage()
          f = 65535 + f
        end if
      end repeat
      if the ticks > scrollTime then
        CropToVisibleArea(me, point((whichIsFirstNow - 2 * ButtonWidth), 0))
      end if
      whichIsFirstNow = whichIsFirstNow - 1
      if the mouseDown = 0 or whichIsFirstNow = 1 then
        scroll = 0
      end if
    end repeat
    exit repeat
  end if
  repeat while scroll
    scrollTime = the ticks + 25
    f = ((whichIsFirstNow - 1 * ButtonWidth) / 7)
    repeat while f <= ((whichIsFirstNow * ButtonWidth) / 7)
      if the ticks > scrollTime then
      else
        CropToVisibleArea(me, point((f * 7), 0))
        updateStage()
        f = 1 + f
      end if
    end repeat
    if the ticks > scrollTime then
      CropToVisibleArea(me, point((whichIsFirstNow * ButtonWidth), 0))
    end if
    whichIsFirstNow = whichIsFirstNow + 1
    if the mouseDown = 0 or whichIsFirstNow + MaxVisibleIndexButton - 1 = member("CatalogPage_index").count(#line) then
      scroll = 0
    end if
  end repeat
end

on CropToVisibleArea me, StartPoint 
  StartPoint = StartPoint + point(1, 0)
  MyMaxWidth = sprite(me.spriteNum + 1).left - sprite(me.spriteNum - 1).right
  myImage = image(MyMaxWidth, ButtonHeigth, 32)
  member("CropcatalogIndexPic").image = myImage
  Pic = member("catalogIndexPic")
  targetRect = member("CropcatalogIndexPic").rect
  sourseRect = rect(StartPoint, StartPoint + point((ButtonWidth * (MyMaxWidth / ButtonWidth) + 1), ButtonHeigth))
  member("CropcatalogIndexPic").image.copyPixels(Pic.image, targetRect, sourseRect)
end

on mouseUp me 
  oldItemLimiter = the itemDelimiter
  the itemDelimiter = ","
  click = (the mouseH - sprite(me.spriteNum).left / ButtonWidth) + whichIsFirstNow
  Pic = member(member("CatalogPage_index").getPropRef(#line, activeButton).getProp(#item, 1) & "_inactive")
  aPoint = point((ButtonWidth * activeButton - 1), 0)
  sourseRect = member(member("CatalogPage_index").getPropRef(#line, activeButton).getProp(#item, 1) & "_inactive").rect
  targetRect = rect(aPoint, aPoint + point(ButtonWidth, ButtonHeigth))
  member("catalogIndexPic").image.copyPixels(Pic.image, targetRect, sourseRect)
  Pic = member(member("CatalogPage_index").getPropRef(#line, click).getProp(#item, 1) & "_active")
  aPoint = point((ButtonWidth * click - 1), 0)
  sourseRect = member(member("CatalogPage_index").getPropRef(#line, click).getProp(#item, 1) & "_active").rect
  targetRect = rect(aPoint, aPoint + point(ButtonWidth, ButtonHeigth))
  member("catalogIndexPic").image.copyPixels(Pic.image, targetRect, sourseRect)
  activeButton = click
  CropToVisibleArea(me, point((whichIsFirstNow - 1 * ButtonWidth), 0))
  sFrame = links.getAt(click)
  if not voidp(sFrame) then
    goContext(sFrame, context)
  end if
  the itemDelimiter = oldItemLimiter
end
