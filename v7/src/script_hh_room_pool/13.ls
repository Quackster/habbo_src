on construct(me)
  pClouds = []
  f = 1
  repeat while f <= 4
    pClouds.addProp("pilvi" & f, createObject(#temp, "Pelle Cloud Class"))
    tSprite = getVisualizer(#pooltower).getSprById("pilvi" & f)
    tStartPointX = [711, 888, 515, 318].getAt(f)
    pClouds.getAt("pilvi" & f).prepare(tSprite, tStartPointX)
    f = 1 + f
  end repeat
  return(receivePrepare(me.getID()))
  exit
end

on deconstruct(me)
  pClouds = void()
  removePrepare(me.getID())
  return(1)
  exit
end

on prepare(me)
  call(#update, pClouds)
  exit
end