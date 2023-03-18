on RGBtoHSL tRGB
  if tRGB.ilk = #color then
    tRGB = [tRGB.red, tRGB.green, tRGB.blue]
  end if
  tRGB = tRGB / 255.0
  tDiff = float(tRGB.max() - tRGB.min())
  if tDiff = 0 then
    tH = 0
  else
    if (tRGB.max() = tRGB[1]) and (tRGB[2] >= tRGB[3]) then
      tH = 60 * (tRGB[2] - tRGB[3]) / tDiff
    else
      if (tRGB.max() = tRGB[1]) and (tRGB[2] < tRGB[3]) then
        tH = (60 * (tRGB[2] - tRGB[3]) / tDiff) + 360
      else
        if tRGB.max() = tRGB[2] then
          tH = (60 * (tRGB[3] - tRGB[1]) / tDiff) + 120
        else
          if tRGB.max() = tRGB[3] then
            tH = (60 * (tRGB[1] - tRGB[2]) / tDiff) + 240
          end if
        end if
      end if
    end if
  end if
  tL = 0.5 * (tRGB.max() + tRGB.min())
  if tDiff = 0 then
    tS = 0
  else
    if tL <= 0.5 then
      tS = tDiff / tL * 0.5
    else
      if tL > 0.5 then
        tS = tDiff / (1 - tL) * 0.5
      end if
    end if
  end if
  tH = integer(tH / 360 * 255)
  tS = integer(tS * 255)
  tL = integer(tL * 255)
  return [tH, tS, tL]
end

on HSLtoRGB tHSL
  tHSL = tHSL / 255.0
  if tHSL[3] < 0.5 then
    tQ = tHSL[3] * (1 + tHSL[2])
  else
    tQ = tHSL[3] + tHSL[2] - (tHSL[3] * tHSL[2])
  end if
  tP = (2 * tHSL[3]) - tQ
  tTR = tHSL[1] + (1 / 3.0)
  tTG = tHSL[1]
  tTB = tHSL[1] - (1 / 3.0)
  if tTR < 0 then
    tTR = tTR + 1
  end if
  if tTG < 0 then
    tTG = tTG + 1
  end if
  if tTB < 0 then
    tTB = tTB + 1
  end if
  if tTR > 1 then
    tTR = tTR - 1
  end if
  if tTG > 1 then
    tTG = tTG - 1
  end if
  if tTB > 1 then
    tTB = tTB - 1
  end if
  if tTR < (1 / 6.0) then
    tR = tP + ((tQ - tP) * 6 * tTR)
  else
    if (tTR >= (1 / 6.0)) and (tTR < 0.5) then
      tR = tQ
    else
      if (tTR >= 0.5) and (tTR < (2 / 3.0)) then
        tR = tP + ((tQ - tP) * 6 * ((2 / 3.0) - tTR))
      else
        tR = tP
      end if
    end if
  end if
  if tTG < (1 / 6.0) then
    tG = tP + ((tQ - tP) * 6 * tTG)
  else
    if (tTG >= (1 / 6.0)) and (tTG < 0.5) then
      tG = tQ
    else
      if (tTG >= 0.5) and (tTG < (2 / 3.0)) then
        tG = tP + ((tQ - tP) * 6 * ((2 / 3.0) - tTG))
      else
        tG = tP
      end if
    end if
  end if
  if tTB < (1 / 6.0) then
    tB = tP + ((tQ - tP) * 6 * tTB)
  else
    if (tTB >= (1 / 6.0)) and (tTB < 0.5) then
      tB = tQ
    else
      if (tTB >= 0.5) and (tTB < (2 / 3.0)) then
        tB = tP + ((tQ - tP) * 6 * ((2 / 3.0) - tTB))
      else
        tB = tP
      end if
    end if
  end if
  tR = integer(tR * 255)
  tG = integer(tG * 255)
  tB = integer(tB * 255)
  return rgb(tR, tG, tB)
end
