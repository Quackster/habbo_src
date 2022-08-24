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
  if variableExists(("layout.fields.image." & me.pPageData[#layout])) then
    pImageElements = getVariableValue(("layout.fields.image." & me.pPageData[#layout]))
  end if
  if variableExists(("layout.fields.text." & me.pPageData[#layout])) then
    pTextElements = getVariableValue(("layout.fields.text." & me.pPageData[#layout]))
  end if
end

on downloadCompleted me, tProps
  if (tProps[#props][#pageid] <> me.pPageData[#pageid]) then
    return 
  end if
  tDlProps = tProps[#props]
  if tDlProps.getaProp(#imagedownload) then
    if voidp(pWndObj) then
      return RETURN, error(me, "Missing handle to window object!", #downloadCompleted, #major)
    end if
    if not pWndObj.elementExists(tDlProps[#element]) then
      return error(me, ("Missing target element " & tDlProps[#element]), #downloadCompleted, #minor)
    end if
    me.centerBlitImageToElement(getMember(tProps.getaProp(#assetId)).image, pWndObj.getElement(tDlProps[#element]))
  end if
end

on handleClick me, tEvent, tSprID, tProp
  if (tEvent = #mouseUp) then
  end if
end
