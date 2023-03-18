on construct me
  tWindowObj = getThread(#catalogue).getInterface().getCatalogWindow()
  if not tWindowObj then
    tWindowObj = VOID
    return error(me, "Couldn't access catalogue window!", #construct)
  end if
  tHeaderImageNo = getThread(#catalogue).getComponent().pCatalogProps["Recycler"]["headerImage"]
  getThread(#recycler).getInterface().setHeaderImage(tHeaderImageNo)
  getThread(#recycler).getInterface().setHostWindowObject(tWindowObj)
  getThread(#recycler).getComponent().openRecycler()
  return 1
end

on deconstruct me
  getThread(#recycler).getComponent().closeRecycler()
  return 1
end

on closePage me
  getThread(#recycler).getComponent().closeRecycler()
end

on eventProc me, tEvent, tSprID, tProp
  tRecyclerInterface = getThread(#recycler).getInterface()
  return tRecyclerInterface.eventProc(tEvent, tSprID, tProp)
end
