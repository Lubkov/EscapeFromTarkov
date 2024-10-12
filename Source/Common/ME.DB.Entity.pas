unit ME.DB.Entity;

interface

uses
  System.Classes, System.SysUtils, System.Variants, System.SysConst, System.JSON,
  FMX.Graphics, Data.DB, Uni;

type
  TEntityClass = class of TEntity;
//  TRecordState = (New, Managed, Removed);

  TEntity = class(TObject)
  private
    function GetIsNewInstance: Boolean;
  protected
    FID: Variant;
//    FRecordState: TRecordState;
  public
    constructor Create; virtual;
    destructor Destroy; override;

    procedure Assign(const Source: TEntity); overload; virtual;
    procedure Assign(const DataSet: TDataSet); overload; virtual;
    procedure Assign(const Source: TJSONValue); overload; virtual;
    procedure AssignTo(const Dest: TJSONObject); virtual;
    class procedure AssignPicture(const Field: TField; Bitmap: TBitmap);
    class procedure AssignPictureTo(const Source: TBitmap; const Field: TField); overload;
    class procedure AssignPictureTo(const Source: TBitmap; Param: TParam); overload;

    class function EntityName: string; virtual; abstract;
    class function FieldList: string; virtual; abstract;

    property ID: Variant read FID write FID;
//    property RecordState: TRecordState read FRecordState write FRecordState;
    property IsNewInstance: Boolean read GetIsNewInstance;
  end;

implementation

uses
  ME.DB.Utils;

{ TEntity }

constructor TEntity.Create;
begin
  inherited;

  FID := Null;
//  FRecordState := TRecordState.New;
end;

destructor TEntity.Destroy;
begin

  inherited;
end;

function TEntity.GetIsNewInstance: Boolean;
begin
  Result := VarIsNull(ID) or VarIsEmpty(ID);
end;

procedure TEntity.Assign(const Source: TEntity);
begin
  FID := Source.ID;
end;

procedure TEntity.Assign(const DataSet: TDataSet);
begin
  FID := DataSet.FieldByName('ID').Value;
end;

procedure TEntity.Assign(const Source: TJSONValue);
begin
  FID := Source.GetValue<Integer>('id');
end;

procedure TEntity.AssignTo(const Dest: TJSONObject);
var
  Value: Integer;
begin          
  if VarIsEmpty(FID) or VarIsNull(FID) then
    Value := -1
  else
    Value := Integer(FID);
    
  Dest.AddPair('id', Value);
end;

class procedure TEntity.AssignPicture(const Field: TField; Bitmap: TBitmap);
var
  Stream: TMemoryStream;
  EmptyPicture: TBitmap;
begin
  if Field.IsNull then begin
    EmptyPicture := TBitmap.Create;
    try
      Bitmap. Assign(EmptyPicture);
    finally
      EmptyPicture.Free;
    end;

    Exit;
  end;

  Stream := TMemoryStream.Create;
  try
    TBlobField(Field).SaveToStream(Stream);
    Stream.Position := 0;
    if Stream.Size > 0 then
      Bitmap.LoadFromStream(Stream)
    else
      Bitmap.Assign(nil);
  finally
    Stream.Free;
  end;
end;

class procedure TEntity.AssignPictureTo(const Source: TBitmap; const Field: TField);
var
  Stream: TMemoryStream;
begin
  Stream := TMemoryStream.Create;
  try
    Source.SaveToStream(Stream);
    Stream.Position := 0;
    TBlobField(Field).LoadFromStream(Stream);
  finally
    Stream.Free;
  end;
end;

class procedure TEntity.AssignPictureTo(const Source: TBitmap; Param: TParam);
var
  Stream: TMemoryStream;
begin
 if Source.IsEmpty then begin
   Param.Value := Null;
   Exit;
 end;

  Stream := TMemoryStream.Create;
  try
    Source.SaveToStream(Stream);
    Stream.Position := 0;

    TUniParam(Param).LoadFromStream(Stream, ftBlob);
  finally
    Stream.Free;
  end;
end;

end.
