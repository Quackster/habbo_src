on resolveLargePreview me, tOffer 
  if not objectp(tOffer) then
    return(error(me, "Invalid input format", #resolveLargePreview, #major))
  end if
  if tOffer.getCount() < 1 then
    return(error(me, "Offer  has no content", #resolveLargePreview, #major))
  end if
  tPrevMember = "ctlg_pic_"
  tOfferName = tOffer.getName()
  if memberExists(tPrevMember & tOfferName) then
    return(getMember(tPrevMember & tOfferName).image)
  end if
  tClassID = tOffer.getContent(1).getClassId()
  if memberExists("ctlg_fx_prev_" & tClassID) then
    return(getMember("ctlg_fx_prev_" & tClassID).image)
  end if
  return(getMember("no_icon_small").image)
end

on showPreview me, tOfferGroup 
  if voidp(me.pWndObj) then
    return("\r", error(me, "Missing handle to window object!", #showPreview, #major))
  end if
  if not objectp(tOfferGroup) then
    return(error(me, "Invalid input format", #showPreview, #major))
  end if
  if tOfferGroup.getCount() < 1 then
    return(error(me, "Offer group is empty", #showPreview, #major))
  end if
  if tOfferGroup.getOffer(1).getCount() < 1 then
    return(error(me, "Offer group item at index 1 has no content", #showPreview, #major))
  end if
  tPrevImage = me.resolveLargePreview(tOfferGroup.getOffer(1))
  if ilk(tPrevImage) <> #image then
    return FALSE
  end if
  me.centerBlitImageToElement(tPrevImage, me.pWndObj.getElement(me.getProp(#pImageElements, 2)))
  tCatalogProps = me.pPersistentCatalogData.getProps(tOfferGroup.getOffer(1).getName())
  if listp(tCatalogProps) then
    tDesc = tCatalogProps.getAt(#description)
    tExp = tOfferGroup.getOffer(1).getContent(1).getExpiration()
    if tExp <> -1 then
      tHours = (tExp / 60)
      tMins = (tExp mod 60)
      tExpText = replaceChunks(getText("expiring_item_postfix", "Lasts %x% hours %y% minutes."), "%x%", tHours)
      tExpText = replaceChunks(tExpText, "%y%", tMins)
      tDesc = tDesc && tExpText
    end if
    me.setElementText(me.pWndObj, "ctlg_description", tDesc)
    me.setElementText(me.pWndObj, "ctlg_product_name", tCatalogProps.getAt(#name))
  else
    error(me, "Missing catalogprops for offer " & tOfferGroup.getOffer(1).getName(), #showPreview, #minor)
  end if
  i = 1
  repeat while i <= me.count(#pOfferTypesAvailable)
    tElements = me.pOfferTypesAvailable.getAt(i).getaProp(#elements)
    tText = me.getOfferPriceTextByType(tOfferGroup, me.pOfferTypesAvailable.getAt(i).getaProp(#type))
    repeat while tElements <= undefined
      tElement = getAt(undefined, tOfferGroup)
      me.setElementText(me.pWndObj, tElement, tText)
    end repeat
    i = (1 + i)
  end repeat
end

on handleClick me, tEvent, tSprID, tProp 
  if (tEvent = #mouseUp) then
    if (tSprID = "ctlg_productstrip") then
      if ilk(tProp) <> #point then
        return()
      end if
      tSelectedItem = void()
      if objectp(me.pProductStrip) then
        me.pProductStrip.selectItemAt(tProp)
        tSelectedItem = me.pProductStrip.getSelectedItem()
      end if
      if not voidp(tSelectedItem) then
        repeat while tSprID <= tSprID
          tElement = getAt(tSprID, tEvent)
          if me.pWndObj.elementExists(tElement) then
            me.pWndObj.getElement(tElement).hide()
          end if
        end repeat
        me.showPreview(tSelectedItem)
        me.showPriceBox()
        me.setBuyButtonStates(me.getOfferTypeList(tSelectedItem))
      end if
    else
      if tSprID <> "ctlg_buy_button" then
        if tSprID <> "ctlg_buy_pixels_credits" then
          if (tSprID = "ctlg_buy_pixels") then
            if not objectp(me.pProductStrip) then
              return()
            end if
            tSelectedItem = me.pProductStrip.getSelectedItem()
            if not voidp(tSelectedItem) then
              tOfferType = me.getPropRef(#pOfferTypesAvailable, tSprID).getaProp(#type)
              tOffer = me.getOfferByType(tSelectedItem, tOfferType)
              if voidp(tOffer) then
                return(error(me, "Unable to find offer of type " & tOfferType & " check page offer configuration.", #handleClick, #major))
              end if
              tExtraProps = void()
              if (tSprID = "ctlg_buy_pixels_credits") or (tSprID = "ctlg_buy_pixels") then
                tExtraProps = [#disableGift]
              end if
              getThread(#catalogue).getComponent().requestPurchase(tOfferType, me.getProp(#pPageData, #pageid), tOffer, #sendPurchaseFromCatalog, tExtraProps)
            end if
          else
            if (tSprID = "ctlg_buy_andwear") then
              if not objectp(me.pProductStrip) then
                return()
              end if
              tSelectedItem = me.pProductStrip.getSelectedItem()
              if not voidp(tSelectedItem) then
                tOfferType = me.getPropRef(#pOfferTypesAvailable, tSprID).getaProp(#type)
                tOffer = me.getOfferByType(tSelectedItem, tOfferType)
                if voidp(tOffer) then
                  return(error(me, "Unable to find offer of type " & tOfferType & " check page offer configuration.", #handleClick, #major))
                end if
                getThread(#catalogue).getComponent().requestPurchase(tOfferType, me.getProp(#pPageData, #pageid), tOffer, #sendPurchaseAndWear, [#disableGift, #closeCatalogue])
              end if
            else
              if tSprID contains "ctlg_buy_" then
                tItemIndex = value(chars(tSprID, 10, 10))
                if not integerp(tItemIndex) then
                  return()
                end if
                if tItemIndex > me.getPropRef(#pPageData, #offers).count then
                  return(error(me, "No product to purchase at index : " & tItemIndex, #minor))
                end if
                tOffer = me.getOfferByType(me.getPropRef(#pPageData, #offers).getAt(tItemIndex), #credits)
                getThread(#catalogue).getComponent().requestPurchase(tOfferType, me.getProp(#pPageData, #pageid), tOffer, #sendPurchaseFromCatalog)
              end if
            end if
          end if
        end if
      end if
    end if
  end if
end
