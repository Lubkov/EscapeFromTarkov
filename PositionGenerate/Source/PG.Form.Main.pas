unit PG.Form.Main;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs,
  FMX.Controls.Presentation, FMX.StdCtrls, Data.DB, MemDS, DBAccess, Uni,
  FMX.Edit, FMX.EditBox, FMX.NumberBox, System.Rtti, System.Bindings.Outputs,
  Fmx.Bind.Editors, Data.Bind.EngExt, Fmx.Bind.DBEngExt, Data.Bind.Components,
  Data.Bind.DBScope, FMX.ListBox, Datasnap.DBClient, FMX.Objects,
  FMX.Clipboard, FMX.Platform, FMX.Layouts, System.ImageList, FMX.ImgList;

type
  TMainForm = class(TForm)
    Panel1: TPanel;
    laTopPoint: TLabel;
    edPositionX: TNumberBox;
    edPositionY: TNumberBox;
    F: TClientDataSet;
    FID: TIntegerField;
    FName: TStringField;
    FLeft: TIntegerField;
    FTop: TIntegerField;
    FRight: TIntegerField;
    FBottom: TIntegerField;
    edMapName: TComboBox;
    buGenerate: TButton;
    BindSourceDB1: TBindSourceDB;
    BindingsList1: TBindingsList;
    LinkListControlToField1: TLinkListControlToField;
    Label1: TLabel;
    edMapLeft: TNumberBox;
    edMapRight: TNumberBox;
    LinkControlToField1: TLinkControlToField;
    LinkControlToField2: TLinkControlToField;
    Label2: TLabel;
    edMapTop: TNumberBox;
    edMapBottom: TNumberBox;
    LinkControlToField3: TLinkControlToField;
    LinkControlToField4: TLinkControlToField;
    Line1: TLine;
    laScreenShotName: TLabel;
    ImageList24: TImageList;
    VerticalLayout: TLayout;
    buTop: TSpeedButton;
    buBottom: TSpeedButton;
    HorizontalLayout: TLayout;
    edLeft: TSpeedButton;
    buRight: TSpeedButton;
    Layout3: TLayout;
    UniConnection1: TUniConnection;
    procedure buGenerateClick(Sender: TObject);
    procedure edLeftClick(Sender: TObject);
    procedure edMapNameChange(Sender: TObject);
    procedure buRightClick(Sender: TObject);
    procedure buTopClick(Sender: TObject);
    procedure buBottomClick(Sender: TObject);
  private
    procedure Init;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  end;

var
  MainForm: TMainForm;

implementation

uses
  App.Main.Service;

{$R *.fmx}

{ TMainForm }

constructor TMainForm.Create(AOwner: TComponent);
begin
  inherited;

  Init;
  laScreenShotName.Visible := False;
end;

destructor TMainForm.Destroy;
begin

  inherited;
end;

procedure TMainForm.Init;
var
  Query: TUniQuery;
begin
  F.CreateDataSet;
  F.Open;

  AppService.Connect;
  try
    Query := TUniQuery.Create(Self);
    try
      Query.Connection := AppService.Connection.Connection;
      Query.SQL.Text := 'SELECT ID, Name, Left, Top, Right, Bottom FROM Map';
      Query.Open;

      F.DisableControls;
      try
        while not Query.Eof do begin
          F.Append;
          FID.Value := Query.FieldByName('ID').Value;
          FName.AsString := Query.FieldByName('Name').AsString;
          FLeft.AsInteger := Query.FieldByName('Left').AsInteger;
          FTop.AsInteger := Query.FieldByName('Top').AsInteger;
          FRight.AsInteger := Query.FieldByName('Right').AsInteger;
          FBottom.AsInteger := Query.FieldByName('Bottom').AsInteger;
          F.Post;

          Query.Next;
        end;

        F.First;
      finally
        F.EnableControls;
      end;
    finally
      Query.Free;
    end;
  finally
    AppService.Disconnect;
  end;

  edMapNameChange(Self);
end;

procedure TMainForm.buGenerateClick(Sender: TObject);
const
//  FileNameFmt = '2024-02-20[21-57]_X.x, 0.0, Y.y_0.0, 0.0, 0.0, 0.0_0.00 (0).png';
  FileNameFmt = '%s_%d.0, 0.0, %d.0_0.0, 0.0, 0.0, 0.0_0.00 (0).png';
var
  x, y: Integer;
  FileName: string;
  clp: IFMXClipboardService;
begin
  x := Trunc(edPositionX.Value);
  y := Trunc(edPositionY.Value);
  FileName := Format(FileNameFmt, [FormatDateTime('yyyy-mm-dd[hh-nn]', Now), x, y]);
  laScreenShotName.Text := FileName;
  laScreenShotName.Visible := True;

  if TPlatformServices.Current.SupportsPlatformService(IFMXClipboardService) then begin
    clp := IFMXClipboardService(TPlatformServices.Current.GetPlatformService(IFMXClipboardService));
    clp.SetClipboard(FileName);
  end;
end;

procedure TMainForm.edMapNameChange(Sender: TObject);
begin
  if FLeft.AsInteger < FRight.AsInteger then begin
    edPositionX.Min := FLeft.AsInteger;
    edPositionX.Max := FRight.AsInteger;
  end
  else begin
    edPositionX.Min := FRight.AsInteger;
    edPositionX.Max := FLeft.AsInteger;
  end;
end;

procedure TMainForm.edLeftClick(Sender: TObject);
var
  Value: Integer;
begin
  Value := Trunc(edPositionX.Value);
  if FLeft.AsInteger < FRight.AsInteger then
    Dec(Value)
  else
    Inc(Value);

  edPositionX.Value := Value;
end;

procedure TMainForm.buRightClick(Sender: TObject);
var
  Value: Integer;
begin
  Value := Trunc(edPositionX.Value);
  if FLeft.AsInteger < FRight.AsInteger then
    Inc(Value)
  else
    Dec(Value);

  edPositionX.Value := Value;
end;

procedure TMainForm.buTopClick(Sender: TObject);
var
  Value: Integer;
begin
  Value := Trunc(edPositionY.Value);
  if FTop.AsInteger < FBottom.AsInteger then
    Dec(Value)
  else
    Inc(Value);

  edPositionY.Value := Value;
end;

procedure TMainForm.buBottomClick(Sender: TObject);
var
  Value: Integer;
begin
  Value := Trunc(edPositionY.Value);
  if FTop.AsInteger < FBottom.AsInteger then
    Inc(Value)
  else
    Dec(Value);

  edPositionY.Value := Value;
end;

end.
