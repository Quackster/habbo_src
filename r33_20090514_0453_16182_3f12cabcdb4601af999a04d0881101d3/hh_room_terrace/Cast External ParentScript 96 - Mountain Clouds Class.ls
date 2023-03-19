property pCloudList

on construct me
  pCloudList = []
  repeat with f = 1 to 4
    tCloud = createObject(#temp, "Single Cloud Class")
    tsprite = getThread(#room).getInterface().getRoomVisualizer().getSprById("pilvi" & f)
    tStartPointX = [200, 330, 490, 630][f]
    tCloud.prepare(tsprite, tStartPointX)
    pCloudList.add(tCloud)
  end repeat
  return receivePrepare(me.getID())
end

on deconstruct me
  pCloudList = VOID
  removePrepare(me.getID())
  return 1
end

on prepare me
  call(#update, pCloudList)
end
