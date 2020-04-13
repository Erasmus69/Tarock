unit Classes.Dataset.Helpers;

interface

uses
  Data.DB
, Spring
, RDQuery
;

type
  TFieldsValueReader = record
  private
    FQuery: TRDQuery;
  public
    function FieldAsStr(const AFieldName: string): string;
    function FieldAsNullableStr(const AFieldName: string): Nullable<String>;
    function FieldAsInt(const AFieldName: string): Integer;
    function FieldAsNullableInt(const AFieldName: string): TNullableInteger;
    function FieldAsFloat(const AFieldName: string): Double;
    function FieldAsDateTime(const AFieldName: string): TDateTime;
    function FieldAsNullableDateTime(const AFieldName: string): TNullableDateTime;

    property Query: TRDQuery read FQuery write FQuery;
  end;

implementation

{======================================================================================================================}
function TFieldsValueReader.FieldAsStr(const AFieldName: string): string;
{======================================================================================================================}
begin
  Result := FQuery.FieldByName(AFieldName).AsString;
end;

{======================================================================================================================}
function TFieldsValueReader.FieldAsNullableStr(const AFieldName: string): Nullable<String>;
{======================================================================================================================}
begin
  Result := nil;
  if (not FQuery.FieldByName(AFieldName).IsNull) then
    Result := FieldAsStr(AFieldName);
end;

{======================================================================================================================}
function TFieldsValueReader.FieldAsInt(const AFieldName: string): Integer;
{======================================================================================================================}
begin
  Result := FQuery.FieldByName(AFieldName).AsInteger;
end;

{======================================================================================================================}
function TFieldsValueReader.FieldAsNullableInt(const AFieldName: string): TNullableInteger;
{======================================================================================================================}
begin
  Result := nil;
  if (not FQuery.FieldByName(AFieldName).IsNull) then
    Result := FQuery.FieldByName(AFieldName).AsInteger;
end;

{======================================================================================================================}
function TFieldsValueReader.FieldAsFloat(const AFieldName: string): Double;
{======================================================================================================================}
begin
  Result := FQuery.FieldByName(AFieldName).AsFloat;
end;

{======================================================================================================================}
function TFieldsValueReader.FieldAsDateTime(const AFieldName: string): TDateTime;
{======================================================================================================================}
begin
  Result := FQuery.FieldByName(AFieldName).AsDateTime;
end;

{======================================================================================================================}
function TFieldsValueReader.FieldAsNullableDateTime(const AFieldName: string): TNullableDateTime;
{======================================================================================================================}
begin
  Result := nil;
  if (not FQuery.FieldByName(AFieldName).IsNull) then
    Result := FQuery.FieldByName(AFieldName).AsDateTime;
end;

end.
