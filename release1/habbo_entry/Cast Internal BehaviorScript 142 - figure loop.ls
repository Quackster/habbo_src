global figurePartList, figureColorList

on exitFrame
  figurePartList = [:]
  figurePartList = [#sd: "sd=001", #hr: "hr=001", #hd: "hd=001", #ey: "ey=001", #fc: "fc=001", #bd: "bd=001", #lh: "lh=001", #rh: "rh=001", #ls: "ls=001", #rs: "rs=001", #lg: "lg=001", #sh: "sh=001"]
  figureColorList = [:]
  figureColorList = [#sd: "0", #hr: "0", #hd: "0", #ey: "0", #fc: "0", #bd: "0", #lh: "0", #rh: "0", #ls: "0", #rs: "0", #lg: "0", #sh: "0"]
  go(the frame)
end
