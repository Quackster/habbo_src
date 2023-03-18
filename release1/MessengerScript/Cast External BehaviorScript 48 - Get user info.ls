on exitFrame me
  global gLoginName, gLoginPw, gUserLoginRetrieve
  gUserLoginRetrieve = 1
  sendEPFuseMsg("INFORETRIEVE" && gLoginName && gLoginPw)
end
