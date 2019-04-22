on constructBrokerManager()
  return(createManager(#broker_manager, getClassVariable("broker.manager.class")))
  exit
end

on deconstructBrokerManager()
  return(removeManager(#broker_manager))
  exit
end

on getBrokerManager()
  tMgr = getObjectManager()
  if not tMgr.managerExists(#broker_manager) then
    return(constructBrokerManager())
  end if
  return(tMgr.getManager(#broker_manager))
  exit
end

on createBroker(tMessage)
  return(getBrokerManager().create(tMessage))
  exit
end

on removeBroker(tMessage)
  return(getBrokerManager().Remove(tMessage))
  exit
end

on getBroker(tMessage)
  return(getBrokerManager().get(tMessage))
  exit
end

on brokerExists(tMessage)
  return(getBrokerManager().exists(tMessage))
  exit
end

on printBrokers()
  return(getBrokerManager().print())
  exit
end

on registerMessage(tMessage, tClientID, tMethod)
  return(getBrokerManager().register(tMessage, tClientID, tMethod))
  exit
end

on unregisterMessage(tMessage, tClientID)
  return(getBrokerManager().unregister(tMessage, tClientID))
  exit
end

on executeMessage(tMessage, tArgA, tArgB, tArgC)
  return(getBrokerManager().execute(tMessage, tArgA, tArgB, tArgC))
  exit
end