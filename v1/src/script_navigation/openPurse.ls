on mouseUp
  openPurse()
end

on mouseEnter me
  helpText_setText(AddTextToField("OpenPurse"))
end

on mouseLeave me
  helpText_empty(AddTextToField("OpenPurse"))
end
