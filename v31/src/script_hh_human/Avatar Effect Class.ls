property pSpriteList, pProps, pPeopleSize, pExcludedBodyPartIndex, pDirOffset, pSizeParams, pShadowName, pAddedBodyPartIndex, pAddedBodyParts, pAddedBodyPartActionList

on construct me 
  pAddedBodyParts = [:]
  pAddedBodyPartIndex = []
  pAddedBodyPartActionList = [:]
  pExcludedBodyPartIndex = []
  pSizeParams = [0, 0]
  pFrame = 0
  pDirOffset = 0
  pSpriteList = [:]
  return TRUE
end

on deconstruct me 
  pAddedBodyParts = [:]
  pAddedBodyPartIndex = []
  pAddedBodyPartActionList = [:]
  pExcludedBodyPartIndex = []
  repeat while pSpriteList <= undefined
    tProps = getAt(undefined, undefined)
    tsprite = tProps.getaProp(#sprite)
    releaseSprite(tsprite.spriteNum)
  end repeat
  pSpriteList = [:]
  return TRUE
end

on define me, tID, tText, tAvatarObj 
  if (tAvatarObj = 0) then
    return FALSE
  end if
  pXFactor = tAvatarObj.pXFactor
  pPeopleSize = tAvatarObj.pPeopleSize
  pFrameTotal = 1
  tTempDelim = the itemDelimiter
  the itemDelimiter = "/"
  pProps = [:]
  i = 1
  repeat while i <= tText.count(#line)
    tLine = tText.getProp(#line, i)
    if tLine.getProp(#char, 1) <> "#" and tLine contains "/" then
      tKey = symbol(tLine.getProp(#item, 1))
      tValue = tLine.getProp(#item, 2)
      tValue = value(tValue)
      if (tKey = #sprite) then
        tSpriteNum = reserveSprite(tAvatarObj.getID())
        if tSpriteNum > 0 then
          tValue.setaProp(#sprite, sprite(tSpriteNum))
          pProps.addProp(tKey, tValue)
          tValue.setaProp(#direction, -1)
        end if
      else
        if (tKey = symbol(pPeopleSize & "_size")) then
          pSizeParams = tValue
        else
          if (tKey = #exclude_bodypart) then
            pExcludedBodyPartIndex.add(tValue)
          else
            pProps.addProp(tKey, tValue)
          end if
        end if
      end if
    end if
    i = (1 + i)
  end repeat
  the itemDelimiter = tTempDelim
  i = 1
  repeat while i <= pProps.count
    ttype = pProps.getPropAt(i)
    tParam = pProps.getAt(i)
    if (tKey = #add_bodypart) then
      me.addBodyPart(tParam, tAvatarObj)
    else
      if (tKey = #sprite) then
        me.addSprite(tParam, tAvatarObj)
      else
        if (tKey = #human_sprite_props) then
          me.setHumanSpriteProps(tParam, tAvatarObj)
        else
          if (tKey = #shadow) then
            pShadowName = tParam
          else
            if (tKey = #OffD) then
              pDirOffset = integer(tParam)
            end if
          end if
        end if
      end if
    end if
    i = (1 + i)
  end repeat
  me.updateSprites(tAvatarObj, 1)
  return TRUE
end

on getEffectDirOffset me 
  return(pDirOffset)
end

on getEffectSizeParams me 
  return(pSizeParams)
end

on getEffectShadowName me 
  return(pShadowName)
end

on getAddedBodyPartIndex me 
  return(pAddedBodyPartIndex)
end

on getExcludedBodyPartIndex me 
  return(pExcludedBodyPartIndex)
end

on getEffectBodyPartModel me, tPart 
  tPartInfo = pAddedBodyParts.getaProp(tPart)
  if (tPartInfo = 0) then
    return FALSE
  end if
  if (tPartInfo.getaProp("model") = 0) then
    tPartInfo.setaProp("model", "1")
  end if
  if (tPartInfo.getaProp("color") = 0) then
    tPartInfo.setaProp("color", rgb(0, 0, 0))
    tPartInfo.setaProp("color", rgb(255, 255, 255))
  end if
  if (tPartInfo.getaProp("setid") = 0) then
    tPartInfo.setaProp("setid", "1")
  end if
  if (tPartInfo.getaProp("colorid") = 0) then
    tPartInfo.setaProp("colorid", "1")
  end if
  return(tPartInfo)
end

on getEffectBodyPartAction me, tPart 
  tAction = pAddedBodyPartActionList.getaProp(tPart)
  if (tAction = void()) then
    return("std")
  else
    return(tAction)
  end if
end

on changesBodyparts me 
  return(me.excludesBodyparts() or me.addsBodyparts())
end

on addsBodyparts me 
  return(me.count(#pAddedBodyPartIndex) > 0)
end

on excludesBodyparts me 
  return(me.count(#pExcludedBodyPartIndex) > 0)
end

on alignEffectBodyparts me, tPartDefinition, tDirection 
  i = 1
  repeat while i <= pAddedBodyParts.count
    tID = pAddedBodyParts.getPropAt(i)
    tProps = pAddedBodyParts.getAt(i)
    if (tPartDefinition.findPos(tID) = 0) then
      tAlignmentDef = tProps.getaProp(#align)
      tAlignment = #top
      if symbolp(tAlignmentDef) then
        tAlignment = tAlignmentDef
      else
        if listp(tAlignmentDef) then
          if tAlignmentDef.count >= (tDirection + 1) then
            tAlignment = tAlignmentDef.getAt((tDirection + 1))
          end if
        end if
      end if
      if (tAlignment = #bottom) then
        tPartDefinition.addAt(1, tID)
      else
        tPartDefinition.append(tID)
      end if
    end if
    i = (1 + i)
  end repeat
  return(tPartDefinition)
end

on hasSprites me 
  return(pSpriteList.count > 0)
end

on getEffectSpriteProps me 
  return(pSpriteList)
end

on updateSprites me, tAvatarObj, tForcedUpdate 
  if (tAvatarObj = 0) then
    return FALSE
  end if
  me.setMember(tAvatarObj.getProperty(#direction), tAvatarObj.pSprite.loc, tAvatarObj.pSprite.locZ, tAvatarObj.pXFactor, tForcedUpdate)
  return TRUE
end

on setAnimation me, tPart, tAnim 
  if (tPart = "all") then
    repeat while pSpriteList <= tAnim
      tProps = getAt(tAnim, tPart)
      i = 1
      repeat while i <= tAnim.count
        tProps.setaProp(tAnim.getPropAt(i), tAnim.getAt(i))
        i = (1 + i)
      end repeat
      tProps.setaProp(#counter, 0)
    end repeat
  else
    if (pSpriteList.findPos(tPart) = 0) then
      return FALSE
    end if
    tProps = pSpriteList.getaProp(tPart)
    i = 1
    repeat while i <= tAnim.count
      tProps.setaProp(tAnim.getPropAt(i), tAnim.getAt(i))
      i = (1 + i)
    end repeat
    tProps.setaProp(#counter, 0)
  end if
end

on addBodyPart me, tParam 
  tID = tParam.getaProp(#id)
  if (pAddedBodyPartIndex.findPos(tID) = 0) then
    pAddedBodyPartIndex.add(tID)
    if tParam.findPos(#act) > 0 then
      pAddedBodyPartActionList.setaProp(tID, tParam.getaProp(#act))
    end if
    if tParam.findPos(#ink) > 0 then
      tParam.setaProp("ink", integer(tParam.getaProp(#ink)))
    end if
    if tParam.findPos(#blend) > 0 then
      tParam.setaProp("blend", integer(tParam.getaProp(#blend)))
    end if
    pAddedBodyParts.setaProp(tID, tParam)
  end if
  return TRUE
end

on addSprite me, tParam, tAvatarObj 
  tID = symbol(tParam.getaProp(#id))
  tsprite = tParam.getaProp(#sprite)
  if (pSpriteList.findPos(tID) = 0) then
    if (tParam.findPos(#offZ) = 0) then
      tParam.setaProp(#offZ, 1)
    end if
    tParam.setaProp(#sprite, tsprite)
    if tParam.findPos(#ink) > 0 then
      tsprite.ink = integer(tParam.getaProp(#ink))
    end if
    tParam.setaProp(#frame, 0)
    pSpriteList.setaProp(tID, tParam)
  end if
  return TRUE
end

on setMember me, tdir, tloc, tlocz, tXFactor, tForcedUpdate 
  repeat while pSpriteList <= tloc
    tProps = getAt(tloc, tdir)
    tXFix = 0
    tYFix = 0
    tDFix = 0
    tChanges = 0
    if not tForcedUpdate then
      if tdir <> tProps.getaProp(#direction) then
        tChanges = 1
      end if
      tFrames = tProps.getaProp(#frm)
      if tFrames <> void() then
        tFrameTotal = tFrames.count
        if tFrameTotal > 1 then
          tFrameSkipTotal = tProps.getaProp(#skip)
          if (tFrameSkipTotal = void()) then
            tFrameSkipTotal = 1
          end if
          tSkipCounter = tProps.getaProp(#counter)
          if tSkipCounter < (tFrameSkipTotal - 1) then
            tProps.setaProp(#counter, (tSkipCounter + 1))
          else
            tFrame = tProps.getaProp(#frame)
            tFrameMem = tFrames.getAt(tFrame)
            tXFixes = tProps.getaProp(#OffX)
            if tXFixes <> void() then
              if tXFixes.count < tFrame then
                tXFix = tXFixes.getAt(1)
              else
                tXFix = tXFixes.getAt(tFrame)
              end if
            end if
            tYFixes = tProps.getaProp(#OffY)
            if tYFixes <> void() then
              if tYFixes.count < tFrame then
                tYFix = tYFixes.getAt(1)
              else
                tYFix = tYFixes.getAt(tFrame)
              end if
            end if
            tDFixes = tProps.getaProp(#OffD)
            if tDFixes <> void() then
              if tDFixes.count < tFrame then
                tDFix = tDFixes.getAt(1)
              else
                tDFix = tDFixes.getAt(tFrame)
              end if
            end if
            tBlend = void()
            tBlendProps = tProps.getaProp(#blend)
            if tBlendProps <> void() then
              if tBlendProps.count > 1 and tFrame <= tBlendProps.count then
                tBlend = tBlendProps.getAt(tFrame)
              end if
            end if
            tProps.setaProp(#counter, 0)
            tChanges = 1
          end if
        end if
      else
        tFrame = 1
        tFrameMem = 0
      end if
    end if
    tsprite = tProps.getaProp(#sprite)
    if tsprite <> void() then
      if tChanges or tForcedUpdate then
        tProps.setaProp(#direction, tdir)
        tdir = ((tdir + tDFix) mod 8)
        tMemName = pPeopleSize & "_" & tProps.getaProp(#member)
        tList = [tMemName & "_" & tdir & "_" & tFrameMem, tMemName & "_" & tdir & "_0", tMemName & "_0_" & tFrameMem, tMemName & "_0_0"]
        repeat while pSpriteList <= tloc
          tMemName = getAt(tloc, tdir)
          tMemNum = getmemnum(tMemName)
          if tMemNum > 0 then
            tsprite.castNum = tMemNum
            tsprite.skew = 0
            tsprite.rotation = 0
          else
            if tMemNum < 0 then
              tsprite.castNum = abs(tMemNum)
              tsprite.skew = 180
              tsprite.rotation = 180
            else
            end if
            if not voidp(tBlend) then
              tsprite.blend = tBlend
            end if
            if tFrame < tFrameTotal then
              tProps.setaProp(#frame, (tFrame + 1))
            else
              tProps.setaProp(#frame, 1)
            end if
            if listp(tXFix) then
              tXFix = tXFix.getAt((tdir + 1))
            end if
            if listp(tYFix) then
              tYFix = tYFix.getAt((tdir + 1))
            end if
            if (tXFactor = 32) then
              tSizeMultiplier = 0.5
            else
              tSizeMultiplier = 1
            end if
            tXFix = (tXFix * tSizeMultiplier)
            tYFix = (tYFix * tSizeMultiplier)
            if (tsprite.rotation = 0) then
              tsprite.loc = (tloc + point(tXFix, tYFix))
            else
              tsprite.loc = ((tloc + point(tXFactor, 0)) + point(tXFix, tYFix))
            end if
            tOffZ = tProps.getaProp(#offZ)
            if listp(tOffZ) then
              tOffZ = tOffZ.getAt((tdir + 1))
            end if
            tsprite.locZ = (tlocz + tOffZ)
          end if
        end repeat
      end if
    end if
  end repeat
end

on setLocation me, tloc, tlocz, tXFactor 
  repeat while pSpriteList <= tlocz
    tProps = getAt(tlocz, tloc)
    tsprite = tProps.getaProp(#sprite)
    if (tsprite.rotation = 0) then
      tsprite.loc = tloc
    else
      tsprite.loc = (tloc + point(tXFactor, 0))
    end if
    tsprite.locZ = (tlocz + tProps.getaProp(#offZ))
  end repeat
end

on setHumanSpriteProps me, tParam, tAvatarObj 
  if ilk(tAvatarObj.pSprite) <> #sprite then
    return FALSE
  end if
  i = 1
  repeat while i <= tParam.count
    tKey = tParam.getPropAt(i)
    tValue = tParam.getAt(i)
    if (tKey = #ink) then
      tAvatarObj.pSprite.ink = tValue
    else
      if (tKey = #bgColor) then
        tAvatarObj.pSprite.bgColor = rgb(tValue)
      else
        if (tKey = #foreColor) then
          tAvatarObj.pSprite.foreColor = rgb(tValue)
        else
          if (tKey = #righthandup) then
            tAvatarObj.pRightHandUp = 1
          else
            if (tKey = #lefthandup) then
              tAvatarObj.pLeftHandUp = 1
            end if
          end if
        end if
      end if
    end if
    i = (1 + i)
  end repeat
  return TRUE
end
