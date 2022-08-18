global MyMaxLines

on keyDown me
  if (member("post.it field_Add").line.count > 0) then
    if ((the key = RETURN) and ((member("post.it field_Add").height / member("post.it field_Add").lineHeight) <= MyMaxLines)) then
      pass()
    end if
    if ((member("post.it field_Add").height / member("post.it field_Add").lineHeight) <= MyMaxLines) then
      pass()
    end if
    if (the keyCode = 51) then
      pass()
    end if
  end if
end
