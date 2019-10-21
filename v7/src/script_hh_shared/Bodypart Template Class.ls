property pAction, pPart, pDirection, pActionLh, pActionRh, pmodel, pMemString, pCacheRectA, pCacheImage, pXFix, pYFix, pDrawProps, pCacheRectB

on deconsturct me 
  ancestor = void()
  return TRUE
end

on define me, tPart, tmodel, tColor, tDirection, tAction, tAncestor 
  ancestor = tAncestor
  pPart = tPart
  pmodel = tmodel
  pDrawProps = [#maskImage:0, #ink:0, #bgColor:0]
  pCacheImage = 0
  pCacheRectA = rect(0, 0, 0, 0)
  pCacheRectB = rect(0, 0, 0, 0)
  defineInk(me)
  setColor(me, tColor)
  pDirection = tDirection
  pAction = tAction
  pActionLh = tAction
  pActionRh = tAction
  pMemString = ""
  pXFix = 0
  pYFix = 0
  return TRUE
end

on update me 
  tAnimCounter = 0
  tAction = pAction
  tPart = pPart
  tdir = me.getProp(#pFlipList, (pDirection + 1))
  pXFix = 0
  pYFix = 0
  if pPart <> "bd" then
    if pPart <> "lg" then
      if (pPart = "sh") then
        if (pAction = "wlk") then
          tAnimCounter = me.pAnimCounter
        end if
      else
        if pPart <> "lh" then
          if (pPart = "ls") then
            if (pDirection = tdir) then
              if not voidp(pActionLh) then
                tAction = pActionLh
              end if
            else
              if not voidp(pActionRh) then
                tAction = pActionRh
              end if
            end if
            if (tAction = "wlk") then
              tAnimCounter = me.pAnimCounter
            else
              if (tAction = "wav") then
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
            if pPart <> "rh" then
              if (pPart = "rs") then
                if (pDirection = tdir) then
                  if not voidp(pActionRh) then
                    tAction = pActionRh
                  end if
                else
                  if not voidp(pActionLh) then
                    tAction = pActionLh
                  end if
                end if
                if (tAction = "wlk") then
                  tAnimCounter = me.pAnimCounter
                else
                  if (tAction = "wav") then
                    tAnimCounter = (me.pAnimCounter mod 2)
                    tPart = "l" & pPart.getProp(#char, 2)
                    tdir = pDirection
                  else
                    if (tAction = "sig") then
                      tAnimCounter = 0
                      tPart = "l" & pPart.getProp(#char, 2)
                      tdir = pDirection
                      tAction = "wav"
                    end if
                  end if
                end if
              else
                if pPart <> "hd" then
                  if (pPart = "fc") then
                    if me.pTalking then
                      if (pAction = "lay") then
                        tAction = "lsp"
                      else
                        tAction = "spk"
                      end if
                      tAnimCounter = (me.pAnimCounter mod 2)
                    end if
                  else
                    if (pPart = "ey") then
                      if me.pTalking and pAction <> "lay" and ((me.pAnimCounter mod 2) = 0) then
                        pYFix = -1
                      end if
                    else
                      if (pPart = "hr") then
                        if me.pTalking and ((me.pAnimCounter mod 2) = 0) then
                          if pAction <> "lay" then
                            tAction = "spk"
                          end if
                        end if
                      else
                        if (pPart = "ri") then
                          if not me.pCarrying then
                            return()
                          end if
                          tAction = pActionRh
                          tdir = pDirection
                        else
                          if (pPart = "li") then
                            tAction = pActionLh
                            tdir = pDirection
                          end if
                        end if
                      end if
                    end if
                  end if
                  tMemString = me.pPeopleSize & "_" & tAction & "_" & tPart & "_" & pmodel & "_" & tdir & "_" & tAnimCounter
                  if pMemString <> tMemString then
                    tMemNum = getmemnum(tMemString)
                    if tMemNum > 0 then
                      pMemString = tMemString
                      tmember = member(tMemNum)
                      tRegPnt = tmember.regPoint
                      tX = -tRegPnt.getAt(1)
                      tY = ((me.pBuffer.rect.height - tRegPnt.getAt(2)) - 10)
                      me.pUpdateRect = union(me.pUpdateRect, pCacheRectA)
                      pCacheImage = tmember.image
                      pCacheRectA = ((rect(tX, tY, (tX + pCacheImage.width), (tY + pCacheImage.height)) + [pXFix, pYFix, pXFix, pYFix]) + rect(me.pLocFix, me.pLocFix))
                      pCacheRectB = pCacheImage.rect
                      pDrawProps.setAt(#maskImage, pCacheImage.createMatte())
                      me.pUpdateRect = union(me.pUpdateRect, pCacheRectA)
                    else
                      return()
                    end if
                  end if
                  me.pBuffer.copyPixels(pCacheImage, pCacheRectA, pCacheRectB, pDrawProps)
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
  end if
end

on setItemObj me, tmodel 
  if (pPart = "ri") or (pPart = "li") then
    pmodel = tmodel
  end if
end

on defineDir me, tdir, tPart 
  if voidp(tPart) or (tPart = pPart) then
    pDirection = tdir
  end if
end

on defineDirMultiple me, tdir, tTargetPartList 
  if tTargetPartList.getOne(pPart) then
    pDirection = tdir
  end if
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
  return TRUE
end

on setModel me, tmodel 
  pmodel = tmodel
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
  if not memberExists(pMemString) then
    return FALSE
  end if
  tmember = member(getmemnum(pMemString))
  tImgRect = tmember.rect
  tCntrPoint = point((tImgRect.width / 2), (tImgRect.height / 2))
  tRegPoint = tmember.regPoint
  return(((tRegPoint * -1) + tCntrPoint))
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
  if memberExists(tMemName) then
    tmember = member(getmemnum(tMemName))
    tImage = tmember.image
    tRegPnt = tmember.regPoint
    tX = -tRegPnt.getAt(1)
    tY = ((tImg.rect.height - tRegPnt.getAt(2)) - 10)
    tRect = rect(tX, tY, (tX + tImage.width), (tY + tImage.height))
    tMatte = tImage.createMatte()
    tImg.copyPixels(tImage, tRect, tImage.rect, [#maskImage:tMatte, #ink:pDrawProps.getAt(#ink), #bgColor:pDrawProps.getAt(#bgColor)])
    return TRUE
  end if
  return FALSE
end

on reset me 
  pAction = "std"
  pActionLh = void()
  pActionRh = void()
end
