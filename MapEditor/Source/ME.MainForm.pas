unit ME.MainForm;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs,
  FMX.Controls.Presentation, FMX.StdCtrls, System.ImageList, FMX.ImgList,
  FMX.Objects, ME.Frame.Map, ME.Frame.Layer, ME.DB.Map, ME.DB.Quest,
  ME.DB.Layer, LocalMap;

type
  TMainForm = class(TForm)
    Panel1: TPanel;
    Button1: TButton;
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure Button1Click(Sender: TObject);
  private
    FMapPanel: TfrMap;

    procedure OnMapChanged(const Map: TMap);
    procedure ImportLocalMap(const LocalMap: TLocalMap);
  public
  end;

var
  MainForm: TMainForm;

implementation

uses
  ME.AppService, ME.Service.Layer, ME.Service.Map, ME.DB.Marker, ME.Service.Marker,
  ME.Service.Quest;

{$R *.fmx}

// id, icon, name, выходы чвк(кол-во), выходы дикого(кол-во), выходы совместные(кол-во), квесты (кол-во)

procedure TMainForm.FormCreate(Sender: TObject);
begin
  AppService.Connect;
  Self.Caption := '[Maps Editor] Database = "' + AppService.Database + '"';

  FMapPanel := TfrMap.Create(Self);
  FMapPanel.Parent := Self;
  FMapPanel.Align := TAlignLayout.Client;
  FMapPanel.OnChange := OnMapChanged;
end;

procedure TMainForm.FormShow(Sender: TObject);
begin
  FMapPanel.Init;
end;

procedure TMainForm.OnMapChanged(const Map: TMap);
begin

end;

procedure TMainForm.ImportLocalMap(const LocalMap: TLocalMap);

  procedure ImportExtraction(const Map: TMap; Kind: TMarkerKind; Items: array of TMapTag);
  var
    Marker: TMarker;
    MapTag: TMapTag;
  begin
    for MapTag in Items do begin
       Marker := TMarker.Create;
       try
         Marker.ID := Null;
         Marker.MapID := Map.ID;
         Marker.QuestID := Null;
         Marker.Name := MapTag.Caption;
         Marker.Kind := Kind;
         Marker.Left := MapTag.Position.X;
         Marker.Top := MapTag.Position.Y;
       finally
         Map.Tags.Add(Marker);
       end;
    end;
  end;

  procedure ImportQuest(const Map: TMap; const Items: array of TQuestTag);
  var
    QuestTag: TQuestTag;
    Quest: TQuest;
    Part: TPoint;
    Marker: TMarker;
  begin
    for QuestTag in Items do begin
      Quest := TQuest.Create;
      try
        Quest.MapID := Map.ID;
        Quest.Name := QuestTag.Caption;

        for Part in QuestTag.Parts do begin
          Marker := TMarker.Create;
          try
            Marker.ID := Null;
            Marker.MapID := Map.ID;
            Marker.QuestID := Quest.ID;
            Marker.Name := '';
            Marker.Kind := TMarkerKind.Quest;
            Marker.Left := Part.X;
            Marker.Top := Part.Y;
          finally
            Quest.Markers.Add(Marker);
          end;
        end;
      finally
        Map.Quests.Add(Quest);
      end;
    end;
  end;

var
  Map: TMap;
  Layer: TLayer;
begin
  Map := TMap.Create;
  try
    Map.ID := Null;
    Map.Name := LocalMap.Name;
    Map.Left := LocalMap.Left.X;
    Map.Top := LocalMap.Left.Y;
    Map.Right := LocalMap.Right.X;
    Map.Bottom := LocalMap.Right.Y;

    if FileExists('d:\Projects\Delphi\EscapeFromTarkov\Bin\MapIcon\' + LocalMap.Name + '.jpg') then
      Map.Picture.LoadFromFile('d:\Projects\Delphi\EscapeFromTarkov\Bin\MapIcon\' + LocalMap.Name + '.jpg');

    Layer := TLayer.Create;
    try
      Layer.MapID := Map.ID;
      Layer.Level := MainLayerIndex;
      Layer.Name := 'Основной';

      if FileExists('d:\Projects\Delphi\EscapeFromTarkov\Bin\Maps\' + LocalMap.Name + '.jpg') then
        Layer.Picture.LoadFromFile('d:\Projects\Delphi\EscapeFromTarkov\Bin\Maps\' + LocalMap.Name + '.jpg');
    finally
      Map.Layers.Add(Layer);
    end;

    ImportExtraction(Map, TMarkerKind.PMCExtraction, LocalMap.PMCExtraction);
    ImportExtraction(Map, TMarkerKind.ScavExtraction, LocalMap.ScavExtraction);
    ImportExtraction(Map, TMarkerKind.CoopExtraction, LocalMap.SharedExtraction);
    ImportQuest(Map, LocalMap.Quests);

    MapService.Save(Map);
  finally
    Map.Free;
  end;
end;

procedure TMainForm.Button1Click(Sender: TObject);
begin

  ImportLocalMap(WoodsMap);
  ImportLocalMap(CustomsMap);
  ImportLocalMap(InterchangeMap);
  ImportLocalMap(ShorelineMap);
  ImportLocalMap(ReserveMap);

  ShowMessage('Success');
end;

end.
