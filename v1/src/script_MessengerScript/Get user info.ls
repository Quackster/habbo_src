on exitFrame me 
  gUserLoginRetrieve = 1
  sendEPFuseMsg("INFORETRIEVE" && gLoginName && gLoginPw)
end
