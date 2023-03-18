property isupdate
global gLoginName, gLoginPw, gGoTo, gUserLoginRetrieve

on exitFrame me
  if isupdate then
    fuseRegister(isupdate)
  end if
  gLoginName = field("loginname")
  gLoginPw = field("loginpw")
  put field("charactername_field")
  put field("password_field")
  put isupdate
  epLogin(gLoginName, gLoginPw)
  gUserLoginRetrieve = 1
  sendEPFuseMsg("INFORETRIEVE" && gLoginName && gLoginPw)
end

on getPropertyDescriptionList me
  pList = [:]
  addProp(pList, #isupdate, [#comment: "is this update", #default: 0, #format: #boolean])
  return pList
end
