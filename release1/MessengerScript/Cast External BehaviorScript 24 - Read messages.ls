global gBuddyList, gMessageManager, gChosenBuddyId

on mouseDown me
  mname = sprite(me.spriteNum).member.name
  num = integer(char 6 of mname)
  gChosenBuddyId = getBuddyIdFromFieldNum(gBuddyList, num)
  goContext("msgread")
end
