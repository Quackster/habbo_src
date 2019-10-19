on construct me 
  return(1)
end

on deconstruct me 
  return(1)
end

on testForObjectToObjectCollision me, tThisObject, tOtherObject, tDump 
  if tThisObject = tOtherObject then
    return(0)
  end if
  if tOtherObject.getGameObjectProperty(#gameobject_collisionshape_type) = #none then
    return(0)
  else
    if tOtherObject.getGameObjectProperty(#gameobject_collisionshape_type) = #point then
      if tOtherObject.getGameObjectProperty(#gameobject_collisionshape_type) = #none then
        return(0)
      else
        if tOtherObject.getGameObjectProperty(#gameobject_collisionshape_type) = #point then
          return(0)
        else
          if tOtherObject.getGameObjectProperty(#gameobject_collisionshape_type) = #circle then
            return(me.TestPointToCircleCollision(tOtherObject, tThisObject))
          else
            if tOtherObject.getGameObjectProperty(#gameobject_collisionshape_type) = #triplecircle then
            else
              if tOtherObject.getGameObjectProperty(#gameobject_collisionshape_type) = #box then
              end if
            end if
          end if
        end if
      end if
    else
      if tOtherObject.getGameObjectProperty(#gameobject_collisionshape_type) = #circle then
        if tOtherObject.getGameObjectProperty(#gameobject_collisionshape_type) = #none then
          return(0)
        else
          if tOtherObject.getGameObjectProperty(#gameobject_collisionshape_type) = #point then
            return(me.TestPointToCircleCollision(tThisObject, tOtherObject))
          else
            if tOtherObject.getGameObjectProperty(#gameobject_collisionshape_type) = #circle then
              return(me.TestCircleToCircleCollision(tThisObject, tOtherObject, tDump))
            else
              if tOtherObject.getGameObjectProperty(#gameobject_collisionshape_type) = #triplecircle then
              else
                if tOtherObject.getGameObjectProperty(#gameobject_collisionshape_type) = #box then
                  return(0)
                end if
              end if
            end if
          end if
        end if
      else
        if tOtherObject.getGameObjectProperty(#gameobject_collisionshape_type) = #triplecircle then
          if tOtherObject.getGameObjectProperty(#gameobject_collisionshape_type) = #none then
            return(0)
          else
            if tOtherObject.getGameObjectProperty(#gameobject_collisionshape_type) = #box then
              return(0)
            end if
          end if
        else
          if tOtherObject.getGameObjectProperty(#gameobject_collisionshape_type) = #box then
            if tOtherObject.getGameObjectProperty(#gameobject_collisionshape_type) = #none then
              return(0)
            else
              if tOtherObject.getGameObjectProperty(#gameobject_collisionshape_type) = #point then
              else
                if tOtherObject.getGameObjectProperty(#gameobject_collisionshape_type) = #circle then
                  return(0)
                else
                  if tOtherObject.getGameObjectProperty(#gameobject_collisionshape_type) = #triplecircle then
                    return(0)
                  else
                    if tOtherObject.getGameObjectProperty(#gameobject_collisionshape_type) = #box then
                      return(0)
                    end if
                  end if
                end if
              end if
            end if
          end if
        end if
      end if
    end if
  end if
  return(0)
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
  collisionDistance = tOtherObject.getGameObjectProperty(#gameobject_collisionshape_radius)
  if distanceY <= collisionDistance and distanceX <= collisionDistance then
    if sqrt((distanceX * distanceX) + (distanceY * distanceY)) < tOtherObject.getGameObjectProperty(#gameobject_collisionshape_radius) then
      return(1)
    end if
  end if
  return(0)
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
  if distanceY <= collisionDistance and distanceX <= collisionDistance then
    if (distanceX * distanceX) + (distanceY * distanceY) < (collisionDistance * collisionDistance) then
      return(1)
    end if
  end if
  return(0)
end

on testDistance me, i_pos1X, i_pos1Y, i_pos2X, i_pos2Y, i_distance 
  distX = abs(i_pos2X - i_pos1X)
  distY = abs(i_pos2Y - i_pos1Y)
  if distX > i_distance or distY > i_distance then
    return(0)
  else
    if (distX * distX) + (distY * distY) < (i_distance * i_distance) then
      return(1)
    end if
  end if
  return(0)
end
