property m_ar_iValue, m_iLength, m_iBitsPerWord, m_iBitMask, m_iCarryMask

on construct this
  m_ar_iValue = []
  m_iLength = 0
  m_iBitsPerWord = 12
  m_iBitMask = 1
  repeat with i = 1 to m_iBitsPerWord
    m_iBitMask = bitOr((m_iBitMask * 2), 1)
  end repeat
  m_iCarryMask = bitOr((m_iBitMask * 2), 1)
  return 1
end

on setup this, a_vInput
  case a_vInput.ilk of
    #integer:
      t_iValue = a_vInput
      t_iLength = (((4 * 8) + 7) / m_iBitsPerWord)
      m_ar_iValue = []
      m_ar_iValue.addAt(t_iLength, 0)
      repeat with i = 1 to t_iLength
        t_iValue = bitAnd(t_iValue, m_iBitMask)
        t_iValue = (t_iValue / 2)
        m_ar_iValue[i] = t_iValue
      end repeat
      m_iLength = t_iLength
      repeat while 1
        if (m_ar_iValue[m_iLength] = 0) then
          m_iLength = (m_iLength - 1)
          next repeat
        end if
        exit repeat
      end repeat
    #list:
      m_ar_iValue = a_vInput.m_ar_iValue.duplicate()
      m_iValue = a_vInput.m_iValue
  end case
end

on multiply this, a_rOperand
  t_ar_iResult = []
  t_ar_iResult.addAt((m_iLength + a_rOperand.m_iLength), 0)
  repeat with i = 1 to m_iLength
    repeat with j = 1 to a_rOperand.m_iLength
      t_iProduct = (m_ar_iValue[i] * a_rOperand.m_ar_iValue[j])
      k = (i + j)
      repeat while (t_iProduct <> 0)
        t_iProduct = (t_iProduct + t_ar_iResult[k])
        t_ar_iResult[k] = bitAnd(t_iProduct, m_iBitMask)
        t_iProduct = this.BitRight(t_iProduct, m_iBitsPerWord)
        k = (k + 1)
      end repeat
    end repeat
  end repeat
  t_rBigInt = createObject(#temp, "CBigInt16")
  t_rBigInt.setup(t_ar_iResult)
  return t_rBigInt
end

on power this, a_rBigIntExp, a_rBigIntMod
  t_rResult = createObject(#temp, "CBigInt16")
  t_rBase = this
  repeat with n = 1 to a_rBigIntExp.m_iLength
    bit = 1
    repeat while (bit < m_iBitMask)
      if (bitAnd(a_rBigIntExp.m_ar_iValue[n], bit) <> 0) then
        t_rResult = t_rResult.multiply(t_rBase).Modulo(a_rBigIntMod)
      end if
      t_rBase = t_rBase.multiply(t_rBase).Modulo(a_rBigIntMod)
    end repeat
  end repeat
  return t_rResult
end

on Compare this, a_rOperand
  if (m_iLength = a_rOperand.m_iLength) then
  end if
  return 0
end

on Modulo this, a_rModulus
end

on toString this
  return EMPTY
end

on FromString this, a_sHex
end

on BitRight this, n, s
  s = (s mod 32)
  if (n > 0) then
    return bitOr((n / power(2, s)), 0)
  else
    f = (n / power(2, s))
    i = integer(f)
    if (i > f) then
      return (i - 1)
    else
      return i
    end if
  end if
end
