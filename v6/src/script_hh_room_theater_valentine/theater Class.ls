property pAnimPhase, pAnimTimer

on construct me 
  pAnimPhase = 0
  pAnimTimer = the timer
  return TRUE
end

on deconstruct me 
  return(removeUpdate(me.getID()))
end

on prepare me 
  return(receiveUpdate(me.getID()))
end

on update me 
  if (pAnimPhase = 0) then
    if the timer > (pAnimTimer + (60 * 20)) then
      if (random(20) = 1) then
        tMode = random(4)
        tObj = getThread(#room).getInterface().getRoomVisualizer()
        if (tObj = 0) then
          return FALSE
        end if
        if (tMode = 1) then
          tSp = tObj.getSprById("valentinebear_eyes")
          if (tSp = 0) then
            return FALSE
          end if
          tSp.blend = 100
          pAnimPhase = 3
        else
          if (tMode = 2) then
            tSp = tObj.getSprById("valentinebear_ears")
            if (tSp = 0) then
              return FALSE
            end if
            tSp.blend = 100
            pAnimPhase = 3
          else
            if (tMode = 3) then
              tSp1 = tObj.getSprById("valentinebear_ears")
              tSp2 = tObj.getSprById("valentinebear_eyes")
              if (tSp1 = 0) or (tSp2 = 0) then
                return FALSE
              end if
              tSp1.blend = 100
              tSp2.blend = 100
              pAnimPhase = 3
            else
              if (tMode = 4) then
                tSp = tObj.getSprById("valentinebear_eyes")
                if (tSp = 0) then
                  return FALSE
                end if
                tSp.blend = 100
                pAnimPhase = 1
              end if
            end if
          end if
        end if
        pAnimTimer = the timer
      end if
    end if
  else
    if (tMode = 1) then
      if the timer > (pAnimTimer + 10) then
        tObj = getThread(#room).getInterface().getRoomVisualizer()
        if (tObj = 0) then
          return FALSE
        end if
        tSp1 = tObj.getSprById("valentinebear_eyes")
        if (tSp1 = 0) then
          return FALSE
        end if
        tSp1.blend = 0
        pAnimPhase = 2
      end if
    else
      if (tMode = 2) then
        if the timer > (pAnimTimer + 20) then
          tObj = getThread(#room).getInterface().getRoomVisualizer()
          if (tObj = 0) then
            return FALSE
          end if
          tSp1 = tObj.getSprById("valentinebear_eyes")
          if (tSp1 = 0) then
            return FALSE
          end if
          tSp1.blend = 100
          pAnimPhase = 3
        end if
      else
        if (tMode = 3) then
          if the timer > (pAnimTimer + 30) then
            tObj = getThread(#room).getInterface().getRoomVisualizer()
            if (tObj = 0) then
              return FALSE
            end if
            tSp1 = tObj.getSprById("valentinebear_ears")
            tSp2 = tObj.getSprById("valentinebear_eyes")
            if (tSp1 = 0) or (tSp2 = 0) then
              return FALSE
            end if
            tSp1.blend = 0
            tSp2.blend = 0
            pAnimPhase = 0
            pAnimTimer = the timer
          end if
        end if
      end if
    end if
  end if
end

on showprogram me, tMsg 
  if voidp(tMsg) then
    return FALSE
  end if
  tDst = tMsg.getAt(#show_dest)
  tCmd = tMsg.getAt(#show_command)
  tPar = tMsg.getAt(#show_params)
  put(tDst, tCmd, tPar)
end
