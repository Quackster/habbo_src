on helpText_setText s 
  if voidp(s) then
    return()
  end if
  member("helpbox").text = s
  updateStage()
end

on helpText_empty ifS 
  if voidp(ifS) then
    return()
  end if
  if (member("helpbox").text = ifS) then
    member("helpbox").text = ""
  end if
  updateStage()
end
