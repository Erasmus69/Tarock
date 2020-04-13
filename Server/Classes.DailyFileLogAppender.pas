unit Classes.DailyFileLogAppender;

interface

uses
  System.SyncObjs
, Spring.Logging
, Spring.Logging.Appenders
;

type
  TDailyFileLogAppender = class(TStreamLogAppender)
  private
    FBaseFileName: String;
    FLastFileDate: TDateTime;
    FLock: TCriticalSection;
    procedure SetFileName(const Value: string);
  protected
    procedure DoSend(const event: TLogEvent); override;
  public
    constructor Create;
    destructor Destroy; override;
    property FileName: string write SetFileName;
  end;

implementation

uses
  System.Classes
, System.SysUtils
;

{ TDailyFileLogAppender }

{======================================================================================================================}
constructor TDailyFileLogAppender.Create;
{======================================================================================================================}
begin
  inherited CreateInternal(True, nil);
  FLock := TCriticalSection.Create;
end;

{======================================================================================================================}
destructor TDailyFileLogAppender.Destroy;
{======================================================================================================================}
begin
  FLock.Free;

  inherited;
end;

{======================================================================================================================}
procedure TDailyFileLogAppender.DoSend(const event: TLogEvent);
{======================================================================================================================}
begin
  FLock.Enter;
  try
    if Date <> FLastFileDate then
      SetFileName(FBaseFileName);
  finally
    FLock.Leave;
  end;

  inherited;
end;

{======================================================================================================================}
procedure TDailyFileLogAppender.SetFileName(const Value: string);
{======================================================================================================================}
const
  SDateFormat: string = 'yyyy''-''mm''-''dd''';
var
  fileName: String;
  stream: TStream;
begin
  FBaseFileName := Value ;
  FLastFileDate := Date;

  if Value.Contains('%s') then
    fileName := System.SysUtils.Format(Value, [FormatDateTime(SDateFormat, FLastFileDate)])
  else
    fileName := Value;

  if FileExists(fileName) then begin
    stream := TFileStream.Create(fileName, fmOpenWrite or fmShareDenyWrite);
    stream.Seek(0, soFromEnd);
  end
  else
    stream := TFileStream.Create(fileName, fmCreate or fmShareDenyWrite);

  SetStream(stream);
end;

end.
