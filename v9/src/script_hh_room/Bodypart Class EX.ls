on deconsturct(me)
  ancestor = void()
  return(1)
  exit
end

on define(me, tPart, tmodel, tColor, tDirection, tAction, tAncestor)
  ancestor = tAncestor
  pPart = tPart
  pmodel = tmodel
  pDrawProps = [#maskImage:0, #ink:0, #bgColor:0]
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
  pFlipH = 0
  pLastLocFix = point(1000, 1000)
  pAnimation = 0
  pAnimFrame = 1
  pTotalFrame = 1
  return(1)
  exit
end

on update(me)
  tAnimCntr = 0
  tAction = pAction
  tPart = pPart
  tdir = me.getProp(#pFlipList, pDirection + 1)
  pXFix = 0
  pYFix = 0
  if me.pAnimating and me.checkPartNotCarrying() then
    tMemString = me.animate()
    if me = 0 then
      pYFix = pYFix + pXFix / 2
      pXFix = pXFix / 2
    else
      if me = 1 then
        pYFix = pYFix + pXFix
        pXFix = 0
      else
        if me = 2 then
          pYFix = pYFix - pXFix / 2
          pXFix = pXFix / 2
        else
          if me = 4 then
            pYFix = pYFix + pXFix / 2
            pXFix = -pXFix / 2
          else
            if me = 5 then
              pYFix = pYFix - pXFix
              pXFix = 0
            else
              if me = 6 then
                pYFix = pYFix - pXFix / 2
                pXFix = -pXFix / 2
              else
                if me = 7 then
                  pXFix = -pXFix
                end if
              end if
            end if
          end if
        end if
      end if
    end if
    if me.pPeopleSize = "sh" then
      tSizeMultiplier = 0.7
    else
      tSizeMultiplier = 1
    end if
    pXFix = pXFix * tSizeMultiplier
    pYFix = pYFix * tSizeMultiplier
  else
    if me <> "bd" then
      if me <> "lg" then
        if me = "sh" then
          if pAction = "wlk" then
            tAnimCntr = me.pAnimCounter
          end if
        else
          if me <> "lh" then
            if me = "ls" then
              if pDirection = tdir then
                if not voidp(pActionLh) then
                  tAction = pActionLh
                end if
              else
                if not voidp(pActionRh) then
                  tAction = pActionRh
                end if
              end if
              if tAction = "wlk" then
                tAnimCntr = me.pAnimCounter
              else
                if tAction = "wav" then
                  tAnimCntr = me.pAnimCounter mod 2
                else
                  if ["crr", "drk", "ohd"].getPos(tAction) <> 0 then
                    if pDirection >= 4 then
                      pXFix = -40
                      tPart = "r" & pPart.getProp(#char, 2)
                    end if
                    tdir = pDirection
                  end if
                end if
              end if
            else
              if me <> "rh" then
                if me = "rs" then
                  if pDirection = tdir then
                    if not voidp(pActionRh) then
                      tAction = pActionRh
                    end if
                  else
                    if not voidp(pActionLh) then
                      tAction = pActionLh
                    end if
                  end if
                  if tAction = "wlk" then
                    tAnimCntr = me.pAnimCounter
                  else
                    if tAction = "wav" then
                      tAnimCntr = me.pAnimCounter mod 2
                      tPart = "l" & pPart.getProp(#char, 2)
                      tdir = pDirection
                    else
                      if tAction = "sig" then
                        tAnimCntr = 0
                        tPart = "l" & pPart.getProp(#char, 2)
                        tdir = pDirection
                        tAction = "wav"
                      end if
                    end if
                  end if
                else
                  if me <> "hd" then
                    if me = "fc" then
                      if me.pTalking then
                        if pAction = "lay" then
                          tAction = "lsp"
                        else
                          tAction = "spk"
                        end if
                        tAnimCntr = me.pAnimCounter mod 2
                      end if
                    else
                      if me = "ey" then
                        if me.pTalking and pAction <> "lay" and me.pAnimCounter mod 2 = 0 then
                          pYFix = -1
                        end if
                      else
                        if me = "hr" then
                          if me.pTalking and me.pAnimCounter mod 2 = 0 then
                            if pAction <> "lay" then
                              tAction = "spk"
                            end if
                          end if
                        else
                          if me = "ri" then
                            if not me.pCarrying then
                              pMemString = ""
                              if pCacheRectA.width > 0 then
                                me.pUpdateRect = union(me.pUpdateRect, pCacheRectA)
                                pCacheRectA = rect(0, 0, 0, 0)
                              end if
                              return()
                            else
                              tAction = pActionRh
                              tdir = pDirection
                            end if
                          else
                            if me = "li" then
                              tAction = pActionLh
                              tdir = pDirection
                            end if
                          end if
                        end if
                      end if
                    end if
                    tMemString = me.pPeopleSize & "_" & tAction & "_" & tPart & "_" & pmodel & "_" & tdir & "_" & tAnimCntr
                    pFlipH = 0
                    tLocFixChanged = pLastLocFix <> point(pXFix, pYFix)
                    pLastLocFix = point(pXFix, pYFix)
                    if pMemString <> tMemString or tLocFixChanged then
                      pMemString = tMemString
                      tMemNum = getmemnum(tMemString)
                      if tMemNum > 0 then
                        tmember = member(tMemNum)
                        tRegPnt = tmember.regPoint
                        tX = -tRegPnt.getAt(1)
                        tY = rect.height - tRegPnt.getAt(2) - 10
                        me.pUpdateRect = union(me.pUpdateRect, pCacheRectA)
                        pCacheImage = tmember.image
                        tLocFix = me.pLocFix
                        if pFlipH then
                          pCacheImage = me.flipHorizontal(pCacheImage)
                          tX = -tX - tmember.width + me.width
                          tLocFix = point(-me.getProp(#pLocFix, 1), me.getProp(#pLocFix, 2))
                          if me.pPeopleSize = "sh" then
                            tX = tX - 2
                          end if
                        end if
                        pCacheRectA = rect(tX, tY, tX + pCacheImage.width, tY + pCacheImage.height) + [pXFix, pYFix, pXFix, pYFix] + rect(tLocFix, tLocFix)
                        pCacheRectB = pCacheImage.rect
                        pDrawProps.setAt(#maskImage, pCacheImage.createMatte())
                        me.pUpdateRect = union(me.pUpdateRect, pCacheRectA)
                      else
                        me.pUpdateRect = union(me.pUpdateRect, pCacheRectA)
                        pCacheRectA = rect(0, 0, 0, 0)
                        return()
                      end if
                    end if
                    me.copyPixels(pCacheImage, pCacheRectA, pCacheRectB, pDrawProps)
                    exit
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

on render(me)
  if memberExists(pMemString) then
    me.copyPixels(pCacheRectB, pCacheRectA, pCacheRectB, pDrawProps)
  end if
  exit
end

on setItemObj(me, tmodel)
  if pPart = "ri" or pPart = "li" then
    pmodel = tmodel
  end if
  exit
end

on defineDir(me, tdir, tPart)
  if voidp(tPart) or tPart = pPart then
    pDirection = tdir
  end if
  exit
end

on defineDirMultiple(me, tdir, tTargetPartList)
  if tTargetPartList.getOne(pPart) then
    pDirection = tdir
  end if
  exit
end

on defineAct(me, tAct, tTargetPartList)
  if pAction = "std" then
    pAction = tAct
  end if
  exit
end

on defineActMultiple(me, tAct, tTargetPartList)
  if tTargetPartList.getOne(pPart) then
    if pAction = "std" then
      pAction = tAct
    end if
    if pPart = "ey" and tAct = "std" then
      pAction = "std"
    end if
  end if
  exit
end

on defineInk(me, tInk)
  if voidp(tInk) then
    if me = "ey" then
      tInk = 36
    else
      if me = "sd" then
        tInk = 32
      else
        if me = "ri" then
          tInk = 8
        else
          if me = "li" then
            tInk = 8
          else
            tInk = 41
          end if
        end if
      end if
    end if
  end if
  pDrawProps.setAt(#ink, tInk)
  return(1)
  exit
end

on setModel(me, tmodel)
  pmodel = tmodel
  exit
end

on setColor(me, tColor)
  if voidp(tColor) then
    return(0)
  end if
  if tColor = "" then
    return(0)
  end if
  if tColor.ilk = #color and pDrawProps.getAt(#ink) <> 36 then
    pDrawProps.setAt(#bgColor, tColor)
  else
    pDrawProps.setAt(#bgColor, rgb(255, 255, 255))
  end if
  return(1)
  exit
end

on checkPartNotCarrying(me)
  if not me.getProperty(#carrying) then
    return(1)
  end if
  if pDirection = me.getProp(#pFlipList, pDirection + 1) then
    tHandParts = ["rh", "rs", "ri"]
  else
    tHandParts = ["lh", "ls", "li", "ri"]
  end if
  if tHandParts.getPos(pPart) then
    return(0)
  else
    return(1)
  end if
  exit
end

on doHandWork(me, tAct)
  if ["lh", "ls", "li", "rh", "rs", "ri"].getOne(pPart) <> 0 then
    pAction = tAct
  end if
  exit
end

on doHandWorkLeft(me, tAct)
  pActionLh = tAct
  exit
end

on doHandWorkRight(me, tAct)
  pActionRh = tAct
  exit
end

on layDown(me)
  pAction = "lay"
  exit
end

on getCurrentMember(me)
  return(pMemString)
  exit
end

on getColor(me)
  return(pDrawProps.getAt(#bgColor))
  exit
end

on getDirection(me)
  return(pDirection)
  exit
end

on getLocation(me)
  if voidp(pMemString) then
    return(0)
  end if
  if not memberExists(pMemString) then
    return(0)
  end if
  tmember = member(getmemnum(pMemString))
  tImgRect = tmember.rect
  tCntrPoint = point(tImgRect.width / 2, tImgRect.height / 2)
  tRegPoint = tmember.regPoint
  return(-tRegPoint + tCntrPoint)
  exit
end

on copyPicture(me, tImg, tdir, tHumanSize, tAction, tAnimFrame)
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
  if memberExists(tMemName) then
    tmember = member(getmemnum(tMemName))
    tImage = tmember.image
    tRegPnt = tmember.regPoint
    tX = -tRegPnt.getAt(1)
    tY = rect.height - tRegPnt.getAt(2) - 10
    tRect = rect(tX, tY, tX + tImage.width, tY + tImage.height)
    tMatte = tImage.createMatte()
    tImg.copyPixels(tImage, tRect, tImage.rect, [#maskImage:tMatte, #ink:pDrawProps.getAt(#ink), #bgColor:pDrawProps.getAt(#bgColor)])
    return(1)
  end if
  return(0)
  exit
end

on reset(me)
  pAction = "std"
  pActionLh = void()
  pActionRh = void()
  exit
end

on skipAnimationFrame(me)
  pAnimFrame = pAnimFrame + 1
  if pAnimFrame > pTotalFrame then
    pAnimFrame = 1
  end if
  return(1)
  exit
end

on setAnimation(me, tPart, tAnim)
  if tPart <> pPart then
    return()
  end if
  pAnimation = value(tAnim)
  pTotalFrame = pAnimation.getAt(1).count
  pAnimFrame = 1
  exit
end

on remAnimation(me)
  pAnimation = 0
  pAnimFrame = 1
  pTotalFrame = 1
  exit
end

on animate(me)
  if pPart = "ri" then
    if pCacheRectA.width > 0 then
      me.pUpdateRect = union(me.pUpdateRect, pCacheRectA)
      pCacheRectA = rect(0, 0, 0, 0)
    end if
    return("")
  end if
  if not pAnimation then
    return("")
  end if
  tdir = pDirection + pAnimation.getAt(#OffD).getAt(pAnimFrame)
  if tdir > 7 then
    tdir = min(tdir - 8, 7)
  else
    if tdir < 0 then
      tdir = max(7 + tdir + 1, 0)
    end if
  end if
  if ["hd", "fc", "ey", "hr"].getOne(pPart) <> 0 then
    if tdir = 4 and pDirection = 3 or tdir = 0 and pDirection = 7 then
      pFlipH = 1
    else
      pFlipH = 0
    end if
  else
    pFlipH = 0
  end if
  tdir = me.getProp(#pFlipList, tdir + 1)
  pXFix = pAnimation.getAt(#OffX).getAt(pAnimFrame)
  pYFix = pAnimation.getAt(#OffY).getAt(pAnimFrame)
  tMemName = me.pPeopleSize & "_" & pAnimation.getAt(#act).getAt(pAnimFrame) & "_" & pPart & "_" & pmodel & "_" & tdir & "_" & pAnimation.getAt(#frm).getAt(pAnimFrame)
  pAnimFrame = pAnimFrame + 1
  if pAnimFrame > pTotalFrame then
    pAnimFrame = 1
  end if
  return(tMemName)
  exit
end

on flipHorizontal(me, tImg)
  tImage = image(tImg.width, tImg.height, tImg.depth)
  tQuad = [point(tImg.width, 0), point(0, 0), point(0, tImg.height), point(tImg.width, tImg.height)]
  tImage.copyPixels(tImg, tQuad, tImg.rect)
  return(tImage)
  exit
end