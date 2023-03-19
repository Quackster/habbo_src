property pProps, pSizeParams, pAddedBodyParts, pAddedBodyPartIndex, pAddedBodyPartActionList, pExcludedBodyPartIndex, pShadowName, pDirOffset, pSpriteList, pFrame, pFrameTotal, pXFactor, pPeopleSize

on construct me
  pAddedBodyParts = [:]
  pAddedBodyPartIndex = []
  pAddedBodyPartActionList = [:]
  pExcludedBodyPartIndex = []
  pSizeParams = [0, 0]
  pFrame = 0
  pDirOffset = 0
  pSpriteList = [:]
  return 1
end

on deconstruct me
  pAddedBodyParts = [:]
  pAddedBodyPartIndex = []
  pAddedBodyPartActionList = [:]
  pExcludedBodyPartIndex = []
  repeat with tProps in pSpriteList
    tsprite = tProps.getaProp(#sprite)
    releaseSprite(tsprite.spriteNum)
  end repeat
  pSpriteList = [:]
  return 1
end

on define me, tID, tText, tAvatarObj
  if tAvatarObj = 0 then
    return 0
  end if
  pXFactor = tAvatarObj.pXFactor
  pPeopleSize = tAvatarObj.pPeopleSize
  pFrameTotal = 1
  tTempDelim = the itemDelimiter
  the itemDelimiter = "/"
  pProps = [:]
  repeat with i = 1 to tText.line.count
    tLine = tText.line[i]
    if (tLine.char[1] <> "#") and (tLine contains "/") then
      tKey = symbol(tLine.item[1])
      tValue = tLine.item[2]
      tValue = value(tValue)
      case tKey of
        #sprite:
          tSpriteNum = reserveSprite(tAvatarObj.getID())
          if tSpriteNum > 0 then
            tValue.setaProp(#sprite, sprite(tSpriteNum))
            pProps.addProp(tKey, tValue)
            tValue.setaProp(#direction, -1)
          end if
        symbol(pPeopleSize & "_size"):
          pSizeParams = tValue
        #exclude_bodypart:
          pExcludedBodyPartIndex.add(tValue)
        otherwise:
          pProps.addProp(tKey, tValue)
      end case
    end if
  end repeat
  the itemDelimiter = tTempDelim
  repeat with i = 1 to pProps.count
    ttype = pProps.getPropAt(i)
    tParam = pProps[i]
    case ttype of
      #add_bodypart:
        me.addBodyPart(tParam, tAvatarObj)
      #sprite:
        me.addSprite(tParam, tAvatarObj)
      #human_sprite_props:
        me.setHumanSpriteProps(tParam, tAvatarObj)
      #shadow:
        pShadowName = tParam
      #OffD:
        pDirOffset = integer(tParam)
    end case
  end repeat
  me.updateSprites(tAvatarObj, 1)
  return 1
end

on getEffectDirOffset me
  return pDirOffset
end

on getEffectSizeParams me
  return pSizeParams
end

on getEffectShadowName me
  return pShadowName
end

on getAddedBodyPartIndex me
  return pAddedBodyPartIndex
end

on getExcludedBodyPartIndex me
  return pExcludedBodyPartIndex
end

on getEffectBodyPartModel me, tPart
  tPartInfo = pAddedBodyParts.getaProp(tPart)
  if tPartInfo = 0 then
    return 0
  end if
  if tPartInfo.getaProp("model") = 0 then
    tPartInfo.setaProp("model", "1")
  end if
  if tPartInfo.getaProp("color") = 0 then
    tPartInfo.setaProp("color", rgb(0, 0, 0))
    tPartInfo.setaProp("color", rgb(255, 255, 255))
  end if
  if tPartInfo.getaProp("setid") = 0 then
    tPartInfo.setaProp("setid", "1")
  end if
  if tPartInfo.getaProp("colorid") = 0 then
    tPartInfo.setaProp("colorid", "1")
  end if
  return tPartInfo
end

on getEffectBodyPartAction me, tPart
  tAction = pAddedBodyPartActionList.getaProp(tPart)
  if tAction = VOID then
    return "std"
  else
    return tAction
  end if
end

on changesBodyparts me
  return me.excludesBodyparts() or me.addsBodyparts()
end

on addsBodyparts me
  return me.pAddedBodyPartIndex.count > 0
end

on excludesBodyparts me
  return me.pExcludedBodyPartIndex.count > 0
end

on alignEffectBodyparts me, tPartDefinition, tDirection
  repeat with i = 1 to pAddedBodyParts.count
    tID = pAddedBodyParts.getPropAt(i)
    tProps = pAddedBodyParts[i]
    if tPartDefinition.findPos(tID) = 0 then
      tAlignmentDef = tProps.getaProp(#align)
      tAlignment = #top
      if symbolp(tAlignmentDef) then
        tAlignment = tAlignmentDef
      else
        if listp(tAlignmentDef) then
          if tAlignmentDef.count >= (tDirection + 1) then
            tAlignment = tAlignmentDef[tDirection + 1]
          end if
        end if
      end if
      case tAlignment of
        #bottom:
          tPartDefinition.addAt(1, tID)
        otherwise:
          tPartDefinition.append(tID)
      end case
    end if
  end repeat
  return tPartDefinition
end

on hasSprites me
  return pSpriteList.count > 0
end

on getEffectSpriteProps me
  return pSpriteList
end

on updateSprites me, tAvatarObj, tForcedUpdate
  if tAvatarObj = 0 then
    return 0
  end if
  me.setMember(tAvatarObj.getProperty(#direction), tAvatarObj.pSprite.loc, tAvatarObj.pSprite.locZ, tAvatarObj.pXFactor, tForcedUpdate)
  return 1
end

on setAnimation me, tPart, tAnim
  if tPart = "all" then
    repeat with tProps in pSpriteList
      repeat with i = 1 to tAnim.count
        tProps.setaProp(tAnim.getPropAt(i), tAnim[i])
      end repeat
      tProps.setaProp(#counter, 0)
    end repeat
  else
    if pSpriteList.findPos(tPart) = 0 then
      return 0
    end if
    tProps = pSpriteList.getaProp(tPart)
    repeat with i = 1 to tAnim.count
      tProps.setaProp(tAnim.getPropAt(i), tAnim[i])
    end repeat
    tProps.setaProp(#counter, 0)
  end if
end

on addBodyPart me, tParam
  tID = tParam.getaProp(#id)
  if pAddedBodyPartIndex.findPos(tID) = 0 then
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
  return 1
end

on addSprite me, tParam, tAvatarObj
  tID = symbol(tParam.getaProp(#id))
  tsprite = tParam.getaProp(#sprite)
  if pSpriteList.findPos(tID) = 0 then
    if tParam.findPos(#offZ) = 0 then
      tParam.setaProp(#offZ, 1)
    end if
    tParam.setaProp(#sprite, tsprite)
    if tParam.findPos(#ink) > 0 then
      tsprite.ink = integer(tParam.getaProp(#ink))
    end if
    tParam.setaProp(#frame, 0)
    pSpriteList.setaProp(tID, tParam)
  end if
  return 1
end

on setMember me, tdir, tloc, tlocz, tXFactor, tForcedUpdate
  repeat with tProps in pSpriteList
    tXFix = 0
    tYFix = 0
    tDFix = 0
    tChanges = 0
    if not tForcedUpdate then
      if tdir <> tProps.getaProp(#direction) then
        tChanges = 1
      end if
      tFrames = tProps.getaProp(#frm)
      if tFrames <> VOID then
        tFrameTotal = tFrames.count
        if tFrameTotal > 1 then
          tFrameSkipTotal = tProps.getaProp(#skip)
          if tFrameSkipTotal = VOID then
            tFrameSkipTotal = 1
          end if
          tSkipCounter = tProps.getaProp(#counter)
          if tSkipCounter < (tFrameSkipTotal - 1) then
            tProps.setaProp(#counter, tSkipCounter + 1)
          else
            tFrame = tProps.getaProp(#frame)
            tFrameMem = tFrames[tFrame]
            tXFixes = tProps.getaProp(#OffX)
            if tXFixes <> VOID then
              if tXFixes.count < tFrame then
                tXFix = tXFixes[1]
              else
                tXFix = tXFixes[tFrame]
              end if
            end if
            tYFixes = tProps.getaProp(#OffY)
            if tYFixes <> VOID then
              if tYFixes.count < tFrame then
                tYFix = tYFixes[1]
              else
                tYFix = tYFixes[tFrame]
              end if
            end if
            tDFixes = tProps.getaProp(#OffD)
            if tDFixes <> VOID then
              if tDFixes.count < tFrame then
                tDFix = tDFixes[1]
              else
                tDFix = tDFixes[tFrame]
              end if
            end if
            tBlend = VOID
            tBlendProps = tProps.getaProp(#blend)
            if tBlendProps <> VOID then
              if (tBlendProps.count > 1) and (tFrame <= tBlendProps.count) then
                tBlend = tBlendProps[tFrame]
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
    if tsprite <> VOID then
      if tChanges or tForcedUpdate then
        tProps.setaProp(#direction, tdir)
        tdir = (tdir + tDFix) mod 8
        tMemName = pPeopleSize & "_" & tProps.getaProp(#member)
        tList = [tMemName & "_" & tdir & "_" & tFrameMem, tMemName & "_" & tdir & "_0", tMemName & "_0_" & tFrameMem, tMemName & "_0_0"]
        repeat with tMemName in tList
          tMemNum = getmemnum(tMemName)
          if tMemNum > 0 then
            tsprite.castNum = tMemNum
            tsprite.skew = 0
            tsprite.rotation = 0
            exit repeat
            next repeat
          end if
          if tMemNum < 0 then
            tsprite.castNum = abs(tMemNum)
            tsprite.skew = 180
            tsprite.rotation = 180
            exit repeat
          end if
        end repeat
        if not voidp(tBlend) then
          tsprite.blend = tBlend
        end if
        if tFrame < tFrameTotal then
          tProps.setaProp(#frame, tFrame + 1)
        else
          tProps.setaProp(#frame, 1)
        end if
      end if
      if listp(tXFix) then
        tXFix = tXFix[tdir + 1]
      end if
      if listp(tYFix) then
        tYFix = tYFix[tdir + 1]
      end if
      if tXFactor = 32 then
        tSizeMultiplier = 0.5
      else
        tSizeMultiplier = 1
      end if
      tXFix = tXFix * tSizeMultiplier
      tYFix = tYFix * tSizeMultiplier
      if tsprite.rotation = 0 then
        tsprite.loc = tloc + point(tXFix, tYFix)
      else
        tsprite.loc = tloc + point(tXFactor, 0) + point(tXFix, tYFix)
      end if
      tOffZ = tProps.getaProp(#offZ)
      if listp(tOffZ) then
        tOffZ = tOffZ[tdir + 1]
      end if
      tsprite.locZ = tlocz + tOffZ
    end if
  end repeat
end

on setLocation me, tloc, tlocz, tXFactor
  repeat with tProps in pSpriteList
    tsprite = tProps.getaProp(#sprite)
    if tsprite.rotation = 0 then
      tsprite.loc = tloc
    else
      tsprite.loc = tloc + point(tXFactor, 0)
    end if
    tsprite.locZ = tlocz + tProps.getaProp(#offZ)
  end repeat
end

on setHumanSpriteProps me, tParam, tAvatarObj
  if ilk(tAvatarObj.pSprite) <> #sprite then
    return 0
  end if
  repeat with i = 1 to tParam.count
    tKey = tParam.getPropAt(i)
    tValue = tParam[i]
    case tKey of
      #ink:
        tAvatarObj.pSprite.ink = tValue
      #bgColor:
        tAvatarObj.pSprite.bgColor = rgb(tValue)
      #foreColor:
        tAvatarObj.pSprite.foreColor = rgb(tValue)
      #righthandup:
        tAvatarObj.pRightHandUp = 1
      #lefthandup:
        tAvatarObj.pLeftHandUp = 1
    end case
  end repeat
  return 1
end
