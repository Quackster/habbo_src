property id, valid, delays

on construct me
  valid = 1
  delays = [:]
  return 1
end

on deconstruct me
  if count(delays) > 0 then
    repeat with i = 1 to count(delays)
      timeout(delays.getPropAt(i)).forget()
    end repeat
  end if
  delays = [:]
  return 1
end

on setID me, tid
  if voidp(me.id) then
    id = tid
  else
    error(me, "Attempted to redefine object's ID:" & RETURN & me.id && "->" && tid, #setID)
  end if
end

on getID me
  return id
end

on delay me, tTime, tMethod, tArgument
  if not integerp(tTime) then
    return error(me, "Integer expected:" && tTime, #delay)
  end if
  if not symbolp(tMethod) then
    return error(me, "Symbol expected:" && tMethod, #delay)
  end if
  tUniqueId = "Delay" && me.getID() && the milliSeconds
  timeout(tUniqueId).new(tTime, #executeDelay, me)
  tList = [#method: tMethod, #argument: tArgument]
  me.delays[tUniqueId] = tList
  return tUniqueId
end

on cancel me, tDelayID
  if voidp(me.delays[tDelayID]) then
    return 0
  end if
  timeout(tDelayID).forget()
  return me.delays.deleteProp(tDelayID)
end

on getRefCount me
  return integer(string(param(1)).word[string(param(1)).word.count - 1]) - 3
end

on print me
  put me
end

on executeDelay me, tTimeout
  tid = tTimeout.name
  tTask = delays[tid]
  me.cancel(tid)
  call(tTask[#method], me, tTask[#argument])
end
