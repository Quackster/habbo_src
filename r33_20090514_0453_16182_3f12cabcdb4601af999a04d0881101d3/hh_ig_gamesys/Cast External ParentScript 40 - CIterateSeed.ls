on TestSeed this, a_iSeed
  repeat with i = 1 to 1000
    put this.IntToBits(a_iSeed) && a_iSeed
    a_iSeed = this.IterateSeed(a_iSeed)
  end repeat
end

on IterateSeed this, a_iSeed
  t_iSeed2 = 0
  if a_iSeed = 0 then
    a_iSeed = -1
  end if
  t_iSeed2 = this.BitLeft(a_iSeed, 13)
  a_iSeed = bitXor(a_iSeed, t_iSeed2)
  t_iSeed2 = this.BitRight(a_iSeed, 17)
  a_iSeed = bitXor(a_iSeed, t_iSeed2)
  t_iSeed2 = this.BitLeft(a_iSeed, 5)
  a_iSeed = bitXor(a_iSeed, t_iSeed2)
  return a_iSeed
end

on getRandomNumber this, iteratedSeed, maxValue
  if iteratedSeed < 0 then
    return abs(iteratedSeed) mod maxValue
  else
    return iteratedSeed mod maxValue
  end if
end

on BitLeft this, n, s
  return integer(n * power(2, s mod 32))
end

on BitRight this, n, s
  s = s mod 32
  if n > 0 then
    return bitOr(n / power(2, s), 0)
  else
    f = n / power(2, s)
    i = integer(f)
    if i > f then
      return i - 1
    else
      return i
    end if
  end if
end

on BitRightZF this, n, s
  s = s mod 32
  if n < 0 then
    if s = 0 then
      return (float(the maxinteger) * 2) + 2 + n
    else
      return bitOr((n + the maxinteger + 1) / power(2, s), power(2, 31 - s))
    end if
  else
    return bitOr(n / power(2, s), 0)
  end if
end

on IntToBits this, a_iInput
  tDigits = "01"
  repeat while a_iInput > 0
    tD = a_iInput mod 2
    a_iInput = a_iInput / 2
    tHexstr = tDigits.char[tD + 1] & tHexstr
  end repeat
  repeat while 1
    if length(tHexstr) = 32 then
      exit repeat
    end if
    put "0" before tHexstr
  end repeat
  return tHexstr
end
