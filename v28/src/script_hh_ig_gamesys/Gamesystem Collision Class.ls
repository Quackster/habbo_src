on construct(me)
  return(1)
  exit
end

on deconstruct(me)
  return(1)
  exit
end

on testForObjectToObjectCollision(me, tThisObject, tOtherObject, tDump)
  if tThisObject = tOtherObject then
    return(0)
  end if
  if me = #none then
    return(0)
  else
    if me = #point then
      if me = #none then
        return(0)
      else
        if me = #point then
          return(0)
        else
          if me = #circle then
            return(me.TestPointToCircleCollision(tOtherObject, tThisObject))
          else
            if me = #triplecircle then
            else
              if me = #box then
              end if
            end if
          end if
        end if
      end if
    else
      if me = #circle then
        if me = #none then
          return(0)
        else
          if me = #point then
            return(me.TestPointToCircleCollision(tThisObject, tOtherObject))
          else
            if me = #circle then
              return(me.TestCircleToCircleCollision(tThisObject, tOtherObject, tDump))
            else
              if me = #triplecircle then
              else
                if me = #box then
                  return(0)
                end if
              end if
            end if
          end if
        end if
      else
        if me = #triplecircle then
          if me = #none then
            return(0)
          else
            if me = #box then
              return(0)
            end if
          end if
        else
          if me = #box then
            if me = #none then
              return(0)
            else
              if me = #point then
              else
                if me = #circle then
                  return(0)
                else
                  if me = #triplecircle then
                    return(0)
                  else
                    if me = #box then
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
  exit
end

on TestPointToCircleCollision(me, tThisObject, tOtherObject)
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
    if sqrt(distanceX * distanceX + distanceY * distanceY) < tOtherObject.getGameObjectProperty(#gameobject_collisionshape_radius) then
      return(1)
    end if
  end if
  return(0)
  exit
end

on TestCircleToCircleCollision(me, tThisObject, tOtherObject, tDump)
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
    if distanceX * distanceX + distanceY * distanceY < collisionDistance * collisionDistance then
      return(1)
    end if
  end if
  return(0)
  exit
end

on testDistance(me, i_pos1X, i_pos1Y, i_pos2X, i_pos2Y, i_distance)
  distX = abs(i_pos2X - i_pos1X)
  distY = abs(i_pos2Y - i_pos1Y)
  if distX > i_distance or distY > i_distance then
    return(0)
  else
    if distX * distX + distY * distY < i_distance * i_distance then
      return(1)
    end if
  end if
  return(0)
  exit
end