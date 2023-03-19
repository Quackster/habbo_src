on addWindows me
  me.pWindowID = "rq"
  tWrapObjRef = me.getWindowWrapper()
  if tWrapObjRef = 0 then
    return 0
  end if
  tWrapObjRef.addOneWindow(me.getWindowId(), "ig_ag_play_again.window", me.pWindowSetId, [#scrollFromLocX: -400, #spaceBottom: 2])
  return 1
end

on render me
  tID = me.getBasicFlagId()
  tService = me.getIGComponent("AfterGame")
  if tService = 0 then
    return 0
  end if
  me.setInfoFlag(tID, me.getWindowId(), "ig_title_play_again", "AfterGameTime", ["light": rgb("#8C8C8C")], tService.getMsecAtNextState())
  return 1
end
