on construct me
  callAncestor(#construct, [me])
end

on eventHandler me, tEvent, tSpriteID, tParam
  if tSpriteID = "bubble_close" then
    getThread("new_user_help").getInterface().removeHelpBubble(me.pBubbleId)
  end if
end
