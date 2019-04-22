on handleClick me, tEvent, tSprID, tProp 
  if tEvent = #mouseUp then
    if tSprID = "ctlg_text_5" then
      executeMessage(#openAchievementsWindow)
    else
      if tSprID = "ctlg_text_7" then
        tNodeName = me.getPropRef(#pPageData, #localization).getAt(#texts).getAt(8)
        tNode = getThread(#catalogue).getComponent().getNodeByName(tNodeName)
        if voidp(tNode) then
          return(error(me, "Node by name '" & tNodeName & "' not found!", #handleClick))
        end if
        getThread(#catalogue).getComponent().preparePage(tNode.getAt(#pageid))
        getThread(#catalogue).getInterface().activateTreeviewNodeByName(tNodeName)
      end if
    end if
  end if
end
