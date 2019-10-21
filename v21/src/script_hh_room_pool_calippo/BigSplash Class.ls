on deconstruct(me)
  return(removeUpdate(me.getID()))
  exit
end

on StartUpdateBigSplash(me)
  return(receiveUpdate(me.getID()))
  exit
end

on HideBigSplash(me)
  me.setVisible(0)
  exit
end

on update(me)
  if me.pVisible = 1 then
    me.updateSplashs()
  end if
  exit
end