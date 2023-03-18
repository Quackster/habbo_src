on enterFrame me
  global goUserStrip
  if objectp(goUserStrip) then
    prepareHandItems(goUserStrip)
  end if
end
