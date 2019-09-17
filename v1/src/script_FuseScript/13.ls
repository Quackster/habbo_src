property i, key, sbox, j

on new me 
  return(me)
end

on setKey me, myKey 
  put("New key assigned to RC4:" && myKey)
  myKey = string(myKey)
  sbox = []
  key = []
  i = 0
  repeat while i <= 255
    key.setAt(i + 1, charToNum(myKey.char[i mod length(myKey) + 1]))
    sbox.setAt(i + 1, i)
    i = 1 + i
  end repeat
  j = 0
  i = 0
  repeat while i <= 255
    j = j + sbox.getAt(i + 1) + key.getAt(i + 1) mod 256
    k = sbox.getAt(i + 1)
    sbox.setAt(i + 1, sbox.getAt(j + 1))
    sbox.setAt(j + 1, k)
    i = 1 + i
  end repeat
  i = 0
  j = 0
end

on encipher me, Data 
  cipher = ""
  a = 1
  repeat while a <= length(Data)
    i = i + 1 mod 256
    j = j + sbox.getAt(i + 1) mod 256
    temp = sbox.getAt(i + 1)
    sbox.setAt(i + 1, sbox.getAt(j + 1))
    sbox.setAt(j + 1, temp)
    d = sbox.getAt(sbox.getAt(i + 1) + sbox.getAt(j + 1) mod 256 + 1)
    cipher = cipher & me.int2hex(bitXor(charToNum(Data.char[a]), d))
    a = 1 + a
  end repeat
  return(cipher)
end

on decipher me, Data 
  cipher = ""
  a = 1
  repeat while a <= length(Data)
    i = i + 1 mod 256
    put("i:" && i)
    j = j + sbox.getAt(i + 1) mod 256
    put("j:" && j)
    temp = sbox.getAt(i + 1)
    sbox.setAt(i + 1, sbox.getAt(j + 1))
    sbox.setAt(j + 1, temp)
    d = sbox.getAt(sbox.getAt(i + 1) + sbox.getAt(j + 1) mod 256 + 1)
    put("d:" && d)
    t = me.hex2int(Data.char[a..a + 1])
    put("t:" && t)
    cipher = cipher & numToChar(bitXor(t, d))
    a = a + 1
    put("-----")
    a = 1 + a
  end repeat
  return(cipher)
end

on createKey me 
  k = ""
  the randomSeed = the milliSeconds
  i = 1
  repeat while i <= 4
    k = k & me.int2hex(random(256) - 1)
    i = 1 + i
  end repeat
  return(abs(me.hex2int(k)))
end

on int2hex me, aint 
  digits = "0123456789ABCDEF"
  h = ""
  if aint <= 0 then
    hexstr = "00"
  else
    repeat while aint > 0
      d = aint mod 16
      aint = aint / 16
      hexstr = digits.char[d + 1] & hexstr
    end repeat
  end if
  if hexstr.length mod 2 = 1 then
    hexstr = "0" & hexstr
  end if
  return(hexstr)
end

on hex2int me, ahex 
  digits = "0123456789ABCDEF"
  base = 1
  tot = 0
  repeat while length(ahex) > 0
    lc = the last char in ahex
    vl = offset(lc, digits) - 1
    tot = tot + base * vl
    base = base * 16
  end repeat
  return(tot)
end
