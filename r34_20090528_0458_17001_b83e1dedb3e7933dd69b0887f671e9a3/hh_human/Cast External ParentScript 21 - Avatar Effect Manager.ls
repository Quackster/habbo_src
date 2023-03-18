property pCurrentEffects

on construct me
  pCurrentEffects = [:]
  return 1
end

on deconstruct me
  me.clearEffects()
  return 1
end

on getCurrentEffectState me
  if pCurrentEffects.count = 0 then
    return 0
  end if
  tID = pCurrentEffects.getPropAt(1)
  tR = [:]
  tR.setaProp(tID, me.getEffectTimeRemaining(tID))
  return tR
end

on constructEffect me, tAvatarObj, tID
  if tID = VOID then
    return 0
  end if
  if pCurrentEffects.getaProp(tID) <> 0 then
    return pCurrentEffects.getaProp(tID)
  end if
  tMemName = "fx." & tID
  if not memberExists(tMemName) then
    return error(me, "Definition for effect not found:" && tMemName, #action_fx, #minor)
  end if
  tmember = member(getmemnum(tMemName))
  tProps = tmember.text
  tClass = "Avatar Effect Class"
  tMemNum = getmemnum("Avatar Effect" && tID && "Class")
  if tMemNum > 0 then
    tClass = [tClass, "Avatar Effect" && tID && "Class"]
  end if
  tObject = createObject(#temp, tClass)
  if tObject = 0 then
    return 0
  end if
  tObject.define(tID, tProps, tAvatarObj)
  pCurrentEffects.setaProp(tID, tObject)
  if tObject.changesBodyparts() then
    tPartIndex = tObject.getAddedBodyPartIndex()
    repeat with tPart in tPartIndex
      tmodel = tObject.getEffectBodyPartModel(tPart)
      tAvatarObj.pRawFigure.setaProp(tPart, tmodel)
      tPartListAction = tObject.getEffectBodyPartAction(tPart)
      tAvatarObj.definePartListAction([tPart], tPartListAction)
    end repeat
    tAvatarObj.changeFigureAndData()
  end if
  tAvatarObj.startAnimation(tMemName)
  return 1
end

on updateEffects me, tAvatarObj
  repeat with tObject in pCurrentEffects
    if tObject.hasSprites() then
      tObject.updateSprites(tAvatarObj)
    end if
  end repeat
end

on clearEffects me, tAvatarObj
  repeat with tObject in pCurrentEffects
    if tObject.changesBodyparts() then
      tPartIndex = tObject.getAddedBodyPartIndex()
      repeat with tPart in tPartIndex
        if objectp(tAvatarObj) then
          i = 1
          repeat while i <= tAvatarObj.pPartList.count
            if tAvatarObj.pPartList[i].pPart = tPart then
              tAvatarObj.pPartList.deleteAt(i)
              next repeat
            end if
            i = i + 1
          end repeat
        end if
      end repeat
      tFigureChanged = 1
    end if
    tObject.deconstruct()
  end repeat
  pCurrentEffects = [:]
  if objectp(tAvatarObj) then
    tAvatarObj.pPartIndex = [:]
    repeat with i = 1 to tAvatarObj.pPartList.count
      tAvatarObj.pPartIndex.addProp(tAvatarObj.pPartList[i].pPart, i)
    end repeat
    if tFigureChanged then
      tAvatarObj.changeFigureAndData()
    end if
    tAvatarObj.stopAnimation()
    tAvatarObj.pFx = 0
    executeMessage(#updateInfostandAvatar)
  end if
  return 1
end

on effectExists me, tID
  if tID = VOID then
    return 0
  end if
  return pCurrentEffects.findPos(tID) > 0
end

on getEffectDirOffset me
  repeat with tEffect in pCurrentEffects
    tOffD = tEffect.getEffectDirOffset()
    if tOffD <> 0 then
      return tOffD
    end if
  end repeat
  return 0
end

on getEffectSizeParams me
  tSize = [0, 0]
  repeat with tEffect in pCurrentEffects
    tEffectSize = tEffect.getEffectSizeParams()
    if tEffectSize <> 0 then
      if tEffectSize[1] > tSize[1] then
        tSize[1] = tEffectSize[1]
      end if
      if tEffectSize[2] > tSize[2] then
        tSize[2] = tEffectSize[2]
      end if
    end if
  end repeat
  return tSize
end

on getEffectShadowName me
  repeat with tEffect in pCurrentEffects
    tShadow = tEffect.getEffectShadowName()
    if tShadow <> 0 then
      return tShadow
    end if
  end repeat
  return 0
end

on getEffectSpriteProps me
  tList = []
  repeat with i = 1 to pCurrentEffects.count
    tEffect = pCurrentEffects[i]
    tEffectSprites = tEffect.getEffectSpriteProps()
    repeat with tsprite in tEffectSprites
      tList.append(tsprite)
    end repeat
  end repeat
  return tList
end

on getEffectAddedPartIndex me
  tList = []
  repeat with i = 1 to pCurrentEffects.count
    tEffect = pCurrentEffects[i]
    tEffectParts = tEffect.getAddedBodyPartIndex()
    repeat with tPart in tEffectParts
      if tList.findPos(tPart) = 0 then
        tList.append(tPart)
      end if
    end repeat
  end repeat
  return tList
end

on getEffectExcludedPartIndex me
  tList = []
  repeat with tEffect in pCurrentEffects
    tEffectParts = tEffect.getExcludedBodyPartIndex()
    repeat with tPart in tEffectParts
      if tList.findPos(tPart) = 0 then
        tList.append(tPart)
      end if
    end repeat
  end repeat
  return tList
end

on alignEffectBodyparts me, tPartDefinition, tDirection
  repeat with i = 1 to pCurrentEffects.count
    tEffect = pCurrentEffects[i]
    if tEffect.addsBodyparts() then
      tEffect.alignEffectBodyparts(tPartDefinition, tDirection)
    end if
  end repeat
  return tPartDefinition
end

on setAnimation me, tPart, tAnim
  call(#setAnimation, pCurrentEffects, tPart, value(tAnim))
end

on getEffectTimeRemaining me, tID
  if tID = VOID then
    return -1
  end if
  tActiveList = getObject(#session).GET("active_fx")
  if tActiveList = 0 then
    return -1
  end if
  if tActiveList.findPos(tID) = 0 then
    return -1
  end if
  tEndTime = tActiveList.getaProp(tID)
  tTime = (tEndTime - the milliSeconds) / 1000
  if tTime < 0 then
    return 0
  end if
  return tTime
end
