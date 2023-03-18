property pBubbleList

on construct me
  pBubbleList = []
  repeat with i = 1 to 10
    tObj = createObject(#temp, "Lobby Bubble Class")
    tObj.define(i)
    pBubbleList.add(tObj)
  end repeat
  return receiveUpdate(me.getID())
end

on deconstruct me
  pBubbleList = []
  return removeUpdate(me.getID())
end

on update me
  call(#update, pBubbleList)
end
