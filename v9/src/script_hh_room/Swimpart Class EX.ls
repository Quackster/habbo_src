property pAction, pPart, pDirection, pYFix, pXFix, pActionLh, pActionRh, pmodel, pLastLocFix, pMemString, pCacheRectA, pCacheImage, pDrawProps, pCacheRectB, pSwimProps, pAnimation, pAnimFrame, pTotalFrame

on deconsturct me 
  ancestor = void()
  return TRUE
end

on define me, tPart, tmodel, tColor, tDirection, tAction, tAncestor 
  ancestor = tAncestor
  pPart = tPart
  pmodel = tmodel
  pDrawProps = [#maskImage:0, #ink:0, #bgColor:0]
  pSwimProps = [#maskImage:0, #ink:0, #bgColor:rgb(0, 156, 156), #color:rgb(0, 156, 156), #blend:60]
  pCacheImage = 0
  pCacheRectA = rect(0, 0, 0, 0)
  pCacheRectB = rect(0, 0, 0, 0)
  me.defineInk()
  me.setColor(tColor)
  pDirection = tDirection
  pAction = tAction
  pActionLh = tAction
  pActionRh = tAction
  pMemString = ""
  pXFix = 0
  pYFix = 0
  pLastLocFix = point(1000, 1000)
  pAnimation = 0
  pAnimFrame = 1
  pTotalFrame = 1
  return TRUE
end

on update me 
  tAnimCounter = 0
  tAction = pAction
  tPart = pPart
  tdir = me.getProp(#pFlipList, (pDirection + 1))
  pXFix = 0
  pYFix = 0
  if me.pAnimating then
    tMemString = me.animate()
    tAncestorDir = me.pDirection
    if (me.pPeopleSize = "sh") then
      tSizeMultiplier = 0.7
    else
      tSizeMultiplier = 1
    end if
    if (tAncestorDir = 0) then
      pYFix = (pYFix + (pXFix / 2))
      pXFix = (pXFix / 2)
    else
      if (tAncestorDir = 1) then
        pYFix = (pYFix + pXFix)
        pXFix = 0
      else
        if (tAncestorDir = 2) then
          pYFix = (pYFix - (pXFix / 2))
          pXFix = (pXFix / 2)
        else
          if (tAncestorDir = 4) then
            pYFix = (pYFix + (pXFix / 2))
            pXFix = (-pXFix / 2)
          else
            if (tAncestorDir = 5) then
              pYFix = (pYFix - pXFix)
              pXFix = 0
            else
              if (tAncestorDir = 6) then
                pYFix = (pYFix - (pXFix / 2))
                pXFix = (-pXFix / 2)
              else
                if (tAncestorDir = 7) then
                  pXFix = -pXFix
                end if
              end if
            end if
          end if
        end if
      end if
    end if
    pXFix = (pXFix * tSizeMultiplier)
    pYFix = (pYFix * tSizeMultiplier)
  else
    if tAncestorDir <> "bd" then
      if tAncestorDir <> "lg" then
        if (tAncestorDir = "sh") then
          tUnderWater = 1
          if (pAction = "wlk") or (pAction = "swm") or (pAction = "sws") then
            tAnimCounter = me.pAnimCounter
          end if
        else
          if tAncestorDir <> "lh" then
            if (tAncestorDir = "ls") then
              tUnderWater = 1
              if (pDirection = tdir) then
                if not voidp(pActionLh) then
                  tAction = pActionLh
                end if
              else
                if not voidp(pActionRh) then
                  tAction = pActionRh
                end if
              end if
              if (tAction = "wlk") or (pAction = "swm") or (pAction = "sws") then
                tAnimCounter = me.pAnimCounter
              else
                if (tAction = "wav") then
                  tUnderWater = 0
                  tAnimCounter = (me.pAnimCounter mod 2)
                else
                  if ["crr", "drk", "ohd"].getPos(tAction) <> 0 then
                    pXFix = -40
                    tPart = "r" & pPart.getProp(#char, 2)
                    tdir = pDirection
                  end if
                end if
              end if
            else
              if tAncestorDir <> "rh" then
                if (tAncestorDir = "rs") then
                  tUnderWater = 1
                  if (pDirection = tdir) then
                    if not voidp(pActionRh) then
                      tAction = pActionRh
                    end if
                  else
                    if not voidp(pActionLh) then
                      tAction = pActionLh
                    end if
                  end if
                  if (tAction = "wlk") or (pAction = "swm") or (pAction = "sws") then
                    tAnimCounter = me.pAnimCounter
                  else
                    if (tAction = "wav") then
                      tUnderWater = 0
                      tAnimCounter = (me.pAnimCounter mod 2)
                      tPart = "l" & pPart.getProp(#char, 2)
                      tdir = pDirection
                    end if
                  end if
                else
                  if tAncestorDir <> "hd" then
                    if (tAncestorDir = "fc") then
                      tUnderWater = 0
                      if me.pTalking then
                        if (pAction = "lay") then
                          tAction = "lsp"
                        else
                          tAction = "spk"
                        end if
                        tAnimCounter = (me.pAnimCounter mod 2)
                      end if
                    else
                      if (tAncestorDir = "ey") then
                        tUnderWater = 0
                        if me.pTalking and pAction <> "lay" and ((me.pAnimCounter mod 2) = 0) then
                          pYFix = -1
                        end if
                      else
                        if (tAncestorDir = "hr") then
                          tUnderWater = 0
                          if me.pTalking and ((me.pAnimCounter mod 2) = 0) then
                            if pAction <> "lay" then
                              tAction = "spk"
                            end if
                          end if
                        else
                          if (tAncestorDir = "ri") then
                            if not me.pCarrying then
                              return()
                            end if
                            tAction = pActionRh
                            tdir = pDirection
                          else
                            if (tAncestorDir = "li") then
                              tAction = pActionLh
                              tdir = pDirection
                            else
                              tUnderWater = 1
                            end if
                          end if
                        end if
                      end if
                    end if
                    tMemString = me.pPeopleSize & "_" & tAction & "_" & tPart & "_" & pmodel & "_" & tdir & "_" & tAnimCounter
                    tLocFixChanged = pLastLocFix <> point(pXFix, pYFix)
                    pLastLocFix = point(pXFix, pYFix)
                    if pMemString <> tMemString or tLocFixChanged then
                      tMemNum = getmemnum(tMemString)
                      if tMemNum > 0 then
                        pMemString = tMemString
                        tmember = member(tMemNum)
                        tRegPnt = tmember.regPoint
                        tX = -tRegPnt.getAt(1)
                        tY = ((me.pBuffer.rect.height - tRegPnt.getAt(2)) - 10)
                        me.pUpdateRect = union(me.pUpdateRect, pCacheRectA)
                        pCacheImage = tmember.image
                        pCacheRectA = rect(tX, tY, (tX + pCacheImage.width), (tY + pCacheImage.height))
                        pCacheRectB = pCacheImage.rect
                        pDrawProps.setAt(#maskImage, pCacheImage.createMatte())
                        me.pUpdateRect = union(me.pUpdateRect, pCacheRectA)
                      else
                        return()
                      end if
                    end if
                    if (me.pMainAction = "swm") then
                      tRectMod = ((rect(14, 0, 14, 0) + rect(me.pLocFix, me.pLocFix)) + [pXFix, pYFix, pXFix, pYFix])
                    else
                      tRectMod = (rect(me.pLocFix, me.pLocFix) + [pXFix, pYFix, pXFix, pYFix])
                    end if
                    me.pBuffer.copyPixels(pCacheImage, (pCacheRectA + tRectMod), pCacheRectB, pDrawProps)
                    if tUnderWater and me.pSwim then
                      pSwimProps.setAt(#maskImage, pDrawProps.getAt(#maskImage))
                      me.pBuffer.copyPixels(pCacheImage, (pCacheRectA + tRectMod), pCacheRectB, pSwimProps)
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
end

on render me 
  if memberExists(pMemString) then
    me.pBuffer.copyPixels(pCacheRectB, pCacheRectA, pCacheRectB, pDrawProps)
    if me.pSwim then
      pSwimProps.setAt(#maskImage, pDrawProps.getAt(#maskImage))
      me.pBuffer.copyPixels(pCacheImage, ((pCacheRectA + [pXFix, pYFix, pXFix, pYFix]) + rect(me.pLocFix, me.pLocFix)), pCacheRectB, pSwimProps)
    end if
  end if
end

on setItemObj me, tmodel 
  if pPart <> "ri" and pPart <> "li" then
    return()
  end if
  pmodel = tmodel
end

on defineDir me, tdir, tPart 
  if voidp(tPart) or (tPart = pPart) then
    pDirection = tdir
  end if
end

on defineDirMultiple me, tdir, tTargetPartList 
  if (tTargetPartList.getPos(pPart) = 0) then
    return()
  end if
  pDirection = tdir
end

on defineAct me, tAct, tTargetPartList 
  if (pAction = "std") then
    pAction = tAct
  end if
end

on defineActMultiple me, tAct, tTargetPartList 
  if (tTargetPartList.getPos(pPart) = 0) then
    return()
  end if
  if (pAction = "std") then
    pAction = tAct
  end if
  if (pPart = "ey") and (tAct = "std") then
    pAction = "std"
  end if
end

on defineInk me, tInk 
  if voidp(tInk) then
    if (pPart = "ey") then
      tInk = 36
    else
      if (pPart = "sd") then
        tInk = 32
      else
        if (pPart = "ri") then
          tInk = 8
        else
          if (pPart = "li") then
            tInk = 8
          else
            tInk = 41
          end if
        end if
      end if
    end if
  end if
  pDrawProps.setAt(#ink, tInk)
  pSwimProps.setAt(#ink, tInk)
  return TRUE
end

on setModel me, tmodel 
  pmodel = tmodel
end

on setColor me, tColor 
  if voidp(tColor) then
    return FALSE
  end if
  if (tColor = "") then
    return FALSE
  end if
  if (tColor.ilk = #color) and pDrawProps.getAt(#ink) <> 36 then
    pDrawProps.setAt(#bgColor, tColor)
  else
    pDrawProps.setAt(#bgColor, rgb(255, 255, 255))
  end if
  return TRUE
end

on doHandWork me, tAct 
  if ["lh", "ls", "li", "rh", "rs", "ri"].getOne(pPart) <> 0 then
    pAction = tAct
  end if
end

on doHandWorkLeft me, tAct 
  pActionLh = tAct
end

on doHandWorkRight me, tAct 
  pActionRh = tAct
end

on layDown me 
  pAction = "lay"
end

on getCurrentMember me 
  return(pMemString)
end

on getColor me 
  return(pDrawProps.getAt(#bgColor))
end

on getDirection me 
  return(pDirection)
end

on getLocation me 
  if voidp(pMemString) then
    return FALSE
  end if
  tMemNum = getmemnum(pMemString)
  if (tMemNum = 0) then
    return FALSE
  end if
  tImgRect = member(tMemNum).rect
  tCenterPoint = point((tImgRect.width / 2), (tImgRect.height / 2))
  tRegPoint = member(tMemNum).regPoint
  return(((tRegPoint * -1) + tCenterPoint))
end

on copyPicture me, tImg, tdir, tHumanSize, tAction, tAnimFrame 
  if voidp(tdir) then
    tdir = "2"
  end if
  if voidp(tHumanSize) then
    tHumanSize = "h"
  end if
  if voidp(tAction) then
    tAction = "std"
  end if
  if voidp(tAnimFrame) then
    tAnimFrame = "0"
  end if
  tMemName = tHumanSize & "_" & tAction & "_" & pPart & "_" & pmodel & "_" & tdir & "_" & tAnimFrame
  tMemNum = getmemnum(tMemName)
  if (tMemNum = 0) then
    tmodel = "0" & pmodel.getProp(#char, 2, 3)
    tMemName = tHumanSize & "_" & tAction & "_" & pPart & "_" & tmodel & "_" & tdir & "_" & tAnimFrame
    tMemNum = getmemnum(tMemName)
    if (tMemNum = 0) then
      return FALSE
    end if
  end if
  tmember = member(tMemNum)
  tImage = tmember.image
  tRegPnt = tmember.regPoint
  tX = -tRegPnt.getAt(1)
  tY = ((tImg.rect.height - tRegPnt.getAt(2)) - 10)
  tRect = rect(tX, tY, (tX + tImage.width), (tY + tImage.height))
  tMatte = tImage.createMatte()
  tImg.copyPixels(tImage, tRect, tImage.rect, [#maskImage:tMatte, #ink:pDrawProps.getAt(#ink), #bgColor:pDrawProps.getAt(#bgColor)])
  return TRUE
end

on reset me, tSwimFlag 
  pAction = "std"
  pActionLh = void()
  pActionRh = void()
end

on setAnimation me, tPart, tAnim 
  if tPart <> pPart then
    return()
  end if
  pAnimation = value(tAnim)
  pTotalFrame = pAnimation.getAt(1).count
  pAnimFrame = 1
end

on remAnimation me 
  pAnimation = 0
  pAnimFrame = 1
  pTotalFrame = 1
end

on animate me 
  if not pAnimation then
    return("")
  end if
  tdir = (pDirection + pAnimation.getAt(#OffD).getAt(pAnimFrame))
  if tdir > 7 then
    tdir = (tdir - (tdir mod 7))
  else
    if tdir < 0 then
      tdir = ((7 + tdir) + 1)
    end if
  end if
  tdir = me.getProp(#pFlipList, (tdir + 1))
  pXFix = pAnimation.getAt(#OffX).getAt(pAnimFrame)
  pYFix = pAnimation.getAt(#OffY).getAt(pAnimFrame)
  tMemName = me.pPeopleSize & "_" & pAnimation.getAt(#act).getAt(pAnimFrame) & "_" & pPart & "_" & pmodel & "_" & tdir & "_" & pAnimation.getAt(#frm).getAt(pAnimFrame)
  pAnimFrame = (pAnimFrame + 1)
  if pAnimFrame > pTotalFrame then
    pAnimFrame = 1
  end if
  return(tMemName)
end
