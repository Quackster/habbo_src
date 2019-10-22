property pItemObjList

on construct me 
  pItemObjList = []
  receiveUpdate(me.getID())
  tVisObj = getThread(#room).getInterface().getRoomVisualizer()
  i = 1
  repeat while 1
    tSpr = tVisObj.getSprById("cloud" & i)
    if tSpr <> 0 then
      tObj = createObject(#temp, "Rooftop Cloud Class")
      tObj.define(tSpr, i)
      pItemObjList.add(tObj)
    else
    end if
    i = (i + 1)
  end repeat
end

on deconstruct me 
  call(#deconstruct, pItemObjList)
  pItemObjList = []
  return(removeUpdate(me.getID()))
end

on update me 
  call(#update, pItemObjList)
end
