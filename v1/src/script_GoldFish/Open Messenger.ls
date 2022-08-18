on mouseUp
  openMessenger()
end

on mouseEnter me
  helpText_setText(AddTextToField("OpenMessenger"))
end

on mouseLeave me
  helpText_empty(AddTextToField("OpenMessenger"))
end
