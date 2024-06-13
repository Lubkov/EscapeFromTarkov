unit Unit1;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  System.Rtti, System.TypInfo, System.SysConst, System.JSON, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.StdCtrls;

type
  TMarkerKind = (PMCExtraction, ScavExtraction, CoopExtraction, Quest);

  TMarker = record
    Name: string;
    Kind: TMarkerKind;
    Left: Integer;
    Top: Integer;
  end;

  TMarkerArray = array of TMarker;

  TMap = record
    ID: Variant;
    Name: string;
    Left: Integer;
    Top: Integer;
    Right: Integer;
    Bottom: Integer;
    Markers: TMarkerArray;
  end;

  TForm1 = class(TForm)
    Panel1: TPanel;
    Memo1: TMemo;
    Button1: TButton;
    Button2: TButton;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
  private
    procedure Load(const Data: string);
    procedure LoadExtractions(const Value: TJSONValue; var Data: TMarkerArray);
  public
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

procedure TForm1.LoadExtractions(const Value: TJSONValue; var Data: TMarkerArray);
var
  List: TJSONArray;
  Item: TJSONValue;
  i: Integer;
begin
  if not (Value is TJSONArray) then begin
    SetLength(Data, 0);
    Exit;
  end;

  List := Value as TJSONArray;
  SetLength(Data, List.Count);

  for i := 0 to List.Count - 1 do begin
    Item := List.Items[i] as TJSONObject;

    Data[i].Name := Item.GetValue<string>('name');
    Data[i].Left := Item.GetValue<Integer>('left');
    Data[i].Top := Item.GetValue<Integer>('top');
  end;
end;

procedure TForm1.Load(const Data: string);
var
  List: TJSONArray;
  Item: TJSONValue;
  i: Integer;
  Map: TMap;
begin
  Item := TJSONObject.ParseJSONValue(Data);
  if not (Item is TJSONArray) then
    Exit;

  List := Item as TJSONArray;
  try
    for i := 0 to List.Count - 1 do begin
      Item := List.Items[i] as TJSONObject;

      Map.ID := Item.GetValue<Integer>('id');
      Map.Name := Item.GetValue<string>('name');
      Map.Left := Item.GetValue<Integer>('left');
      Map.Top := Item.GetValue<Integer>('top');
      Map.Right := Item.GetValue<Integer>('right');
      Map.Bottom := Item.GetValue<Integer>('bottom');

      LoadExtractions(Item.FindValue('markers'), Map.Markers);
    end;
  finally
    List.Free;
  end;
end;

procedure TForm1.Button1Click(Sender: TObject);
var
  Data: TStrings;
begin
  Data := TStringList.Create;
  try
    Data.LoadFromFile('d:\Projects\Delphi\EscapeFromTarkov\JsonTest\Data\map.json');
    Load(Data.Text);
  finally
    Data.Free;
  end;
end;

procedure TForm1.Button2Click(Sender: TObject);
var
  JSONObject: TJSONObject;
  Kind: TMarkerKind;
begin
  JSONObject := TJSONObject.Create;
  try
    JSONObject.AddPair('name', 'Woods');
//    JSONObject.AddPair('kind', GetEnumName(TypeInfo(TMarkerKind), integer(TMarkerKind.PMCExtraction)));
    JSONObject.AddPair('kind', TRttiEnumerationType.GetName<TMarkerKind>(TMarkerKind.PMCExtraction));

    Memo1.Lines.Add(JSONObject.ToJSON);
  finally
    JSONObject.Free;
  end;

  Kind := TRttiEnumerationType.GetValue<TMarkerKind>('ScavExtraction');
end;

end.
