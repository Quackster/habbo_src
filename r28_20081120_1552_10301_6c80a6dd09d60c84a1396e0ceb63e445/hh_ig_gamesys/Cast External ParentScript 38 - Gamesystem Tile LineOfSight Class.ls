on construct me
  return 1
end

on deconstruct me
  return 1
end

on testForLineOfSight me, tLineOfSightTester, tX1, tY1, tX2, tY2, tBlockingLevel, tExcludeFirst, tExcludeLast
  tDeltaX = tX2 - tX1
  tDeltaY = tY2 - tY1
  tDump = 0
  if tDump then
    put "* X1/Y1:" && tX1 && tY1 && "X2/Y2:" && tX2 && tY2 && "* tDeltaX" && tDeltaX && "* tDeltaY" && tDeltaY
  end if
  if tDeltaX = 0 then
    if tDump then
      put "* 1"
    end if
    if tDeltaY = 0 then
      if tExcludeFirst or tExcludeLast then
        return 1
      end if
      return tLineOfSightTester.isBlockingLineOfSight(tX1, tY1, tBlockingLevel)
    end if
    if tDeltaY > 0 then
      if tDump then
        put "* 1b"
      end if
      tYFirst = tY1
      if tExcludeLast then
        tYLast = tY2 - 1
      else
        tYLast = tY2
      end if
      repeat with tY = tYFirst to tYLast
        if tExcludeFirst then
          tExcludeFirst = 0
          next repeat
        end if
        if tLineOfSightTester.isBlockingLineOfSight(tX1, tY, tBlockingLevel) then
          return 0
        end if
      end repeat
    else
      if tDump then
        put "* 1c"
      end if
      tYFirst = tY1
      if tExcludeLast then
        tYLast = tY2 + 1
      else
        tYLast = tY2
      end if
      repeat with tY = tYFirst down to tYLast
        if tExcludeFirst then
          tExcludeFirst = 0
          next repeat
        end if
        if tLineOfSightTester.isBlockingLineOfSight(tX1, tY, tBlockingLevel) then
          return 0
        end if
      end repeat
    end if
  else
    if tDeltaY = 0 then
      if tDump then
        put "* 2"
      end if
      if tDeltaX > 0 then
        if tDump then
          put "* 2a"
        end if
        tXFirst = tX1
        if tExcludeLast then
          tXLast = tX2 - 1
        else
          tXLast = tX2
        end if
        repeat with tX = tXFirst to tXLast
          if tExcludeFirst then
            tExcludeFirst = 0
            next repeat
          end if
          if tLineOfSightTester.isBlockingLineOfSight(tX, tY1, tBlockingLevel) then
            return 0
          end if
        end repeat
      else
        if tDump then
          put "* 2b"
        end if
        tXFirst = tX1
        if tExcludeLast then
          tXLast = tX2 + 1
        else
          tXLast = tX2
        end if
        repeat with tX = tXFirst down to tXLast
          if tExcludeFirst then
            tExcludeFirst = 0
            next repeat
          end if
          if tDump then
            put "* isBlockingLineOfSight result" && tX && tY1 && tLineOfSightTester.isBlockingLineOfSight(tX, tY1, tBlockingLevel)
          end if
          if tLineOfSightTester.isBlockingLineOfSight(tX, tY1, tBlockingLevel) then
            return 0
          end if
        end repeat
      end if
    else
      if tDeltaX > 0 then
        if tDump then
          put "* 3"
        end if
        if tDeltaY > 0 then
          if tDeltaX > tDeltaY then
            if tDump then
              put "* 3a"
            end if
            tY = tY1
            tD = (tDeltaY * 4) - tDeltaX
            tXFirst = tX1
            if tExcludeLast then
              tXLast = tX2 - 1
            else
              tXLast = tX2
            end if
            repeat with tX = tXFirst to tXLast
              if tExcludeFirst then
                tExcludeFirst = 0
              else
                if tLineOfSightTester.isBlockingLineOfSight(tX, tY, tBlockingLevel) then
                  return 0
                end if
              end if
              if tD < 0 then
                tD = tD + (tDeltaY * 4)
                next repeat
              end if
              tD = tD + ((tDeltaY - tDeltaX) * 4)
              tY = tY + 1
            end repeat
          else
            if tDump then
              put "* 3b"
            end if
            tX = tX1
            tD = (tDeltaX * 4) - tDeltaY
            tYFirst = tY1
            if tExcludeLast then
              tYLast = tY2 - 1
            else
              tYLast = tY2
            end if
            repeat with tY = tYFirst to tYLast
              if tExcludeFirst then
                tExcludeFirst = 0
              else
                if tDump then
                  put "* testing" && tX && tY
                end if
                if tLineOfSightTester.isBlockingLineOfSight(tX, tY, tBlockingLevel) then
                  return 0
                end if
              end if
              if tD < 0 then
                tD = tD + (tDeltaX * 4)
                next repeat
              end if
              tD = tD + ((tDeltaX - tDeltaY) * 4)
              tX = tX + 1
            end repeat
          end if
        else
          tDeltaY = -tDeltaY
          if tDeltaX > tDeltaY then
            if tDump then
              put "* 3c"
            end if
            tY = tY1
            tD = (tDeltaY * 4) - tDeltaX
            tXFirst = tX1
            if tExcludeLast then
              tXLast = tX2 - 1
            else
              tXLast = tX2
            end if
            repeat with tX = tXFirst to tXLast
              if tExcludeFirst then
                tExcludeFirst = 0
              else
                if tLineOfSightTester.isBlockingLineOfSight(tX, tY, tBlockingLevel) then
                  return 0
                end if
              end if
              if tD < 0 then
                tD = tD + (tDeltaY * 4)
                next repeat
              end if
              tD = tD + ((tDeltaY - tDeltaX) * 4)
              tY = tY - 1
            end repeat
          else
            if tDump then
              put "* 3d"
            end if
            tX = tX1
            tD = (tDeltaX * 4) - tDeltaY
            tYFirst = tY1
            if tExcludeLast then
              tYLast = tY2 + 1
            else
              tYLast = tY2
            end if
            repeat with tY = tYFirst down to tYLast
              if tExcludeFirst then
                tExcludeFirst = 0
              else
                if tLineOfSightTester.isBlockingLineOfSight(tX, tY, tBlockingLevel) then
                  return 0
                end if
              end if
              if tD < 0 then
                tD = tD + (tDeltaX * 4)
                next repeat
              end if
              tD = tD + ((tDeltaX - tDeltaY) * 4)
              tX = tX + 1
            end repeat
          end if
        end if
      else
        if tDump then
          put "* 4"
        end if
        tDeltaX = -tDeltaX
        if tDeltaY > 0 then
          if tDeltaX > tDeltaY then
            if tDump then
              put "* 4a"
            end if
            tY = tY1
            tD = (tDeltaY * 4) - tDeltaX
            tXFirst = tX1
            if tExcludeLast then
              tXLast = tX2 + 1
            else
              tXLast = tX2
            end if
            repeat with tX = tXFirst down to tXLast
              if tExcludeFirst then
                tExcludeFirst = 0
              else
                if tLineOfSightTester.isBlockingLineOfSight(tX, tY, tBlockingLevel) then
                  return 0
                end if
              end if
              if tD < 0 then
                tD = tD + (tDeltaY * 4)
                next repeat
              end if
              tD = tD + ((tDeltaY - tDeltaX) * 4)
              tY = tY + 1
            end repeat
          else
            if tDump then
              put "* 4b"
            end if
            tX = tX1
            tD = (tDeltaX * 4) - tDeltaY
            tYFirst = tY1
            if tExcludeLast then
              tYLast = tY2 - 1
            else
              tYLast = tY2
            end if
            repeat with tY = tYFirst to tYLast
              if tExcludeFirst then
                tExcludeFirst = 0
              else
                if tLineOfSightTester.isBlockingLineOfSight(tX, tY, tBlockingLevel) then
                  return 0
                end if
              end if
              if tD < 0 then
                tD = tD + (tDeltaX * 4)
                next repeat
              end if
              tD = tD + ((tDeltaX - tDeltaY) * 4)
              tX = tX - 1
            end repeat
          end if
        else
          tDeltaY = -tDeltaY
          if tDeltaX > tDeltaY then
            if tDump then
              put "* 4c"
            end if
            tY = tY1
            tD = (tDeltaY * 4) - tDeltaX
            tXFirst = tX1
            if tExcludeLast then
              tXLast = tX2 + 1
            else
              tXLast = tX2
            end if
            if tDump then
              put "* tXFirst:" && tXFirst && "tXLast:" && tXLast
            end if
            repeat with tX = tXFirst down to tXLast
              if tExcludeFirst then
                tExcludeFirst = 0
              else
                if tLineOfSightTester.isBlockingLineOfSight(tX, tY, tBlockingLevel) then
                  return 0
                end if
              end if
              if tD < 0 then
                tD = tD + (tDeltaY * 4)
                next repeat
              end if
              tD = tD + ((tDeltaY - tDeltaX) * 4)
              tY = tY - 1
            end repeat
          else
            if tDump then
              put "* 4d"
            end if
            tX = tX1
            tD = (tDeltaX * 4) - tDeltaY
            tYFirst = tY1
            if tExcludeLast then
              tYLast = tY2 + 1
            else
              tYLast = tY2
            end if
            repeat with tY = tYFirst down to tYLast
              if tExcludeFirst then
                tExcludeFirst = 0
              else
                if tLineOfSightTester.isBlockingLineOfSight(tX, tY, tBlockingLevel) then
                  return 0
                end if
              end if
              if tD < 0 then
                tD = tD + (tDeltaY * 4)
                next repeat
              end if
              tD = tD + ((tDeltaX - tDeltaY) * 4)
              tX = tX - 1
            end repeat
          end if
        end if
      end if
    end if
  end if
  return 1
end
