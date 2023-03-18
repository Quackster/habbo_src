property pSquareRoot

on construct me
  return 1
end

on deconstruct me
  return 1
end

on testForObjectToObjectCollision me, tThisObject, tOtherObject, tDump
  if tThisObject = tOtherObject then
    return 0
  end if
  case tOtherObject.getGameObjectProperty(#gameobject_collisionshape_type) of
    #none:
      return 0
    #point:
      case tThisObject.getGameObjectProperty(#gameobject_collisionshape_type) of
        #none:
          return 0
        #point:
          return 0
        #circle:
          return me.TestPointToCircleCollision(tOtherObject, tThisObject)
        #triplecircle:
        #box:
      end case
    #circle:
      case tThisObject.getGameObjectProperty(#gameobject_collisionshape_type) of
        #none:
          return 0
        #point:
          return me.TestPointToCircleCollision(tThisObject, tOtherObject)
        #circle:
          return me.TestCircleToCircleCollision(tThisObject, tOtherObject, tDump)
        #triplecircle:
        #box:
          return 0
      end case
    #triplecircle:
      case tThisObject.getGameObjectProperty(#gameobject_collisionshape_type) of
        #none:
          return 0
        #box:
          return 0
      end case
    #box:
      case tThisObject.getGameObjectProperty(#gameobject_collisionshape_type) of
        #none:
          return 0
        #point:
        #circle:
          return 0
        #triplecircle:
          return 0
        #box:
          return 0
      end case
  end case
  return 0
end

on TestPointToCircleCollision me, tThisObject, tOtherObject
  distanceX = tOtherObject.getLocation().x - tThisObject.getLocation().x
  if distanceX < 0 then
    distanceX = -distanceX
  end if
  distanceY = tOtherObject.getLocation().y - tThisObject.getLocation().y
  if distanceY < 0 then
    distanceY = -distanceY
  end if
  if sqrt((distanceX * distanceX) + (distanceY * distanceY)) < tOtherObject.getGameObjectProperty(#gameobject_collisionshape_radius) then
    return 1
  else
    return 0
  end if
end

on TestCircleToCircleCollision me, tThisObject, tOtherObject, tDump
  distanceX = tOtherObject.getLocation().x - tThisObject.getLocation().x
  if distanceX < 0 then
    distanceX = -distanceX
  end if
  distanceY = tOtherObject.getLocation().y - tThisObject.getLocation().y
  if distanceY < 0 then
    distanceY = -distanceY
  end if
  collisionDistance = tOtherObject.getGameObjectProperty(#gameobject_collisionshape_radius) + tThisObject.getGameObjectProperty(#gameobject_collisionshape_radius)
  if (distanceY < collisionDistance) and (distanceX < collisionDistance) then
    if ((distanceX * distanceX) + (distanceY * distanceY)) < (collisionDistance * collisionDistance) then
      return 1
    end if
  end if
  return 0
end

on testDistance me, i_pos1X, i_pos1Y, i_pos2X, i_pos2Y, i_distance
  distX = abs(i_pos2X - i_pos1X)
  distY = abs(i_pos2Y - i_pos1Y)
  if (distX > i_distance) or (distY > i_distance) then
    return 0
  else
    if ((distX * distX) + (distY * distY)) < (i_distance * i_distance) then
      return 1
    end if
  end if
  return 0
end
