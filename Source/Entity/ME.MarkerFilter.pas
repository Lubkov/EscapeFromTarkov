unit ME.MarkerFilter;

interface

uses
  System.SysUtils, System.Classes, System.Variants,
  ME.DB.Marker, ME.DB.Quest;

type
  TBoolArray = array of Boolean;

  TMarkerFilter = class
  private
    FGroupFilter: TMarkerKindSet;
    FQuestFilter: TBoolArray;
  public
    constructor Create;

    procedure EnableGroup(const Kind: TMarkerKind);
    procedure DisableGroup(const Kind: TMarkerKind);

    property GroupFilter: TMarkerKindSet read FGroupFilter;
    property QuestFilter: TBoolArray read FQuestFilter;
  end;

implementation

{ TMarkerFilter }

constructor TMarkerFilter.Create;
begin
  inherited;

  FGroupFilter := [];
  SetLength(FQuestFilter, 0);
end;

procedure TMarkerFilter.EnableGroup(const Kind: TMarkerKind);
begin
  FGroupFilter := FGroupFilter + [Kind];
end;

procedure TMarkerFilter.DisableGroup(const Kind: TMarkerKind);
begin
  FGroupFilter := FGroupFilter - [Kind];
end;

end.
