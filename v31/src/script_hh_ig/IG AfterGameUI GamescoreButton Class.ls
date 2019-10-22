on addWindows me 
  me.pWindowID = "gb"
  tWrapObjRef = me.getWindowWrapper()
  if (tWrapObjRef = 0) then
    return FALSE
  end if
  tWrapObjRef.addOneWindow(me.getWindowId(), "ig_ag_hide_highscores.window", me.pWindowSetId, [#scrollFromLocX:-450])
  return TRUE
end
