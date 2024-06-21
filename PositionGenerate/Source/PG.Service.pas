unit PG.Service;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Rtti,
  System.TypInfo, System.SysConst, System.JSON, System.IOUtils, Generics.Collections;

type
  TMarkerKind = (PMCExtraction, ScavExtraction, CoopExtraction, Quest);

  TMap = record
  public
    Name: string;
    Left: Integer;
    Top: Integer;
    Right: Integer;
    Bottom: Integer;
  end;

  TMapArray = array of TMap;

  TPositionService = class(TComponent)
  private
    FItems: TMapArray;

    function GetItem(Index: Integer): TMap;
    procedure InternalLoad(const Data: string);
    function GetCount: Integer;
  public
    procedure LoadParams;
    procedure LoadDataFromJSON;
    function KindToStr(Value: TMarkerKind): string;

    property Items[Index: Integer]: TMap read GetItem;
    property Count: Integer read GetCount;
  end;

var
  PositionService: TPositionService;

implementation

uses
  PG.Constants;

{ TPositionService }

function TPositionService.GetItem(Index: Integer): TMap;
begin
  Result := FItems[Index];
end;

function TPositionService.GetCount: Integer;
begin
  Result := Length(FItems);
end;

procedure TPositionService.InternalLoad(const Data: string);
var
  Root: TJSONArray;
  JSONObject: TJSONValue;
  i: Integer;
begin
  JSONObject := TJSONObject.ParseJSONValue(Data);
  if not (JSONObject is TJSONArray) then
    Exit;

  Root := TJSONArray(JSONObject);
  try
    SetLength(FItems, Root.Count);
    for i := 0 to Root.Count - 1 do begin
      JSONObject := TJSONObject(Root.Items[i]);

      FItems[i].Name := JSONObject.GetValue<string>('name');
      FItems[i].Left := JSONObject.GetValue<Integer>('left');
      FItems[i].Top := JSONObject.GetValue<Integer>('top');
      FItems[i].Right := JSONObject.GetValue<Integer>('right');
      FItems[i].Bottom := JSONObject.GetValue<Integer>('bottom');
    end;
  finally
    Root.Free;
  end;
end;

procedure TPositionService.LoadParams;
begin
  AppParams.Load;
end;

procedure TPositionService.LoadDataFromJSON;
var
  Data: TStrings;
  FileName: string;
begin
  FileName := TPath.Combine(AppParams.DataPath, 'data.json');

  Data := TStringList.Create;
  try
    Data.LoadFromFile(FileName, TEncoding.UTF8);
    InternalLoad(Data.Text);
  finally
    Data.Free;
  end;
end;

function TPositionService.KindToStr(Value: TMarkerKind): string;
begin
  case Value of
    TMarkerKind.PMCExtraction:
      Result := 'Выход ЧВК';
    TMarkerKind.ScavExtraction:
      Result := 'Выход дикого';
    TMarkerKind.CoopExtraction:
      Result := 'Совм. выход';
    TMarkerKind.Quest:
      Result := 'Квест';
  else
    Result := '';
  end;
end;

end.
