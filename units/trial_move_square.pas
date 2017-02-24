{
  Stimulus Control
  Copyright (C) 2014-2017 Carlos Rafael Fernandes Picanço, Universidade Federal do Pará.

  The present file is distributed under the terms of the GNU General Public License (GPL v3.0).

  You should have received a copy of the GNU General Public License
  along with this program. If not, see <http://www.gnu.org/licenses/>.
}
unit trial_move_square;

{$mode objfpc}{$H+}

interface

uses LCLIntf, Classes, SysUtils, Forms, Graphics
    , pupil_communication
    , trial_abstract
    , draw_methods
    ;

type

  FDataSupport = record
    TrialBegin : Extended;
    TrialEnd : Extended;
  end;

  { TMSQ }

  {
    Move a square with eye movements
  }
  TMSQ = class(TTrial)
  private
    FPolygon : TPoints;
    FGazePoint : TPoint;
    FDataSupport : FDataSupport;
    procedure None(Sender: TObject);
    procedure UpdateSquare(Sender: TObject; AMultiPartMessage : TMPMessage);
    procedure TrialKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure TrialStart(Sender: TObject);
    procedure TrialBeforeEnd(Sender: TObject);
    procedure TrialPaint;
  protected
    procedure WriteData(Sender: TObject); override;
    procedure Paint; override;
  public
    constructor Create(AOwner: TComponent); override;
    procedure Play(ACorrection : Boolean); override;
  end;

implementation

uses timestamps;

{ TMSQ }

procedure TMSQ.TrialKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if (ssCtrl in Shift) and (key = 67) { c } then
    if GlobalContainer.PupilEnabled then
      //
end;

procedure TMSQ.None(Sender: TObject);
begin
  { Implement an OnNone event here }
  if Assigned(OnNone) then OnNone(Sender);
end;

procedure TMSQ.UpdateSquare(Sender: TObject; AMultiPartMessage: TMPMessage);
var
  LX,LY : Double;
begin
  if AMultiPartMessage.Topic = 'surface' then
    with AMultiPartMessage.Message do
      if LowerCase(S['name']) = 'screen' then
		    if O['gaze_on_srf'].Count > 0 then
  		    { 'topic':'gaze',
            'norm_pos':p['norm_pos'],
            'confidence':p['confidence'],
            'timestamp':p['timestamp'],
            'base_data':[p] }
          with O['gaze_on_srf'].Items[0].O['norm_pos'] do
		        begin

              LX := Items[0].AsFloat;
		          LY := Items[1].AsFloat;

              LY := 1.0-LY;
              FGazePoint := Point(Round(LX*Screen.Width),Round(LY*Screen.Height));
		          // WriteLn('x,y:',FGazePoint.X,',',FGazePoint.Y);
              Invalidate;
				    end;
end;

procedure TMSQ.TrialBeforeEnd(Sender: TObject);
begin
  // Trial Result
  Result := 'NONE';
  IETConsequence := 'NONE';
  FDataSupport.TrialEnd := TickCount;

  // Write Data
  WriteData(Sender);
end;

procedure TMSQ.TrialStart(Sender: TObject);
begin
  if GlobalContainer.PupilEnabled then
    begin
      GlobalContainer.PupilClient.Subscribe('surface');
      GlobalContainer.PupilClient.OnMultiPartMessageReceived := @UpdateSquare;
    end;
  FDataSupport.TrialBegin := TickCount;
  Invalidate;
end;

procedure TMSQ.TrialPaint;
begin

end;

procedure TMSQ.WriteData(Sender: TObject);
begin
  inherited WriteData(Sender);
  Data := Data + #9 +
          TimestampToStr(FDataSupport.TrialBegin - TimeStart) + #9 +
          TimestampToStr(FDataSupport.TrialEnd - TimeStart);

  if Assigned(OnTrialWriteData) then OnTrialWriteData(Self);
end;

procedure TMSQ.Paint;
const
  L_SIZE : integer = 100;
var
  i : integer;
begin
  inherited Paint;
  Canvas.Brush.Color := clWhite;
  Canvas.Rectangle(FGazePoint.X-L_SIZE,FGazePoint.Y-L_SIZE, FGazePoint.X+L_SIZE, FGazePoint.Y+L_SIZE);
  for i := 0 to High(FPolygon) do
    begin
      if PointInPolygon(FGazePoint.X,FGazePoint.Y,FPolygon) then
        Canvas.Brush.Color := clGreen;
      //else
      //  Canvas.Brush.Color := clWhite;
      Canvas.Polygon(FPolygon);
    end;
end;

constructor TMSQ.Create(AOwner: TComponent);
const
  LSize : integer = 100;
var
  LX,LY : integer;
begin
  inherited Create(AOwner);
  OnTrialBeforeEnd := @TrialBeforeEnd;
  OnTrialKeyUp := @TrialKeyUp;
  OnTrialStart := @TrialStart;
  FGazePoint := Point(0,0);

  // Square
  SetLength(FPolygon,4);
  LX := 300; LY := 300;
  FPolygon[0] := Point(LX,LY);
  FPolygon[1] := Point(LX+LSize,LY);
  FPolygon[2] := Point(LX+LSize,LY+LSize);
  FPolygon[3] := Point(LX,LY+LSize);

  with Canvas do
    begin
      Brush.Color := clBlack;
      Pen.Color   := clBlack;

      Brush.Style := bsSolid;
      Pen.Style   := psSolid
    end;

  Header := 'StmBegin' + #9 +
            '__StmEnd' + #9 ;
end;

procedure TMSQ.Play(ACorrection: Boolean);
begin
  inherited Play(ACorrection);

  if Self.ClassType = TMSQ then Config(Self);
end;


end.

