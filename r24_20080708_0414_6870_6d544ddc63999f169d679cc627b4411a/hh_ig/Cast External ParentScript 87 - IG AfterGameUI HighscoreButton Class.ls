on addWindows me
  me.pWindowID = "hb"
  tWrapObjRef = me.getWindowWrapper()
  if tWrapObjRef = 0 then
    return 0
  end if
  tWrapObjRef.addOneWindow(me.getWindowId(), "ig_ag_show_highscores.window", me.pWindowSetId, [#scrollFromLocX: -450])
  return 1
end
