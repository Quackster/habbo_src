on deconstruct me
  return removeUpdate(me.getID())
end

on StartUpdateBigSplash me
  return receiveUpdate(me.getID())
end

on HideBigSplash me
  me.setVisible(0)
end

on update me
  if me.pVisible = 1 then
    me.updateSplashs()
  end if
end
