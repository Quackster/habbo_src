on mouseUp
  global gUnits
  if gUnits <> VOID then
    if gUnits.count > 0 then
      openNavigator()
    end if
  end if
end

on mouseEnter me
  helpText_setText(AddTextToField("OpenNavigator"))
end

on mouseLeave me
  helpText_empty(AddTextToField("OpenNavigator"))
end
