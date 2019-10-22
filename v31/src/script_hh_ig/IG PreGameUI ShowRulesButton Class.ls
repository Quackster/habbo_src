on addWindows me 
  me.pWindowID = "rb"
  tWrapObjRef = me.getWindowWrapper()
  if (tWrapObjRef = 0) then
    return FALSE
  end if
  tWrapObjRef.addOneWindow(me.getWindowId(), "ig_pg_show_rules.window", me.pWindowSetId, [#scrollFromLocX:-190, #spaceBottom:0])
  return TRUE
end
