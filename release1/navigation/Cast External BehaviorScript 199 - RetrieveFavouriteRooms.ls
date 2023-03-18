on mouseUp me
  global gMyName
  sendEPFuseMsg("GET_FAVORITE_ROOMS" && gMyName)
  put "Retrieving favourite rooms..."
end
