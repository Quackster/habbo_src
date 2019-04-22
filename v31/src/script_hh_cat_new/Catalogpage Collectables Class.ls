on handleClick(me, tEvent, tSprID, tProp)
  if tEvent = #mouseUp then
    if me = "ctlg_collectibles_link" then
      executeMessage(#externalLinkClick, the mouseLoc)
      openNetPage(getPredefinedURL(getText("url_collectables_link")))
    end if
  end if
  exit
end