object ArtPictureService: TArtPictureService
  OldCreateOrder = False
  AllowPause = False
  DisplayName = 'SEKA Article Picture Service'
  StartType = stManual
  AfterInstall = ServiceAfterInstall
  AfterUninstall = ServiceAfterUninstall
  OnShutdown = ServiceShutdown
  OnStart = ServiceStart
  OnStop = ServiceStop
  Height = 150
  Width = 215
end
