on mouseDown me 
  mname = sprite(me.spriteNum).member.name
  num = integer(mname.char[6])
  gChosenBuddyId = getBuddyIdFromFieldNum(gBuddyList, num)
  goContext("msgread")
end
