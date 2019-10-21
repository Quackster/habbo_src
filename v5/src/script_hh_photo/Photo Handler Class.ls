on construct(me)
  registerListener(getVariable("connection.info.id"), me.getID(), ["FILM":#handle_film])
  getMultiuserManager().registerListener(getVariable("connection.mus.id"), me.getID(), ["FILM":#handle_film])
  return(1)
  exit
end

on deconstruct(me)
  unregisterListener(getVariable("connection.info.id"), me.getID(), ["FILM":#handle_film])
  getMultiuserManager().unregisterListener(getVariable("connection.mus.id"), me.getID(), ["FILM":#handle_film])
  return(1)
  exit
end

on handle_film(me, tMsg)
  me.getComponent().setFilm(value(tMsg.getaProp(#content)))
  exit
end