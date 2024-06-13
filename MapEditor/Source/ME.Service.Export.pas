unit ME.Service.Export;

interface

uses
  System.SysUtils, System.Classes, Generics.Collections, Data.DB, ME.DB.Entity,
  ME.DB.Service, ME.DB.Map, ME.DB.Quest, ME.DB.Marker;

type
  TExportService = class(TObject)
  private
  public
    procedure ExportToJSON(const FileName: string);
  end;

implementation

uses
  ME.Service.Layer, ME.Service.Map, ME.Service.Marker, ME.Service.Quest;

{ TExportService }

procedure TExportService.ExportToJSON(const FileName: string);
var
  Data: TStrings;
  Items: TList<TEntity>;
  i: Integer;
  Map: TMap;
begin
  Data := TStringList.Create;
  try
    Items := TList<TEntity>.Create;
    try
      MapService.GetAll(Items);

      Data.Add('[');
      for i := 0 to Items.Count - 1 do begin
        Map := TMap(Items[i]);

        Data.Add('  {');
        Data.Add('    "name": "' + Map.Name + '",');
        Data.Add('    "left": ' + Map.Left.ToString + ',');
        Data.Add('    "top": ' + Map.Top.ToString + ',');
        Data.Add('    "right": ' + Map.Right.ToString + ',');
        Data.Add('    "bottom": ' + Map.Bottom.ToString + ',');
        Data.Add('    "layers": [{"level": 0, "name": "main"}],');
        Data.Add('    "markers": [],');
        Data.Add('    "quests": []');


        MapService.LoadLayers(Map, False);
        MapService.LoadMarkers(Map);
        MapService.LoadQuests(Map);

        Data.Add('  },');
      end;
      Data.Add(']');
    finally
      Items.Free;
    end;

    Data.SaveToFile(FileName);
  finally
    Data.Free;
  end;
end;

end.
