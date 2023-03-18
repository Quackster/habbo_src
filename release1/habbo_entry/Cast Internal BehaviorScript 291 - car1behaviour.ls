property myModel, carDir, myCurrModel, startX, startY, caronecounter, caronesmallcount

on beginSprite me
  myModel = ["cab", "bus"]
  startX = 206
  startY = 496
  iSpr = me.spriteNum
  caronecounter = 0
  caronesmallcount = 0
  carDir = 1
  isCar = random(4)
  if isCar = 1 then
    myCurrModel = myModel[random(myModel.count)]
  else
    myCurrModel = "car"
  end if
  sprite(iSpr).member = myCurrModel & carDir
  sprite(iSpr).locH = startX
  sprite(iSpr).locV = startY
  if myCurrModel = "car" then
    sprite(iSpr).backColor = random(150) + 20
  else
    sprite(iSpr).backColor = 0
  end if
end

on exitFrame me
  global caronecounter, caronesmallcount
  iSpr = me.spriteNum
  if caronesmallcount = 0 then
    sprite(iSpr).locH = sprite(iSpr).locH + 2
    sprite(iSpr).locV = sprite(iSpr).locV - 1
  end if
  if sprite(iSpr).locV < 353 then
    caronesmallcount = 1
    carDir = 2
    sprite(iSpr).member = myCurrModel & carDir
  end if
  if sprite(iSpr).locH > 740 then
    caronecounter = 0
    caronesmallcount = 0
    carDir = 1
    isCar = random(4)
    if isCar = 1 then
      myCurrModel = myModel[random(myModel.count)]
    else
      myCurrModel = "car"
    end if
    sprite(iSpr).member = myCurrModel & carDir
    sprite(iSpr).locH = startX
    sprite(iSpr).locV = startY
    if myCurrModel = "car" then
      sprite(iSpr).backColor = random(150) + 20
    else
      sprite(iSpr).backColor = 0
    end if
  end if
  if caronesmallcount = 1 then
    sprite(iSpr).locH = sprite(iSpr).locH + 2
    sprite(iSpr).locV = sprite(iSpr).locV + 1
  end if
  caronecounter = caronecounter + 1
end

on endSprite me
  iSpr = me.spriteNum
end
