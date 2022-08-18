property pEngine

on construct me
  pEngine = createObject("Snowwar Engine", "Snowwar Arena Class")
  return 1
end

on deconstruct me
  return removeObject("Snowwar Engine")
end

on prepare me
  return pEngine.prepare()
end
