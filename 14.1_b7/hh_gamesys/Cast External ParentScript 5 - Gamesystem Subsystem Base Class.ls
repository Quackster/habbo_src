property systemid, messagesender, messageHandler, baselogic, procmanager, turnmanager, world, component, variablemanager

on construct me
  return 1
end

on deconstruct me
  return 1
end

on defineClient me
  return 1
end

on getSystemId me
  return systemid
end

on getMessageSender me
  return messagesender
end

on getMessageHandler me
  return messageHandler
end

on getBaseLogic me
  return baselogic
end

on getProcManager me
  return procmanager
end

on getTurnManager me
  return turnmanager
end

on getWorld me
  return world
end

on getComponent me
  return component
end

on getVariableManager me
  return variablemanager
end

on getFacade me
  return getObject(systemid)
end
