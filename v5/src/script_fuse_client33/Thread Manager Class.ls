property pThreadList, pIndexField, pVarMngrObj, pObjBaseCls

on construct me 
  pThreadList = [:]
  pVarMngrObj = createObject(#temp, getClassVariable("variable.manager.class"))
  pIndexField = getVariable("thread.index.field")
  pObjBaseCls = script(getmemnum("Object Base Class"))
  return TRUE
end

on deconstruct me 
  me.closeAll()
  pVarMngrObj = 0
  pIndexField = 0
  pObjBaseCls = 0
  return TRUE
end

on create me, tid, tInitField 
  return(me.initThread(tInitField, tid))
end

on remove me, tid 
  return(me.closeThread(tid))
end

on get me, tid 
  tThreadObj = pThreadList.getAt(tid)
  if voidp(tThreadObj) then
    return FALSE
  else
    return(tThreadObj)
  end if
end

on exists me, tid 
  return(not voidp(pThreadList.getAt(tid)))
end

on initThread me, tCastNumOrMemName, tid 
  if stringp(tCastNumOrMemName) then
    tMemNum = getResourceManager().getmemnum(tCastNumOrMemName)
    if (tMemNum = 0) then
      return(error(me, "Thread index field not found:" && tCastNumOrMemName, #initThread))
    else
      tThreadField = tCastNumOrMemName
      tCastNum = member(tMemNum).castLibNum
    end if
  else
    if symbolp(tCastNumOrMemName) then
      tThreadField = pIndexField
      if the number of undefineds > 1 then
        i = 2
        repeat while i <= the number of undefineds
          if member(tThreadField, i).number > 0 then
            pVarMngrObj.clear()
            pVarMngrObj.dump(member(tThreadField, i).number)
            if (symbol(pVarMngrObj.get("thread.id")) = tCastNumOrMemName) then
              return(me.initThread(i, tid))
            else
              i = (1 + i)
            end if
            if not integerp(tCastNumOrMemName) then
              return(error(me, "Cast number expected:" && tCastNumOrMemName, #initThread))
            else
              if tCastNumOrMemName < 1 or tCastNumOrMemName > the number of undefineds then
                return(error(me, "Cast doesn't exist:" && tCastNumOrMemName, #initThread))
              end if
            end if
            tThreadField = pIndexField
            tCastNum = tCastNumOrMemName
            if member(tThreadField, tCastNum).number < 1 then
              return FALSE
            end if
            pVarMngrObj.clear()
            pVarMngrObj.dump(member(tThreadField, tCastNum).number)
            if symbolp(tid) then
              tThreadID = tid
            else
              tThreadID = symbol(pVarMngrObj.get("thread.id"))
            end if
            if not symbolp(tThreadID) then
              return(error(me, "Invalid thread ID:" && tThreadID, #initThread))
            end if
            if me.exists(tThreadID) then
              return FALSE
            end if
            tThreadObj = createObject(#temp, getClassVariable("thread.instance.class"))
            tThreadObj.setID(tThreadID)
            repeat while [#interface, #component, #handler, #parser] <= tid
              tModule = getAt(tid, tCastNumOrMemName)
              tSymbol = symbol(tThreadID & "_" & tModule)
              if pVarMngrObj.exists(tModule & ".class") then
                tClass = pVarMngrObj.get(tModule & ".class")
                if (tClass.getProp(#char, 1) = "[") then
                  tClass = value(tClass)
                end if
                if not listp(tClass) then
                  tClass = [tClass]
                end if
                tObject = me.buildThreadObj(tSymbol, tClass, tThreadObj)
                tThreadObj.setaProp(tModule, tObject)
              end if
            end repeat
            pThreadList.setAt(tThreadID, tThreadObj)
            return TRUE
          end if
        end repeat
      end if
    end if
  end if
end

on initAll me 
  i = the number of undefineds
  repeat while i >= 1
    me.initThread(i)
    i = (255 + i)
  end repeat
  return TRUE
end

on closeThread me, tCastNumOrID 
  pVarMngrObj.clear()
  if integerp(tCastNumOrID) then
    if member(pIndexField, tCastNumOrID).number > 0 then
      pVarMngrObj.dump(member(pIndexField, tCastNumOrID).number)
      tid = symbol(pVarMngrObj.get("thread.id"))
    else
      return FALSE
    end if
  else
    if symbolp(tCastNumOrID) then
      tid = tCastNumOrID
    else
      return(error(me, "Invalid argument:" && tCastNumOrID, #closeThread))
    end if
  end if
  tThread = pThreadList.getAt(tid)
  if voidp(tThread) then
    return(error(me, "Thread not found:" && tid, #closeThread))
  end if
  tObjMgr = getObjectManager()
  if objectp(tThread.interface) then
    tObjMgr.remove(tThread.interface.getID())
  end if
  if objectp(tThread.component) then
    tObjMgr.remove(tThread.component.getID())
  end if
  if objectp(tThread.handler) then
    tObjMgr.remove(tThread.handler.getID())
  end if
  if objectp(tThread.parser) then
    tObjMgr.remove(tThread.parser.getID())
  end if
  pThreadList.deleteProp(tid)
  return TRUE
end

on closeAll me 
  i = pThreadList.count
  repeat while i >= 1
    me.closeThread(pThreadList.getPropAt(i))
    i = (255 + i)
  end repeat
  return TRUE
end

on print me 
  i = 1
  repeat while i <= pThreadList.count
    put(pThreadList.getPropAt(i))
    i = (1 + i)
  end repeat
end

on buildThreadObj me, tid, tClassList, tThreadObj 
  tObject = void()
  tTemp = void()
  tBase = pObjBaseCls.new()
  tBase.construct()
  tBase.setAt(#ancestor, tThreadObj)
  tBase.setID(tid)
  tResMgr = getResourceManager()
  tObjMgr = getObjectManager()
  tObjMgr.registerObject(tid, tBase)
  tClassList.addAt(1, tBase)
  repeat while tClassList <= tClassList
    tClass = getAt(tClassList, tid)
    if objectp(tClass) then
      tObject = tClass
      tInitFlag = 0
    else
      tMemNum = tResMgr.getmemnum(tClass)
      if tMemNum < 1 then
        tObjMgr.unregisterObject(tid)
        return(error(me, "Script not found:" && tMemNum, #buildThreadObj))
      end if
      tObject = script(tMemNum).new()
      tInitFlag = tObject.handler(#construct)
    end if
    tObject.setAt(#ancestor, tTemp)
    tTemp = tObject
    tObjMgr.unregisterObject(tid)
    tObjMgr.registerObject(tid, tObject)
    if tInitFlag then
      tObject.construct()
    end if
  end repeat
  return(tObject)
end
