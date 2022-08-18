on construct me
  return initThread("games.index")
end

on deconstruct me
  return closeThread(#games)
end
