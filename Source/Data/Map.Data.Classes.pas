unit Map.Data.Classes;

interface

uses
  System.SysUtils, System.Classes, System.Variants, System.Rtti, System.TypInfo,
  System.SysConst, System.JSON, Generics.Collections, Map.Data.Types;

type
  TJSONDataImport = class(TObject)
  private
    class procedure LoadLayers(const Source: TJSONValue; Items: TList<TLayer>);
    class procedure LoadMarkers(const Source: TJSONValue; Items: TList<TMarker>);
    class procedure LoadMarkerItems(const Source: TJSONValue; Items: TList<TItemImage>);
    class procedure LoadMarkerImages(const Source: TJSONValue; Items: TObjectList<TMarkerImage>);
    class procedure LoadQuests(const Source: TJSONValue; Items: TList<TQuest>);
  public
    class procedure Load(const Data: string; Items: TList<TMap>);
    class procedure LoadFromFile(const FileName: string; Items: TList<TMap>);
  end;

  TJSONDataExport = class(TObject)
  private
    class procedure SaveLayers(const Root: TJSONObject; Items: TList<TLayer>);
    class procedure SaveMarkers(const Root: TJSONObject; Items: TList<TMarker>);
    class procedure SaveMarkerItems(const Root: TJSONObject; Items: TList<TItemImage>);
    class procedure SaveMarkerImages(const Root: TJSONObject; Items: TObjectList<TMarkerImage>);
    class procedure SaveQuests(const Root: TJSONObject; Items: TList<TQuest>);
  public
    class function Save(Items: TList<TMap>): string;
    class procedure SaveToFile(const FileName: string; Items: TList<TMap>);
  end;

implementation

class procedure TJSONDataImport.LoadLayers(const Source: TJSONValue; Items: TList<TLayer>);
var
  i: Integer;
  List: TJSONArray;
  Layer: TLayer;
begin
  if not (Source is TJSONArray) then
    Exit;

  List := TJSONArray(Source);
  for i := 0 to List.Count - 1 do begin
    Layer := TLayer.Create;
    try
      Layer.Assign(TJSONObject(List.Items[i]));
    finally
      Items.Add(Layer);
    end;
  end;
end;

class procedure TJSONDataImport.LoadMarkers(const Source: TJSONValue; Items: TList<TMarker>);
var
  i: Integer;
  List: TJSONArray;
  JSONObject: TJSONValue;
  Marker: TMarker;
begin
  if not (Source is TJSONArray) then
    Exit;

  List := TJSONArray(Source);
  for i := 0 to List.Count - 1 do begin
    JSONObject := TJSONObject(List.Items[i]);

    Marker := TMarker.Create;
    try
      Marker.Assign(JSONObject);
      LoadMarkerItems(JSONObject.FindValue('items'), Marker.Items);
      LoadMarkerImages(JSONObject.FindValue('images'), Marker.Images);
    finally
      Items.Add(Marker);
    end;
  end;
end;

class procedure TJSONDataImport.LoadMarkerItems(const Source: TJSONValue; Items: TList<TItemImage>);
var
  i: Integer;
  List: TJSONArray;
  JSONObject: TJSONValue;
  ItemImage: TItemImage;
begin
  if (Source = nil) or not (Source is TJSONArray) then
    Exit;

  List := TJSONArray(Source);
  for i := 0 to List.Count - 1 do begin
    JSONObject := TJSONObject(List.Items[i]);

    ItemImage := TItemImage.Create;
    try
      ItemImage.Assign(JSONObject);
    finally
      Items.Add(ItemImage);
    end;
  end;
end;

class procedure TJSONDataImport.LoadMarkerImages(const Source: TJSONValue; Items: TObjectList<TMarkerImage>);
var
  i: Integer;
  List: TJSONArray;
  JSONObject: TJSONValue;
  Image: TMarkerImage;
begin
  if not (Source is TJSONArray) then
    Exit;

  List := TJSONArray(Source);
  for i := 0 to List.Count - 1 do begin
    JSONObject := TJSONObject(List.Items[i]);

    Image := TMarkerImage.Create;
    try
      Image.Assign(JSONObject);
    finally
      Items.Add(Image);
    end;
  end;
end;

class procedure TJSONDataImport.LoadQuests(const Source: TJSONValue; Items: TList<TQuest>);
var
  i: Integer;
  List: TJSONArray;
  JSONObject: TJSONValue;
  Quest: TQuest;
begin
  if not (Source is TJSONArray) then
    Exit;

  List := TJSONArray(Source);
  for i := 0 to List.Count - 1 do begin
    JSONObject := TJSONObject(List.Items[i]);

    Quest := TQuest.Create;
    try
      Quest.Assign(JSONObject);
      LoadMarkers(JSONObject.FindValue('markers'), Quest.Markers);
    finally
      Items.Add(Quest);
    end;
  end;
end;

class procedure TJSONDataImport.Load(const Data: string; Items: TList<TMap>);
var
  Root: TJSONArray;
  JSONObject: TJSONValue;
  Map: TMap;
  i: Integer;
