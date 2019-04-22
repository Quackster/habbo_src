on construct(me)
  pItemObjList = []
  receiveUpdate(me.getID())
  tVisObj = getThread(#room).getInterface().getRoomVisualizer()
  i = 1
  repeat while 1
    tSpr = tVisObj.getSprById("palm" & i)
    if tSpr <> 0 then
      tObj = createObject(#temp, "Palm Class")
      tObj.define(tSpr)
      pItemObjList.add(tObj)
    else
    end if
    i = i + 1
  end repeat
  exit
end

on deconstruct(me)
  call(#deconstruct, pItemObjList)
  pItemObjList = []
  return(removeUpdate(me.getID()))
  exit
end

on update(me)
  call(#update, pItemObjList)
  exit
end