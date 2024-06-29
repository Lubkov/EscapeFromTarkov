unit ME.MainForm;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  System.IOUtils, Generics.Collections, FMX.Types, FMX.Controls, FMX.Forms,
  FMX.Graphics, FMX.Dialogs, FMX.Controls.Presentation, FMX.StdCtrls,
  System.ImageList, FMX.ImgList, FMX.Objects, FMX.Layouts,
  ME.Frame.Map, Map.Data.Types, ME.Filter.Map, ME.Frame.MapData;

type
  TMainForm = class(TForm)
    Panel1: TPanel;
    buExpot: TButton;
    TopLayout: TLayout;
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure buExpotClick(Sender: TObject);
    procedure MapChanged(const Map: TMap);
  private
//    FMapPanel: TfrMap;
    FMapFilter: TMapFilter;
    FMapData: TfrMapData;
  public
  end;

var
  MainForm: TMainForm;

implementation

uses
  App.Constants, App.Service, ME.Service.Layer, ME.Service.Map, ME.DB.Marker,
  ME.Service.Marker, ME.Service.Quest, ME.Service.Export,
  Map.Data.Service, Map.Data.Classes;

{$R *.fmx}

// id, icon, name, выходы чвк(кол-во), выходы дикого(кол-во), выходы совместные(кол-во), квесты (кол-во)

procedure TMainForm.FormCreate(Sender: TObject);
begin
  AppService.LoadParams;
  AppService.LoadDataFromJSON;

  Self.Caption := '[Map Editor] JSON storage';
//  Self.Caption := '[Maps Editor] Database = "' + AppService.Database + '"';

//  FMapPanel := TfrMap.Create(Self);
//  FMapPanel.Parent := Self;
//  FMapPanel.Align := TAlignLayout.Client;
////  FMapPanel.OnChange := OnMapChanged;

  FMapFilter := TMapFilter.Create(Self);
  FMapFilter.Parent := TopLayout;
  FMapFilter.Position.X := 20;
  FMapFilter.Position.Y := 0;
  FMapFilter.OnMapChanged := MapChanged;

  FMapData := TfrMapData.Create(Self);
  FMapData.Parent := Self;
  FMapData.Align := TAlignLayout.Client;
end;

procedure TMainForm.FormShow(Sender: TObject);
begin
  FMapFilter.Init;
//  FMapPanel.Init;
end;

procedure TMainForm.MapChanged(const Map: TMap);
begin
  FMapData.Init(Map);
end;

procedure TMainForm.buExpotClick(Sender: TObject);
var
  FileName: string;
begin
  FileName := System.IOUtils.TPath.Combine(AppParams.DataPath, 'data.json');
  TJSONDataExport.SaveToFile(FileName, DataSertvice.Items);

  ShowMessage('Done');
end;

end.
