property pActive, pSync, pAnimFrame, pUserClicked

on prepare me, tdata 
  pUserClicked = 0
  pLastDir = -1
  pSync = 0
  return TRUE
end

on updateStuffdata me, tValue 
  pAnimFrame = 1
  pActive = 1
end

on update me 
  if pActive then
    pSync = (pSync + 1)
    if pSync < 3 then
      return TRUE
    end if
    pSync = 0
    if me.count(#pSprList) < 5 then
      return FALSE
    end if
    if pAnimFrame > 0 then
      if (pAnimFrame = 1) then
        me.switchMember("a", "1")
      else
        if (pAnimFrame = 2) then
          me.switchMember("d", "1")
        else
          if (pAnimFrame = 3) then
            me.switchMember("d", "2")
          else
            if (pAnimFrame = 4) then
              me.switchMember("d", "3")
            else
              if (pAnimFrame = 5) then
                me.switchMember("d", "4")
              else
                if (pAnimFrame = 6) then
                  me.switchMember("d", "5")
                else
                  if (pAnimFrame = 7) then
                    me.switchMember("a", "0")
                  else
                    if (pAnimFrame = 8) then
                      if pUserClicked then
                        me.giveDrink()
                      end if
                      pUserClicked = 0
                    else
                      if (pAnimFrame = 9) then
                        me.switchMember("d", "6")
                      else
                        if (pAnimFrame = 15) then
                          me.switchMember("d", "0")
                          pAnimFrame = 0
                          pActive = 0
                          return TRUE
                        end if
                      end if
                    end if
                  end if
                end if
              end if
            end if
          end if
        end if
      end if
      pAnimFrame = (pAnimFrame + 1)
    end if
  end if
end

on switchMember me, tPart, tNewMem 
  tSprNum = ["a", "b", "c", "d", "e", "f"].getPos(tPart)
  if me.count(#pSprList) < tSprNum or (tSprNum = 0) then
    return FALSE
  end if
  tName = me.getPropRef(#pSprList, tSprNum).member.name
  tName = tName.getProp(#char, 1, (tName.length - 1)) & tNewMem
  if memberExists(tName) then
    tmember = member(getmemnum(tName))
    me.getPropRef(#pSprList, tSprNum).castNum = tmember.number
    me.getPropRef(#pSprList, tSprNum).width = tmember.width
    me.getPropRef(#pSprList, tSprNum).height = tmember.height
  end if
end

on select me 
  tUserObj = getThread(#room).getComponent().getOwnUser()
  if (tUserObj = 0) then
    return TRUE
  end if
  tCarrying = tUserObj.getProperty(#carrying)
  tloc = tUserObj.getProperty(#loc)
  tLocX = tloc.getAt(1)
  tLocY = tloc.getAt(2)
  if (me.getProp(#pDirection, 1) = 4) then
    if (me.pLocX = tLocX) and ((me.pLocY - tLocY) = -1) then
      if the doubleClick and not tCarrying then
        me.setAnimation()
      end if
    else
      getThread(#room).getComponent().getRoomConnection().send("MOVE", [#short:me.pLocX, #short:(me.pLocY + 1)])
    end if
  else
    if (me.getProp(#pDirection, 1) = 0) then
      if (me.pLocX = tLocX) and ((me.pLocY - tLocY) = 1) then
        if the doubleClick and not tCarrying then
          me.setAnimation()
        end if
      else
        getThread(#room).getComponent().getRoomConnection().send("MOVE", [#short:me.pLocX, #short:(me.pLocY - 1)])
      end if
    else
      if (me.getProp(#pDirection, 1) = 2) then
        if (me.pLocY = tLocY) and ((me.pLocX - tLocX) = -1) then
          if the doubleClick and not tCarrying then
            me.setAnimation()
          end if
        else
          getThread(#room).getComponent().getRoomConnection().send("MOVE", [#short:(me.pLocX + 1), #short:me.pLocY])
        end if
      else
        if (me.getProp(#pDirection, 1) = 6) then
          if (me.pLocY = tLocY) and ((me.pLocX - tLocX) = 1) then
            if the doubleClick and not tCarrying then
              me.setAnimation()
            end if
          else
            getThread(#room).getComponent().getRoomConnection().send("MOVE", [#short:(me.pLocX - 1), #short:me.pLocY])
          end if
        end if
      end if
    end if
  end if
  return TRUE
end

on setAnimation me 
  if (pActive = 1) then
    return TRUE
  end if
  pUserClicked = 1
  tConnection = getThread(#room).getComponent().getRoomConnection()
  if (tConnection = 0) then
    return FALSE
  end if
  getThread(#room).getComponent().getRoomConnection().send("SETSTUFFDATA", [#string:string(me.getID()), #string:"TRUE"])
  tConnection.send("LOOKTO", me.pLocX && me.pLocY)
end

on giveDrink me 
  tConnection = getThread(#room).getComponent().getRoomConnection()
  if (tConnection = 0) then
    return FALSE
  end if
  tClass = me.pClass
  if tClass contains "*" then
    tClass = tClass.getProp(#char, 1, (offset("*", tClass) - 1))
  end if
  tToken = value(getVariable("obj_" & tClass))
  if not listp(tToken) then
    tToken = [4]
  end if
  tToken = tToken.getAt(1)
  tConnection.send("CARRYDRINK", tToken)
end
