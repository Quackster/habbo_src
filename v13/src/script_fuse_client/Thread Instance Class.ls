property interface, component, handler

on construct me
  interface = 0
  component = 0
  handler = 0
  return 1
end

on deconstruct me
  interface = 0
  component = 0
  handler = 0
  return 1
end

on getInterface me
  return interface
end

on getComponent me
  return component
end

on getHandler me
  return handler
end
