on construct(me)
  return(1)
  exit
end

on deconstruct(me)
  return(1)
  exit
end

on defineClient(me)
  return(1)
  exit
end

on getSystemId(me)
  return(systemid)
  exit
end

on getMessageSender(me)
  return(messagesender)
  exit
end

on getMessageHandler(me)
  return(messageHandler)
  exit
end

on getBaseLogic(me)
  return(baselogic)
  exit
end

on getProcManager(me)
  return(procmanager)
  exit
end

on getTurnManager(me)
  return(turnmanager)
  exit
end

on getWorld(me)
  return(world)
  exit
end

on getComponent(me)
  return(component)
  exit
end

on getVariableManager(me)
  return(variablemanager)
  exit
end

on getFacade(me)
  return(getObject(systemid))
  exit
end