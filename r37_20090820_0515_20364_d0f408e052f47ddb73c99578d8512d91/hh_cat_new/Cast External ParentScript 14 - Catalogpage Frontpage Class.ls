property pWndObj, pImageElements, pTextElements, pPageItemDownloader

on construct me
  pWndObj = VOID
  pPageItemDownloader = getThread(#catalogue).getComponent().getPageItemDownloader()
  pImageElements = getStructVariable("layout.fields.image.default")
  pTextElements = getStructVariable("layout.fields.text.default")
  return callAncestor(#construct, [me])
end

on deconstruct me
  pPageItemDownloader.removeCallback(me, #downloadCompleted)
  return callAncestor(#deconstruct, [me])
end

on define me, tdata
  me.pPageData = tdata
  if variableExists("layout.fields.image." & me.pPageData[#layout]) then
    pImageElements = getStructVariable("layout.fields.image." & me.pPageData[#layout])
  end if
  if variableExists("layout.fields.text." & me.pPageData[#layout]) then
    pTextElements = getStructVariable("layout.fields.text." & me.pPageData[#layout])
  end if
end

on mergeWindow me, tParentWndObj
  tLayoutMember = "ctlg_" & me.pPageData[#layout] & ".window"
  if not memberExists(tLayoutMember) then
    return error(me, "Layout member " & tLayoutMember & " missing.", #mergeWindow)
  end if
  tParentWndObj.merge(tLayoutMember)
  pWndObj = tParentWndObj
  tTextFields = me.pPageData[#localization][#texts]
  repeat with i = 1 to tTextFields.count
    if pTextElements.count >= i then
      me.setElementText(pWndObj, pTextElements[i], tTextFields[i])
    end if
  end repeat
  tBitmaps = me.pPageData[#localization][#images]
  pPageItemDownloader.defineCallback(me, #downloadCompleted)
  if pImageElements.count >= 1 then
    tBitmap = tBitmaps[1]
    if tParentWndObj.elementExists(pImageElements[1]) and (tBitmap.length > 1) then
      if memberExists(tBitmap) then
        me.centerBlitImageToElement(getMember(tBitmap).image, tParentWndObj.getElement(pImageElements[1]))
      else
        pPageItemDownloader.registerDownload(#bitmap, tBitmap, [#imagedownload: 1, #element: pImageElements[1], #assetId: tBitmap, #pageid: me.pPageData[#pageid]])
      end if
    end if
  end if
  if pImageElements.count >= 2 then
    tBitmap = tBitmaps[2]
    if tParentWndObj.elementExists(pImageElements[2]) and (tBitmap.length > 1) then
      if memberExists(tBitmap) then
        me.centerBlitImageToElement(getMember(tBitmap).image, tParentWndObj.getElement(pImageElements[2]))
      else
        pPageItemDownloader.registerDownload(#topStoryImage, tBitmap, [#imagedownload: 1, #element: pImageElements[2], #assetId: tBitmap, #pageid: me.pPageData[#pageid]])
      end if
    end if
  end if
  pWndObj.getElement("redeem").deactivate()
  if me.pPageData[#localization][#texts].count >= 8 then
    if me.pPageData[#localization][#texts][8] <> #empty then
      tFont = pWndObj.getElement("ctlg_txt3").getFont()
      tFont[#color] = rgb(me.pPageData[#localization][#texts][8])
      pWndObj.getElement("ctlg_txt3").setFont(tFont)
    end if
  end if
  if me.pPageData[#localization][#texts].count >= 9 then
    if me.pPageData[#localization][#texts][9] <> #empty then
      tFont = pWndObj.getElement("ctlg_txt1").getFont()
      tFont[#color] = rgb(me.pPageData[#localization][#texts][9])
      pWndObj.getElement("ctlg_txt1").setFont(tFont)
      tFont = pWndObj.getElement("ctlg_txt2").getFont()
      tFont[#color] = rgb(me.pPageData[#localization][#texts][9])
      pWndObj.getElement("ctlg_txt2").setFont(tFont)
    end if
  end if
end

on clearVoucherCodeField me
  if voidp(pWndObj) then
    return RETURN, error(me, "Missing handle to window object!", #clearVoucherCodeField, #major)
  end if
  if pWndObj.elementExists("voucher_code") then
    pWndObj.getElement("voucher_code").setText(EMPTY)
  end if
  if pWndObj.elementExists("redeem") then
    pWndObj.getElement("redeem").deactivate()
  end if
end

on downloadCompleted me, tProps
  if tProps[#props][#pageid] <> me.pPageData[#pageid] then
    return 
  end if
  tDlProps = tProps[#props]
  if tDlProps.getaProp(#imagedownload) then
    if voidp(pWndObj) then
      return RETURN, error(me, "Missing handle to window object!", #downloadCompleted, #major)
    end if
    if not pWndObj.elementExists(tDlProps[#element]) then
      return error(me, "Missing target element " & tDlProps[#element], #downloadCompleted, #minor)
    end if
    tmember = getMember(tProps.getaProp(#assetId))
    if tmember.type <> #bitmap then
      return error(me, "Downloaded member was of incorrect type!", #downloadCompleted, #major)
    end if
    me.centerBlitImageToElement(tmember.image, pWndObj.getElement(tDlProps[#element]))
  end if
end

on handleClick me, tEvent, tSprID, tProp
  if tEvent = #mouseUp then
    case tSprID of
      "ctlg_txt3":
        getThread(#catalogue).getInterface().followLink(me.pPageData[#localization][#texts][7])
      "redeem":
        if voidp(pWndObj) then
          return RETURN, error(me, "Missing handle to window object!", #handleClick, #major)
        end if
        if pWndObj.elementExists("voucher_code") then
          tVoucherCode = pWndObj.getElement("voucher_code").getText()
          getThread(#catalogue).getHandler().sendRedeemVoucher(tVoucherCode)
        end if
    end case
  else
    if tEvent = #keyUp then
      case tSprID of
        "voucher_code":
          if voidp(pWndObj) then
            return RETURN, error(me, "Missing handle to window object!", #handleClick, #major)
          end if
          if pWndObj.elementExists("redeem") then
            if pWndObj.getElement("voucher_code").getText().length > 0 then
              pWndObj.getElement("redeem").Activate()
            else
              pWndObj.getElement("redeem").deactivate()
            end if
          end if
      end case
    end if
  end if
end
