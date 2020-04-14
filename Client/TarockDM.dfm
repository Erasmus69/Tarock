object dmTarock: TdmTarock
  OldCreateOrder = False
  OnCreate = DataModuleCreate
  Height = 304
  Width = 670
  object WiRLClientApplication1: TWiRLClientApplication
    DefaultMediaType = 'application/json'
    AppName = 'app'
    Client = WiRLClient1
    Left = 144
    Top = 48
  end
  object WiRLClient1: TWiRLClient
    WiRLEngineURL = 'http://localhost:8080/rest'
    ProxyParams.BasicAuthentication = False
    ProxyParams.ProxyPort = 0
    NoProtocolErrorException = False
    Left = 176
    Top = 128
  end
  object resPlayers: TWiRLClientResourceJSON
    Application = WiRLClientApplication1
    Resource = 'v1/players'
    Left = 320
    Top = 136
  end
end
