on handleClick me, tEvent, tSprID, tProp
  if tEvent = #mouseUp then
    case tSprID of
      "ctlg_text_5":
        executeMessage(#externalLinkClick, the mouseLoc)
        openNetPage(getText("url_purselink"))
      "ctlg_text_7":
        tNodeName = me.pPageData[#localization][#texts][8]
        tNode = getThread(#catalogue).getComponent().getNodeByName(tNodeName)
        if voidp(tNode) then
          return error(me, "Node by name '" & tNodeName & "' not found!", #handleClick)
        end if
        getThread(#catalogue).getComponent().preparePage(tNode[#pageid])
        getThread(#catalogue).getInterface().activateTreeviewNodeByName(tNodeName)
    end case
  end if
end
