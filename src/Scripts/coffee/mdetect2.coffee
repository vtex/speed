console.log "Welcome to VTEX Speed! Have a nice day"  if console.log

InitDeviceScan2 = ->

  #We'll use these 4 variables to speed other processing. They're super common.
  #    isIphone = DetectIphoneOrIpod();
  #    isAndroidPhone = DetectAndroidPhone();
  #    isTierIphone = DetectTierIphone();
  #    isTierTablet = DetectTierTablet();

  #    //Optional: Comment these out if you don't need them.
  #    isTierRichCss = DetectTierRichCss();
  #    isTierGenericMobile = DetectTierOtherPhones();
  ScreenMediaType = 0 #desktop
  href = document.location.href
  pos = href.indexOf("?")
  aux = ""
  ScreenMediaType = 2  if DetectIphoneOrIpod() #iphoneIpod
  ScreenMediaType = 3  if DetectTierTablet() # Tablet
  ScreenMediaType = 4  if DetectAndroidPhone() # Android
  ScreenMediaType = 5  if DetectTierOtherPhones() #generic
  ScreenMediaType = 5  if DetectBlackBerry() #generic

  #alert(navigator.userAgent.toLowerCase());
  unless ScreenMediaType is 0
    unless pos is -1
      aux = "&uam=true&mobile=" + ScreenMediaType
    else
      aux = "?uam=true&mobile=" + ScreenMediaType
    document.location.href = href + aux
  return

#Now, run the initialization method.
InitDeviceScan2()