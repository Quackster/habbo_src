on keyDown me 
  if member("post.it field_Add").count(#line) > 0 then
    if the key = "\r" and member("post.it field_Add").height / member("post.it field_Add").lineHeight <= MyMaxLines then
      pass()
    end if
    if member("post.it field_Add").height / member("post.it field_Add").lineHeight <= MyMaxLines then
      pass()
    end if
    if the keyCode = 51 then
      pass()
    end if
  end if
end
