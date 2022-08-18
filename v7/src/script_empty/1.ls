global gHasCompleted

on exitFrame
  _player.debugPlaybackEnabled = 1
  if (voidp(gHasCompleted) and (member("RC4 Class").number > 0)) then
    gHasCompleted = 1
    member("RC4 Class").scriptText = ((((((((((((((((((((((((((((((((((("on setKey me, k" & RETURN) & "put ") & QUOTE) & "setKey() called.") & QUOTE) & EMPTY) & RETURN) & "end") & RETURN) & EMPTY) & RETURN) & "on encipher me, data") & RETURN) & "return data") & RETURN) & "end") & RETURN) & EMPTY) & RETURN) & "on decipher me, data") & RETURN) & "return data") & RETURN) & "end") & RETURN) & EMPTY) & RETURN) & "on createKey me") & RETURN) & "return ") & QUOTE) & QUOTE) & EMPTY) & RETURN) & "end")
  end if
end
