property m_mp_ar_rUsepool, m_mp_ar_rFreepool, m_iRefSource, m_iAllocationSize, m_rEmptyFactor, m_rEmptyVisual

on construct me
  m_mp_ar_rUsepool = [:]
  m_mp_ar_rFreepool = [:]
  m_iRefSource = 0
  m_iAllocationSize = 8
  m_rEmptyFactor = createObject("StubFactor", "CEmptyFactor")
  m_rEmptyVisual = createObject("StubVisual", "CEmptyVisualizer")
  return 1
end

on deconstruct me
  me.clearAll()
  removeObject("StubFactor")
  removeObject("StubVisual")
  return 1
end

on clearAll me
  repeat with t_ar_pool in m_mp_ar_rUsepool
    if t_ar_pool.count > 0 then
      repeat with tObject in t_ar_pool
        me.removeRoomObject(tObject.GetParam("CLASS"), tObject.GetParam("REF"))
      end repeat
      t_ar_pool = []
    end if
  end repeat
  m_mp_ar_rUsepool = [:]
  repeat with t_ar_pool in m_mp_ar_rFreepool
    if t_ar_pool.count > 0 then
      repeat with tObject in t_ar_pool
        me.removeRoomObject(tObject.GetParam("CLASS"), tObject.GetParam("REF"))
      end repeat
      t_ar_pool = []
    end if
  end repeat
  m_mp_ar_rFreepool = [:]
end

on FreeAll me
  repeat with t_ar_pool in m_mp_ar_rUsepool
    if t_ar_pool.count > 0 then
      repeat with tObject in t_ar_pool
        me.FreeObject(tObject)
      end repeat
    end if
  end repeat
end

on Reserve me, a_sClass, a_iCount
  tClassPool = m_mp_ar_rFreepool.getaProp(a_sClass)
  if voidp(tClassPool) then
    m_mp_ar_rFreepool.setaProp(a_sClass, [])
  end if
  tClassPool = m_mp_ar_rFreepool.getaProp(a_sClass)
  if voidp(a_iCount) then
    a_iCount = m_iAllocationSize
  end if
  repeat with i = 1 to a_iCount
    tNewObject = me.createRoomObject(a_sClass, me.GetNewRef())
    tNewObject.m_rFactor.deconstruct()
    tNewObject.m_rVisual.deconstruct()
    tNewObject.SetParam("StandardFactor", tNewObject.GetFactor())
    tNewObject.SetParam("StandardVisual", tNewObject.getVisual())
    tNewObject.m_rFactor = m_rEmptyFactor
    tNewObject.m_rVisual = m_rEmptyVisual
    tClassPool.append(tNewObject)
  end repeat
end

on newObject me, a_sClass, a_mp_params
  tClassPool = m_mp_ar_rFreepool.getaProp(a_sClass)
  if voidp(tClassPool) then
    me.Reserve(a_sClass)
  end if
  tClassPool = m_mp_ar_rFreepool.getaProp(a_sClass)
  if tClassPool.count < 1 then
    me.Reserve(a_sClass)
  end if
  tUsePool = m_mp_ar_rUsepool.getaProp(a_sClass)
  if voidp(tUsePool) then
    m_mp_ar_rUsepool.setaProp(a_sClass, [])
  end if
  tUsePool = m_mp_ar_rUsepool.getaProp(a_sClass)
  tObject = tClassPool[tClassPool.count]
  tObject.m_rFactor = tObject.GetParam("StandardFactor")
  tObject.m_rVisual = tObject.GetParam("StandardVisual")
  tObject.m_rFactor.construct()
  tObject.m_rVisual.construct()
  tClassPool.deleteAt(tClassPool.count)
  tUsePool.append(tObject)
  if not voidp(a_mp_params) then
    repeat with i = 1 to a_mp_params.count
      tKey = a_mp_params.getPropAt(i)
      tValue = a_mp_params.getaProp(tKey)
      tObject.SetParam(tKey, tValue)
    end repeat
  end if
  return tObject
end

on FreeObject me, a_rObject
  t_sClass = a_rObject.GetParam("CLASS")
  tUsePool = m_mp_ar_rUsepool.getaProp(t_sClass)
  t_iIndex = tUsePool.getOne(a_rObject)
  if t_iIndex = 0 then
    return error(me, "ERROR : Objectpool reference mismatch!", #FreeObject)
  end if
  tUsePool.deleteAt(t_iIndex)
  tClassPool = m_mp_ar_rFreepool.getaProp(t_sClass)
  tClassPool.append(a_rObject)
  a_rObject.m_rFactor.deconstruct()
  a_rObject.m_rVisual.deconstruct()
  a_rObject.SetParam("StandardFactor", a_rObject.GetFactor())
  a_rObject.SetParam("StandardVisual", a_rObject.getVisual())
  a_rObject.m_rFactor = m_rEmptyFactor
  a_rObject.m_rVisual = m_rEmptyVisual
  return 1
end

on createRoomObject me, a_sClass, a_iRef, a_mp_params
  t_rXML = CreateXML()
  t_rXML.open(getMember("empty.node.xml").text)
  t_rXML.Search("type", "NODE")
  t_rXML.SetParam("REF", a_iRef)
  t_rXML.SetParam("CLASS", a_sClass)
  t_rRoomContext = getThread(#room).getComponent()._AccessRoom()
  t_rRoomContext._CreateIndexed(a_iRef, a_sClass, t_rXML)
  tNewObject = t_rRoomContext._AccessIndexed(a_iRef, a_sClass)
  tNewObject.SetParam("Reference", a_iRef)
  if not voidp(a_mp_params) then
    repeat with i = 1 to a_mp_params.count
      tKey = a_mp_params.getPropAt(i)
      tValue = a_mp_params.getaProp(tKey)
      tNewObject.SetParam(tKey, tValue)
    end repeat
  end if
  return tNewObject
end

on removeRoomObject me, a_sClass, a_iRef
  t_rRoomContext = getThread(#room).getComponent()._AccessRoom()
  if not voidp(t_rRoomContext) then
    t_rRoomContext._RemoveIndexed(a_iRef, a_sClass)
  end if
end

on GetNewRef me
  m_iRefSource = m_iRefSource + 1
  return m_iRefSource
end
