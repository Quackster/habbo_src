property pPageData

on construct me 
  pPageData = void()
  return TRUE
end

on deconstruct me 
  pPageData = void()
  return TRUE
end

on define me, tdata 
  pPageData = tdata
end

on getPageId me 
  return(pPageData.getAt(#pageid))
end

on getClassAsset me, tClassName 
  tClass = tClassName
  if tClass contains "*" then
    tClass = tClass.getProp(#char, 1, (offset("*", tClass) - 1))
  end if
  return(tClass)
end

on renderLargePreviewImage me, tProps 
  if not voidp(tProps.getAt("dealList")) then
    if not objectExists("ctlg_dealpreviewObj") then
      tObj = createObject("ctlg_dealpreviewObj", ["Deal Preview Class"])
      if (tObj = 0) then
        return(error(me, "Failed object creation!", #showHideDialog, #major))
      end if
    else
      tObj = getObject("ctlg_dealpreviewObj")
    end if
    tObj.define(tProps.getAt("dealList"))
    tImage = tObj.getPicture()
  else
    if voidp(tProps.getAt("class")) then
      return(error(me, "Class property missing", #showPreviewImage, #minor))
    else
      tClass = tProps.getAt("class")
    end if
    if voidp(tProps.getAt("direction")) then
      return(error(me, "Direction property missing", #showPreviewImage, #minor))
    else
      tProps.setAt("direction", "2,2,2")
      tDirection = value("[" & tProps.getAt("direction") & "]")
      if tDirection.count < 3 then
        tDirection = [0, 0, 0]
      end if
    end if
    if voidp(tProps.getAt("dimensions")) then
      return(error(me, "Dimensions property missing", #showPreviewImage, #minor))
    else
      tDimensions = value("[" & tProps.getAt("dimensions") & "]")
      if tDimensions.count < 2 then
        tDimensions = [1, 1]
      end if
    end if
    if voidp(tProps.getAt("partColors")) then
      return(error(me, "PartColors property missing", #showPreviewImage, #minor))
    else
      tpartColors = tProps.getAt("partColors")
      if (tpartColors = "") or (tpartColors = "0,0,0") then
        tpartColors = "*ffffff"
      end if
    end if
    if voidp(tProps.getAt("objectType")) then
      return(error(me, "objectType property missing", #showPreviewImage, #minor))
    else
      tObjectType = tProps.getAt("objectType")
    end if
    tdata = [:]
    tdata.setAt(#id, "ctlg_previewObj")
    tdata.setAt(#class, tClass)
    tdata.setAt(#name, tClass)
    tdata.setAt(#custom, tClass)
    tdata.setAt(#direction, tDirection)
    tdata.setAt(#dimensions, tDimensions)
    tdata.setAt(#colors, tpartColors)
    tdata.setAt(#objectType, tObjectType)
    if not objectExists("ctlg_previewObj") then
      tObj = createObject("ctlg_previewObj", ["Product Preview Class"])
      if (tObj = 0) then
        return(error(me, "Failed object creation!", #showHideDialog, #major))
      end if
    else
      tObj = getObject("ctlg_previewObj")
    end if
    tObj.define(tdata.duplicate())
    tImage = tObj.getPicture()
  end if
  return(tImage)
end

on getPossibleBuyButtonTypes me, tWndObj 
  tBuyButtonNames = getVariableValue("layout.buybutton.types")
  tTypes = [:]
  tElementList = tWndObj.getProperty(#elementList)
  i = 1
  repeat while i <= tElementList.count
    tID = tElementList.getPropAt(i)
    ttype = tBuyButtonNames.getaProp(tID)
    if not voidp(ttype) then
      if voidp(tTypes.getaProp(tID)) then
        tTypes.setaProp(tID, ttype)
      end if
    end if
    i = (1 + i)
  end repeat
  return(tTypes)
end

on getOfferTypeList me, tItemGroup 
  tList = []
  if not voidp(me.getOfferByType(tItemGroup, #credits)) then
    tList.add(#credits)
  end if
  if not voidp(me.getOfferByType(tItemGroup, #creditsandpixels)) then
    tList.add(#creditsandpixels)
  end if
  if not voidp(me.getOfferByType(tItemGroup, #pixels)) then
    tList.add(#pixels)
  end if
  return(tList)
end

on getOfferByType me, tItemGroup, tOfferType 
  repeat while tItemGroup <= tOfferType
    tOffer = getAt(tOfferType, tItemGroup)
    if (tItemGroup = #credits) then
      if (tOffer.getAt(#price).getAt(#pixels) = 0) then
        return(tOffer)
      end if
    else
      if (tItemGroup = #creditsandpixels) then
        if tOffer.getAt(#price).getAt(#pixels) <> 0 and tOffer.getAt(#price).getAt(#credits) <> 0 then
          return(tOffer)
        end if
      else
        if (tItemGroup = #pixels) then
          if (tOffer.getAt(#price).getAt(#credits) = 0) then
            return(tOffer)
          end if
        end if
      end if
    end if
  end repeat
  return(void())
end

on getOfferPriceTextByType me, tItemGroup, tOfferType 
  tOffer = me.getOfferByType(tItemGroup, tOfferType)
  if not voidp(tOffer) then
    if (tOfferType = #credits) then
      return(tOffer.getAt(#price).getAt(#credits) && getText("credits", "credits"))
    else
      if (tOfferType = #creditsandpixels) then
        return(tOffer.getAt(#price).getAt(#pixels) && getText("pixels", "pixels") && "&" && tOffer.getAt(#price).getAt(#credits) && getText("credits", "credits"))
      else
        if (tOfferType = #pixels) then
          return(tOffer.getAt(#price).getAt(#pixels) && getText("pixels", "pixels"))
        end if
      end if
    end if
  end if
  return("")
end

on centerRectInRect me, tSmallrect, tLargeRect 
  tpoint = point(0, 0)
  tpoint.locH = ((tLargeRect.width - tSmallrect.width) / 2)
  tpoint.locV = ((tLargeRect.height - tSmallrect.height) / 2)
  if tpoint.locH < 0 then
    tpoint.locH = 0
  end if
  if tpoint.locV < 0 then
    tpoint.locV = 0
  end if
  return(tpoint)
end

on centerBlitImageToElement me, tImage, tElement 
  tElement.clearBuffer()
  tOffset = me.centerRectInRect(tImage.rect, tElement.getProperty(#image).rect)
  tOldImage = tElement.getProperty(#image)
  tOldImage.copyPixels(tImage, (tImage.rect + rect(tOffset.locH, tOffset.locV, tOffset.locH, tOffset.locV)), tImage.rect)
  tElement.feedImage(tOldImage)
end

on mergeWindow me 
  return(error(me, "Calling virtual function from Catalogpage Base Class, you shouldn't be doing this!"))
end

on unmergeWindow me 
  return(error(me, "Calling virtual function from Catalogpage Base Class, you shouldn't be doing this!"))
end

on renderPage me 
  return(error(me, "Calling virtual function from Catalogpage Base Class, you shouldn't be doing this!"))
end

on handleClick me, tEvent, tSprID, tProp 
  return(error(me, "Calling virtual function from Catalogpage Base Class, you shouldn't be doing this!"))
end
