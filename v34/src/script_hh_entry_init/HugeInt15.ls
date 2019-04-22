on new(me)
  if the traceScript then
    return(0)
  end if
  the traceScript = 0
  _player.traceScript = 0
  _player.traceScript = 0
  pData_NxIhNARqldyJyY2PfT03dK8t9OLUR = []
  pNegative = 0
  pBase = 10000
  pDigits = string(pBase).length - 1
  pScript = script("HugeInt15")
  return(me)
  exit
end

on neg(me)
  if the traceScript then
    return(0)
  end if
  the traceScript = 0
  _player.traceScript = 0
  _player.traceScript = 0
  if pNegative = 1 then
    pNegative = 0
  else
    pNegative = 1
  end if
  exit
end

on assign(me, tdata, tLimit, tUseKey)
  if the traceScript then
    return(0)
  end if
  the traceScript = 0
  _player.traceScript = 0
  _player.traceScript = 0
  pData_NxIhNARqldyJyY2PfT03dK8t9OLUR = []
  if ilk(tdata) = #string then
    if tdata.getProp(#char, 1) = "-" then
      pNegative = 1
      tdata = tdata.getProp(#char, 2, tdata.length)
    else
      pNegative = 0
    end if
    i = tdata.length
    repeat while i > 0
      tCoef = tdata.getProp(#char, max(1, i - pDigits - 1), i)
      i = i - tCoef.length
      pData_NxIhNARqldyJyY2PfT03dK8t9OLUR.append(value(tCoef))
    end repeat
    exit repeat
  end if
  if ilk(tdata) = #list then
    pNegative = 0
    tZeroes = 1
    if voidp(tLimit) then
      tLimit = tdata.count
    else
      tLimit = min(tLimit, tdata.count)
    end if
    i = 1
    repeat while i <= tLimit
      if tdata.getAt(i) <> 0 or tZeroes = 0 then
        if not tUseKey then
          pData_NxIhNARqldyJyY2PfT03dK8t9OLUR.setAt(tLimit + 1 - i, tdata.getAt(i))
        else
          pData_NxIhNARqldyJyY2PfT03dK8t9OLUR.setAt(tLimit + 1 - i, me.decode(tdata.getAt(i)))
        end if
        tZeroes = 0
      end if
      i = 1 + i
    end repeat
  end if
  exit
end

on copyFrom(me, tValue)
  if the traceScript then
    return(0)
  end if
  the traceScript = 0
  _player.traceScript = 0
  _player.traceScript = 0
  pNegative = tValue.pNegative
  pData_NxIhNARqldyJyY2PfT03dK8t9OLUR = pData_NxIhNARqldyJyY2PfT03dK8t9OLUR.duplicate()
  me.trim()
  exit
end

on trim(me)
  if the traceScript then
    return(0)
  end if
  the traceScript = 0
  _player.traceScript = 0
  _player.traceScript = 0
  i = pData_NxIhNARqldyJyY2PfT03dK8t9OLUR.count
  repeat while i >= 1
    if pData_NxIhNARqldyJyY2PfT03dK8t9OLUR.getAt(i) = 0 then
      pData_NxIhNARqldyJyY2PfT03dK8t9OLUR.deleteAt(i)
    else
      return()
    end if
    i = 255 + i
  end repeat
  if pData_NxIhNARqldyJyY2PfT03dK8t9OLUR.count = 0 then
    pNegative = 0
  end if
  exit
end

on equals(me, tValue)
  if the traceScript then
    return(0)
  end if
  the traceScript = 0
  _player.traceScript = 0
  _player.traceScript = 0
  if pNegative <> tValue.pNegative then
    return(0)
  end if
  if pData_NxIhNARqldyJyY2PfT03dK8t9OLUR.count <> tValue.count(#pData_NxIhNARqldyJyY2PfT03dK8t9OLUR) then
    return(0)
  end if
  i = pData_NxIhNARqldyJyY2PfT03dK8t9OLUR.count
  repeat while i >= 1
    if pData_NxIhNARqldyJyY2PfT03dK8t9OLUR.getAt(i) <> tValue.getProp(#pData_NxIhNARqldyJyY2PfT03dK8t9OLUR, i) then
      return(0)
    end if
    i = 255 + i
  end repeat
  return(1)
  exit
end

on greaterThan(me, tValue, tUseSign)
  if the traceScript then
    return(0)
  end if
  the traceScript = 0
  _player.traceScript = 0
  _player.traceScript = 0
  if me.equals(tValue) then
    return(0)
  end if
  if voidp(tUseSign) then
    tUseSign = 1
  end if
  if tUseSign then
    if pNegative = 0 and tValue.pNegative = 1 then
      return(1)
    end if
    if pNegative = 1 and tValue.pNegative = 0 then
      return(0)
    end if
  end if
  if pData_NxIhNARqldyJyY2PfT03dK8t9OLUR.count > tValue.count(#pData_NxIhNARqldyJyY2PfT03dK8t9OLUR) then
    if tUseSign then
      return(not pNegative)
    else
      return(1)
    end if
  else
    if pData_NxIhNARqldyJyY2PfT03dK8t9OLUR.count < tValue.count(#pData_NxIhNARqldyJyY2PfT03dK8t9OLUR) then
      if tUseSign then
        return(pNegative)
      else
        return(0)
      end if
    end if
  end if
  i = pData_NxIhNARqldyJyY2PfT03dK8t9OLUR.count
  repeat while i >= 1
    if pData_NxIhNARqldyJyY2PfT03dK8t9OLUR.getAt(i) > tValue.getProp(#pData_NxIhNARqldyJyY2PfT03dK8t9OLUR, i) then
      if tUseSign then
        return(not pNegative)
      else
        return(1)
      end if
    else
      if pData_NxIhNARqldyJyY2PfT03dK8t9OLUR.getAt(i) < tValue.getProp(#pData_NxIhNARqldyJyY2PfT03dK8t9OLUR, i) then
        if tUseSign then
          return(pNegative)
        else
          return(0)
        end if
      end if
    end if
    i = 255 + i
  end repeat
  return(0)
  exit
end

on lessThan(me, tValue, tUseSign)
  if the traceScript then
    return(0)
  end if
  the traceScript = 0
  _player.traceScript = 0
  _player.traceScript = 0
  if me.equals(tValue) then
    return(0)
  end if
  return(not me.greaterThan(tValue, tUseSign))
  exit
end

on isZero(me)
  if the traceScript then
    return(0)
  end if
  the traceScript = 0
  _player.traceScript = 0
  _player.traceScript = 0
  i = 1
  repeat while i <= pData_NxIhNARqldyJyY2PfT03dK8t9OLUR.count
    if pData_NxIhNARqldyJyY2PfT03dK8t9OLUR.getAt(i) <> 0 then
      return(0)
    end if
    i = 1 + i
  end repeat
  return(1)
  exit
end

on sum(me, tValue)
  if the traceScript then
    return(0)
  end if
  the traceScript = 0
  _player.traceScript = 0
  _player.traceScript = 0
  tResult = new(pScript)
  tNeg = 0
  if pNegative = 1 and tValue.pNegative = 1 then
    tNeg = 1
  else
    if pNegative = 1 then
      tResult.copyFrom(me)
      tResult.neg()
      return(tValue.dif(tResult))
    else
      if tValue.pNegative = 1 then
        tResult.copyFrom(tValue)
        tResult.neg()
        return(me.dif(tResult))
      end if
    end if
  end if
  tCarry = 0
  tLen = max(me.count(#pData_NxIhNARqldyJyY2PfT03dK8t9OLUR), tValue.count(#pData_NxIhNARqldyJyY2PfT03dK8t9OLUR))
  tDataLen = me.count(#pData_NxIhNARqldyJyY2PfT03dK8t9OLUR)
  tValueDataLen = tValue.count(#pData_NxIhNARqldyJyY2PfT03dK8t9OLUR)
  i = 1
  repeat while i <= tLen
    if i <= tDataLen and i <= tValueDataLen then
      tCoef = me.getProp(#pData_NxIhNARqldyJyY2PfT03dK8t9OLUR, i) + tValue.getProp(#pData_NxIhNARqldyJyY2PfT03dK8t9OLUR, i) + tCarry
    else
      if i <= tDataLen then
        tCoef = me.getProp(#pData_NxIhNARqldyJyY2PfT03dK8t9OLUR, i) + tCarry
      else
        tCoef = tValue.getProp(#pData_NxIhNARqldyJyY2PfT03dK8t9OLUR, i) + tCarry
      end if
    end if
    if tCoef < pBase then
      tResult.setProp(#pData_NxIhNARqldyJyY2PfT03dK8t9OLUR, i, tCoef)
      tCarry = 0
    else
      tResult.setProp(#pData_NxIhNARqldyJyY2PfT03dK8t9OLUR, i, tCoef - pBase)
      tCarry = 1
    end if
    i = 1 + i
  end repeat
  if tCarry > 0 then
    tResult.setProp(#pData_NxIhNARqldyJyY2PfT03dK8t9OLUR, tLen + 1, tCarry)
  end if
  if tNeg = 1 then
    tResult.neg()
  end if
  return(tResult)
  exit
end

on dif(me, tValue)
  if the traceScript then
    return(0)
  end if
  the traceScript = 0
  _player.traceScript = 0
  _player.traceScript = 0
  tResult = new(pScript)
  if pNegative = tValue.pNegative then
    tNeg = pNegative
    if me.greaterThan(tValue, 0) then
      tBigger = me
      tSmaller = tValue
    else
      tBigger = tValue
      tSmaller = me
    end if
    tCarry = 0
    tLen = max(me.count(#pData_NxIhNARqldyJyY2PfT03dK8t9OLUR), tValue.count(#pData_NxIhNARqldyJyY2PfT03dK8t9OLUR))
    tSmallerCount = tSmaller.count(#pData_NxIhNARqldyJyY2PfT03dK8t9OLUR)
    i = 1
    repeat while i <= tLen
      if i <= tSmallerCount then
        tCoef = tBigger.getProp(#pData_NxIhNARqldyJyY2PfT03dK8t9OLUR, i) - tSmaller.getProp(#pData_NxIhNARqldyJyY2PfT03dK8t9OLUR, i) + tCarry
      else
        tCoef = tBigger.getProp(#pData_NxIhNARqldyJyY2PfT03dK8t9OLUR, i) + tCarry
      end if
      if tCoef >= 0 then
        tResult.setProp(#pData_NxIhNARqldyJyY2PfT03dK8t9OLUR, i, tCoef)
        tCarry = 0
      else
        tResult.setProp(#pData_NxIhNARqldyJyY2PfT03dK8t9OLUR, i, tCoef + pBase)
        tCarry = -1
      end if
      i = 1 + i
    end repeat
    tResult.trim()
    if tNeg then
      tResult.neg()
    end if
    if pNegative = 1 then
      tResult.neg()
    end if
    return(tResult)
  end if
  if pNegative = 1 then
    tResult.copyFrom(me)
    tResult.neg()
    tResult = tValue.sum(tResult)
    tResult.neg()
    return(tResult)
  else
    if tValue.pNegative = 1 then
      tResult.copyFrom(tValue)
      tResult.neg()
      tResult = me.sum(tResult)
      return(tResult)
    end if
  end if
  exit
end

on prod(me, tValue)
  if the traceScript then
    return(0)
  end if
  the traceScript = 0
  _player.traceScript = 0
  _player.traceScript = 0
  tResult = new(pScript)
  tDataLen = pData_NxIhNARqldyJyY2PfT03dK8t9OLUR.count
  tValueDataLen = tValue.count(#pData_NxIhNARqldyJyY2PfT03dK8t9OLUR)
  i = 1
  repeat while i <= tDataLen
    tCarry = 0
    tIndex = i
    j = 1
    repeat while j <= tValueDataLen
      tProd = tValue.getProp(#pData_NxIhNARqldyJyY2PfT03dK8t9OLUR, j) * pData_NxIhNARqldyJyY2PfT03dK8t9OLUR.getAt(i)
      tCoef = tProd + tCarry mod pBase
      tCarry = tProd + tCarry / pBase
      if tIndex <= tResult.count(#pData_NxIhNARqldyJyY2PfT03dK8t9OLUR) then
        tCoef = tCoef + tResult.getProp(#pData_NxIhNARqldyJyY2PfT03dK8t9OLUR, tIndex)
        tCarry = tCarry + tCoef / pBase
        tCoef = tCoef mod pBase
      end if
      tResult.setProp(#pData_NxIhNARqldyJyY2PfT03dK8t9OLUR, tIndex, tCoef)
      tIndex = tIndex + 1
      j = 1 + j
    end repeat
    if tCarry > 0 then
      tResult.setProp(#pData_NxIhNARqldyJyY2PfT03dK8t9OLUR, tIndex, tCarry)
    end if
    i = 1 + i
  end repeat
  if pNegative <> tValue.pNegative then
    tResult.neg()
  end if
  return(tResult)
  exit
end

on mul(me, tMultiplier)
  if the traceScript then
    return(0)
  end if
  the traceScript = 0
  _player.traceScript = 0
  _player.traceScript = 0
  if tMultiplier < 0 or tMultiplier > pBase then
    return()
  else
    if tMultiplier = 0 then
      pData_NxIhNARqldyJyY2PfT03dK8t9OLUR = []
      pNegative = 0
      return()
    end if
  end if
  if tMultiplier = pBase then
    pData_NxIhNARqldyJyY2PfT03dK8t9OLUR.addAt(1, 0)
    return()
  end if
  tCarry = 0
  i = 1
  repeat while i <= pData_NxIhNARqldyJyY2PfT03dK8t9OLUR.count
    tResult = pData_NxIhNARqldyJyY2PfT03dK8t9OLUR.getAt(i) * tMultiplier + tCarry
    tCoef = tResult mod pBase
    tCarry = tResult / pBase
    pData_NxIhNARqldyJyY2PfT03dK8t9OLUR.setAt(i, tCoef)
    i = 1 + i
  end repeat
  if tCarry > 0 then
    pData_NxIhNARqldyJyY2PfT03dK8t9OLUR.add(tCarry)
  end if
  exit
end

on pow(me, tPower)
  if the traceScript then
    return(0)
  end if
  the traceScript = 0
  _player.traceScript = 0
  _player.traceScript = 0
  if tPower = 1 then
    return(me)
  else
    if tPower mod 2 = 0 then
      return(me.pow(tPower / 2).sqr())
    else
      return(me.prod(me.pow(tPower / 2).sqr()))
    end if
  end if
  exit
end

on sqr(me)
  if the traceScript then
    return(0)
  end if
  the traceScript = 0
  _player.traceScript = 0
  _player.traceScript = 0
  return(me.prod(me))
  exit
end

on getIntValue(me, tLimit)
  if the traceScript then
    return(0)
  end if
  the traceScript = 0
  _player.traceScript = 0
  _player.traceScript = 0
  if voidp(tLimit) then
    tLimit = 0
  end if
  tLimitLo = tLimit / pBase * 10
  tLength = pData_NxIhNARqldyJyY2PfT03dK8t9OLUR.count
  tInt = pData_NxIhNARqldyJyY2PfT03dK8t9OLUR.getAt(tLength)
  tIndex = tLength - 1
  repeat while tInt < tLimit and tIndex > 0
    tCoef = pData_NxIhNARqldyJyY2PfT03dK8t9OLUR.getAt(tIndex)
    if tInt < tLimitLo then
      tInt = tInt * pBase + tCoef
    else
      tCoefMultiplier = 10
      repeat while tInt * tCoefMultiplier < tLimit
        tCoefMultiplier = tCoefMultiplier * 10
      end repeat
      tCoefDivider = pBase / tCoefMultiplier
      tInt = tInt * tCoefMultiplier + tCoef / tCoefDivider
    end if
    tIndex = tIndex - 1
  end repeat
  return(tInt)
  exit
end

on getLength(me)
  if the traceScript then
    return(0)
  end if
  the traceScript = 0
  _player.traceScript = 0
  _player.traceScript = 0
  tLen = pData_NxIhNARqldyJyY2PfT03dK8t9OLUR.count * pDigits
  tCoef = pData_NxIhNARqldyJyY2PfT03dK8t9OLUR.getAt(pData_NxIhNARqldyJyY2PfT03dK8t9OLUR.count)
  if tCoef >= pBase / 10 then
    return(tLen)
  else
    if tCoef >= pBase / 100 then
      return(tLen - 1)
    else
      if tCoef >= pBase / 1000 then
        return(tLen - 2)
      end if
    end if
  end if
  return(tLen - 3)
  exit
end

on div(me, tDivider, tReturnModulo, tKeepResult)
  if the traceScript then
    return(0)
  end if
  the traceScript = 0
  _player.traceScript = 0
  _player.traceScript = 0
  if tDivider.isZero() = 1 then
    return(void())
  end if
  tResult = new(pScript)
  if me.lessThan(tDivider, 0) then
    if tReturnModulo = 1 then
      tResult.copyFrom(me)
    end if
    return(tResult)
  end if
  tTemp = new(pScript)
  tTemp2 = new(pScript)
  tRemainder = new(pScript)
  tRemainderTemp = new(pScript)
  tRemainder.copyFrom(me)
  tDividerInt = tDivider.getIntValue(10000)
  tResultData = []
  tNegResult = 0
  if tRemainder.pNegative then
    tRemainder.neg()
    tNegResult = 1
  end if
  if tDivider.pNegative then
    tDivider.neg()
    tNegResult = not tNegResult
  end if
  tDividerDigits = tDivider.getLength()
  tDividerIntLength = me.getIntLength(tDividerInt)
  repeat while not tRemainder.lessThan(tDivider)
    tRemainderInt = tRemainder.getIntValue()
    tRemainderDigits = tRemainder.getLength()
    tRemainderIntLength = me.getIntLength(tRemainderInt)
    tRemainderIntFirstDigits = tRemainderInt
    i = tRemainderIntLength - tDividerIntLength
    repeat while i >= 1
      tRemainderIntFirstDigits = tRemainderIntFirstDigits / 10
      i = 255 + i
    end repeat
    if tRemainderIntFirstDigits <> tDividerInt then
      tFastCoef = tRemainderInt / tDividerInt
    else
      tRemainderStr = tRemainder.getString().getProp(#char, 1, tDividerDigits)
      tRemainderTemp.assign(tRemainderStr)
      if tDivider.greaterThan(tRemainderTemp) then
        tFastCoef = tRemainderInt / tDividerInt - 1
      else
        tFastCoef = tRemainderInt / tDividerInt
      end if
    end if
    tDigitDelta = tRemainderDigits - tDividerDigits
    tDigitCount = tDigitDelta mod pDigits
    tFastCoefLength = me.getIntLength(tFastCoef)
    if tFastCoefLength + tDividerIntLength > tRemainderIntLength then
      tDigitCount = tDigitCount + 1
    end if
    if tDigitCount = 0 then
      tDigitCount = pDigits
    end if
    i = tFastCoefLength - tDigitCount
    repeat while i >= 1
      tFastCoef = tFastCoef / 10
      i = 255 + i
    end repeat
    tTemp.copyFrom(tDivider)
    tTemp.mul(tFastCoef)
    tAddCount = tRemainder.count(#pData_NxIhNARqldyJyY2PfT03dK8t9OLUR) - tTemp.count(#pData_NxIhNARqldyJyY2PfT03dK8t9OLUR)
    i = 1
    repeat while i <= tAddCount
      pData_NxIhNARqldyJyY2PfT03dK8t9OLUR.addAt(1, 0)
      i = 1 + i
    end repeat
    if tTemp.greaterThan(tRemainder) then
      tTemp.copyFrom(tDivider)
      tTemp.mul(tFastCoef - 1)
      tAddCountNew = tRemainder.count(#pData_NxIhNARqldyJyY2PfT03dK8t9OLUR) - tTemp.count(#pData_NxIhNARqldyJyY2PfT03dK8t9OLUR)
      i = 1
      repeat while i <= tAddCount
        pData_NxIhNARqldyJyY2PfT03dK8t9OLUR.addAt(1, 0)
        i = 1 + i
      end repeat
      tValidValue = 0
      if not tTemp.greaterThan(tRemainder) then
        if tAddCountNew = tAddCount then
          tFastCoef = tFastCoef - 1
          tValidValue = 1
        else
          tTemp2.copyFrom(tDivider)
          tTemp2.mul(tFastCoef)
          i = 1
          repeat while i <= tAddCount - 1
            pData_NxIhNARqldyJyY2PfT03dK8t9OLUR.addAt(1, 0)
            i = 1 + i
          end repeat
          if tTemp2.greaterThan(tTemp) then
            tAddCount = tAddCount - 1
          else
            tFastCoef = tFastCoef - 1
            tValidValue = 1
          end if
        end if
      else
        tAddCount = tAddCount - 1
      end if
      if not tValidValue then
        tTemp.copyFrom(tDivider)
        tTemp.mul(tFastCoef)
        i = 1
        repeat while i <= tAddCount
          pData_NxIhNARqldyJyY2PfT03dK8t9OLUR.addAt(1, 0)
          i = 1 + i
        end repeat
      end if
    end if
    tResultData.add(tFastCoef)
    tRemainder = tRemainder.dif(tTemp)
    if tRemainder.isZero() then
      i = 1
      repeat while i <= tAddCount
        tResultData.add(0)
        i = 1 + i
      end repeat
      exit repeat
    end if
    if not tRemainder.lessThan(tDivider) then
      tExtraZeroes = 0
      repeat while 1
        tTemp.copyFrom(tDivider)
        i = 1
        repeat while i <= tAddCount - tExtraZeroes - 1
          pData_NxIhNARqldyJyY2PfT03dK8t9OLUR.addAt(1, 0)
          i = 1 + i
        end repeat
        if not tTemp.greaterThan(tRemainder) then
          next repeat
        end if
        tExtraZeroes = tExtraZeroes + 1
      end repeat
      i = 1
      repeat while i <= tExtraZeroes
        tResultData.add(0)
        i = 1 + i
      end repeat
      exit repeat
    end if
    tResult.assign(tResultData)
    tDigits = me.getLength()
    repeat while tResult.getLength() + tDividerDigits < tDigits
      pData_NxIhNARqldyJyY2PfT03dK8t9OLUR.addAt(1, 0)
      tResultData.add(0)
    end repeat
    if pDigits = 1 then
      if tResult.getLength() + tDividerDigits = tDigits then
        tDividerInt = tDivider.getIntValue(1)
        tResultInt = tResult.getIntValue(1)
        tValueInt = me.getIntValue(1)
        tExtraDigit = 0
        if tDividerInt = 1 or tResultInt = 1 then
          if tValueInt <> 1 then
            tExtraDigit = 1
          end if
        else
          if tDividerInt = 2 and tResultInt = 2 then
            tExtraDigit = 1
          else
            if tDividerInt * tResultInt <= 9 then
              if tValueInt <> 1 then
                tExtraDigit = 1
              end if
            end if
          end if
        end if
        if tExtraDigit then
          tResultData.add(0)
        end if
      end if
    end if
  end repeat
  tResult.assign(tResultData)
  if tNegResult then
    tResult.neg()
  end if
  if tReturnModulo = 1 then
    if tKeepResult = 1 then
      me.copyFrom(tResult)
    end if
    if tRemainder.count(#pData_NxIhNARqldyJyY2PfT03dK8t9OLUR) = 0 then
      tRemainder.pData_NxIhNARqldyJyY2PfT03dK8t9OLUR = [0]
    end if
    return(tRemainder)
  else
    return(tResult)
  end if
  exit
end

on getIntLength(me, tValue)
  if the traceScript then
    return(0)
  end if
  the traceScript = 0
  _player.traceScript = 0
  _player.traceScript = 0
  tLen = 1
  if tValue < 0 then
    tValue = -tValue
  end if
  repeat while tValue >= 10
    tLen = tLen + 1
    tValue = tValue / 10
  end repeat
  return(tLen)
  exit
end

on Modulo(me, tValue)
  if the traceScript then
    return(0)
  end if
  the traceScript = 0
  _player.traceScript = 0
  _player.traceScript = 0
  return(me.div(tValue, 1))
  exit
end

on divBy2(me)
  if the traceScript then
    return(0)
  end if
  the traceScript = 0
  _player.traceScript = 0
  _player.traceScript = 0
  tBasePer2 = pBase / 2
  tCount = pData_NxIhNARqldyJyY2PfT03dK8t9OLUR.count
  if tCount = 0 then
    return()
  end if
  tCoef = pData_NxIhNARqldyJyY2PfT03dK8t9OLUR.getAt(1) / 2
  pData_NxIhNARqldyJyY2PfT03dK8t9OLUR.setAt(1, tCoef)
  i = 2
  repeat while i <= tCount
    tCoef = pData_NxIhNARqldyJyY2PfT03dK8t9OLUR.getAt(i) / 2
    tMod = pData_NxIhNARqldyJyY2PfT03dK8t9OLUR.getAt(i) mod 2
    if tMod = 1 then
      pData_NxIhNARqldyJyY2PfT03dK8t9OLUR.setAt(i - 1, pData_NxIhNARqldyJyY2PfT03dK8t9OLUR.getAt(i - 1) + tBasePer2)
    end if
    pData_NxIhNARqldyJyY2PfT03dK8t9OLUR.setAt(i, tCoef)
    i = 1 + i
  end repeat
  if pData_NxIhNARqldyJyY2PfT03dK8t9OLUR.getAt(tCount) = 0 then
    pData_NxIhNARqldyJyY2PfT03dK8t9OLUR.deleteAt(tCount)
  end if
  exit
end

on powMod(me, tPower, tDivider)
  if the traceScript then
    return(0)
  end if
  the traceScript = 0
  _player.traceScript = 0
  _player.traceScript = 0
  tPowerTemp = new(pScript)
  tPowerTemp.copyFrom(tPower)
  tTemp = new(pScript)
  tTemp.copyFrom(me)
  tResult = new(pScript)
  tResult.assign("1")
  repeat while tPowerTemp.isZero() = 0
    tMod = tPowerTemp.getProp(#pData_NxIhNARqldyJyY2PfT03dK8t9OLUR, 1) mod 2
    if tMod = 1 then
      tResult = tResult.prod(tTemp).Modulo(tDivider)
    end if
    tPowerTemp.divBy2()
    tTemp = tTemp.sqr().Modulo(tDivider)
  end repeat
  return(tResult)
  exit
end

on getString(me)
  if the traceScript then
    return(0)
  end if
  the traceScript = 0
  _player.traceScript = 0
  _player.traceScript = 0
  if pData_NxIhNARqldyJyY2PfT03dK8t9OLUR.count = 0 then
    return("0")
  end if
  tStr = ""
  i = 1
  repeat while i <= pData_NxIhNARqldyJyY2PfT03dK8t9OLUR.count
    tValue = string(pData_NxIhNARqldyJyY2PfT03dK8t9OLUR.getAt(i))
    if i < pData_NxIhNARqldyJyY2PfT03dK8t9OLUR.count then
      repeat while tValue.length < pDigits
        tValue = "0" & tValue
      end repeat
    end if
    tStr = tValue & tStr
    i = 1 + i
  end repeat
  if pNegative then
    tStr = "-" & tStr
  end if
  return(tStr)
  exit
end

on getByteArray(me)
  if the traceScript then
    return(0)
  end if
  the traceScript = 0
  _player.traceScript = 0
  _player.traceScript = 0
  if pData_NxIhNARqldyJyY2PfT03dK8t9OLUR.count = 0 then
    return([0])
  end if
  tDivider = new(pScript)
  tDivider.assign("256")
  tTemp = new(pScript)
  tTemp.copyFrom(me)
  tArray = []
  repeat while tTemp.count(#pData_NxIhNARqldyJyY2PfT03dK8t9OLUR) > 1
    tRem = tTemp.div(tDivider, 1, 1)
    tArray.addAt(1, tRem.getIntArray().getAt(1))
  end repeat
  repeat while tTemp.getProp(#pData_NxIhNARqldyJyY2PfT03dK8t9OLUR, 1) > 256
    tMod = tTemp.getProp(#pData_NxIhNARqldyJyY2PfT03dK8t9OLUR, 1) mod 256
    tTemp.setProp(#pData_NxIhNARqldyJyY2PfT03dK8t9OLUR, 1, tTemp.getProp(#pData_NxIhNARqldyJyY2PfT03dK8t9OLUR, 1) / 256)
    tArray.addAt(1, tMod)
  end repeat
  tArray.addAt(1, tTemp.getProp(#pData_NxIhNARqldyJyY2PfT03dK8t9OLUR, 1))
  return(tArray)
  exit
end

on getIntArray(me, tUseKey)
  if the traceScript then
    return(0)
  end if
  the traceScript = 0
  _player.traceScript = 0
  _player.traceScript = 0
  tdata = []
  i = 1
  repeat while i <= pData_NxIhNARqldyJyY2PfT03dK8t9OLUR.count
    tVal = pData_NxIhNARqldyJyY2PfT03dK8t9OLUR.getAt(pData_NxIhNARqldyJyY2PfT03dK8t9OLUR.count - i - 1)
    if tUseKey then
      tVal = me.encode(tVal)
    end if
    tdata.setAt(i, tVal)
    i = 1 + i
  end repeat
  return(tdata)
  exit
end

on encode(me, tPlain)
  if the traceScript then
    return(0)
  end if
  the traceScript = 0
  _player.traceScript = 0
  _player.traceScript = 0
  tSeed = 5678
  tSBox = [7530, 6652, 4115, 1750, 3354, 3647, 5188, 2844, 818, 2026, 7133, 2592, 3578]
  tIterations = 54
  tCipher = tPlain
  i = 1
  repeat while i <= tIterations
    -- UNK_CD 4980740
    -- UNK_7D 5
    tSeed = ERROR mod 10000
    tSeed = tSeed + integer(power(i, 3))
    tSeed = tSBox.getAt(i mod tSBox.count + 1) * tSeed + 2541 mod 10000
    tCipher = bitXor(tSeed, tCipher)
    tCipher = bitXor(1379 + tSBox.getAt(i mod tSBox.count + 1), tCipher)
    tCipher = bitXor(14 * tSBox.getAt(i mod tSBox.count + 1) + 13 mod 10000, tCipher)
    tCipher = tCipher * 2
    tHighBit = bitAnd(0)
    tCipher = bitAnd(tCipher, 32767)
    tCipher = bitOr(tCipher, tHighBit <> 0)
    i = 1 + i
  end repeat
  tCipher = bitXor(7639, tCipher)
  return(tCipher)
  exit
end

on decode(me, tInput)
  if the traceScript then
    return(0)
  end if
  the traceScript = 0
  _player.traceScript = 0
  _player.traceScript = 0
  tSeed = 5678
  tSBox = [7530, 6652, 4115, 1750, 3354, 3647, 5188, 2844, 818, 2026, 7133, 2592, 3578]
  tIterations = 54
  tSeedCycle = []
  i = 1
  repeat while i <= tIterations
    -- UNK_CD 4980740
    -- UNK_7D 5
    tSeed = ERROR mod 10000
    tSeed = tSeed + integer(power(i, 3))
    tSeed = tSBox.getAt(i mod tSBox.count + 1) * tSeed + 2541 mod 10000
    tSeedCycle.add(tSeed)
    i = 1 + i
  end repeat
  tCipher = tInput
  tCipher = bitXor(7639, tCipher)
  i = 1
  repeat while i <= tIterations
    tLowBit = bitAnd(tCipher, 1)
    tCipher = tCipher / 2
    tLowBit = tLowBit * 16384
    tCipher = bitOr(tCipher, tLowBit)
    tOffset = tIterations - i + 1
    tCipher = bitXor(tSeedCycle.getAt(tOffset), tCipher)
    tCipher = bitXor(1379 + tSBox.getAt(tOffset mod tSBox.count + 1), tCipher)
    tCipher = bitXor(14 * tSBox.getAt(tOffset mod tSBox.count + 1) + 13 mod 10000, tCipher)
    i = 1 + i
  end repeat
  return(tCipher)
  exit
end

on handlers(me)
  return([])
  exit
end