begin
  JSONObject := TJSONObject.ParseJSONValue(Data);
  if not (JSONObject is TJSONArray) then
    Exit;

  Root := TJSONArray(JSONObject);
  try
    for i := 0 to Root.Count - 1 do begin
      JSONObject := TJSONObject(Root.Items[i]);

      Map := TMap.Create;
      try
        Map.Assign(JSONObject);
        LoadLayers(JSONObject.FindValue('layers'), Map.Layers);
        LoadMarkers(JSONObject.FindValue('markers'), Map.Markers);
        LoadQuests(JSONObject.FindValue('quests'), Map.Quests);
      finally
        Items.Add(Map);
      end;
    end;
  finally
    Root.Free;
  end;
end;

class procedure TJSONDataImport.LoadFromFile(const FileName: string; Items: TList<TMap>);
var
  Data: TStrings;
begin
  Data := TStringList.Create;
  try
    Data.LoadFromFile(FileName, TEncoding.UTF8);
    Load(Data.Text, Items);
  finally
    Data.Free;
  end;
end;

{ TJSONDataExport }

class procedure TJSONDataExport.SaveLayers(const Root: TJSONObject; Items: TList<TLayer>);
var
  Layer: TLayer;
  JSONItems: TJSONArray;
  JSONObject: TJSONObject;
begin
  JSONItems := TJSONArray.Create;
  for Layer in Items do begin
    JSONObject := TJSONObject.Create;
    try
      Layer.AssignTo(JSONObject);
    finally
      JSONItems.Add(JSONObject);
    end;
  end;
  Root.AddPair('layers', JSONItems);
end;

class procedure TJSONDataExport.SaveMarkers(const Root: TJSONObject; Items: TList<TMarker>);
var
  Marker: TMarker;
  JSONItems: TJSONArray;
  JSONObject: TJSONObject;
begin
  JSONItems := TJSONArray.Create;
  for Marker in Items do begin
    JSONObject := TJSONObject.Create;
    try
      Marker.AssignTo(JSONObject);

      SaveMarkerItems(JSONObject, Marker.Items);
      SaveMarkerImages(JSONObject, Marker.Images);
    finally
      JSONItems.Add(JSONObject);
    end;
  end;
  Root.AddPair('markers', JSONItems);
end;

class procedure TJSONDataExport.SaveMarkerItems(const Root: TJSONObject; Items: TList<TItemImage>);
var
  ItemImage: TItemImage;
  JSONItems: TJSONArray;
  JSONObject: TJSONObject;
begin
  JSONItems := TJSONArray.Create;
  for ItemImage in Items do begin
    JSONObject := TJSONObject.Create;
    try
      ItemImage.AssignTo(JSONObject);
    finally
      JSONItems.Add(JSONObject);
    end;
  end;
  Root.AddPair('items', JSONItems);
end;

class procedure TJSONDataExport.SaveMarkerImages(const Root: TJSONObject; Items: TObjectList<TMarkerImage>);
var
  Image: TMarkerImage;
  JSONItems: TJSONArray;
  JSONObject: TJSONObject;
begin
  JSONItems := TJSONArray.Create;
  for Image in Items do begin
    JSONObject := TJSONObject.Create;
    try
      Image.AssignTo(JSONObject);
    finally
      JSONItems.Add(JSONObject);
    end;
  end;
  Root.AddPair('images', JSONItems);
end;

class procedure TJSONDataExport.SaveQuests(const Root: TJSONObject; Items: TList<TQuest>);
var
  Quest: TQuest;
  JSONItems: TJSONArray;
  JSONObject: TJSONObject;
begin
  JSONItems := TJSONArray.Create;
  for Quest in Items do begin
    JSONObject := TJSONObject.Create;
    try
      Quest.AssignTo(JSONObject);
      SaveMarkers(JSONObject, Quest.Markers);
    finally
      JSONItems.Add(JSONObject);
    end;
  end;
  Root.AddPair('quests', JSONItems);
end;

class function TJSONDataExport.Save(Items: TList<TMap>): string;
var
  Root: TJSONArray;
  JSONObject: TJSONObject;
  Map: TMap;
begin
  Root := TJSONArray.Create;
  try
    for Map in Items do begin
      JSONObject := TJSONObject.Create;
      try
        Map.AssignTo(JSONObject);
        SaveLayers(JSONObject, Map.Layers);
        SaveMarkers(JSONObject, Map.Markers);
        SaveQuests(JSONObject, Map.Quests);
      finally
        Root.Add(JSONObject);
      end;
    end;

    Result := Root.ToJSON;
  finally
    Root.Free;
  end;
end;

class procedure TJSONDataExport.SaveToFile(const FileName: string; Items: TList<TMap>);
var
  Data: TStrings;
begin
  Data := TStringList.Create;
  try
    Data.Text := Save(Items);
    Data.SaveToFile(FileName, TEncoding.UTF8)
  finally
    Data.Free;
  end;
end;

end.
