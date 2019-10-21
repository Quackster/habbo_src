property pCloudList

on construct me 
  pCloudList = []
  f = 1
  repeat while f <= 4
    tCloud = createObject(#temp, "Single Cloud Class")
    tsprite = getThread(#room).getInterface().getRoomVisualizer().getSprById("pilvi" & f)
    tStartPointX = [200, 330, 490, 630].getAt(f)
    tCloud.prepare(tsprite, tStartPointX)
    pCloudList.add(tCloud)
    f = (1 + f)
  end repeat
  return(receivePrepare(me.getID()))
end

on deconstruct me 
  pCloudList = void()
  removePrepare(me.getID())
  return TRUE
end

on prepare me 
  call(#update, pCloudList)
end
