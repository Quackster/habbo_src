on addWindows me
  me.pWindowID = "rb"
  tWrapObjRef = me.getWindowWrapper()
  if tWrapObjRef = 0 then
    return 0
  end if
  tWrapObjRef.addOneWindow(me.getWindowId(), "ig_pg_hide_rules.window", me.pWindowSetId, [#scrollFromLocX: -190, #spaceBottom: 0])
  return 1
end
