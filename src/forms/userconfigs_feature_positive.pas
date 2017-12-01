{
  Stimulus Control
  Copyright (C) 2014-2017 Carlos Rafael Fernandes Picanço, Universidade Federal do Pará.

  The present file is distributed under the terms of the GNU General Public License (GPL v3.0).

  You should have received a copy of the GNU General Public License
  along with this program. If not, see <http://www.gnu.org/licenses/>.
}
unit userconfigs_feature_positive;

{$mode objfpc}{$H+}

interface

uses Classes, SysUtils, FileUtil, IDEWindowIntf, Forms, Controls, Graphics,
     Dialogs, ExtCtrls, StdCtrls, Spin, ActnList, Grids, XMLPropStorage
     , GUI.Helpers.Grids
     , Canvas.Helpers
     ;

type

    { TTrial }
    TComparison = record
        Top : integer;
        Left : integer;
        Width : integer;
        Height : integer;
        Path : string;
    end;

    TStmMatrix = array of array of TComparison;

    TStmCircleGrid = array of TComparison;

    TTrial = record
        Id : integer;
        Positive : Boolean;
        //Name: string;
        //Kind: string;
        //NumComp: integer;
        Comps : array of TComparison;
    end;

    TTrials = array of TTrial;

    { TFormFPE }

    TFormFPE = class(TForm)
      btnClose: TButton;
      btnMinimizeTopTab: TButton;
      btnOk: TButton;
      gbLimitedHold: TGroupBox;
      gbTrials: TGroupBox;
      LabelGapLength: TLabel;
      LabelLimitedHold: TLabel;
      LabelStimuliNumber: TLabel;
      LabelSize: TLabel;
      LabelBorder: TLabel;
      LabelTrials: TLabel;
      Panel1: TPanel;
      RadioGroupEffect: TRadioGroup;
      RadioGroupGrids: TRadioGroup;
      seGapLength: TSpinEdit;
      seLimitedHold: TSpinEdit;
      seSize: TSpinEdit;
      seBorder: TSpinEdit;
      seStimuliNumber: TSpinEdit;
      seTrials: TSpinEdit;
      PreviewTimer: TTimer;
      XMLPropStorage1: TXMLPropStorage;
      procedure btnEditNodes1Click(Sender: TObject);
      procedure btnMinimizeTopTabClick(Sender: TObject);
      procedure Button2Click(Sender: TObject);
      procedure cbPreviewChange(Sender: TObject);
      procedure FormActivate(Sender: TObject);
      procedure FormCreate(Sender: TObject);
      procedure FormDestroy(Sender: TObject);
      procedure FormKeyPress(Sender: TObject; var Key: char);
      procedure FormPaint(Sender: TObject);
      procedure PreviewTimerTimer(Sender: TObject);
      procedure RadioGroupGridsSelectionChanged(Sender: TObject);
      procedure seGapLengthEditingDone(Sender: TObject);
    private
    // fullscreen
      //FFullScreen : Boolean;
      //FOriginalBounds : TRect;
      //FOriginalWindowState : TWindowState;
      //FScreenBounds : TRect;
    // other
      FDrawMask : Boolean;
      FCanDraw : Boolean;
      FCurrentTrial : integer;
      FMonitor: integer;
      FTrials : TTrials;
      FBitmap : TBitmap;
      function GetMatrix(AMonitor : integer) : TStmMatrix;
      function GetCircleGrid(AMonitor : integer) : TStmCircleGrid;
      procedure SetMonitor(AValue: integer);
    public
      procedure AddTrialsToGrid(ATrialGrid : TStringGrid);
      procedure SetMatrix(AStmMatrix: TStmMatrix);
      procedure SetCircleGrid(AStmCircleGrid : TStmCircleGrid);
      procedure WriteToDisk(ADefaultMainSection: TStrings; ADefaultBlocSection : TStrings;
        ATrialGrid : TStringGrid; AFilename : string);
      property MonitorToShow : integer read FMonitor write SetMonitor;
    end;

