on construct(me)
  tWindowObj = getThread(#catalogue).getInterface().getCatalogWindow()
  if not tWindowObj then
    tWindowObj = void()
    return(error(me, "Couldn't access catalogue window!", #construct, #major))
  end if
  tImageList = getThread(#catalogue).getComponent().getPageDataByLayout("recycler").getAt(#localization).getAt(#images)
  getThread(#recycler).getInterface().setHeaderImage(getmemnum(tImageList.getAt(1)))
  getThread(#recycler).getInterface().setHostWindowObject(tWindowObj)
  getThread(#recycler).getComponent().openRecycler()
  return(1)
  exit
end

on deconstruct(me)
  getThread(#recycler).getComponent().closeRecycler()
  return(1)
  exit
end

on closePage(me)
  getThread(#recycler).getComponent().closeRecycler()
  exit
end

on define(me)
  exit
end

on eventProc(me, tEvent, tSprID, tProp)
  tRecyclerInterface = getThread(#recycler).getInterface()
  return(tRecyclerInterface.eventProc(tEvent, tSprID, tProp))
  exit
end