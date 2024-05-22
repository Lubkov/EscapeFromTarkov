unit LocalMap;

interface

uses
  System.SysUtils;

type
  TPoint = record
  private
    function GetEmpty: Boolean;
    procedure SetEmpty(const Value: Boolean);
  public
    X: Integer;
    Y: Integer;

    constructor Create(X, Y: Integer);

    property Empty: Boolean read GetEmpty write SetEmpty;
  end;

  TMapTag = record
    Position: TPoint;
    Caption: string;

    constructor Create(const Caption: string; X, Y: Integer);
  end;

  TQuestTag = record
    Parts: array of TPoint;
    Caption: string;

    constructor Create(const Caption: string; Parts: array of TPoint);
  end;

  TLocalMap = record
    Name: string;
    Left: TPoint;
    Right: TPoint;
    FileName: string;
    PMCExtraction: array of TMapTag;
    ScavExtraction: array of TMapTag;
    SharedExtraction: array of TMapTag;
    Quests: array of TQuestTag;
  end;

  TMapTagType = (tagPMCExtraction, tagScavExtraction, tagSharedExtraction, tagQuest);

const
  MapTypeTitle: array[TMapTagType] of string = ('������ ���', '������ ������', '����. ������', '������');

var
  MapFilter: set of TMapTagType = [tagPMCExtraction, tagScavExtraction, tagSharedExtraction];
  QuestFilter: array of Boolean;
  WoodsMap: TLocalMap;
  CustomsMap: TLocalMap;
  InterchangeMap: TLocalMap;
  ShorelineMap: TLocalMap;
  ReserveMap: TLocalMap;

implementation

{ TPoint }

constructor TPoint.Create(X, Y: Integer);
begin
  Self.X := X;
  Self.Y := Y;
end;

function TPoint.GetEmpty: Boolean;
begin
  Result := (X = Integer.MinValue) and (Y = Integer.MaxValue);
end;

procedure TPoint.SetEmpty(const Value: Boolean);
begin
  X := Integer.MinValue;
  Y := Integer.MaxValue;
end;

{ TMapTag }

constructor TMapTag.Create(const Caption: string; X, Y: Integer);
begin
  Self.Caption := Caption;
  Position.X := X;
  Position.Y := Y;
end;

{ TQuestTag }

constructor TQuestTag.Create(const Caption: string; Parts: array of TPoint);
var
  i: Integer;
begin
  Self.Caption := Caption;
  SetLength(Self.Parts, Length(Parts));
  for i := 0 to Length(Parts) - 1 do
    Self.Parts[i] := Parts[i];
end;