var
  FormFPE: TFormFPE;

resourcestring
  rsPositive = 'Positiva';
  rsNegative = 'Negativa';
  rsComparison = 'C';
  rsPosition = 'Bnd';

implementation

{$R *.lfm}

uses LazFileUtils, Session.ConfigurationFile, strutils, constants;
{ TFormFPE }

procedure TFormFPE.FormActivate(Sender: TObject);
begin
  //BorderStyle := bsNone;
  FCurrentTrial := 0;
  WindowState:=wsMaximized;
  //SetMatrix(GetMatrix(MonitorToShow));
  SetCircleGrid(GetCircleGrid(MonitorToShow));
end;

procedure TFormFPE.FormCreate(Sender: TObject);
begin
  FBitmap := TBitmap.Create;
  RandomMask(FBitmap);
  FDrawMask := True;
end;

procedure TFormFPE.FormDestroy(Sender: TObject);
begin
  FBitmap.Free;
end;

procedure TFormFPE.FormKeyPress(Sender: TObject; var Key: char);
begin
  if key in [#32] then
    Panel1.Visible := not Panel1.Visible;
end;

procedure TFormFPE.FormPaint(Sender: TObject);
var
  i : integer;
  OldCanvas : TCanvas;
  aWidth, aHeight : integer;
  aR : TRect;
  aGapValues : string;
  aGap : Boolean;
  aGapDegree : integer;
  aGapLength : integer;

  procedure NextValue(var S : string);
  begin
    Delete( S, 1, pos( #32, S ) );
    if Length( S ) > 0 then
      while S[1] = #32 do
        Delete( S, 1, 1 );
  end;

  procedure SaveOldCanvas;
  begin
    OldCanvas.Brush.Color := Canvas.Brush.Color;
    OldCanvas.Brush.Style := Canvas.Brush.Style;

    OldCanvas.Pen.Color := Canvas.Pen.Color;
    OldCanvas.Pen.Style := Canvas.Pen.Style;
    OldCanvas.Pen.Mode := Canvas.Pen.Mode;
  end;

  procedure LoadOldCanvas;
  begin
    Canvas.Brush.Color := OldCanvas.Brush.Color;
    Canvas.Brush.Style := OldCanvas.Brush.Style;

    Canvas.Pen.Color := OldCanvas.Pen.Color;
    Canvas.Pen.Style := OldCanvas.Pen.Style;
    Canvas.Pen.Mode := OldCanvas.Pen.Mode;
  end;

begin
  if FCanDraw then
    begin
      OldCanvas := TCanvas.Create;
      SaveOldCanvas;
      if FDrawMask then
        Canvas.StretchDraw(ClientRect,FBitmap);
      LoadOldCanvas;

      try
        //DrawCircle(Canvas, 300, 300, 100, True, 50, 5 );
        if RadioGroupGrids.ItemIndex <> -1 then
          begin
            for i := Low(FTrials[FCurrentTrial].Comps) to Length(FTrials[FCurrentTrial].Comps)-1 do
              begin
                aR.Left := FTrials[FCurrentTrial].Comps[i].Left;
                aR.Top := FTrials[FCurrentTrial].Comps[i].Top;
                aWidth := FTrials[FCurrentTrial].Comps[i].Width;
                aR.Right := aR.Left + aWidth;
                aHeight := FTrials[FCurrentTrial].Comps[i].Height;
                aR.Bottom := aR.Top + aHeight;

                aGapValues := FTrials[FCurrentTrial].Comps[i].Path;
                //WriteLn(aGapValues);
                aGap := StrToBoolDef(Copy(aGapValues,0,pos(#32,aGapValues)-1),False);
                NextValue(aGapValues);

                aGapDegree := 16*StrToIntDef(Copy(aGapValues,0,pos(#32,aGapValues)-1),1);
                NextValue(aGapValues);

                aGapLength := 16*(360-StrToIntDef(Copy(aGapValues,0,pos(#32,aGapValues)-1),360));
                case RadioGroupGrids.ItemIndex of
                 0: DrawCustomEllipse(Canvas,aR,GetInnerRect(aR,aWidth,aHeight),aGap,aGapDegree,aGapLength);
                 1: DrawCustomEllipse(Canvas,AR,aGapDegree,aGapLength);
                end;
              end;
            i := FCurrentTrial + 1;
            Canvas.TextOut(FTrials[i-1].Comps[0].Left - 10, FTrials[i-1].Comps[0].Top - 10 , IntToStr(i));
            Canvas.TextOut(FTrials[i-1].Comps[0].Left - 20, FTrials[i-1].Comps[0].Top - 30 , BoolToStr(FTrials[FCurrentTrial].Positive, 'Positive', 'Negative'));
          end;

      finally
        LoadOldCanvas;
        OldCanvas.Free;
      end;
    end;
end;

procedure TFormFPE.PreviewTimerTimer(Sender: TObject);
begin
  if FCurrentTrial < High(FTrials) then
    Inc(FCurrentTrial)
  else FCurrentTrial := 0;
  Invalidate;
end;

procedure TFormFPE.RadioGroupGridsSelectionChanged(Sender: TObject);
begin
  case RadioGroupGrids.ItemIndex of
    0:
      begin
        FDrawMask := False;
        SetMatrix(GetMatrix(MonitorToShow));
      end;
    1:
      begin
        SetCircleGrid(GetCircleGrid(MonitorToShow));
        FDrawMask := True;
      end;
  end;
end;

procedure TFormFPE.seGapLengthEditingDone(Sender: TObject);
begin
  case RadioGroupGrids.ItemIndex of
    0: SetMatrix(GetMatrix(MonitorToShow));
    1: SetCircleGrid(GetCircleGrid(MonitorToShow));
  end;
end;

function TFormFPE.GetMatrix(AMonitor: integer): TStmMatrix;
var
  i,j,
  LRowCount,LColCount,SHeight,SWidth,SYGap,SXGap,SLeft,STop: integer;
  function GetPositionFromSegment(ASegmentSize,AStep,ASteps,
    AStimulusSize,AInterStimulusGap : integer):integer;
  var
    LSize : integer;
  begin
    LSize := AStimulusSize + AInterStimulusGap;
    Result := Round((LSize*AStep)-((LSize*ASteps)/2)+((ASegmentSize+AInterStimulusGap)/2));
  end;
begin
  SHeight := 150;
  SWidth := 150;
  SYGap := 100;
  SXGap := 100;
  SLeft := 0;
  STop := 0;
  LRowCount := 3;
  LColCount := 3;
  SetLength(Result, LRowCount,LColCount);
  for i := Low(Result) to High(Result) do
    begin
      SLeft := GetPositionFromSegment(Screen.Monitors[AMonitor].Width,i,LColCount,SWidth,SXGap);
      for j:= Low(Result[i]) to High(Result[i]) do
        begin
          STop := GetPositionFromSegment(Screen.Monitors[AMonitor].Height,j,LRowCount,SHeight,SYGap);
          Result[i][j].Left := SLeft;
          Result[i][j].Top := STop;
          Result[i][j].Width := SWidth;
          Result[i][j].Height := SHeight;
        end;
    end;
end;

function TFormFPE.GetCircleGrid(AMonitor: integer): TStmCircleGrid;
var
  LP : TPoint;
  LR : TRect;
  LW, LH,
  LSLeft, LSTop, LSCount, i, LSSize, LBorderSize: Integer;
begin
  LBorderSize := seBorder.Value;
  LSSize := seSize.Value;
  LW := Screen.Monitors[AMonitor].Width;
  LH := Screen.Monitors[AMonitor].Height;
  //LR := GetCentralRect(LW,LH,(LSSize+LBorderSize) div 2);
  LR := GetCentralRect(LW, LH, LBorderSize, LBorderSize, LBorderSize, LBorderSize);

  LSCount := seStimuliNumber.Value;
  SetLength(Result,LSCount);
  for i := 0 to LSCount -1 do
    begin
      LP := GetPointFromAngle(i*(360/LSCount),LR);
      LSLeft:= LP.X- (LSSize div 2);
      LSTop := LP.Y- (LSSize div 2);
      Result[i].Left := LSLeft;
      Result[i].Top := LSTop;
      Result[i].Width := LSSize;
      Result[i].Height := LSSize;
    end;
end;

procedure TFormFPE.SetMonitor(AValue: integer);
begin
  if FMonitor = AValue then Exit;
  FMonitor := AValue;
  Left := Screen.Monitors[FMonitor].Left;
end;

procedure TFormFPE.AddTrialsToGrid(ATrialGrid: TStringGrid);
var
  aComp, LowComp, HighComp : integer;
  aContingency, aPosition : string;
  aCol, aRow, aTrial : integer;
begin
  {
    Example:

    3 x 3 matriz = 9 positions
    2 trials per position
    ______________________________

    Equals to a Group of 18 trials to repeat.

    It gives 72 trials repeating it by 4.
    ______________________________

  }
  aRow := 1;
  aCol := 0;
  for aTrial := Low(FTrials) to High(FTrials) do
  begin
    if FTrials[aTrial].Positive then
      aContingency := rsPositive
    else
      aContingency := rsNegative;

    with ATrialGrid do
      begin
        if (aRow + 1) > RowCount then RowCount := aRow + 1;
        Cells[0, aRow] := IntToStr(aRow);    //Trial Number
        Cells[1, aRow] := aContingency;
        Cells[2, aRow] := '';
        aCol := 3;

        LowComp := Low(FTrials[aTrial].Comps);
        HighComp := High(FTrials[aTrial].Comps);
        for aComp := LowComp to HighComp do
        begin
          if (aCol + 1) > ColCount then ColCount := aCol + 1;
          Cells[aCol, 0] := rsComparison + IntToStr(aComp + 1);
          Cells[aCol, aRow] := FTrials[aTrial].Comps[aComp].Path;
          Inc(aCol);
        end;

        for aComp := LowComp to HighComp do
        begin
          if (aCol + 1) > ColCount then ColCount := aCol + 1;
          Cells[aCol, 0] := rsComparison + IntToStr(aComp + 1) + rsPosition;
          aPosition := IntToStr(FTrials[aTrial].Comps[aComp].Top) + #32 +
                       IntToStr(FTrials[aTrial].Comps[aComp].Left) + #32 +
                       IntToStr(FTrials[aTrial].Comps[aComp].Width) + #32 +
                       IntToStr(FTrials[aTrial].Comps[aComp].Height);

          Cells[aCol, aRow] := aPosition;
          Inc(aCol);
        end;
        Inc(aRow);
      end;
    end;
end;

procedure TFormFPE.SetMatrix(AStmMatrix : TStmMatrix);
var
  LCount,LTrial, LStimulusToGap, LComp, i, j : integer;
  LGapDegree : integer;
  LGapLength : integer;
  LHasGap : Boolean;
begin
  LStimulusToGap := 0;
  LCount := (High(AStmMatrix)+1)*(High(AStmMatrix[0])+1);
  FCanDraw := False;
  // seTrials.Value default is 4, and 4 coordenates
  // we are making a 72 trials session, 4 * 2 trials for each coordenate;
  // times 2 cause we are making a go/no-go session, each positive trial must have a negative correlate
  // here 36 positive, 36 negative
  SetLength( FTrials, (seTrials.Value*LCount)*2);

  // set coordenates to memory
  for LTrial := Low(FTrials) to High(FTrials) do
    begin
      SetLength(FTrials[LTrial].Comps, LCount);

      LComp := 0;
      for i := Low(AStmMatrix) to High(AStmMatrix) do
        for j := Low(AStmMatrix[i]) to High(AStmMatrix[i]) do
          begin
            FTrials[LTrial].Comps[LComp].Left := AStmMatrix[i][j].Left;
            FTrials[LTrial].Comps[LComp].Top := AStmMatrix[i][j].Top;
            FTrials[LTrial].Comps[LComp].Width := AStmMatrix[i][j].Width;
            FTrials[LTrial].Comps[LComp].Height := AStmMatrix[i][j].Height;
            Inc(LComp);
          end;

      LHasGap := (LTrial mod 2) = 0;
      case RadioGroupEffect.ItemIndex of
       0: FTrials[LTrial].Positive := LHasGap;
       1: FTrials[LTrial].Positive := not LHasGap;
      end;

      for LComp := 0 to LCount -1 do
        begin
          if LHasGap and (i = LStimulusToGap) then
            begin
              LGapDegree := Random(361);
              LGapLength := seGapLength.Value;
              FTrials[LTrial].Comps[LComp].Path := '1' + #32 + IntToStr(LGapDegree) + #32 + IntToStr(LGapLength) + #32;
            end
          else
            FTrials[LTrial].Comps[LComp].Path := '0' + #32 + '0' + #32 + '0' + #32;
        end;

      if LHasGap then
        if LStimulusToGap = LCount-1 then
          LStimulusToGap := 0
        else
          Inc(LStimulusToGap);
    end;
  LabelTrials.Caption := IntToStr(High(FTrials)+1);
  FCanDraw := True;
  Invalidate;
end;

procedure TFormFPE.SetCircleGrid(AStmCircleGrid: TStmCircleGrid);
var
  LCount,LTrial, i : integer;
  LHasGap : Boolean;
  LStimulusToGap,
  LGapDegree : integer;
  LGapLength : integer;
begin
  LStimulusToGap := 0;
  LCount := High(AStmCircleGrid)+1;
  FCanDraw := False;
  // seTrials.Value default is 4, and 4 coordenates
  // we are making a 72 trials session, 4 * 2 trials for each coordenate;
  // times 2 cause we are making a go/no-go session, each positive trial must have a negative correlate
  // here 36 positive, 36 negative
  SetLength(FTrials, (seTrials.Value*LCount)*2);

  // set coordenates to memory
  for LTrial := Low(FTrials) to High(FTrials) do
    begin
      SetLength(FTrials[LTrial].Comps, LCount);

      LHasGap := (LTrial mod 2) = 0;
      case RadioGroupEffect.ItemIndex of
       0: FTrials[LTrial].Positive := LHasGap;
       1: FTrials[LTrial].Positive := not LHasGap;
      end;

      for i := Low(AStmCircleGrid) to High(AStmCircleGrid) do
        begin
          FTrials[LTrial].Comps[i].Left := AStmCircleGrid[i].Left;
          FTrials[LTrial].Comps[i].Top := AStmCircleGrid[i].Top;
          FTrials[LTrial].Comps[i].Width := AStmCircleGrid[i].Width;
          FTrials[LTrial].Comps[i].Height := AStmCircleGrid[i].Height;

          if LHasGap and (i = LStimulusToGap) then  // there is a gap
            begin
              LGapDegree := Random(361);
              LGapLength := seGapLength.Value;
              FTrials[LTrial].Comps[i].Path := '1' + #32 + IntToStr(LGapDegree) + #32 + IntToStr(LGapLength) + #32;
            end
          else // no gap
            FTrials[LTrial].Comps[i].Path := '0' + #32 + '0' + #32 + '0' + #32;
        end;

      if LHasGap then
        if LStimulusToGap = High(AStmCircleGrid) then
          LStimulusToGap := 0
        else
          Inc(LStimulusToGap);
    end;

  LabelTrials.Caption := IntToStr(High(FTrials)+1);
  FCanDraw := True;
  Invalidate;
end;

procedure TFormFPE.btnMinimizeTopTabClick(Sender: TObject);
begin
  Panel1.Visible := not Panel1.Visible;
end;

procedure TFormFPE.btnEditNodes1Click(Sender: TObject);
begin
  case RadioGroupGrids.ItemIndex of
   0: SetMatrix(GetMatrix(MonitorToShow));
   1: SetCircleGrid(GetCircleGrid(MonitorToShow));
  end;
end;

procedure TFormFPE.Button2Click(Sender: TObject);
begin
  Inc(FcurrentTrial);
end;

procedure TFormFPE.cbPreviewChange(Sender: TObject);
begin
  PreviewTimer.Enabled := not PreviewTimer.Enabled;
  //ShowMessage(BoolToStr(PreviewTimer.Enabled));
  Invalidate;
end;

procedure TFormFPE.WriteToDisk(ADefaultMainSection: TStrings;
  ADefaultBlocSection: TStrings; ATrialGrid: TStringGrid; AFilename: string);
var
  LRow : integer;
  LNewBloc : TConfigurationFile;
  LNumComp : Integer;
  LValues : string;
  i : integer;
  function GetNumComp : integer;
  var TopRightCell : string;
  begin
    with ATrialGrid do
      begin
        TopRightCell := Cells[ColCount - 1, 0];
        Delete(TopRightCell, Pos(rsPosition, TopRightCell), Length(rsPosition));
        Delete(TopRightCell, Pos(rsComparison, TopRightCell), Length(rsComparison));
        Result := StrToInt(TopRightCell);
      end;
  end;
begin
  if FileExistsUTF8(AFilename) then
    DeleteFileUTF8(AFilename);

  LNewBloc := TConfigurationFile.Create(AFilename);
  LNewBloc.CacheUpdates:=True;
  LNewBloc.WriteMain(ADefaultMainSection);
  LNewBloc.WriteBlocIfEmpty(1,ADefaultBlocSection);

  with ATrialGrid do
    for LRow := 1 to RowCount-1 do
      begin
         //SList.Values[_BkGnd] := IntToStr(clWhite);
          LNewBloc.WriteToTrial(LRow, _Kind, T_FPFN);
          LNewBloc.WriteToTrial(LRow, _Name,            Cells[1, LRow] + #32 + IntToStr(LRow));
          LNewBloc.WriteToTrial(LRow, _Contingency,     Cells[1, LRow]);
          LNewBloc.WriteToTrial(LRow, _ShouldPlaySound, Cells[2, LRow]);
          LNewBloc.WriteToTrial(LRow, _Schedule,        T_CRF);
          LNewBloc.WriteToTrial(LRow, _ShowStarter,     BoolToStr(False, '1','0'));
          LNewBloc.WriteToTrial(LRow, _Cursor,          IntToStr(crNone));
          LNewBloc.WriteToTrial(LRow, _LimitedHold,     '4000');
          LNewBloc.WriteToTrial(LRow, _NextTrial,       '0');

          LNumComp := GetNumComp;
          LNewBloc.WriteToTrial(LRow, _NumComp,         IntToStr(LNumComp));
          for i := 1 to LNumComp do
            begin
              LNewBloc.WriteToTrial(LRow,_Comp+IntToStr(i)+_cBnd, Cells[i+2+LNumComp, LRow]);
              LValues :=  Cells[i + 2, LRow] + #32;
              LNewBloc.WriteToTrial(LRow,_Comp + IntToStr(i) + _cGap, ExtractDelimited(1,LValues,[#32]));
              LNewBloc.WriteToTrial(LRow,_Comp + IntToStr(i) + _cGap_Degree, ExtractDelimited(2,LValues,[#32]));
              LNewBloc.WriteToTrial(LRow,_Comp + IntToStr(i) + _cGap_Length, ExtractDelimited(3,LValues,[#32]));
            end;
      end;

  // update numblc and numtrials
  LNewBloc.Invalidate;

  // Save changes to disk
  LNewBloc.UpdateFile;
  LNewBloc.Free;
end;

end.

