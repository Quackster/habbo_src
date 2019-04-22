on changePartData me, tmodel, tColor 
  if me.pPart = "bd" then
    return(1)
  end if
  return(me.changePartData(tmodel, tColor))
end

on defineActExplicit me, tAct, tTargetPartList 
  if tTargetPartList.getOne(me.pPart) then
    me.pAction = tAct
  end if
end

on update me 
  tAnimCntr = 0
  tAction = me.pAction
  tPart = me.pPart
  tdir = me.getProp(#pFlipList, me.pDirection + 1)
  if me.pPart <> "bd" then
    if me.pPart <> "lg" then
      if me.pPart = "sh" then
        if me.pAction = "wlk" then
          tAnimCntr = me.pAnimCounter
        end if
      else
        if me.pPart <> "lh" then
          if me.pPart = "ls" then
            if me.pDirection = tdir then
              if not voidp(me.pActionLh) then
                tAction = me.pActionLh
              end if
            else
              if not voidp(me.pActionRh) then
                tAction = me.pActionRh
              end if
            end if
            if tAction = "wlk" then
              tAnimCntr = me.pAnimCounter
            else
              if tAction = "wav" then
                tAnimCntr = me.pAnimCounter mod 2
              else
                if ["crr", "drk", "ohd"].getPos(tAction) <> 0 then
                  if me.pDirection >= 4 then
                    me.pXFix = -40
                    tPart = "r" & me.getProp(#char, 2)
                  end if
                  tdir = me.pDirection
                end if
              end if
            end if
          else
            if me.pPart <> "rh" then
              if me.pPart = "rs" then
                if me.pDirection = tdir then
                  if not voidp(me.pActionRh) then
                    tAction = me.pActionRh
                  end if
                else
                  if not voidp(me.pActionLh) then
                    tAction = me.pActionLh
                  end if
                end if
                if tAction = "wlk" then
                  tAnimCntr = me.pAnimCounter
                else
                  if tAction = "wav" then
                    tAnimCntr = me.pAnimCounter mod 2
                    tPart = "l" & me.getProp(#char, 2)
                    tdir = me.pDirection
                  else
                    if tAction = "sig" then
                      tAnimCntr = 0
                      tPart = "l" & me.getProp(#char, 2)
                      tdir = me.pDirection
                      tAction = "wav"
                    end if
                  end if
                end if
              else
                if me.pPart <> "hd" then
                  if me.pPart = "fc" then
                    if me.pTalking then
                      if me.pAction = "lay" then
                        tAction = "lsp"
                      else
                        tAction = "spk"
                      end if
                      tAnimCntr = me.pAnimCounter mod 2
                    end if
                  else
                    if me.pPart = "ey" then
                      if me.pTalking and me.pAction <> "lay" and me.pAnimCounter mod 2 = 0 then
                        me.pYFix = -1
                      end if
                    else
                      if me.pPart = "hr" then
                        if me.pTalking and me.pAnimCounter mod 2 = 0 then
                          if me.pAction <> "lay" then
                            tAction = "spk"
                          end if
                        end if
                      else
                        if me.pPart = "ri" then
                          if not me.pCarrying then
                            me.pMemString = ""
                            if me.width > 0 then
                              me.pUpdateRect = union(me.pUpdateRect, me.pCacheRectA)
                              me.pCacheRectA = rect(0, 0, 0, 0)
                            end if
                            return()
                          else
                            tAction = me.pActionRh
                            tdir = me.pDirection
                          end if
                        else
                          if me.pPart = "li" then
                            tAction = me.pActionLh
                            tdir = me.pDirection
                          end if
                        end if
                      end if
                    end if
                  end if
                  tMemString = me.pPeopleSize & "_" & tAction & "_" & tPart & "_" & me.pmodel & "_" & tdir & "_" & tAnimCntr
                  me.pFlipH = 0
                  tLocFixChanged = me.pLastLocFix <> point(me.pXFix, me.pYFix)
                  me.pLastLocFix = point(me.pXFix, me.pYFix)
                  if me.pMemString <> tMemString or tLocFixChanged then
                    me.pMemString = tMemString
                    tMemNum = getmemnum(tMemString)
                    if tMemNum > 0 then
                      tmember = member(tMemNum)
                      tRegPnt = tmember.regPoint
                      tX = -tRegPnt.getAt(1)
                      tY = undefined.height - tRegPnt.getAt(2) - 10
                      me.pUpdateRect = union(me.pUpdateRect, me.pCacheRectA)
                      me.pCacheImage = tmember.image
                      tLocFix = me.pLocFix
                      if me.pFlipH then
                        me.pCacheImage = me.flipHorizontal(me.pCacheImage)
                        tX = -tX - tmember.width + me.width
                        tLocFix = point(-me.getProp(#pLocFix, 1), me.getProp(#pLocFix, 2))
                        if me.pPeopleSize = "sh" then
                          tX = tX - 2
                        end if
                      end if
                      me.pCacheRectA = rect(tX, tY, tX + me.width, tY + me.height) + [me.pXFix, me.pYFix, me.pXFix, me.pYFix] + rect(tLocFix, tLocFix)
                      me.pCacheRectB = me.rect
                      me.setProp(#pDrawProps, #maskImage, me.createMatte())
                      me.pUpdateRect = union(me.pUpdateRect, me.pCacheRectA)
                    else
                      me.pUpdateRect = union(me.pUpdateRect, me.pCacheRectA)
                      me.pCacheRectA = rect(0, 0, 0, 0)
                      return()
                    end if
                  end if
                  me.pXFix = 0
                  me.pYFix = 0
                  me.copyPixels(me.pCacheImage, me.pCacheRectA, me.pCacheRectB, me.pDrawProps)
                end if
              end if
            end if
          end if
        end if
      end if
    end if
  end if
end
