on construct(me)
  interface = 0
  component = 0
  handler = 0
  return(1)
  exit
end

on deconstruct(me)
  interface = 0
  component = 0
  handler = 0
  return(1)
  exit
end

on getInterface(me)
  return(interface)
  exit
end

on getComponent(me)
  return(component)
  exit
end

on getHandler(me)
  return(handler)
  exit
end