property code
global gMyName

on mouseDown me
  sendEPFuseMsg("GETORDERINFO /" & code && gMyName)
end

on getPropertyDescriptionList me
  return [#code: [#comment: "Purchasing code (such as A1 STP)", #format: #string, #default: "A2 xxx"]]
end
