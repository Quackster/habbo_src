property interface, component, handler, parser

on construct me
  interface = 0
  component = 0
  handler = 0
  parser = 0
  return 1
end

on deconstruct me
  interface = 0
  component = 0
  handler = 0
  parser = 0
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

on getParser me
  return parser
end
