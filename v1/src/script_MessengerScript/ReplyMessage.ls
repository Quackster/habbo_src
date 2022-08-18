global gBuddyList, gMessageManager, gChosenBuddyId, gMModeChosenMode, gActiveMsg

on mouseUp me
  reply(gActiveMsg)
  goContext("writemsg")
end
