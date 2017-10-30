{
  Stimulus Control
  Copyright (C) 2014-2017 Carlos Rafael Fernandes Picanço, Universidade Federal do Pará.

  The present file is distributed under the terms of the GNU General Public License (GPL v3.0).

  You should have received a copy of the GNU General Public License
  along with this program. If not, see <http://www.gnu.org/licenses/>.
}
unit Controls.Trials.FreeOperantCounter;

{$mode objfpc}{$H+}

interface

uses LCLIntf, LCLType, Controls, Classes, SysUtils, StdCtrls, Graphics

  , Controls.Trials.Abstract
  , Controls.Trials.Helpers
  , Schedules
  ;

type

  {
    TFreeOperantCounter
    Free operant with points at screen center.
    Point and Sound as consequences.
    Responses under TSchedule (of reinforcement)
  }

  TFreeOperantCounter = class(TTrial)
  private
    FDataSupport : TDataSupport;
    FLabelPoints : TLabel;
    FPoints : Integer;
    FSchedule : TSchedule;
    FConsequences : integer;
    procedure TrialBeforeEnd(Sender: TObject);
    procedure TrialKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure TrialStart(Sender: TObject);
    procedure Consequence(Sender: TObject);
    procedure Response(Sender: TObject);
  protected
    procedure WriteData(Sender: TObject); override;
  public
    constructor Create(AOwner: TComponent); override;
    procedure Play(ACorrection : Boolean); override;
  end;

implementation

uses
  constants
  , Timestamps
  , Audio.Bass_nonfree
  ;

constructor TFreeOperantCounter.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  OnTrialBeforeEnd := @TrialBeforeEnd;
  OnTrialKeyUp := @TrialKeyUp;
  OnTrialStart := @TrialStart;

  FLabelPoints := TLabel.Create(Self);
  with FLabelPoints do begin
    Caption := rsReportPoints + ':' + LineEnding + '0';
    Cursor := -1;
    Alignment := taCenter;
    WordWrap := True;
    Align:=alClient;
    Layout := tlCenter;
    Font.Name := 'TimesNewRoman';
    Font.Color := clBlack;
    Parent := TCustomControl(AOwner);
  end;

  FSchedule := TSchedule.Create(Self, DRH, 10, 4000);
  FSchedule.OnConsequence:=@Consequence;
  FSchedule.OnResponse:=@Response;

  Header := Header + #9 +
            rsReportStmBeg + #9 +
            rsReportStmDur + #9 +
            rsReportRspFrq + #9 +
            rsReportPoints;

  Result := T_NONE;
  IETConsequence := T_NONE;

  FConsequences := 0;
  FPoints := 0;
end;

procedure TFreeOperantCounter.TrialKeyUp(Sender: TObject;
  var Key: Word; Shift: TShiftState);
begin
  if Key = 32 { space } then
    if FConsequences >= 20 then EndTrial(Sender) else FSchedule.DoResponse;
end;

procedure TFreeOperantCounter.TrialBeforeEnd(Sender: TObject);
begin
  FDataSupport.StmEnd := TickCount;
  WriteData(Self); // must be self, see TBlc.WriteTrialData
end;

procedure TFreeOperantCounter.Play(ACorrection : Boolean);
begin
  inherited Play(ACorrection);
  with FLabelPoints do
    Font.Size := StrToIntDef(CfgTrial.SList.Values[_MsgFontSize], 22);

  if Self.ClassType = TFreeOperantCounter then Config(Self);
end;

procedure TFreeOperantCounter.TrialStart(Sender: TObject);
begin
  FSchedule.Start;
  FDataSupport.StmBegin := TickCount;
end;

procedure TFreeOperantCounter.Consequence(Sender: TObject);
var
  LSoundFile : string;
  LSound : TBassStream;
begin
  LSoundFile := RootMedia+'CSQ1.wav';

  // increment consequences
  Inc(FConsequences);

  // increment points
  Inc(FPoints);
  FLabelPoints.Caption:= rsReportPoints + ':' + LineEnding + IntToStr(FPoints);

  // play sound
  if FileExists(LSoundFile) then
  begin
    LSound := TBassStream.Create(LSoundFile);
    LSound.Play;
    LSound.Free;
  end;
  LogEvent('C');

  WriteData(Self); // must be self, see TBlc.WriteTrialData
  if Assigned(CounterManager.OnConsequence) then CounterManager.OnConsequence(Self);
end;

procedure TFreeOperantCounter.Response(Sender: TObject);
begin
  LogEvent('R');
  Inc(FDataSupport.Responses);

  if Assigned(CounterManager.OnStmResponse) then CounterManager.OnStmResponse(Sender);
  if Assigned(OnStmResponse) then OnStmResponse(Self);
end;

procedure TFreeOperantCounter.WriteData(Sender: TObject);
var aStart, aDuration : string;
begin
  inherited WriteData(Sender);
  aStart := TimestampToStr(FDataSupport.StmBegin - TimeStart);
  aDuration := TimestampToStr(FDataSupport.StmEnd - TimeStart);

  Data := Data +
    aStart + #9 +
    aDuration + #9 +
    Format('%-*.*d', [4, 8, FDataSupport.Responses]) + #9 +
    Format('%-*.*d', [4, 8, FPoints]);

  if Assigned(OnTrialWriteData) then OnTrialWriteData(Sender);
end;

end.
