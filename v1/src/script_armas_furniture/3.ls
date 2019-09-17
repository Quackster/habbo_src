property tvFrame, fireplaceOn, carLoop, formulaFrame, carLoopCount, stillWait, stillPicture, ancestor

on new me, tName, tMemberPrefix, tMemberFigureType, tLocX, tLocY, tHeight, tDirection, lDimensions, spr, taltitude, pData 
  ancestor = new(script("FUSEMember Class"), tName, tMemberPrefix, tMemberFigureType, tLocX, tLocY, tHeight, tDirection, lDimensions, spr, taltitude, pData)
  polyfonfprand = 0
  formulaFrame = 0
  formulaMode = 0
  carLoop = 1
  stillPicture = 0
  stillWait = 0
  if getaProp(me.pData, "FIREON") = "ON" then
    setOn(me)
  else
    setOff(me)
  end if
  return(me)
end

on updateStuffdata me, tProp, tValue 
  if tValue = "ON" then
    setOn(me)
  else
    setOff(me)
  end if
end

on exitFrame me 
  tvFrame = tvFrame + 1
  if fireplaceOn and tvFrame mod 2 = 1 then
    mname = me.getPropRef(#lSprites, 4).member.name
    the itemDelimiter = "_"
    tmpName = ""
    tmpName = mname.getProp(#item, 1, mname.count(#item) - 1) & "_"
    the itemDelimiter = ","
    if carLoop = 1 then
      carLoopCount = random(7)
    end if
    if carLoop >= 1 then
      newMName = tmpName & formulaFrame
      formulaFrame = formulaFrame + 1
      if formulaFrame > 13 then
        formulaFrame = 1
        carLoop = carLoop + 1
        if carLoop >= carLoopCount then
          carLoop = 0
          stillPicture = random(2)
          stillWait = 50 + random(100)
          tvFrame = 0
        end if
      end if
    else
      if carLoop = 0 then
        if tvFrame <= stillWait then
          if stillPicture = 1 then
            if sprite(me.spriteNum).skew > 0 then
              newMName = tmpName & 16
            else
              newMName = tmpName & 15
            end if
          else
            if stillPicture = 2 then
              newMName = tmpName & 14
            end if
          end if
        else
          carLoop = 1
        end if
      end if
    end if
    if getmemnum(newMName) > 0 then
      me.getPropRef(#lSprites, 4).castNum = getmemnum(newMName)
    end if
  end if
  if fireplaceOn = 0 then
    newMName = "tv_luxus_d_0_1_3_0_0"
    if getmemnum(newMName) > 0 then
      me.getPropRef(#lSprites, 4).castNum = getmemnum(newMName)
    end if
  end if
  me.getPropRef(#lSprites, 4).locZ = me.getPropRef(#lSprites, 1).locZ + 2
end

on setOn me 
  fireplaceOn = 1
end

on setOff me 
  fireplaceOn = 0
end

on mouseDown me 
  callAncestor(#mouseDown, ancestor)
  if the doubleClick then
    if fireplaceOn = 1 then
      onString = "OFF"
    else
      onString = "ON"
    end if
    sendFuseMsg("SETSTUFFDATA /" & me.id & "/" & "FIREON" & "/" & onString)
  end if
end
