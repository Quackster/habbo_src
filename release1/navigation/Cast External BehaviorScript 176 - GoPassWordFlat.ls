property enabled
global gChosenFlatId, gChosenFlatDoorMode

on mouseUp me
  global gFlatWaitStart, gFlatLetIn
  gFlatLetIn = 0
  member("flat_load.status").text = AddTextToField("WaitingWhenCanGoIntoRoom")
  gFlatWaitStart = the milliSeconds
  put gChosenFlatId
  gChosenFlatDoorMode = "x"
  GoToFlatWithNavi(gChosenFlatId)
end
