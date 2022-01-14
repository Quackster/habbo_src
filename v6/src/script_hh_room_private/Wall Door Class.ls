on prepare me 
  tCount = me.count(#pSprList)
  i = 1
  repeat while i <= tCount
    tOldSpr = me.pSprList.getAt(i)
    tOldSpr.ink = 41
    tNewSpr = sprite(reserveSprite(me.getID()))
    tNewSpr.member = tOldSpr.member
    tNewSpr.loc = tOldSpr.loc
    tNewSpr.locZ = ((tOldSpr.locZ + 1) + 75)
    tNewSpr.ink = 8
    tNewSpr.blend = 0
    tBroker = tOldSpr.scriptInstanceList.getAt(1)
    tNewSpr.scriptInstanceList.add(tBroker)
    tOldSpr.scriptInstanceList.deleteAt(1)
    me.pSprList.add(tNewSpr)
    i = (1 + i)
  end repeat
  return TRUE
end

on getInfo me 
  tInfo = [:]
  tInfo.setAt(#name, "wall door")
  tInfo.setAt(#class, me.pClass)
  tInfo.setAt(#custom, me.pCustom)
  return(tInfo)
end
