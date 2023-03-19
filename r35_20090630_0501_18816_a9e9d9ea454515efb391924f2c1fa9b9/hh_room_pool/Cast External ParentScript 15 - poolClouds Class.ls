property pClouds

on construct me
  pClouds = [:]
  repeat with f = 1 to 4
    pClouds.addProp("pilvi" & f, createObject(#temp, "Pelle Cloud Class"))
    tsprite = getVisualizer(#pooltower).getSprById("pilvi" & f)
    tStartPointX = [711, 888, 515, 318][f]
    pClouds["pilvi" & f].prepare(tsprite, tStartPointX)
  end repeat
  return receivePrepare(me.getID())
end

on deconstruct me
  pClouds = VOID
  removePrepare(me.getID())
  return 1
end

on prepare me
  call(#update, pClouds)
end
