unit ME.MemGrid.Screenshots;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  System.Bindings.Outputs, System.Actions, System.ImageList, System.Rtti, FMX.Types,
  FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls, FMX.Grid.Style,
  Data.Bind.EngExt, Fmx.Bind.DBEngExt, Fmx.Bind.Grid, Fmx.Bind.Editors, FMX.ActnList,
  FMX.ImgList, FMX.ExtCtrls, FMX.ScrollBox, FMX.Grid, FMX.Controls.Presentation,
  Data.Bind.Components, Data.Bind.Grid, Data.Bind.DBScope, Data.DB, MemDS, DBAccess,
  Uni, ME.Grid.Resources, ME.DB.Resource, ME.Grid.Screenshots;

type
  TScreenshotsMemGrid = class(TScreenshotsGrid)
  private
  protected
    function GetCommandSQLText: string; override;
  public
    procedure AddRecord; override;
    procedure EditRecord; override;
    procedure DeleteRecord; override;
  end;

implementation

{$R *.fmx}

{ TResourcesMemGrid }

function TScreenshotsMemGrid.GetCommandSQLText: string;
begin
  Result := inherited GetCommandSQLText;
//
//  Result :=
//    ' SELECT r.ID as ID, ' +
//    '        r.Kind as Kind, ' +
//    '        r.Description as Description ' +
//    ' FROM Resource r ' +
//    ' WHERE (r.MarkerID = :MarkerID) AND (r.Kind = :Kind)';
end;

procedure TScreenshotsMemGrid.AddRecord;
var
  Resource: TDBResource;
  Stored: Boolean;
begin
  Stored := False;
  Resource := TDBResource.Create;
  try
//    Resource.MarkerID := FMarker.ID;
    Resource.Kind := ResourceKind;

    Stored := InternalEditRecord(Resource);
    if not Stored then
      Exit;

    Resource.MarkerID := Marker.ID;

    case ResourceKind of
      TResourceKind.Screenshot:
        Marker.Images.Add(Resource);
      TResourceKind.QuestItem:
        Marker.Items.Add(Resource);
    end;

    F.DisableControls;
    try
      F.Append;
  //      FID.Value := Resource.ID;
      FKind.AsInteger := Ord(Resource.Kind);
      FDescription.AsString := Resource.Description;
      F.Post;
    finally
      F.EnableControls;
    end;
  finally
    if not Stored then
      Resource.Free;
  end;
end;

procedure TScreenshotsMemGrid.EditRecord;
var
  Resource: TDBResource;
begin
  case ResourceKind of
    TResourceKind.Screenshot:
      Resource := Marker.Images[Grid.Selected];
    TResourceKind.QuestItem:
      Resource := Marker.Items[Grid.Selected];
  else
    raise Exception.Create('TResourceKind is not supported');
  end;

  if InternalEditRecord(Resource) then begin
    F.DisableControls;
    try
      F.Edit;
  //      FID.Value := Resource.ID;
      FKind.AsInteger := Ord(Resource.Kind);
      FDescription.AsString := Resource.Description;
      F.Post;
    finally
      F.EnableControls;
    end;
  end;
end;

procedure TScreenshotsMemGrid.DeleteRecord;
begin
  if (Grid.Row < 0) or not InternalDeleteRecord then
    Exit;

  case ResourceKind of
    TResourceKind.Screenshot:
      Marker.Images.Delete(Grid.Row);
    TResourceKind.QuestItem:
      Marker.Items.Delete(Grid.Row);
  end;

  F.DisableControls;
  try
    F.Delete;
  finally
    F.EnableControls;
  end;
end;

end.
