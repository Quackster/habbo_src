global gPopUpContext, gGameContext

on goContext s, context
  if voidp(context) then
    context = gPopUpContext
  end if
  if objectp(context) then
    displayFrame(context, s)
  else
    gotoFrame(s)
  end if
end

on goGameContext s
  if objectp(gGameContext) then
    displayFrame(gGameContext, s)
  else
    gotoFrame(s)
  end if
end
