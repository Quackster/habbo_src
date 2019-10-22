property pPageItemDownloader, pTextElements, pWndObj, pImageElements

on construct me 
  pWndObj = void()
  pPageItemDownloader = getThread(#catalogue).getComponent().getPageItemDownloader()
  pImageElements = getVariableValue("layout.fields.image.default")
  pTextElements = getVariableValue("layout.fields.text.default")
  return(callAncestor(#construct, [me]))
end

on deconstruct me 
  pPageItemDownloader.removeCallback(me, #downloadCompleted)
  return(callAncestor(#deconstruct, [me]))
end

on define me, tdata 
  callAncestor(#define, [me], tdata)
  if variableExists("layout.fields.image." & me.getProp(#pPageData, #layout)) then
    pImageElements = getVariableValue("layout.fields.image." & me.getProp(#pPageData, #layout))
  end if
  if variableExists("layout.fields.text." & me.getProp(#pPageData, #layout)) then
    pTextElements = getVariableValue("layout.fields.text." & me.getProp(#pPageData, #layout))
  end if
end

on mergeWindow me, tParentWndObj 
  tLayoutMember = "ctlg_" & me.getProp(#pPageData, #layout) & ".window"
  if not memberExists(tLayoutMember) then
    return(error(me, "Layout member " & tLayoutMember & " missing.", #mergeWindow))
  end if
  tParentWndObj.merge(tLayoutMember)
  pWndObj = tParentWndObj
  tTextFields = me.getPropRef(#pPageData, #localization).getAt(#texts)
  i = 1
  repeat while i <= tTextFields.count
    if tParentWndObj.elementExists(pTextElements.getAt(i)) then
      pWndObj.getElement(pTextElements.getAt(i)).setText(tTextFields.getAt(i))
    end if
    i = (1 + i)
  end repeat
  tBitmaps = me.getPropRef(#pPageData, #localization).getAt(#images)
  i = 1
  repeat while i <= tBitmaps.count
    tBitmap = tBitmaps.getAt(i)
    if tParentWndObj.elementExists(pImageElements.getAt(i)) and tBitmap.length > 1 then
      if memberExists(tBitmap) then
        me.centerBlitImageToElement(getMember(tBitmap).image, tParentWndObj.getElement(pImageElements.getAt(i)))
      else
        pPageItemDownloader.defineCallback(me, #downloadCompleted)
        pPageItemDownloader.registerDownload(#bitmap, tBitmap, [#imagedownload:1, #element:pImageElements.getAt(i), #assetId:tBitmap, #pageid:me.getProp(#pPageData, #pageid)])
      end if
    end if
    i = (1 + i)
  end repeat
end

on unmergeWindow me, tParentWndObj 
  tLayoutMember = "ctlg_" & me.getProp(#pPageData, #layout) & ".window"
  if not memberExists(tLayoutMember) then
    return(error(me, "Layout member " & tLayoutMember & " missing.", #mergeWindow))
  end if
  tParentWndObj.unmerge()
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

on downloadCompleted me, tProps 
  if tProps.getAt(#props).getAt(#pageid) <> me.getProp(#pPageData, #pageid) then
    return()
  end if
  tDlProps = tProps.getAt(#props)
  if tDlProps.getaProp(#imagedownload) then
    if voidp(pWndObj) then
      return("\r", error(me, "Missing handle to window object!", #downloadCompleted, #major))
    end if
    if not pWndObj.elementExists(tDlProps.getAt(#element)) then
      return(error(me, "Missing target element " & tDlProps.getAt(#element), #downloadCompleted, #minor))
    end if
    me.centerBlitImageToElement(getMember(tProps.getaProp(#assetId)).image, pWndObj.getElement(tDlProps.getAt(#element)))
  end if
end

on handleClick me, tEvent, tSprID, tProp 
  if (tEvent = #mouseUp) then
  end if
end
