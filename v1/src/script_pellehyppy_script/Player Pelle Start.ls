on exitFrame
  global goJumper, gKeyAcceptTime, gKeycounter
  gKeyAcceptTime = VOID
  gKeycounter = VOID
  goJumper = VOID
  set the scriptInstanceList of sprite 40 to []
  goJumper = new(script("JumpingPelle Class"), "toto", "sd=001/0&hr=010/224,186,120&hd=002/255,204,153&ey=003/0&fc=001/255,204,153&bd=001/255,204,153&lh=001/255,204,153&rh=001/255,204,153&ls=001/217,113,69&rs=001/217,113,69&lg=004/102,102,102&sh=001/192,180,199&ch=001/217,113,69", "ch=s02/225,204,220", 1)
  set the scriptInstanceList of sprite 40 to [goJumper]
end
