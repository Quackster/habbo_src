on handleClick me, tEvent, tSprID, tProp
  if tEvent = #mouseUp then
    case tSprID of
      "ctlg_collectibles_link":
        executeMessage(#externalLinkClick, the mouseLoc)
        openNetPage(getPredefinedURL(getText("url_collectables_link")))
    end case
  end if
end
