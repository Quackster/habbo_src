property specialCharacters

on beginSprite me
  specialCharacters = 0
end

on keyDown me
  if specialCharacters = 1 then
    sChar = EMPTY
    charactersMap = member("VolterSpecialChars").text
    case the keyPressed of
      "1":
        if the platform contains "win" then
          sChar = numToChar(131)
        else
          sChar = numToChar(196)
        end if
      "2":
        if the platform contains "win" then
          sChar = numToChar(170)
        else
          sChar = numToChar(187)
        end if
      otherwise:
        specialCharacters = 0
        pass()
    end case
    sprite(me.spriteNum).member.text = sprite(me.spriteNum).member.text & sChar
    specialCharacters = 0
    exit
  end if
  if (the keyCode = 127) or (the keyCode = 10) then
    specialCharacters = 1
    exit
  else
    specialCharacters = 0
  end if
  pass()
end
