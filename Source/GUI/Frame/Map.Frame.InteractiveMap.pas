unit Map.Frame.InteractiveMap;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, 
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  FMX.Objects;

type
  TInteractiveMap = class(TFrame)
    Background: TImage;
  private
    function GetBitmap: TBitmap;
    procedure SetBitmap(const Value: TBitmap);
  public
    property Bitmap: TBitmap read GetBitmap write SetBitmap;
  end;

implementation

{$R *.fmx}

{ TInteractiveMap }

function TInteractiveMap.GetBitmap: TBitmap;
begin
  Result := Background.Bitmap;
end;

procedure TInteractiveMap.SetBitmap(const Value: TBitmap);
begin
  Self.Width := Bitmap.Width;
  Self.Height := Bitmap.Height;
  Background.Bitmap.Assign(nil);
  Background.Bitmap.Assign(Value);
end;

end.
