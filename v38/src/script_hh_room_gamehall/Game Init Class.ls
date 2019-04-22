on construct(me)
  return(initThread("games.index"))
  exit
end

on deconstruct(me)
  return(closeThread(#games))
  exit
end