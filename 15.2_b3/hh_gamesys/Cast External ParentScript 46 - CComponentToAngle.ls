property m_componentToAngleArray

on construct me
  m_componentToAngleArray = [0, 0, 0, 1, 1, 1, 1, 2, 2, 2, 2, 2, 3, 3, 3, 3, 4, 4, 4, 4, 4, 5, 5, 5, 5, 6, 6, 6, 6, 6, 7, 7, 7, 7, 8, 8, 8, 8, 8, 9, 9, 9, 9, 10, 10, 10, 10, 10, 11, 11, 11, 11, 12, 12, 12, 12, 12, 13, 13, 13, 13, 13, 14, 14, 14, 14, 15, 15, 15, 15, 15, 16, 16, 16, 16, 16, 17, 17, 17, 17, 17, 18, 18, 18, 18, 18, 19, 19, 19, 19, 19, 20, 20, 20, 20, 20, 21, 21, 21, 21, 21, 22, 22, 22, 22, 22, 23, 23, 23, 23, 23, 24, 24, 24, 24, 24, 24, 25, 25, 25, 25, 25, 26, 26, 26, 26, 26, 26, 27, 27, 27, 27, 27, 28, 28, 28, 28, 28, 28, 29, 29, 29, 29, 29, 29, 30, 30, 30, 30, 30, 30, 31, 31, 31, 31, 31, 31, 32, 32, 32, 32, 32, 32, 33, 33, 33, 33, 33, 33, 34, 34, 34, 34, 34, 34, 34, 35, 35, 35, 35, 35, 35, 36, 36, 36, 36, 36, 36, 36, 37, 37, 37, 37, 37, 37, 37, 38, 38, 38, 38, 38, 38, 38, 39, 39, 39, 39, 39, 39, 39, 39, 40, 40, 40, 40, 40, 40, 40, 41, 41, 41, 41, 41, 41, 41, 41, 42, 42, 42, 42, 42, 42, 42, 42, 43, 43, 43, 43, 43, 43, 43, 43, 44, 44, 44, 44, 44, 44, 44, 44, 44, 45, 45, 45, 45, 45]
end

on getAngleFromComponents me, xComponent, yComponent
  if abs(xComponent) <= abs(yComponent) then
    if yComponent = 0 then
      yComponent = 1
    end if
    xComponent = xComponent * 256
    temp = integer(xComponent) / integer(yComponent)
    if temp < 0 then
      temp = -temp
    end if
    if temp > 255 then
      temp = 255
    end if
    if yComponent < 0 then
      if xComponent > 0 then
        return m_componentToAngleArray[temp + 1]
      else
        return 360 - m_componentToAngleArray[temp + 1]
      end if
    else
      if xComponent > 0 then
        return 180 - m_componentToAngleArray[temp + 1]
      else
        return 180 + m_componentToAngleArray[temp + 1]
      end if
    end if
  else
    if xComponent = 0 then
      xComponent = 1
    end if
    yComponent = yComponent * 256
    temp = integer(yComponent) / integer(xComponent)
    if temp < 0 then
      temp = -temp
    end if
    if temp > 255 then
      temp = 255
    end if
    if yComponent < 0 then
      if xComponent > 0 then
        return 90 - m_componentToAngleArray[temp + 1]
      else
        return 270 + m_componentToAngleArray[temp + 1]
      end if
    else
      if xComponent > 0 then
        return 90 + m_componentToAngleArray[temp + 1]
      else
        return 270 - m_componentToAngleArray[temp + 1]
      end if
    end if
  end if
end
