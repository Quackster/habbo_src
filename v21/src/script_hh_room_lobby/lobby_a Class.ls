on construct(me)
  pBubbleList = []
  i = 1
  repeat while i <= 10
    tObj = createObject(#temp, "Lobby Bubble Class")
    tObj.define(i)
    pBubbleList.add(tObj)
    i = 1 + i
  end repeat
  return(receiveUpdate(me.getID()))
  exit
end

on deconstruct(me)
  pBubbleList = []
  return(removeUpdate(me.getID()))
  exit
end

on update(me)
  call(#update, pBubbleList)
  exit
end