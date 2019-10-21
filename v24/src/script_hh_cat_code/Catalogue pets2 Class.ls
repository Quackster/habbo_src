on construct(me)
  return(1)
  exit
end

on deconstruct(me)
  return(1)
  exit
end

on eventProc(me, tEvent, tSprID, tProp)
  if tEvent = #mouseUp then
    if tSprID = "ctlg_text_3" then
      tURL = getText("url_pets")
      executeMessage(#externalLinkClick, the mouseLoc)
      openNetPage(tURL, "_new")
    end if
  end if
  return(0)
  exit
end