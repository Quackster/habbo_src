property enabled
global gChosenFlatId

on mouseUp me
  global gFlatWaitStart, gFlatLetIn
  gFlatLetIn = 0
  member("flat_load.status").text = AddTextToField("WaitingWhenCanGoIntoRoom")
  gFlatWaitStart = the milliSeconds
  put gChosenFlatId
  GoToFlatWithNavi(gChosenFlatId)
end
