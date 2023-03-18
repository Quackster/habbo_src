property pGradientObj

on construct me
  tVisualizer = getThread(#room).getInterface().getRoomVisualizer()
  tsprite = tVisualizer.getSprById("starlounge_gr")
  if tsprite = 0 then
    return 0
  end if
  tObj = createObject(#temp, "Star Lounge Gradient Class")
  tObj.define(tsprite)
  me.pGradientObj = tObj
  receiveUpdate(me.getID())
end

on deconstruct me
  if not voidp(me.pGradientObj) then
    me.pGradientObj.cleanUp()
    call(#deconstruct, pGradientObj)
  end if
  pGradientObj = VOID
  return removeUpdate(me.getID())
end

on update me
  call(#update, pGradientObj)
end
