unit userconfigs_trial_mirrored;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  {$IFDEF LCLGTK2}
  gtk2, gdk2, //glib2,
  {$ENDIF}
  Spin, ValEdit, Grids, ExtCtrls, draw_methods, math
  ;

type

  { TBresenhamLineForm }
  TTrialsPerNode = array of integer;
  { TCustomAxis }

  TCustomAxis = record
    Trials : integer;
    Angle : string;
    Size : integer;
    BresenhamLine : TPoints;
    Line : TPoints;
    MirroredLine : TPoints;
    TrialsPerNode : TTrialsPerNode;
  end;

  TAxisList = record
    CanRead : Boolean;
    List : array of TCustomAxis;
  end;

  TBresenhamLineForm = class(TForm)
    btnAddAxis: TButton;
    btnEditNodes: TButton;
    btnMinimize: TButton;
    btnFinish: TButton;
    btnRmvAxis: TButton;
    btnShow: TButton;
    Button1: TButton;
    cbChooseGrid: TComboBox;
    cbCentralized: TCheckBox;
    cbUseGrid: TCheckBox;
    cbPreview: TCheckBox;
    cbNox0y0: TCheckBox;
    gbAddRmvAxis: TGroupBox;
    gbPointOne: TGroupBox;
    gbPointZero: TGroupBox;
    gbTrials: TGroupBox;
    lbNodes: TLabel;
    lbSize: TLabel;
    Panel1: TPanel;
    seNodes: TSpinEdit;
    seSize: TSpinEdit;
    seTrials: TSpinEdit;
    StringGrid1: TStringGrid;
    PreviewTimer: TTimer;
    x0: TSpinEdit;
    x1: TSpinEdit;
    y0: TSpinEdit;
    y1: TSpinEdit;
    procedure btnAddAxisClick(Sender: TObject);
    procedure btnFinishClick(Sender: TObject);
    procedure btnMinimizeClick(Sender: TObject);
    procedure btnShowClick(Sender: TObject);
    procedure cbCentralizedChange(Sender: TObject);
    procedure cbChooseGridChange(Sender: TObject);
    procedure cbNox0y0Change(Sender: TObject);
    procedure cbPreviewChange(Sender: TObject);
    procedure cbUseGridChange(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormKeyPress(Sender: TObject; var Key: char);
    procedure FormMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure FormMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure FormMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure FormPaint(Sender: TObject);
    procedure PreviewTimerStartTimer(Sender: TObject);
    procedure PreviewTimerTimer(Sender: TObject);
    procedure seNodesChange(Sender: TObject);
    procedure SpinChange(Sender: TObject);
    procedure SpinClick(Sender: TObject);
    procedure EditingDone(Sender: TObject);
  private
    FCurrentTrial : integer;
    FGrid : TPoints;
    FGridNames : array of string;
    FCentralRect : TRect;
    FCapturing : Boolean;
    FDrawEllipseC : Boolean;
    FBresenhamLine : TPoints;
    FTrialsPerNode : TTrialsPerNode;
    FAngle : String;
    FLine : TPoints;
    FMirroredLine : TPoints;
    FAxis : TAxisList;
    //fullscreen
    FFullScreen : Boolean;
    FOriginalBounds: TRect;
    FOriginalWindowState: TWindowState;
    FScreenBounds: TRect;
    procedure RefreshLine;
    procedure CentralizeStm;
    function GetLine(aBresenhamLine : TPoints) : TPoints;
    function GetMirroredLine(aLine : TPoints) : TPoints;
    function GetAngleFromPoints(p1, p2 : TPoint) : String;
    function GetPointFromAngle (aAngle : float) : TPoint;//standard or user defined distances?
    function GetCentralRect (aLeftBorderSpace, aTopBorderSpace, aRightBorderSpace, aBottomBorderSpace: integer) : TRect;
  public
    procedure SetFullScreen(TurnOn: Boolean);
    property Axis : TAxisList read FAxis;
  end;

var
  BresenhamLineForm: TBresenhamLineForm;

implementation

{$R *.lfm}

{ TBresenhamLineForm }

procedure TBresenhamLineForm.FormPaint(Sender: TObject);
var i, mX, mY:  integer; mP : TPoint;
begin

  mP := ScreenToClient(Point(Mouse.CursorPos.X, Mouse.CursorPos.Y));
  mX := mP.X;
  mY := mP.Y;

  if FDrawEllipseC then
    begin
     Canvas.Brush.Color:= clGreen;
     Canvas.Brush.Style:= bsSolid;
     Canvas.Ellipse(mX -5, mY -5, mX +5, mY +5);
     Canvas.Brush.Style:= bsClear;
    end;

  for i := Low(FBresenhamLine) to High(FBresenhamLine) do
    begin
      PlotPixel(Canvas, FBresenhamLine[i], clBlack);
    end;

  for i := Low(FLine) to High(FLine) do
    begin
      mX := FLine[i].X;
      mY := FLine[i].Y;
      Canvas.Ellipse(mX -5, mY -5, mX +5, mY +5);
      Canvas.TextOut(mX, mY -25, IntToStr(FTrialsPerNode[i]))
    end;

  Canvas.Pen.Color:= clRed;
  Canvas.Rectangle(FCentralRect);
  Canvas.Pen.Color:= clBlack;
  Canvas.TextOut(x0.Value + 10, y0.Value + 10 , FAngle);


  case cbChooseGrid.ItemIndex of
    0:{nothing};
    1..2:begin

      for i := Low(FGrid) to High(FGrid)do
        begin
          mP := FGrid[i];
          mX := mP.X;
          mY := mP.Y;
          Canvas.Ellipse(mX -5, mY -5, mX +5, mY +5);
          Canvas.TextOut(mX, mY, FGridNames[i])
      end;

    end;
  end;

  if cbPreview.Checked then
    begin
      DrawCircle(Canvas, FLine[FCurrentTrial].X, FLine[FCurrentTrial].Y, seSize.Value, False, 0, 0);
      DrawCircle(Canvas, FMirroredLine[FCurrentTrial].X, FMirroredLine[FCurrentTrial].Y, seSize.Value, False, 0, 0);

    end;
  with Canvas do
    begin
      Brush.Style := bsClear;
      Brush.Color := clWhite;
      Pen.Style := psSolid;
      Pen.Color := clBlack;
      Pen.Mode := pmCopy;
    end;
end;

procedure TBresenhamLineForm.PreviewTimerStartTimer(Sender: TObject);
begin
  FCurrentTrial := High(Fline);
  Invalidate;
end;

procedure TBresenhamLineForm.PreviewTimerTimer(Sender: TObject);
begin
  if FCurrentTrial > Low(FLine) then
    Dec(FCurrentTrial)
  else FCurrentTrial := High(Fline);
  Invalidate;
end;

procedure TBresenhamLineForm.seNodesChange(Sender: TObject);
begin
  //RefreshLine;
end;

procedure TBresenhamLineForm.SpinChange(Sender: TObject);
begin

end;

procedure TBresenhamLineForm.SpinClick(Sender: TObject);
  var i : integer;
begin
  if (Sender = x0) or (Sender = x1) or (Sender = y0) or (Sender = y1) or (Sender = seNodes) then
    RefreshLine;

  if Sender = seTrials then
    begin
      SetLength(FTrialsPerNode, Length(FLine));
      for i := Low(FTrialsPerNode) to High(FTrialsPerNode) do
        FTrialsPerNode[i] := seTrials.Value;
    end;
  Invalidate;
end;

procedure TBresenhamLineForm.EditingDone(Sender: TObject);
  var i : integer;
begin
  if (Sender = x0) or (Sender = x1) or (Sender = y0) or (Sender = y1) or (Sender = seNodes) then
    RefreshLine;

  if Sender = seTrials then
    begin
      SetLength(FTrialsPerNode, Length(FLine));
      for i := Low(FTrialsPerNode) to High(FTrialsPerNode) do
        FTrialsPerNode[i] := seTrials.Value;
    end;
  Invalidate;
end;

procedure TBresenhamLineForm.RefreshLine;
begin
  FBresenhamLine := BresenhamLine(x0.value, x1.Value, y0.value, y1.value);
  if cbCentralized.Checked then
      begin
        FLine := GetLine(FBresenhamLine);
        CentralizeStm;
      end
    else
      begin
        FLine := GetLine(FBresenhamLine);
        FMirroredLine := GetMirroredLine(FLine);
      end;
  FAngle := GetAngleFromPoints(Point(x0.value,y0.value), Point(x1.Value, y1.value));
end;

procedure TBresenhamLineForm.CentralizeStm;
var i, fix : integer;
begin
  fix := seSize.Value div 2;
  for i := Low(FLine) to High(FLine) do
    begin
      FLine[i].X := FLine[i].X - fix;
      FLine[i].Y := FLine[i].Y - fix;
    end;
  FMirroredLine := GetMirroredLine(FLine);
end;

procedure TBresenhamLineForm.FormCreate(Sender: TObject);
var i : integer;
begin
  x0.value := Screen.Width div 2;
  y0.value := Screen.Height div 2;
  RefreshLine;

  SetLength(FTrialsPerNode, Length(FLine));
  for i := Low(FTrialsPerNode) to High(FTrialsPerNode) do
  FTrialsPerNode[i] := seTrials.Value;

  FCentralRect := Rect(0, 0, Screen.Width, Screen.Height);
  Canvas.Brush.Style:= bsClear;
end;

procedure TBresenhamLineForm.FormKeyPress(Sender: TObject; var Key: char);
begin
  if key in [#32] then
    begin
      Panel1.Visible := not Panel1.Visible;
      gbAddRmvAxis.Visible := not gbAddRmvAxis.Visible;
    end;
end;

procedure TBresenhamLineForm.FormActivate(Sender: TObject);
begin
  SetFullScreen(True);
end;

procedure TBresenhamLineForm.btnMinimizeClick(Sender: TObject);
begin
  Panel1.Visible := not Panel1.Visible;
  gbAddRmvAxis.Visible := not gbAddRmvAxis.Visible;
end;

procedure TBresenhamLineForm.btnShowClick(Sender: TObject);
begin

  with StringGrid1 do
  if (FAxis.CanRead) and (Cells[0, Row] <> '') then
    begin
      //showmessage(IntToStr(Row));
      FAngle := FAxis.List[Row -1].Angle;
      seSize.value := FAxis.List[Row -1].Size;
      FBresenhamLine := FAxis.List[Row -1].BresenhamLine;
      FLine := FAxis.List[Row -1].Line;
      FMirroredLine := GetMirroredLine(FLine);
      FTrialsPerNode := FAxis.List[Row -1].TrialsPerNode;

      x0.value := FLine[Low(FLine)].X;
      y0.value := FLine[Low(FLine)].Y;
      x1.value := FLine[High(FLine)].X;
      y1.value := FLine[High(FLine)].Y;
    end;
  Invalidate;
end;

procedure TBresenhamLineForm.cbCentralizedChange(Sender: TObject);
begin
  if cbCentralized.Checked then CentralizeStm
  else
    begin
      FLine := GetLine(FBresenhamLine);
      FMirroredLine := GetMirroredLine(FLine);
    end;
  Invalidate;
end;

procedure TBresenhamLineForm.cbChooseGridChange(Sender: TObject);
var i: integer; aDegree : Float;
begin
  i := seSize.value div 2;
  case cbChooseGrid.ItemIndex of
    0 : FCentralRect := Rect(0, 0, Screen.Width, Screen.Height);
    1 : FCentralRect := GetCentralRect(0, 0, 0, 0);
    2 : FCentralRect := GetCentralRect(i, i, i, i);
  end;

  SetLength(FGrid, 360 div 5);
  SetLength(FGridNames, 360 div 5);
  aDegree := 0;
  for i := Low(FGrid) to High (FGrid) do
    begin
      FGridNames[i]:= FloatToStr(aDegree);
      FGrid[i] := GetPointFromAngle(aDegree);
      aDegree := aDegree + 5;
    end;
  RefreshLine;
  Invalidate;
end;

procedure TBresenhamLineForm.cbNox0y0Change(Sender: TObject);
begin
  RefreshLine;
  Invalidate;
end;

procedure TBresenhamLineForm.cbPreviewChange(Sender: TObject);
begin
  PreviewTimer.Enabled:= cbPreview.Checked;
end;

procedure TBresenhamLineForm.cbUseGridChange(Sender: TObject);
begin
  cbChooseGrid.Enabled := not cbChooseGrid.Enabled;
  if not cbChooseGrid.Enabled then cbChooseGrid.ItemIndex := 0;
end;


procedure TBresenhamLineForm.btnAddAxisClick(Sender: TObject);
begin
  FAxis.CanRead := False;
  with StringGrid1 do
    begin
      Row := RowCount;
      SetLength(FAxis.List, RowCount -1);
      with FAxis.List[Row -1] do
        begin
          BresenhamLine := FBresenhamLine;
          Line := FLine;
          MirroredLine := FMirroredLine;
          Angle := FAngle;
          Size := seSize.value;
          Trials := seTrials.Value;
          TrialsPerNode := FTrialsPerNode;
        end;


      if Cells[0, Row] = '' then  //selected row has empty cell on first column
        begin
            case cbChooseGrid.ItemIndex of
              0..2 : begin
                    Cells[0, Row] := FAxis.List[Row -1].Angle;
                  end;
              else
                  begin
                    Cells[0, Row] := 'NA';
                  end;

            end;
          Cells[1, Row] := IntToStr(FAxis.List[Row -1].Trials);
          Cells[2, Row] := IntToStr(Length(FAxis.List[Row -1].Line));
        RowCount := RowCount + 1;
        Row := RowCount;
        end;
    end;
  FAxis.CanRead := True;
end;

procedure TBresenhamLineForm.btnFinishClick(Sender: TObject);
begin

end;

procedure TBresenhamLineForm.FormMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  i : integer;
begin
    if Button = mbLeft then
    begin
      if (x1.value - X)*(x1.value - X) +
         (y1.value - Y)*(y1.value - Y) < 300 then
        begin
          FCapturing := True;
          x1.Value := X;
          Y1.Value := Y;
          RefreshLine;
        end
      else
      if (x0.value - X)*(x0.value - X) +
         (y0.value - Y)*(y0.value - Y) < 300 then
        begin
          FCapturing := True;
          x0.Value := X;
          Y0.Value := Y;
          RefreshLine;
        end;
    for i := Low(FGrid) to High(FGrid) do
      if (FGrid[i].X - X)*(FGrid[i].X - X) +
      (FGrid[i].Y - Y)*(FGrid[i].Y - Y) < 600 then
        begin
          x1.Value := FGrid[i].X;
          y1.Value := FGrid[i].Y;
        end;

    end;
end;

procedure TBresenhamLineForm.FormMouseMove(Sender: TObject; Shift: TShiftState;
  X, Y: Integer);
begin
  if (x1.value - X)*(x1.value - X) +
     (y1.value - Y)*(y1.value - Y) < 300 then
    begin
      FDrawEllipseC := True;
      Invalidate;
    end
  else
    begin
      FDrawEllipseC := False;
      Invalidate;
    end;

  if FCapturing then
    begin
      X1.Value := X;
      Y1.Value := Y;

      RefreshLine;

      Invalidate;
    end;
end;

procedure TBresenhamLineForm.FormMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  FCapturing := False;

  if x1.value < FCentralRect.Left then x1.value := FCentralRect.Left;
  if x1.value > FCentralRect.Right then x1.value := FCentralRect.Right;
  if y1.value < FCentralRect.Top then y1.value := FCentralRect.Top;
  if y1.value > FCentralRect.Bottom then y1.value := FCentralRect.Bottom;
  RefreshLine;


  //y0.value
  //y1.value
  Invalidate;
end;

function TBresenhamLineForm.GetLine(aBresenhamLine: TPoints): TPoints;
var
  i, index :  integer; step, aux : float; iaux : TPoint;
begin
  SetLength(Result,seNodes.Value);

  index := High(aBresenhamLine);
  aux := index;
  step := Length(aBresenhamLine) / (seNodes.Value -1);
  for i := High(Result) downto 1 do
    begin
      Result[i] := aBresenhamLine[index];

      aux := aux - step;
      index := Round(aux);
    end;

  Result[Low(Result)] := aBresenhamLine[Low(aBresenhamLine)];

  if cbNox0y0.Checked then
    begin
      for i := Low(Result) to High(Result) - 1 do
        begin
          iaux := Result[i + 1];
          Result[i + 1] := Result[i];
          Result[i] := iaux;
        end;
      SetLength(Result, Length(Result) -1);
    end;
end;

function TBresenhamLineForm.GetMirroredLine(aLine: TPoints): TPoints;
var i, HalfScreenWidth, HalfScreenHeight, Distance : integer;
begin
  SetLength(Result, Length(aLine));
  HalfScreenWidth := Round(Screen.Width/2);
  HalfScreenHeight := Round(Screen.Height/2);

  if cbCentralized.Checked then
    begin
      HalfScreenWidth := HalfScreenWidth - (seSize.Value div 2);
      HalfScreenHeight := HalfScreenHeight - (seSize.Value div 2);
    end;
  for i := Low(aLine) to High(aLine) do
    begin
     Distance := aLine[i].X;
     if Distance = HalfScreenWidth then Result[i].X := Distance
     else
      if Distance < HalfScreenWidth then Result[i].X := ABS(Distance - HalfScreenWidth) + HalfScreenWidth
      else
       Result[i].X := ABS(ABS(Distance - HalfScreenWidth) - HalfScreenWidth);

     Distance := aLine[i].Y;
     if Distance = HalfScreenHeight then Result[i].Y := Distance
     else
      if Distance < HalfScreenHeight then Result[i].Y := ABS(Distance - HalfScreenHeight) + HalfScreenHeight
        else
         Result[i].Y := ABS(ABS(Distance - HalfScreenHeight) - HalfScreenHeight);
    end;

end;

function TBresenhamLineForm.GetAngleFromPoints(p1, p2: TPoint): String;
  //http://stackoverflow.com/questions/15596217/angle-between-two-vectors
  function AngleOfLine(const P1, P2: TPoint): Double;
  begin
    Result := RadToDeg(ArcTan2((P2.Y - P1.Y),(P2.X - P1.X)));
    if Result < 0 then
      Result := Result + 360;
  end;
begin
  Result := FloatToStrF(AngleOfLine(p1,p2), ffFixed, 8, 2);
end;

function TBresenhamLineForm.GetPointFromAngle(aAngle: float): TPoint;
var Distance : float;
begin
  //http://math.stackexchange.com/questions/143932/calculate-point-given-x-y-angle-and-distance
  //0 on the right, clock increment
  //if aAngle = 0 then
  Distance :=  ((FCentralRect.Right - FCentralRect.Left)/ 2); // '-5' found by trial and error...
  Result.X :=  Round((Distance * cos(DegtoRad(aAngle))) + x0.value);//Screen.Width div 2;
  Result.Y :=  Round((Distance * sin(DegtoRad(aAngle))) + y0.value);//Screen.Height div 2;
end;

function TBresenhamLineForm.GetCentralRect(aLeftBorderSpace, aTopBorderSpace,
  aRightBorderSpace, aBottomBorderSpace: integer): TRect;
  var side : integer;
begin
    if Screen.Height > Screen.Width then
      begin
        side := Screen.Width;
        Result := Rect( (0 + aLeftBorderSpace),
                        (0  + (Screen.Height div 2) - (side div 2) +  aTopBorderSpace),
                        (side - aRightBorderSpace),
                        (side + (Screen.Height div 2) - (side div 2) +  - aBottomBorderSpace)
                      );
      end
    else if Screen.Height < Screen.Width then
      begin
        side := Screen.Height;
        Result := Rect( (0 + (Screen.Width div 2) - (side div 2) + aLeftBorderSpace),
                        (0 + aTopBorderSpace),
                        (side + (Screen.Width div 2) - (side div 2) - aRightBorderSpace),
                        (side - aBottomBorderSpace)
                      );
      end
    else if Screen.Height = Screen.Width then
      begin
        side := Screen.Height;
        Result := Rect( (0 + aLeftBorderSpace),
                        (0 + aTopBorderSpace),
                        (side - aRightBorderSpace),
                        (side - aBottomBorderSpace)
                      );
      end;
end;


procedure TBresenhamLineForm.SetFullScreen(TurnOn: Boolean);
begin
  if TurnOn then
    begin
      //fullscreen true
      FOriginalWindowState := WindowState;
      FOriginalBounds := BoundsRect;

      BorderStyle := bsNone;
      FScreenBounds := Screen.MonitorFromWindow(Handle).BoundsRect;
    with FScreenBounds do
      SetBounds(Left, Top, Right - Left, Bottom - Top);
      {$IFDEF WINDOWS}
        Application.ShowInTaskBar := False;
      {$ENDIF}

      {$IFDEF LCLGTK2}
      gdk_window_fullscreen(PGtkWidget(Self.Handle)^.window);
      {$ENDIF}
    end
  else
    begin
      //fullscreen false
      {$IFDEF MSWINDOWS}
      BorderStyle := bsSizeable;
      {$ENDIF}

      if FOriginalWindowState = wsMaximized then
        WindowState := wsMaximized
      else
        with FOriginalBounds do
          SetBounds(Left, Top, Right - Left, Bottom - Top);

      {$IFDEF LINUX}
      BorderStyle := bsSizeable;
      {$ENDIF}

      {$IFDEF LCLGTK2}
      gdk_window_unfullscreen(PGtkWidget(Self.Handle)^.window);
      {$ENDIF}
    end;
  FFullScreen := TurnOn;
end;

end.
