unit Server.DataModule;

interface

uses
  System.SysUtils, System.Classes, System.ImageList, Vcl.ImgList, Vcl.Controls;

type
  Tdm = class(TDataModule)
    imCards: TImageList;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  dm: Tdm;

implementation

{%CLASSGROUP 'Vcl.Controls.TControl'}

{$R *.dfm}

end.
