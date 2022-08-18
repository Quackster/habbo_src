on exitFrame me
  global gFlatWaitStart, gFlatLetIn
  gFlatLetIn = 0
  member("flat_load.status").text = AddTextToField("WaitingWhenCanGoIntoRoom")
  gFlatWaitStart = the milliSeconds
end
