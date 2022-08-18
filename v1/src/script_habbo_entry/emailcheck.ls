property emailOk

on exitFrame me
  if (the keyboardFocusSprite <> me.spriteNum) then
    emailfield = sprite(me.spriteNum).member.name
    if ((field(emailfield).length > 6) and (field(emailfield) contains "@")) then
      emailOk = 0
      repeat with f = (offset("@", field(emailfield)) + 1) to field(emailfield).length
        if (field(emailfield).char[f] = ".") then
          emailOk = 1
        end if
        if (field(emailfield).char[f] = "@") then
          emailOk = 0
        end if
      end repeat
      if (emailOk = 0) then
        ShowAlert("emailNotCorrect")
      end if
    else
      ShowAlert("emailNotCorrect")
    end if
  end if
end
