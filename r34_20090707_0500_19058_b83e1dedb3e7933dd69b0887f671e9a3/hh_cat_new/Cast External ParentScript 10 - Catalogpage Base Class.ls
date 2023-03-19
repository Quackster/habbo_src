property pPageData

on construct me
  pPageData = VOID
  return 1
end

on deconstruct me
  pPageData = VOID
  return 1
end

on define me, tdata
  pPageData = tdata
end

on getPageId me
  return pPageData[#pageid]
end

on getClassAsset me, tClassName
  if ilk(tClassName) <> #string then
    return EMPTY
  end if
  tClass = tClassName
  if tClass contains "*" then
    tClass = tClass.char[1..offset("*", tClass) - 1]
  end if
  return tClass
end

on renderLargePreviewImage me, tProps
  if not voidp(tProps["dealList"]) then
    if not objectExists("ctlg_dealpreviewObj") then
      tObj = createObject("ctlg_dealpreviewObj", ["Deal Preview Class"])
      if tObj = 0 then
        return error(me, "Failed object creation!", #showHideDialog, #major)
      end if
    else
      tObj = getObject("ctlg_dealpreviewObj")
    end if
    tObj.define(tProps["dealList"])
    tImage = tObj.getPicture()
  else
    if voidp(tProps["class"]) then
      return error(me, "Class property missing", #showPreviewImage, #minor)
    else
      tClass = tProps["class"]
    end if
    if voidp(tProps["direction"]) then
      return error(me, "Direction property missing", #showPreviewImage, #minor)
    else
      tProps["direction"] = "2,2,2"
      tDirection = value("[" & tProps["direction"] & "]")
      if tDirection.count < 3 then
        tDirection = [0, 0, 0]
      end if
    end if
    if voidp(tProps["dimensions"]) then
      return error(me, "Dimensions property missing", #showPreviewImage, #minor)
    else
      tDimensions = value("[" & tProps["dimensions"] & "]")
      if tDimensions.count < 2 then
        tDimensions = [1, 1]
      end if
    end if
    if voidp(tProps["partColors"]) then
      return error(me, "PartColors property missing", #showPreviewImage, #minor)
    else
      tpartColors = tProps["partColors"]
      if (tpartColors = EMPTY) or (tpartColors = "0,0,0") then
        tpartColors = "*ffffff"
      end if
    end if
    if voidp(tProps["objectType"]) then
      return error(me, "objectType property missing", #showPreviewImage, #minor)
    else
      tObjectType = tProps["objectType"]
    end if
    tdata = [:]
    tdata[#id] = "ctlg_previewObj"
    tdata[#class] = tClass
    tdata[#name] = tClass
    tdata[#custom] = tClass
    tdata[#direction] = tDirection
    tdata[#dimensions] = tDimensions
    tdata[#colors] = tpartColors
    tdata[#objectType] = tObjectType
    if not objectExists("ctlg_previewObj") then
      tObj = createObject("ctlg_previewObj", ["Product Preview Class"])
      if tObj = 0 then
        return error(me, "Failed object creation!", #showHideDialog, #major)
      end if
    else
      tObj = getObject("ctlg_previewObj")
    end if
    tObj.define(tdata.duplicate())
    tImage = tObj.getPicture()
  end if
  return tImage
end

on getPossibleBuyButtonTypes me, tWndObj
  tBuyButtonNames = getStructVariable("layout.buybutton.types")
  tTypes = [:]
  tElementList = tWndObj.getProperty(#elementList)
  repeat with i = 1 to tElementList.count
    tID = tElementList.getPropAt(i)
    ttype = tBuyButtonNames.getaProp(tID)
    if not voidp(ttype) then
      if voidp(tTypes.getaProp(tID)) then
        tTypes.setaProp(tID, ttype)
      end if
    end if
  end repeat
  return tTypes
end

on getOfferTypeList me, tItemGroup
  tList = []
  if me.getOfferByType(tItemGroup, #credits) <> 0 then
    tList.add(#credits)
  end if
  if me.getOfferByType(tItemGroup, #creditsandpixels) <> 0 then
    tList.add(#creditsandpixels)
  end if
  if me.getOfferByType(tItemGroup, #pixels) <> 0 then
    tList.add(#pixels)
  end if
  return tList
end

on getOfferByType me, tItemGroup, tOfferType
  if not objectp(tItemGroup) or (tItemGroup = 0) then
    return error(me, "Invalid input format", #getOfferByType, #major)
  end if
  if tItemGroup.getCount() < 1 then
    return error(me, #getOfferPriceTextByType, "Offer group contains no offers", #minor)
  end if
  repeat with i = 1 to tItemGroup.getCount()
    tOffer = tItemGroup.getOffer(i)
    case tOfferType of
      #credits:
        if tOffer.getPrice(#pixels) = 0 then
          return tOffer
        end if
      #creditsandpixels:
        if (tOffer.getPrice(#pixels) <> 0) and (tOffer.getPrice(#credits) <> 0) then
          return tOffer
        end if
      #pixels:
        if tOffer.getPrice(#credits) = 0 then
          return tOffer
        end if
    end case
  end repeat
  return 0
end

on getOfferPriceTextByType me, tItemGroup, tOfferType
  if not objectp(tItemGroup) or (tItemGroup = 0) then
    return error(me, "Invalid input format", #getOfferPriceTextByType, #major)
  end if
  if tItemGroup.getCount() < 1 then
    return error(me, #getOfferPriceTextByType, "Offer group contains no offers", #minor)
  end if
  tOffer = me.getOfferByType(tItemGroup, tOfferType)
  if objectp(tOffer) then
    case tOfferType of
      #credits:
        return tOffer.getPrice(#credits) && getText("credits", "credits")
      #creditsandpixels:
        return tOffer.getPrice(#pixels) && getText("pixels", "pixels") && "&" && tOffer.getPrice(#credits) && getText("credits", "credits")
      #pixels:
        return tOffer.getPrice(#pixels) && getText("pixels", "pixels")
    end case
  end if
  return EMPTY
end

on centerRectInRect me, tSmallrect, tLargeRect
  tpoint = point(0, 0)
  tpoint.locH = (tLargeRect.width - tSmallrect.width) / 2
  tpoint.locV = (tLargeRect.height - tSmallrect.height) / 2
  return tpoint
end

on centerBlitImageToElement me, tImage, tElement
  if not objectp(tElement) or (tElement = 0) then
    return error(me, "Image element was invalid", #centerBlitImageToElement, #minor)
  end if
  tElement.clearBuffer()
  tOffset = me.centerRectInRect(tImage.rect, tElement.getProperty(#image).rect)
  tOldImage = tElement.getProperty(#image)
  if (tOffset.locH >= 0) and (tOffset.locV >= 0) then
    tOldImage.copyPixels(tImage, tImage.rect + rect(tOffset.locH, tOffset.locV, tOffset.locH, tOffset.locV), tImage.rect)
  else
    if (tOffset.locH < 0) and (tOffset.locV >= 0) then
      tOffsetDest = point(0, 0)
      tOffsetSrc = point(0, 0)
      tOffsetSrc.locH = (tImage.width - tOldImage.width) / 2
      tOffsetDest.locV = (tOldImage.height - tImage.height) / 2
      tSrcRect = tImage.rect + rect(tOffsetSrc.locH, tOffsetSrc.locV, tOffsetSrc.locH, tOffsetSrc.locV)
      tdestrect = tImage.rect + rect(tOffsetDest.locH, tOffsetDest.locV, tOffsetDest.locH, tOffsetDest.locV)
      tOldImage.copyPixels(tImage, tdestrect, tSrcRect)
    else
      if (tOffset.locH >= 0) and (tOffset.locV < 0) then
        tOffsetDest = point(0, 0)
        tOffsetSrc = point(0, 0)
        tOffsetSrc.locV = (tImage.height - tOldImage.height) / 2
        tOffsetDest.locH = (tOldImage.width - tImage.width) / 2
        tSrcRect = tImage.rect + rect(tOffsetSrc.locH, tOffsetSrc.locV, tOffsetSrc.locH, tOffsetSrc.locV)
        tdestrect = tImage.rect + rect(tOffsetDest.locH, tOffsetDest.locV, tOffsetDest.locH, tOffsetDest.locV)
        tOldImage.copyPixels(tImage, tdestrect, tSrcRect)
      else
        tOffset = me.centerRectInRect(tElement.getProperty(#image).rect, tImage.rect)
        tOldImage.copyPixels(tImage, tImage.rect, tImage.rect + rect(tOffset.locH, tOffset.locV, tOffset.locH, tOffset.locV))
      end if
    end if
  end if
  tElement.feedImage(tOldImage)
end

on setElementText me, tWndObj, tElemName, tText
  if voidp(tWndObj) then
    return 0
  end if
  if tWndObj.elementExists(tElemName) then
    tWndObj.getElement(tElemName).setText(tText)
  else
  end if
end

on convertOfferListToDeallist me, tOffer
  if not objectp(tOffer) then
    return error(me, "Invalid input format", #convertOfferListToDeallist, #major)
  end if
  if tOffer.getCount() < 1 then
    error(me, "Offer has no content", #convertOfferListToDeallist, #minor)
  end if
  if not objectp(me.pPersistentFurniData) then
    error(me, "Persistent furnidata object is missing", #convertOfferListToDeallist, #major)
    return []
  end if
  tDealList = []
  repeat with i = 1 to tOffer.getCount()
    tFurniProps = me.pPersistentFurniData.getProps(tOffer.getContent(i).getType(), tOffer.getContent(i).getClassId())
    if voidp(tFurniProps) then
      tDealList.add([#class: EMPTY, #partColors: EMPTY, #count: 0])
      next repeat
    end if
    tClass = tFurniProps[#class]
    if tClass = "poster" then
      tClass = tClass && tOffer.getContent(i).getExtraParam()
    end if
    tDealList.add([#class: tClass, #partColors: tFurniProps[#partColors], #count: tOffer.getContent(i).getProductCount()])
  end repeat
  return tDealList
end

on mergeWindow me
  return error(me, "Calling virtual function from Catalogpage Base Class, you shouldn't be doing this!")
end

on downloadCompleted me
  return error(me, "Calling virtual function from Catalogpage Base Class, you shouldn't be doing this!")
end

on unmergeWindow me
  return error(me, "Calling virtual function from Catalogpage Base Class, you shouldn't be doing this!")
end

on renderPage me
  return error(me, "Calling virtual function from Catalogpage Base Class, you shouldn't be doing this!")
end

on getSelectedProduct me
  return error(me, "Calling virtual function from Catalogpage Base Class, you shouldn't be doing this!")
end

on handleClick me, tEvent, tSprID, tProp
  return error(me, "Calling virtual function from Catalogpage Base Class, you shouldn't be doing this!")
end