initialization
  // ����� "���"
  WoodsMap.Name := 'Woods';
  WoodsMap.Left := TPoint.Create(500, -920);
  WoodsMap.Right := TPoint.Create(-700, 480);
  WoodsMap.FileName := 'Woods.jpg';
  SetLength(WoodsMap.PMCExtraction, 7);
  WoodsMap.PMCExtraction[0] := TMapTag.Create('�������', 350, 350);
  WoodsMap.PMCExtraction[1] := TMapTag.Create('��-014', 434, 67);
  WoodsMap.PMCExtraction[2] := TMapTag.Create('�-����� �� ����� (�������)', -485, -510);
  WoodsMap.PMCExtraction[3] := TMapTag.Create('�������� ���� ���', -560, -70);
  WoodsMap.PMCExtraction[4] := TMapTag.Create('��-016', -392, 20);
  WoodsMap.PMCExtraction[5] := TMapTag.Create('����� ���� ���', -520, 290);
  WoodsMap.PMCExtraction[6] := TMapTag.Create('������ �� ��', -135, 412);
  SetLength(WoodsMap.ScavExtraction, 11);
  WoodsMap.ScavExtraction[0] := TMapTag.Create('�������', 350, 350);
  WoodsMap.ScavExtraction[1] := TMapTag.Create('���� �����', 410, 240);
  WoodsMap.ScavExtraction[2] := TMapTag.Create('������� ��������', 186, 252);
  WoodsMap.ScavExtraction[3] := TMapTag.Create('�����', 184, 214);
  WoodsMap.ScavExtraction[4] := TMapTag.Create('������ �����', 229, -683);
  WoodsMap.ScavExtraction[5] := TMapTag.Create('����� ����', 103, -836);
  WoodsMap.ScavExtraction[6] := TMapTag.Create('������ ������', -203, -203);
  WoodsMap.ScavExtraction[7] := TMapTag.Create('��������� �����', -503, -41);
  WoodsMap.ScavExtraction[8] := TMapTag.Create('������ ����', -513, 152);
  WoodsMap.ScavExtraction[9] := TMapTag.Create('����� ���� ���', -520, 290);
  WoodsMap.ScavExtraction[10] := TMapTag.Create('������ �� ��', -135, 412);
  SetLength(WoodsMap.SharedExtraction, 1);
  WoodsMap.SharedExtraction[0] := TMapTag.Create('������ ������ (����)', -362, 348);
  SetLength(WoodsMap.Quests, 4);
  WoodsMap.Quests[0] := TQuestTag.Create('���������� ������ (5)', [TPoint.Create(251, 292), TPoint.Create(401, -609), TPoint.Create(-78, -543),
                                                                   TPoint.Create(-210, -277), TPoint.Create(-447, 251)]);
  WoodsMap.Quests[1] := TQuestTag.Create('������� - ����� 1 (2)', [TPoint.Create(231, -70), TPoint.Create(56, -52)]);
  WoodsMap.Quests[2] := TQuestTag.Create('��������� ����� - ����� 3 (1)', [TPoint.Create(-91, 220)]);
  WoodsMap.Quests[3] := TQuestTag.Create('����� - ����� 2', [TPoint.Create(196, -7), TPoint.Create(-84, -717)]);

  //  ����� "�������"
  CustomsMap.Name := 'Customs';
  CustomsMap.Left := TPoint.Create(800, -300);
  CustomsMap.Right := TPoint.Create(-400, 300);
  CustomsMap.FileName := '�ustoms.jpg';
  SetLength(CustomsMap.PMCExtraction, 9);
  CustomsMap.PMCExtraction[0] := TMapTag.Create('��-1011', 635, -135);
  CustomsMap.PMCExtraction[1] := TMapTag.Create('��-1012', 471, -118);
  CustomsMap.PMCExtraction[2] := TMapTag.Create('������ ��������', 314, -183);
  CustomsMap.PMCExtraction[3] := TMapTag.Create('��-013', 200, -154);
  CustomsMap.PMCExtraction[4] := TMapTag.Create('�������� �� ��', -16, -130);
  CustomsMap.PMCExtraction[5] := TMapTag.Create('���������� ����', -307, -220);
  CustomsMap.PMCExtraction[6] := TMapTag.Create('�����������', -322, -83);
  CustomsMap.PMCExtraction[7] := TMapTag.Create('����� ��������������', -39, 123);
  CustomsMap.PMCExtraction[8] := TMapTag.Create('����� � ������ (�������)', 180, 214);
  SetLength(CustomsMap.ScavExtraction, 17);
  CustomsMap.ScavExtraction[0] := TMapTag.Create('��� ������� ����', 644, 123);
  CustomsMap.ScavExtraction[1] := TMapTag.Create('��� �����', 648, -25);
  CustomsMap.ScavExtraction[2] := TMapTag.Create('���������������� ������', 664, -53);
  CustomsMap.ScavExtraction[3] := TMapTag.Create('������� ���� ������', 651, -163);
  CustomsMap.ScavExtraction[4] := TMapTag.Create('����� 4', 342, -26);
  CustomsMap.ScavExtraction[5] := TMapTag.Create('������ ��������', 300, -196);
  CustomsMap.ScavExtraction[6] := TMapTag.Create('��������� ��������', 213, 1);
  CustomsMap.ScavExtraction[7] := TMapTag.Create('����� 17', 51, -74);
  CustomsMap.ScavExtraction[8] := TMapTag.Create('�������� �� ��', -16, -130);
  CustomsMap.ScavExtraction[9] := TMapTag.Create('�� �� �������', -165, -215);
  CustomsMap.ScavExtraction[10] := TMapTag.Create('�������� � ����������� �����', -249, -227);
  CustomsMap.ScavExtraction[11] := TMapTag.Create('�����������', -322, -83);
  CustomsMap.ScavExtraction[12] := TMapTag.Create('�� � �����', -142, 46);
  CustomsMap.ScavExtraction[13] := TMapTag.Create('�������� ���������', 21, 127);
  CustomsMap.ScavExtraction[14] := TMapTag.Create('������ �� ������ ������', 184, 211);
  CustomsMap.ScavExtraction[15] := TMapTag.Create('�� � ������� ����', 491, 219);
  CustomsMap.ScavExtraction[16] := TMapTag.Create('������ ����� �������', 540, 194);
  SetLength(CustomsMap.SharedExtraction, 0);
  SetLength(CustomsMap.Quests, 3);
  CustomsMap.Quests[0] := TQuestTag.Create('����������', [TPoint.Create(369, -50), TPoint.Create(26, -108)]);
  CustomsMap.Quests[1] := TQuestTag.Create('������ �� �����', [TPoint.Create(570, -22), TPoint.Create(496, -10), TPoint.Create(14, 0)]);
  CustomsMap.Quests[2] := TQuestTag.Create('����� - ����� 2', [TPoint.Create(184, 183)]);

  // ����� "��������"
  InterchangeMap.Name := 'Interchange';
  InterchangeMap.Left := TPoint.Create(533, -477);
  InterchangeMap.Right := TPoint.Create(-367, 423);
  InterchangeMap.FileName := 'Interchange.jpg';
  SetLength(InterchangeMap.PMCExtraction, 5);
  InterchangeMap.PMCExtraction[0] := TMapTag.Create('����� �� �������� ������', 475, -443);
  InterchangeMap.PMCExtraction[1] := TMapTag.Create('����� �� ��� (�������)', -248, -370);
  InterchangeMap.PMCExtraction[2] := TMapTag.Create('���� � ������', -219, -37);
  InterchangeMap.PMCExtraction[3] := TMapTag.Create('���������� �������', -45, 43);
  InterchangeMap.PMCExtraction[4] := TMapTag.Create('��� ���', -315, 262);
  SetLength(InterchangeMap.ScavExtraction, 0);
  SetLength(InterchangeMap.SharedExtraction, 0);
  SetLength(InterchangeMap.Quests, 4);
  InterchangeMap.Quests[0] := TQuestTag.Create('����������', [TPoint.Create(65, -156), TPoint.Create(94, -124), TPoint.Create(-26, -104),
                                                              TPoint.Create(94, 10), TPoint.Create(-31, 25)]);
  InterchangeMap.Quests[1] := TQuestTag.Create('��������� - ����� 1', [TPoint.Create(-3, -295), TPoint.Create(-76, -156), TPoint.Create(33, 146)]);
  InterchangeMap.Quests[2] := TQuestTag.Create('����� ����� - ����� 1', [TPoint.Create(276, 5), TPoint.Create(-172, -354), TPoint.Create(-202, -85)]);
  InterchangeMap.Quests[3] := TQuestTag.Create('�������� - ����� 1', [TPoint.Create(21, -107), TPoint.Create(23, -82)]);

  // ����� "�����"
  ShorelineMap.Name := 'Shoreline';
  ShorelineMap.Left := TPoint.Create(570, -450);
  ShorelineMap.Right := TPoint.Create(-1130, 650);
  ShorelineMap.FileName := 'Shoreline.jpg';
  SetLength(ShorelineMap.PMCExtraction, 7);
  ShorelineMap.PMCExtraction[0] := TMapTag.Create('�������', 385, 310);
  ShorelineMap.PMCExtraction[1] := TMapTag.Create('������� �� ����', 444, -210);
  ShorelineMap.PMCExtraction[2] := TMapTag.Create('����� ����������', -197, -360);
  ShorelineMap.PMCExtraction[3] := TMapTag.Create('�-����� ������ �� ������ (�������)', -543, -375);
  ShorelineMap.PMCExtraction[4] := TMapTag.Create('������ �� �������', -853, 10);
  ShorelineMap.PMCExtraction[5] := TMapTag.Create('��-����', -1025, 310);
  ShorelineMap.PMCExtraction[6] := TMapTag.Create('����� �� �������', -340, 575);
  SetLength(ShorelineMap.ScavExtraction, 0);
  SetLength(ShorelineMap.SharedExtraction, 0);
  SetLength(ShorelineMap.Quests, 14);
  ShorelineMap.Quests[0] := TQuestTag.Create('���������', [TPoint.Create(-264, -84), TPoint.Create(96, 96), TPoint.Create(-316, 496)]);
  ShorelineMap.Quests[1] := TQuestTag.Create('������� - ����� 1', [TPoint.Create(-256, -57), TPoint.Create(-316, 496)]);
  ShorelineMap.Quests[2] := TQuestTag.Create('������� - ����� 2', [TPoint.Create(99, 107)]);
  ShorelineMap.Quests[3] := TQuestTag.Create('����������', [TPoint.Create(380, 165), TPoint.Create(-348, 186), TPoint.Create(-155, -280)]);
  ShorelineMap.Quests[4] := TQuestTag.Create('���� ����', [TPoint.Create(-553, -129), TPoint.Create(81, -167)]);
  ShorelineMap.Quests[5] := TQuestTag.Create('���� �� ������', [TPoint.Create(98, 96), TPoint.Create(-305, 493)]);
  ShorelineMap.Quests[6] := TQuestTag.Create('�����������', [TPoint.Create(-236, -165), TPoint.Create(-594, 476)]);
  ShorelineMap.Quests[7] := TQuestTag.Create('������ - ����� 3', [TPoint.Create(-228, -88), TPoint.Create(-491, 250)]);
  ShorelineMap.Quests[8] := TQuestTag.Create('����� - ����� 1', [TPoint.Create(288, -40)]);
  ShorelineMap.Quests[9] := TQuestTag.Create('�������� - ����� 1', [TPoint.Create(-186, -87)]);
  ShorelineMap.Quests[10] := TQuestTag.Create('������� - ����� 1', [TPoint.Create(-181, -80), TPoint.Create(-290, -85), TPoint.Create(-567, 105)]);
  ShorelineMap.Quests[11] := TQuestTag.Create('����� - ����� 2', [TPoint.Create(-338, -90)]);
  ShorelineMap.Quests[12] := TQuestTag.Create('������� � ��������� - ����� 2', [TPoint.Create(-250, -47), TPoint.Create(-281, -43)]);
  ShorelineMap.Quests[13] := TQuestTag.Create('"��������" ������', [TPoint.Create(220, -158)]);

  // ����� "������"
  ReserveMap.Name := 'Reserve';
  ReserveMap.Left := TPoint.Create(222, -329);
  ReserveMap.Right := TPoint.Create(-227, 309);
  ReserveMap.FileName := 'Reserve.jpg';
  SetLength(ReserveMap.PMCExtraction, 5);
  ReserveMap.PMCExtraction[0] := TMapTag.Create('����������� �������', 51, -245);
  ReserveMap.PMCExtraction[1] := TMapTag.Create('�-2', -121, 170);
  ReserveMap.PMCExtraction[2] := TMapTag.Create('����� �� ������', -10, 209);
  ReserveMap.PMCExtraction[3] := TMapTag.Create('��������������� ���', 40, 76);
  ReserveMap.PMCExtraction[4] := TMapTag.Create('����������', 126, -145);
  SetLength(ReserveMap.ScavExtraction, 0);
  SetLength(ReserveMap.SharedExtraction, 0);
  SetLength(ReserveMap.Quests, 0);

end.
