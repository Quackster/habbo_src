on prepare me
  tCount = me.pSprList.count
  repeat with i = 1 to tCount
    tOldSpr = me.pSprList[i]
    tOldSpr.ink = 41
    tNewSpr = sprite(reserveSprite(me.getID()))
    tNewSpr.member = tOldSpr.member
    tNewSpr.loc = tOldSpr.loc
    tNewSpr.locZ = tOldSpr.locZ + 1 + 75
    tNewSpr.ink = 8
    tNewSpr.blend = 0
    tBroker = tOldSpr.scriptInstanceList[1]
    tNewSpr.scriptInstanceList.add(tBroker)
    tOldSpr.scriptInstanceList.deleteAt(1)
    me.pSprList.add(tNewSpr)
  end repeat
  return 1
end

on getInfo me
  tInfo = [:]
  tInfo[#name] = "wall door"
  tInfo[#class] = me.pClass
  tInfo[#custom] = me.pCustom
  return tInfo
end
