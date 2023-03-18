property pWndObj, pImageElements, pTextElements, pPageItemDownloader

on construct me
  pWndObj = VOID
  pPageItemDownloader = getThread(#catalogue).getComponent().getPageItemDownloader()
  pImageElements = getVariableValue("layout.fields.image.default")
  pTextElements = getVariableValue("layout.fields.text.default")
  return callAncestor(#construct, [me])
end

on deconstruct me
  pPageItemDownloader.removeCallback(me, #downloadCompleted)
  return callAncestor(#deconstruct, [me])
end

on define me, tdata
  callAncestor(#define, [me], tdata)
  if variableExists("layout.fields.image." & me.pPageData[#layout]) then
    pImageElements = getVariableValue("layout.fields.image." & me.pPageData[#layout])
  end if
  if variableExists("layout.fields.text." & me.pPageData[#layout]) then
    pTextElements = getVariableValue("layout.fields.text." & me.pPageData[#layout])
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
    if tParentWndObj.elementExists(pTextElements[i]) then
      pWndObj.getElement(pTextElements[i]).setText(tTextFields[i])
    end if
  end repeat
  tBitmaps = me.pPageData[#localization][#images]
  repeat with i = 1 to tBitmaps.count
    tBitmap = tBitmaps[i]
    if tParentWndObj.elementExists(pImageElements[i]) and (tBitmap.length > 1) then
      if memberExists(tBitmap) then
        me.centerBlitImageToElement(getMember(tBitmap).image, tParentWndObj.getElement(pImageElements[i]))
        next repeat
      end if
      pPageItemDownloader.defineCallback(me, #downloadCompleted)
      pPageItemDownloader.registerDownload(#bitmap, tBitmap, [#imagedownload: 1, #element: pImageElements[i], #assetId: tBitmap, #pageid: me.pPageData[#pageid]])
    end if
  end repeat
end

on unmergeWindow me, tParentWndObj
  tLayoutMember = "ctlg_" & me.pPageData[#layout] & ".window"
  if not memberExists(tLayoutMember) then
    return error(me, "Layout member " & tLayoutMember & " missing.", #mergeWindow)
  end if
  tParentWndObj.unmerge()
end

on centerRectInRect me, tSmallrect, tLargeRect
  tpoint = point(0, 0)
  tpoint.locH = (tLargeRect.width - tSmallrect.width) / 2
  tpoint.locV = (tLargeRect.height - tSmallrect.height) / 2
  if tpoint.locH < 0 then
    tpoint.locH = 0
  end if
  if tpoint.locV < 0 then
    tpoint.locV = 0
  end if
  return tpoint
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
    me.centerBlitImageToElement(getMember(tProps.getaProp(#assetId)).image, pWndObj.getElement(tDlProps[#element]))
  end if
end

on handleClick me, tEvent, tSprID, tProp
  if tEvent = #mouseUp then
    case tSprID of
    end case
  end if
end
