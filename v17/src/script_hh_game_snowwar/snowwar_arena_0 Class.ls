on construct(me)
  pEngine = createObject("Snowwar Engine", "Snowwar Arena Class")
  return(1)
  exit
end

on deconstruct(me)
  return(removeObject("Snowwar Engine"))
  exit
end

on prepare(me)
  return(pEngine.prepare())
  exit
end