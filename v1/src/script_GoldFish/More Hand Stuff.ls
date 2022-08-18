on mouseDown me
  sendFuseMsg("GETSTRIP next")
end

on mouseEnter me
  helpText_setText(AddTextToField("NextHandItems"))
end

on mouseLeave me
  helpText_empty(AddTextToField("NextHandItems"))
end
