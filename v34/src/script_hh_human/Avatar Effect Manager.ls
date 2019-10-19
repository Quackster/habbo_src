property pCurrentEffects

on construct me 
  pCurrentEffects = [:]
  return(1)
end

on deconstruct me 
  me.clearEffects()
  return(1)
end

on getCurrentEffectState me 
  if pCurrentEffects.count = 0 then
    return(0)
  end if
  tID = pCurrentEffects.getPropAt(1)
  tR = [:]
  tR.setaProp(tID, me.getEffectTimeRemaining(tID))
  return(tR)
end

on constructEffect me, tAvatarObj, tID 
  if tID = void() then
    return(0)
  end if
  if pCurrentEffects.getaProp(tID) <> 0 then
    return(pCurrentEffects.getaProp(tID))
  end if
  tMemName = "fx." & tID
  if not memberExists(tMemName) then
    return(error(me, "Definition for effect not found:" && tMemName, #action_fx, #minor))
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
    return(0)
  end if
  tObject.define(tID, tProps, tAvatarObj)
  pCurrentEffects.setaProp(tID, tObject)
  if tObject.changesBodyparts() then
    tPartIndex = tObject.getAddedBodyPartIndex()
    repeat while tPartIndex <= tID
      tPart = getAt(tID, tAvatarObj)
      tmodel = tObject.getEffectBodyPartModel(tPart)
      pRawFigure.setaProp(tPart, tmodel)
      tPartListAction = tObject.getEffectBodyPartAction(tPart)
      tAvatarObj.definePartListAction([tPart], tPartListAction)
    end repeat
    tAvatarObj.changeFigureAndData()
  end if
  tAvatarObj.startAnimation(tMemName)
  return(1)
end

on updateEffects me, tAvatarObj 
  repeat while pCurrentEffects <= undefined
    tObject = getAt(undefined, tAvatarObj)
    if tObject.hasSprites() then
      tObject.updateSprites(tAvatarObj)
    end if
  end repeat
end

on clearEffects me, tAvatarObj 
  repeat while pCurrentEffects <= undefined
    tObject = getAt(undefined, tAvatarObj)
    if tObject.changesBodyparts() then
      tPartIndex = tObject.getAddedBodyPartIndex()
      repeat while pCurrentEffects <= undefined
        tPart = getAt(undefined, tAvatarObj)
        if objectp(tAvatarObj) then
          i = 1
          repeat while i <= tAvatarObj.count(#pPartList)
            if tAvatarObj.getPropRef(#pPartList, i).pPart = tPart then
              pPartList.deleteAt(i)
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
    i = 1
    repeat while i <= tAvatarObj.count(#pPartList)
      pPartIndex.addProp(tAvatarObj.getPropRef(#pPartList, i).pPart, i)
      i = 1 + i
    end repeat
    if tFigureChanged then
      tAvatarObj.changeFigureAndData()
    end if
    tAvatarObj.stopAnimation()
    tAvatarObj.pFx = 0
    executeMessage(#updateInfostandAvatar)
  end if
  return(1)
end

on effectExists me, tID 
  if tID = void() then
    return(0)
  end if
  return(pCurrentEffects.findPos(tID) > 0)
end

on getEffectDirOffset me 
  repeat while pCurrentEffects <= undefined
    tEffect = getAt(undefined, undefined)
    tOffD = tEffect.getEffectDirOffset()
    if tOffD <> 0 then
      return(tOffD)
    end if
  end repeat
  return(0)
end

on getEffectSizeParams me 
  tSize = [0, 0]
  repeat while pCurrentEffects <= undefined
    tEffect = getAt(undefined, undefined)
    tEffectSize = tEffect.getEffectSizeParams()
    if tEffectSize <> 0 then
      if tEffectSize.getAt(1) > tSize.getAt(1) then
        tSize.setAt(1, tEffectSize.getAt(1))
      end if
      if tEffectSize.getAt(2) > tSize.getAt(2) then
        tSize.setAt(2, tEffectSize.getAt(2))
      end if
    end if
  end repeat
  return(tSize)
end

on getEffectShadowName me 
  repeat while pCurrentEffects <= undefined
    tEffect = getAt(undefined, undefined)
    tShadow = tEffect.getEffectShadowName()
    if tShadow <> 0 then
      return(tShadow)
    end if
  end repeat
  return(0)
end

on getEffectSpriteProps me 
  tList = []
  i = 1
  repeat while i <= pCurrentEffects.count
    tEffect = pCurrentEffects.getAt(i)
    tEffectSprites = tEffect.getEffectSpriteProps()
    repeat while tEffectSprites <= undefined
      tsprite = getAt(undefined, undefined)
      tList.append(tsprite)
    end repeat
    i = 1 + i
  end repeat
  return(tList)
end

on getEffectAddedPartIndex me 
  tList = []
  i = 1
  repeat while i <= pCurrentEffects.count
    tEffect = pCurrentEffects.getAt(i)
    tEffectParts = tEffect.getAddedBodyPartIndex()
    repeat while tEffectParts <= undefined
      tPart = getAt(undefined, undefined)
      if tList.findPos(tPart) = 0 then
        tList.append(tPart)
      end if
    end repeat
    i = 1 + i
  end repeat
  return(tList)
end

on getEffectExcludedPartIndex me 
  tList = []
  repeat while pCurrentEffects <= undefined
    tEffect = getAt(undefined, undefined)
    tEffectParts = tEffect.getExcludedBodyPartIndex()
    repeat while pCurrentEffects <= undefined
      tPart = getAt(undefined, undefined)
      if tList.findPos(tPart) = 0 then
        tList.append(tPart)
      end if
    end repeat
  end repeat
  return(tList)
end

on alignEffectBodyparts me, tPartDefinition, tDirection 
  i = 1
  repeat while i <= pCurrentEffects.count
    tEffect = pCurrentEffects.getAt(i)
    if tEffect.addsBodyparts() then
      tEffect.alignEffectBodyparts(tPartDefinition, tDirection)
    end if
    i = 1 + i
  end repeat
  return(tPartDefinition)
end

on setAnimation me, tPart, tAnim 
  call(#setAnimation, pCurrentEffects, tPart, value(tAnim))
end

on getEffectTimeRemaining me, tID 
  if tID = void() then
    return(-1)
  end if
  tActiveList = getObject(#session).GET("active_fx")
  if tActiveList = 0 then
    return(-1)
  end if
  if tActiveList.findPos(tID) = 0 then
    return(-1)
  end if
  tEndTime = tActiveList.getaProp(tID)
  tTime = (tEndTime - the milliSeconds / 1000)
  if tTime < 0 then
    return(0)
  end if
  return(tTime)
end
