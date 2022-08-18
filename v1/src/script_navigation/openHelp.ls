on mouseUp
  openHelp()
end

on mouseEnter me
  helpText_setText(AddTextToField("OpenHelp"))
end

on mouseLeave me
  helpText_empty(AddTextToField("OpenHelp"))
end
