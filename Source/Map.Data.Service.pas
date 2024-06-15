unit Map.Data.Service;

interface

uses
  System.SysUtils, System.Classes, System.Variants, System.Rtti, System.TypInfo,
  System.SysConst, System.JSON, Generics.Collections,
  Map.Data.Types;

type
  TJSONDataImport = class(TObject)
  private
    procedure LoadLayers(const Source: TJSONValue; var Items: TLayerArray);
  public
    procedure Load(const Data: string; var Items: TMapArray);
  end;

implementation

{ TJSONDataImport }

procedure TJSONDataImport.LoadLayers(const Source: TJSONValue; var Items: TLayerArray);
var
  i: Integer;
  List: TJSONArray;
  JSONObject: TJSONValue;
begin
  if not (Source is TJSONArray) then
    Exit;

  List := Source as TJSONArray;
  SetLength(Items, List.Count);
  for i := 0 to List.Count - 1 do begin
    JSONObject := List.Items[i] as TJSONObject;
    Items[i].Assign(JSONObject);
  end;
end;

procedure TJSONDataImport.Load(const Data: string; var Items: TMapArray);
var
  Root: TJSONArray;
  JSONObject: TJSONValue;
  List: TJSONArray;
  i, j: Integer;
  Map: TMap;
begin
  JSONObject := TJSONObject.ParseJSONValue(Data);
  if not (JSONObject is TJSONArray) then
    Exit;

  Root := JSONObject as TJSONArray;
  try
    SetLength(Items, Root.Count);
    for i := 0 to Root.Count - 1 do begin
      JSONObject := Root.Items[i] as TJSONObject;

      Items[i].Assign(JSONObject);

//      List := JSONObject.FindValue('layers') as TJSONArray;
//      SetLength(Items[i].Layers, List.Count);
//      for j := 0 to List.Count - 1 do begin
//        JSONObject := List.Items[j] as TJSONObject;
//        Items[j].Assign(List.Items[j] as TJSONObject);
//      end;

//      Map.Name := JSONObject.GetValue<string>('name');
//      Map.Left := JSONObject.GetValue<Integer>('left');
//      Map.Top := JSONObject.GetValue<Integer>('top');
//      Map.Right := JSONObject.GetValue<Integer>('right');
//      Map.Bottom := JSONObject.GetValue<Integer>('bottom');
//      Items[i] := Map;
//      LoadLayerFromJSON(JSONObject.FindValue('layers'), Map.Layers);
//      LoadMarkersFromJSON(JSONObject.FindValue('markers'), Map.Tags);
//      LoadQuestsFromJSON(JSONObject.FindValue('quests'), Map.Quests);
    end;
  finally
    Root.Free;
  end;
end;

end.
