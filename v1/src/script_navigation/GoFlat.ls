on mouseUp me 
  gFlatLetIn = 0
  member("flat_load.status").text = AddTextToField("WaitingWhenCanGoIntoRoom")
  gFlatWaitStart = the milliSeconds
  put(gChosenFlatId)
  GoToFlatWithNavi(gChosenFlatId)
end
