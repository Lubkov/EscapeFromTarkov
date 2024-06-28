unit ME.Frame.MarkerItem;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, 
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  System.Rtti, FMX.Grid.Style, System.ImageList, FMX.ImgList, System.Actions,
  FMX.ActnList, FMX.Grid, FMX.ScrollBox, FMX.Controls.Presentation;

type
  TfrQuestItemsGrid = class(TFrame)
    paTopPanel: TPanel;
    edAddQuestItem: TSpeedButton;
    edDeleteQuestItem: TSpeedButton;
    laTitle: TLabel;
    Grid: TGrid;
    NameColumn: TStringColumn;
    TraderColumn: TStringColumn;
    ActionList1: TActionList;
    acAddQuestItem: TAction;
    acDeleteQuestItem: TAction;
    ImageList1: TImageList;
  private
  public
  end;

implementation

{$R *.fmx}

end.
