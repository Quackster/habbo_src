on construct me
  tWindowObj = getThread(#catalogue).getInterface().getCatalogWindow()
  if not tWindowObj then
    tWindowObj = VOID
    return error(me, "Couldn't access catalogue window!", #construct, #major)
  end if
  tImageList = getThread(#catalogue).getComponent().getPageDataByLayout("recycler")[#localization][#images]
  getThread(#recycler).getInterface().setHeaderMemberName(tImageList[1])
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

on define me
end

on eventProc me, tEvent, tSprID, tProp
  tRecyclerInterface = getThread(#recycler).getInterface()
  return tRecyclerInterface.eventProc(tEvent, tSprID, tProp)
end
