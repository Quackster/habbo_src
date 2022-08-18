property i, pKey, pSbox, j

on setKey me, tMyKey, tMode 
  tMyKeyS = string(tMyKey)
  pSbox = []
  pKey = []
  tOldKey = [108, 214, 122, 91, 114, 79, 16, 141, 115, 222, 207, 216, 238, 65, 59, 50, 186, 70, 42, 248, 107, 12, 33, 247, 66, 79, 53, 216, 159, 81, 145, 249, 179, 111, 233, 56, 49, 251, 123, 162, 26, 46, 182, 96, 208, 93, 114, 202, 255, 19, 164, 208, 79, 91, 241, 128, 158, 25, 252, 194, 217, 120, 22, 44, 1, 253, 45, 91, 113, 89, 203, 80, 34, 112, 99, 82, 103, 8, 90, 240, 39, 17, 230, 232, 80, 180, 173, 164, 112, 33, 217, 155, 170, 41, 187, 156, 213, 199, 176, 180, 177, 236, 167, 128, 31, 155, 210, 208, 55, 198, 5, 243, 27, 48, 78, 13, 142, 64, 80, 21, 18, 19, 175, 252, 126, 194, 111, 190, 99, 94, 184, 248, 167, 77, 45, 5, 141, 128, 72, 0, 45, 107, 88, 140, 147, 30, 248, 243, 208, 82, 137, 181, 69, 177, 8, 216, 25, 3, 239, 179, 160, 159, 129, 135, 23, 62, 192, 90, 91, 172, 119, 255, 55, 39, 78, 216, 12, 188, 45, 204, 93, 54, 30, 165, 129, 78, 151, 253, 92, 31, 196, 126, 4, 72, 182, 180, 216, 144, 78, 255, 185, 228, 134, 92, 103, 81, 2, 144, 123, 161, 101, 187, 145, 187, 171, 62, 21, 244, 17, 231, 203, 120, 176, 87, 150, 89, 244, 7, 29, 21, 235, 165, 86, 125, 184, 90, 232, 232, 145, 15, 198, 165, 103, 12, 245, 177, 151, 29, 45, 26, 184, 91, 20, 16, 231, 174, 237, 207, 165, 251, 114, 185, 245, 68, 82, 116, 216, 0, 203, 89, 234, 174, 100, 220, 60, 42, 60, 103, 17, 93, 208, 72, 242, 116, 148, 84, 230, 115, 56, 138, 134, 107, 199, 17, 73, 58, 75, 187, 200, 253, 141, 249, 246, 74, 201, 166, 194, 156, 72, 221, 20, 6, 91, 191, 243, 100, 3, 113, 79, 59, 175, 94, 112, 81, 69, 166, 145, 89, 163, 111, 180, 110, 146, 156, 43, 206, 248, 22, 188, 27, 123, 152, 65, 136, 212, 185, 83, 104, 162, 69, 21, 208, 116, 78, 193, 2, 179, 222, 109, 66, 75, 56, 46, 21, 105, 140, 236, 13, 78, 58, 30, 55, 114, 228, 96, 156, 89, 179, 116, 30, 63, 7, 52, 10, 182, 25, 87, 29, 166, 75, 64, 89, 30, 110, 40, 50, 121, 107, 44, 151, 246, 147, 131, 39, 105, 227, 58, 66, 56, 82, 107, 73, 91, 133, 210, 202, 174, 56, 108, 29, 117, 109, 128, 103, 237, 227, 13, 138, 177, 180, 146, 142, 82, 83, 115, 194, 148, 62, 74, 92, 154, 95, 194, 104, 216, 2, 166, 59, 150, 137, 164, 49, 189, 33, 236, 46, 82, 169, 73, 77, 177, 81, 67, 98, 181, 116, 49, 76, 97, 204, 227, 29, 203, 113, 110, 242, 255, 140, 46, 204, 144, 39, 234, 167, 30, 150, 110, 219, 138, 136, 88, 12, 179, 71, 23, 150, 233, 80, 217, 244, 248, 111, 65, 255, 69, 217, 55, 49, 43, 228, 225, 10, 123, 71, 41, 173, 7, 15, 194, 8, 87, 209, 75, 212, 179, 144, 151, 48, 134, 47, 109, 212, 8, 24, 66, 102, 198, 211, 35, 184, 154, 76, 147, 170, 90, 247, 53, 31, 164, 5, 189, 12, 208, 99, 185, 52, 74, 154, 137, 235, 112, 132, 5, 16, 65, 124, 87, 109, 83, 170, 37, 20, 88, 134, 2, 86, 218, 169, 222, 128, 202, 28, 87, 81, 154, 199, 124, 239, 130, 47, 88, 219, 61, 97, 18, 95, 81, 144, 123, 64, 49, 239, 24, 87, 134, 24, 102, 230, 169, 145, 83, 11, 126, 166, 230, 149, 31, 164, 94, 197, 27, 225, 35, 17, 24, 241, 140, 17, 42, 10, 40, 124, 217, 114, 116, 252, 232, 55, 77, 88, 75, 5, 48, 180, 220, 218, 124, 97, 177, 184, 192, 205, 59, 54, 89, 152, 79, 6, 64, 29, 167, 155, 62, 14, 197, 181, 66, 142, 153, 91, 230, 43, 96, 110, 122, 187, 235, 209, 190, 241, 128, 50, 23, 53, 114, 43, 111, 106, 99, 15, 232, 115, 101, 210, 234, 245, 238, 164, 56, 123, 94, 125, 223, 97, 210, 151, 91, 204, 4, 72, 140, 41, 143, 19, 93, 212, 153, 102, 182, 243, 102, 93, 214, 32, 68, 236, 146, 92, 168, 99, 46, 150, 249, 34, 177, 203, 105, 126, 129, 43, 156, 166, 3, 168, 43, 81, 183, 131, 168, 111, 131, 157, 155, 195, 195, 177, 47, 180, 82, 61, 225, 62, 150, 176, 212, 191, 129, 117, 98, 72, 173, 192, 36, 203, 15, 224, 254, 52, 127, 174, 231, 38, 213, 239, 120, 52, 178, 101, 97, 132, 130, 144, 152, 251, 226, 90, 18, 233, 74, 41, 88, 28, 17, 58, 177, 84, 226, 119, 241, 25, 192, 7, 157, 125, 170, 188, 191, 186, 75, 97, 225, 115, 184, 100, 168, 133, 0, 220, 95, 160, 242, 14, 185, 219, 214, 108, 157, 142, 32, 135, 69, 86, 64, 90, 236, 179, 137, 64, 128, 214, 63, 132, 152, 177, 167, 158, 8, 122, 139, 89, 115, 11, 27, 85, 94, 45, 12, 164, 18, 169, 213, 74, 196, 61, 55, 60, 238, 33, 77, 181, 88, 166, 61, 96, 152, 139, 209, 42, 223, 203, 149, 25, 93, 71, 132, 40, 77, 31, 187, 168, 88, 210, 106, 251, 181, 29, 15, 158, 194, 183, 176, 230, 91, 2, 124, 174, 86, 165, 57, 108, 191, 227, 106, 164, 159, 110, 35, 205, 248, 254, 105, 129, 25, 77, 6, 164, 93, 176, 192, 205, 26, 96, 109, 191, 35, 239, 46, 124, 53, 208, 221, 175, 169, 246, 68, 228, 158, 39, 221, 66, 234, 170, 154, 6, 192, 132, 25, 6, 168, 169, 26, 251, 183, 23, 204, 192, 34, 96, 126, 20, 183, 135, 20, 223, 115, 137, 254, 247, 13, 71, 7, 176, 162, 184, 184, 255, 128, 229, 236, 107, 42, 80, 68, 112, 127, 4, 57, 89, 26, 78, 251, 177, 21, 151, 224, 26, 227, 112, 78, 240, 11, 247, 87, 103]
  artificialKey = [35, 121, 254, 59, 140, 105, 46, 109, 15, 39, 72, 179, 239, 231, 202, 123, 215, 211, 204, 40, 96, 3, 162, 105, 247, 52, 103, 128, 150, 193, 109, 214, 192, 172, 26, 136, 37, 99, 208, 41, 144, 96, 39, 42, 233, 228, 114, 56, 7, 125, 119, 57, 36, 251, 146, 153, 88, 154, 107, 155, 126, 191, 172, 98, 117, 89, 53, 19, 122, 242, 32, 43, 246, 0, 144, 97, 120, 129, 168, 238, 212, 196, 61, 4, 17, 102, 244, 147, 79, 62, 114, 31, 176, 98, 94, 203, 225, 79, 45, 12, 232, 102, 109, 76, 160, 168, 163, 60, 189, 226, 121, 172, 2, 158, 121, 159, 165, 140, 188, 40, 220, 66, 201, 59, 42, 62, 117, 231, 47, 219, 168, 74, 198, 159, 178, 14, 129, 120, 97, 15, 30, 139, 206, 60, 141, 85, 117, 200, 128, 253, 225, 14, 57, 31, 205, 93, 21, 147, 8, 78, 122, 43, 32, 163, 118, 10, 202, 4, 110, 116, 61, 59, 3, 208, 131, 114, 60, 177, 101, 95, 45, 106, 27, 230, 63, 116, 18, 152, 144, 219, 67, 40, 242, 60, 91, 225, 49, 179, 5, 233, 184, 204, 117, 174, 56, 201, 53, 255, 214, 31, 237, 7, 109, 250, 170, 109, 116, 40, 236, 71, 22, 94, 244, 171, 135, 15, 201, 32, 168, 131, 175, 65, 184, 41, 219, 72, 244, 36, 72, 128, 148, 140, 36, 57, 111, 219, 13, 119, 152, 127, 87, 147, 48, 83, 217, 8, 113, 49, 250, 63, 219, 21, 91, 66, 201, 252, 141, 215, 87, 170, 19, 254, 134, 48, 47, 234, 99, 53, 211, 160, 111, 179, 62, 162, 137, 213, 215, 135, 43, 172, 129, 41, 78, 147, 155, 9, 240, 234, 218, 57, 246, 232, 207, 158, 122, 57, 205, 150, 68, 91, 174, 153, 144, 116, 0, 21, 68, 57, 183, 144, 117, 81, 154, 177, 155, 239, 74, 152, 0, 241, 191, 234, 110, 250, 98, 232, 203, 118, 222, 239, 13, 75, 13, 246, 193, 229, 215, 165, 252, 120, 37, 181, 125, 123, 62, 147, 70, 153, 24, 83, 56, 30, 82, 220, 117, 196, 89, 179, 84, 52, 229, 224, 25, 154, 217, 168, 85, 252, 134, 39, 33, 171, 107, 240, 101, 1, 211, 213, 126, 85, 150, 111, 11, 187, 176, 52, 212, 63, 184, 73, 2, 0, 24, 20, 13, 182, 48, 16, 163, 223, 12, 4, 165, 148, 67, 237, 126, 133, 240, 132, 218, 180, 115, 157, 67, 239, 226, 143, 8, 158, 136, 163, 222, 155, 199, 24, 146, 34, 154, 169, 41, 59, 197, 137, 227, 13, 110, 20, 229, 113, 105, 235, 110, 253, 112, 34, 69, 172, 108, 173, 38, 154, 167, 199, 142, 4, 232, 197, 115, 27, 130, 225, 60, 142, 168, 147, 178, 246, 160, 145, 75, 233, 145, 108, 189, 148, 45, 198, 119, 63, 20, 103, 171, 63, 133, 230, 222, 172, 126, 18, 59, 80, 241, 170, 194, 212, 84, 49, 132, 235, 33, 40, 138, 141, 179, 62, 152, 95, 214, 8, 53, 84, 215, 49, 236, 69, 119, 17, 215, 127, 56, 202, 159, 192, 240, 121, 60, 246, 151, 96, 105, 44, 230, 189, 72, 68, 161, 139, 209, 150, 201, 68, 248, 214, 1, 192, 189, 214, 122, 163, 202, 104, 139, 217, 70, 50, 83, 42, 47, 76, 148, 160, 227, 60, 17, 100, 27, 60, 248, 217, 177, 30, 148, 98, 169, 247, 89, 232, 77, 129, 128, 119, 41, 147, 230, 3, 6, 93, 110, 214, 199, 117, 16, 89, 230, 106, 206, 243, 8, 14, 166, 3, 28, 230, 180, 224, 73, 189, 164, 143, 115, 183, 36, 193, 218, 91, 95, 125, 95, 23, 6, 233, 176, 50, 135, 107, 44, 227, 178, 225, 124, 74, 4, 115, 119, 78, 99, 3, 213, 178, 98, 84, 230, 197, 175, 28, 230, 66, 247, 105, 193, 140, 121, 207, 171, 241, 57, 170, 28, 135, 197, 233, 170, 148, 135, 8, 226, 56, 247, 6, 184, 137, 132, 39, 253, 190, 229, 54, 80, 165, 208, 5, 134, 38, 142, 207, 173, 253, 252, 43, 118, 44, 73, 100, 151, 166, 6, 58, 233, 216, 119, 101, 21, 43, 235, 141, 148, 105, 170, 25, 112, 3, 152, 56, 251, 114, 126, 208, 174, 29, 192, 211, 245, 71, 57, 205, 163, 250, 124, 111, 5, 237, 16, 211, 110, 196, 64, 210, 249, 174, 248, 44, 75, 155, 212, 35, 42, 35, 53, 186, 18, 161, 87, 54, 204, 15, 68, 8, 117, 192, 113, 199, 18, 91, 77, 117, 128, 15, 99, 119, 31, 213, 37, 75, 217, 199, 114, 208, 212, 240, 93, 193, 155, 35, 32, 124, 33, 49, 20, 191, 186, 122, 197, 198, 11, 34, 74, 133, 207, 84, 21, 65, 211, 146, 53, 59, 172, 160, 119, 148, 171, 139, 201, 79, 177, 71, 137, 103, 49, 172, 162, 230, 228, 131, 53, 30, 162, 254, 204, 49, 93, 177, 27, 162, 182, 225, 126, 234, 98, 104, 60, 51, 68, 236, 206, 129, 23, 138, 17, 220, 185, 233, 70, 239, 226, 136, 186, 245, 144, 6, 253, 85, 4, 185, 135, 219, 52, 68, 158, 128, 240, 134, 159, 90, 145, 167, 113, 1, 172, 100, 228, 222, 53, 128, 233, 142, 201, 91, 211, 175, 93, 170, 53, 227, 9, 235, 210, 85, 59, 202, 61, 14, 20, 104, 181, 154, 161, 172, 114, 36, 11, 107, 202, 206, 153, 59, 120, 76, 117, 39, 83, 233, 159, 120, 94, 40, 54, 77, 63, 203, 144, 205, 121, 92, 81, 14, 45, 208, 102, 83, 126, 39, 245, 76, 115, 25, 106, 23, 147, 221, 135, 207, 82, 173, 33, 69, 35, 206, 171, 191, 227, 204, 119, 37, 180, 133, 174, 248, 43, 214, 99, 44, 251, 229, 194, 148, 186, 57, 89, 9, 147, 231, 7, 75, 207, 3, 252, 2, 136, 218, 179, 138, 223, 30, 213, 141, 209, 170, 57, 70, 48, 67, 113, 134, 137, 13, 85, 135, 14, 113, 208, 21, 191, 185]
  if voidp(tMode) then
    if voidp(value(tMyKey)) then
      tMode = #old
    else
      tMode = #artificialKey
    end if
  end if
  if tMode <> #old then
    if (tMode = void()) then
      i = 0
      repeat while i <= 255
        pKey.setAt((i + 1), charToNum(tMyKeyS.getProp(#char, ((i mod length(tMyKeyS)) + 1))))
        pSbox.setAt((i + 1), i)
        i = (1 + i)
      end repeat
      exit repeat
    end if
    if (tMode = #artificialKey) then
      len = (bitAnd(tMyKey, 248) / 8)
      if len < 20 then
        len = (len + 20)
      end if
      tOffset = (tMyKey mod 1024)
      ckey = []
      fakeKey = []
      prevKey = 0
      m = 2
      i = 0
      repeat while i <= (len - 1)
        fakeKey.setAt((i + 1), i)
        keySkip = ((prevKey mod 29) - (i mod 6))
        m = (m * -1)
        nkey = artificialKey.getAt(((abs(((tOffset + (i * m)) + keySkip)) mod count(artificialKey)) + 1))
        prevKey = nkey
        ckey.setAt((i + 1), nkey)
        fakeKey.setAt((i + 1), ((nkey + 2) + fakeKey.getAt((i + 1))))
        i = (1 + i)
      end repeat
      i = 0
      repeat while i <= 255
        pKey.setAt((i + 1), ckey.getAt(((i mod len) + 1)))
        fakeKey.setAt((i + 1), pKey.getAt((i + 1)))
        pSbox.setAt((i + 1), i)
        i = (1 + i)
      end repeat
      exit repeat
    end if
    if (tMode = #new) then
      i = 0
      repeat while i <= 255
        pKey.setAt((i + 1), i)
        i = (1 + i)
      end repeat
      i = 0
      repeat while i <= 1019
        pKey.setAt(((i mod 256) + 1), ((charToNum(tMyKeyS.getProp(#char, ((i mod length(tMyKeyS)) + 1))) + pKey.getAt(((i mod 256) + 1))) mod 256))
        i = (1 + i)
      end repeat
      i = 0
      repeat while i <= 255
        pSbox.setAt((i + 1), i)
        i = (1 + i)
      end repeat
      put("NEW KEY:" && pSbox)
    end if
    j = 0
    i = 0
    repeat while i <= 255
      j = (((j + pSbox.getAt((i + 1))) + pKey.getAt((i + 1))) mod 256)
      k = pSbox.getAt((i + 1))
      pSbox.setAt((i + 1), pSbox.getAt((j + 1)))
      pSbox.setAt((j + 1), k)
      i = (1 + i)
    end repeat
    i = 0
    j = 0
  end if
end

on encipher me, tdata 
  tCipher = ""
  tBytes = []
  e = 1
  repeat while e <= length(tdata)
    a = charToNum(tdata.char[e])
    if a > 255 then
      add(tBytes, ((a - (a mod 256)) / 256))
      add(tBytes, (a mod 256))
    else
      add(tBytes, a)
    end if
    e = (1 + e)
  end repeat
  tStrServ = getStringServices()
  a = 1
  repeat while a <= tBytes.count
    i = ((i + 1) mod 256)
    j = ((j + pSbox.getAt((i + 1))) mod 256)
    temp = pSbox.getAt((i + 1))
    pSbox.setAt((i + 1), pSbox.getAt((j + 1)))
    pSbox.setAt((j + 1), temp)
    d = pSbox.getAt((((pSbox.getAt((i + 1)) + pSbox.getAt((j + 1))) mod 256) + 1))
    tCipher = tCipher & tStrServ.convertIntToHex(bitXor(tBytes.getAt(a), d))
    a = (1 + a)
  end repeat
  return(tCipher)
end

on decipher me, tdata 
  tCipher = ""
  tStrServ = getStringServices()
  a = 1
  repeat while a <= length(tdata)
    i = ((i + 1) mod 256)
    j = ((j + pSbox.getAt((i + 1))) mod 256)
    temp = pSbox.getAt((i + 1))
    pSbox.setAt((i + 1), pSbox.getAt((j + 1)))
    pSbox.setAt((j + 1), temp)
    d = pSbox.getAt((((pSbox.getAt((i + 1)) + pSbox.getAt((j + 1))) mod 256) + 1))
    t = tStrServ.convertHexToInt(tdata.getProp(#char, a, (a + 1)))
    tCipher = tCipher & numToChar(bitXor(t, d))
    a = (a + 1)
    a = (1 + a)
  end repeat
  return(tCipher)
end

on createKey me 
  tKey = ""
  tSeed = the randomSeed
  the randomSeed = the milliSeconds
  i = 1
  repeat while i <= 4
    tKey = tKey & convertIntToHex((random(256) - 1))
    i = (1 + i)
  end repeat
  the randomSeed = tSeed
  return(abs(convertHexToInt(tKey)))
end