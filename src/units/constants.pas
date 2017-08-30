{
  Stimulus Control
  Copyright (C) 2014-2017 Carlos Rafael Fernandes Picanço, Universidade Federal do Pará.

  The present file is distributed under the terms of the GNU General Public License (GPL v3.0).

  You should have received a copy of the GNU General Public License
  along with this program. If not, see <http://www.gnu.org/licenses/>.
}
unit constants;

{$mode objfpc}{$H+}

interface

const
  // Posições
  _Positions = 'Positions';
  _Cols = 'Cols';
  _Rows = 'Rows';
  _NumPos = 'NumPos';

  // Main
  _Main = 'Main';
  _Name = 'Name';
  _Subject = 'Subject';
  _Media  = 'Media';
  _Data  = 'Data';
  _RootData   = 'RootData';
  _RootMedia  = 'RootMedia';
  _NumBlc = 'NumBlc';
  _Type = 'Type';
  _ServerAddress = 'ServerAddress';

  // Blc
  _NumTrials = 'NumTrials';
  _CrtHitPorcentage = 'Criteria.HitPorcentage';
  _CrtConsecutiveHit  = 'ConsecutiveHitCriterion';
  _CrtConsecutiveMiss = 'ConsecutiveMissCriterion';
  _CrtMaxTrials = 'MaxTrialCriterion';
  _NextBlocOnCriteria = 'NextBloc.OnCriteria';
  _NextBlocOnNotCriteria = 'NextBloc.OnNotCriteria';
  _CsqCriterion = 'CsqCriterion';
  _DefNextBlc = 'DefNextBlc';
  _MaxCorrection = 'MaxCorrection';
  _MaxBlcRepetition = 'MaxBlcRepetition';
  _ITI = 'ITI';
  _Counter = 'Counter';
  _Counter_Performance = 'performance';

  // Blc and Trial
  _BkGnd = 'BkGnd';

  // Trial
  _Cursor = 'Cursor';
  _AutoNxt = 'AutoNxt';
  _CustomNxtValue = 'CustomNxtValue';
  _Kind = 'Kind';
  _LimitedHold = 'LimitedHold';
  _Consequence = 'Consequence';

  // MRD
  _UseMedia = 'UseMedia';
  _ShowStarter = 'Starter';
  _Angle = 'Angle';
  _ExpectedResponse = 'Response';
  _Schedule = 'Schedule';
  _NextTrial = 'NextTrial';
  _cGap = 'Gap';                 //boolean
  _cGap_Degree = 'GapDegree';
  _cGap_Length = 'GapLength';
  //some constants are shared with 'SIMPLE' when 'usemedia' is true

  // MSG
  _Msg = 'Msg';
  _MsgWidth = 'MsgWidth';
  _MsgFontSize = 'MsgFontSize';
  _MsgFontColor = 'MsgFontColor';
  _Prompt = 'Prompt';
  _Style = 'Style';

  // MTS
  _Delayed = 'Delayed';
  _Delay = 'Delay';

  // TCLB
  _ShowDots = 'ShowDots';
  _Blocking = 'Blocking';

  // FPE
  _DrawingType = 'DrawingType';
  _Contingency = 'Contingency';

  // GNG
  _PopUpTime = 'ConsequenceTime';
  _PresentConsequenceJustOnce = 'PresentConsequenceJustOnce';

  // SIMPLE
  _NumComp = 'NumComp';   // number of stimuli on screen / comparisons
  _cBnd = 'Bnd';          // top left width height
  _cStm = 'Stm';          // stimulus path
  _cSch = 'Sch';          // reinforcement schedule
  _cMsg = 'Msg';          // message sent to the report {REGDATA}
  _cCsq = 'Csq';          // PLP code,see the unit 'library'
  _cUsb = 'Usb';          // RS232 code, see the unit 'library'
  _cRes = 'Res';          // Kind of the response, hit, miss or none
  _cNxt = 'Nxt';          // Next trial {if = '0', same as '1', if > 0, go to the specified trial}
  _cIET = 'IET';          // Inter Trial Interval, in miliseconds
  _cTO  = 'TO';           // Time-Out Interval, in miliseconds

  // Identificadores
  _Kplus = 'K+';
  _Kminus = 'K-';
  _Pos = 'P';
  _Blc = 'Blc';
  _Trial = 'T';
  _Comp = 'C';
  _Samp = 'S';

  LAST_BLOCS_INI_FILENAME = 'last.blocs.ini';
  LAST_BLOC_INI_FILENAME = 'last.bloc.ini';


const
  { escriba }
  KEnter = #13#10;
  KPositions = '[Positions]' + #13#10;
  KMain = '[Main]' + #13#10;
  KName = 'Name=' + #9;
  KSubject = 'Subject=' + #9;
  KType = 'Type=' + #9;
  KMedia = 'Media=' + #9;
  KRootMedia = 'RootMedia=' + #9;
  KData = 'Data=' + #9;
  KRootData = 'RootData=' + #9;
  KServer = 'ServerAddress=' + #9;
  KNumBlc = 'NumBlc=' + #9;
  KNumTrial = 'NumTrials=' + #9;
  KMaxCorrection = 'MaxCorrection=' + #9;
  KCrtConsecutiveHit = 'ConsecutiveHitCriterion=' + #9;
  KCrtConsecutiveMiss = 'ConsecutiveMissCriterion=' + #9;
  KCrtMaxTrials = 'MaxTrialCriterion=' + #9;
  KCrtKCsqHit = 'CsqCriterion=' + #9;
  KNumComp = 'NumComp=' + #9;
  KRows = 'Rows=' + #9;
  KCols = 'Cols=' + #9;
  KNumPos = 'NumPos=' + #9;
  KBackGround = 'BkGnd=' + #9;
  KITInterval = 'ITI=' + #9;
  KCursor = 'Cursor=' + #9;
  KKind = 'Kind=' + #9;
  KComAtraso = 'Delayed=' + #9;
  KAtraso = 'Delay=' + #9;
  KAutoNext  = 'AutoNxt=' + #9;
  KCustomNext = 'CustomNxtValue=' + #9;
  KWidth = 'MsgWidth=' + #9;
  KFontSize = 'MsgFontSize=' + #9;
  KFontColor = 'MsgFontColor=' + #9;
  KPrompt = 'Prompt=' + #9;

  KUseMedia = 'UseMedia=' + #9;  //boolean
  KContingency = 'Contingency=' + #9;
  KShowStarter = 'Starter=' + #9; //boolean
  KAngle = 'Angle=' + #9;
  KExpectedResponse = 'Response=' + #9;
  KLimitedHold = 'LimitedHold=' + #9;
  KSchedule = 'Schedule=' + #9;
  KNextTrial = 'NextTrial=' + #9;
  KcGap = 'Gap=' + #9;                 //boolean
  KcGap_Degree = 'GapDegree=' + #9;
  KcGap_Length = 'GapLength=' + #9;
  KConsequence = 'Consequence=' +#9;

  KBnd = 'Bnd=' + #9;
  KStm = 'Stm=' + #9;
  KIET = 'IET=' + #9;
  KSch = 'Sch=' + #9;
  KMsg = 'Msg=' + #9;
  KCsq = 'Csq=' + #9;
  KUsb = 'Usb=' + #9;
  KRes = 'Res=' + #9;
  KNxt = 'Nxt=' + #9;
  KTO = 'TO='  + #9;

  { Session Parameters }
  T_CIC = 'CIC';
  T_CRT = 'CRT';
  T_CND = 'CND';

  { General Parameters }
  T_END = 'END';

  { Trial Kinds }

  T_GNG = 'GNG';
  T_MSQ = 'MSQ';
  T_DZT = 'DZT';
  T_CLB = 'CLB';
  T_FPFN = 'FPFN';
  T_MRD = 'MRD';
  T_MSG = 'MSG';
  T_MTS = 'MTS';
  T_Simple = 'SIMPLE';

  { Schedules }
  T_RR  = 'RR';
  T_FR  = 'FR';
  T_VR = 'VR';
  T_RI = 'RI';
  T_FI = 'FI';
  T_VI  = 'VI';
  T_RT = 'RT';
  T_VT = 'VT';
  T_FT  = 'FT';
  T_CRF = 'CRF';
  T_EXT  = 'EXT';
  T_DRL = 'DRL';
  T_DRH = 'DRH';

  { Res }
  T_HIT = 'HIT';
  T_MISS = 'MISS';
  T_NONE = 'NONE';

  { Nxt }
  T_REP = 'CRT';

const
  //report  messages
  rmKeyPlus = 'Tecla +';
  rmKeyMinus = 'Tecla -';

// report headers
resourcestring
  rsReportMsgTxt = 'Mensagem';
  rsReportStmBeg = 'S.Inicio';
  rsReportStmDur = 'S.Duracao';
  rsReportStmEnd = 'S.Fim';
  rsReportRspLat = 'R.Latencia';
  rsReportRspFrq = 'R.Frequencia';
  rsReportRspExp = 'R.Prevista';

  rsReportStmCmp = 'S.Comparacoes';
  rsReportStmCmpBeg = 'S.Comparacoes.Inicio';
  rsReportStmCmpEnd = 'S.Comparacoes.Fim';
  rsReportRspCmp = 'R.Comparacao.Escolhida';
  rsReportRspCmpLat = 'R.Comparacao.Escolhida.Latencia';
  rsReportStmCmpDur = 'S.Comparacoes.Duracao';

  rsReportStmMod = 'S.Modelo';
  rsReportStmModBeg = 'S.Modelo.Inicio';
  rsReportStmModEnd = 'S.Modelo.Fim';
  rsReportRspModLat = 'R.Modelo.Latencia';
  rsReportStmModDur = 'S.Modelo.Duracao';
  rsReportStmModDel = 'S.Modelo.Atraso';
  rsReportRspModFrq = 'R.Modelo.Frequencia';

  rsReportCsqPLP = 'C.PLP';
  rsReportCsqUSB = 'C.USB';
  rsReportCsqRes = 'C.Resultado';
  rsReportRspCmpFrq = 'R.Comparacoes.Frequencia';

  rsReportTime = 'Tempo';
  rsReportBlocID  = 'Bloco.ID';
  rsReportBlocName = 'Bloco.Nome';
  rsReportTrialID = 'Tentativa.ID';
  rsReportTrialNO = 'Tentativa.Contador';
  rsReportTrialName = 'Tentativa.Nome';
  rsReportEvent = 'Evento';
  rsReportITIBeg = 'IET.Inicio';
  rsReportITIEnd = 'IET.Fim';
  rsReportITI = 'IET';

  rsReportRspLft = 'Lft.Cmp.';
  rsReportRspTop = 'Top.Cmp.';

  rsNA = 'NA';
  RS_COL_SAMPLE = 'Modelo';
  RS_CELL_TRIALS_STM = 'Tent\Stm';


  ExceptionNoScheduleFound = 'Nenhum esquema de reforço encontrado, revise o arquivo de configuração.';
  ExceptionConfigurationNotAllowed = 'A configuração não é permitida.';

  // user configs
  rsPosition = 'Bnd';
  rsComparison = 'C';
  rsMTSRelation = 'Relação';
  rsTrials = 'Tentativas';
  rsConsequence = 'Consequência';
  rsAngle = 'Ângulo';
  rsExpectedResponse = 'Resposta';
  rsContingency = 'Contingência';
  rsPositive = 'Positiva';
  rsNegative = 'Negativa';
  rsStimulus = 'Figura';
  rsLimitedHold = 'Tempo/Estímulo';
  rsSize = 'Tamanho';
  rsDefBlc = 'Bloco 1';
  rsEndSession = 'Fim.';
  rsSchedule = 'Esquema';
  rsSample = 'Modelo';
  rsStimuli = 'Estímulos';
  rsButtonAdd = 'Adicionar';
  rsCaptionBlocs = 'Blocos';
  rsCaptionSessions = 'Sessões';
  rsCaptionNodeEnd= 'FIM';
  rsCaptionNodeBegin= 'INÍCIO';

  rsFilename = 'Nome do arquivo';
  rsColor = 'Cor';
  rsCount = 'Contar';
  rsMediaSound = 'Som';
  rsTimeOut = 'TimeOut';
  rsNextTrial = 'Tentativa Seguinte';
  rsUSBPort = 'Porta USB';
  rsDelay = 'Atraso';
  rsDuration = 'Duração';
  rsStyle = 'Estilo';

  rsFillTypeAxes = 'Eixos';
  rsFillTypeMatriz = 'FP/FN';
  rsFillTypeGoNoGo = 'Go/No-Go';
  rsFillTypeMTS = 'MTS e Simples';
  rsFillTypeBlocChaining = 'Encadear Blocos';
  rsHintBlocsAvailableRightClick = 'Clique com o botão direito e selecione os blocos disponíveis';
  rsBlocs = 'Bloco';
  rsBlocName = 'Nome';
  rsBlocCrtHitPorcentage = 'Critério (% de acertos)';
  rsBlocCrtConsecutiveHit = 'Critério (acertos consecutivos)';
  rsBlocMaxBlcRepetition = 'Número máximo de repetições seguidas do bloco';
  rsBlocNextBlocOnCriteria = 'Bloco seguinte se critério for atingido';
  rsBlocNextBlocOnNotCriteria = 'Bloco seguinte se critério não for atingido';
  rsBlocAddress = 'Endereço';
  rsBlocITI = 'Intervalo entre tentativas';
  rsBlocBkGnd = 'Cor do Fundo';
  rsBlocCounter = 'Mostrar contador ao final?';
  rsBlocVirtualTrialValue = 'Quantas tarefas contabilizam uma tentativa?';
  rsBlocMaxCorrection = 'Número máximo de correções por tentativa';

  rsWindowTitleChoosePositive = 'Escolhas as figuras positivas';
  rsWindowTitleChooseNegative = 'Escolhas as figuras negativas';


  //rsBlocDefNextBlc
  //rsBlocCrtConsecutiveMiss
  //rsBlocCrtMaxTrials
  rsMessCantContinueTableIsEmpty = 'Não foi possível continuar, pois a tabela de tentativas está vazia.';
  rsMessChooseRandomzieTargetCol = 'Escolha o alvo da randomização clicando sobre uma célula de uma coluna.';
  rsMessNoBlocFound = 'Nenhum Bloco foi encontrado.';

  rsRandomizeTrials = 'Randomizar ordem das tentativas';
  rsRandomizeResponses = 'Randomizar respostas';
  rsRandomizeGroupTrial = 'Randomizar em grupos ordem das tentativas';
  rsRandomizeTrialsWithConstraints = 'Randomizar ordem das tentativas com restrições.';

  // config_session
  messuCfgSessionMainError = 'Valor não encontrado: Main, Name or NumBlc.';
  messLoading = 'Carregando...';
  messReady = 'Pronto.';
  messRoot = 'Estrutura';
  messLevel_01 = 'Sessão 1';
  messLevel_04_M = 'Mensagem';
  rsDefName = 'No name';
  rsDefSubject = 'No subject';
  rsDefAddress = '127.0.1.1:50020';
  rsLanguagePTBR = 'Português (Brasil)';
  rsLanguageEN = 'Inglês';

  rsComboGridTypeEyeOrientationTask = 'Tarefa de orientação visual';
  rsComboGridTypeFPE = 'Discriminações sucessivas (feature positive effect)';
  rsComboGridTypeGONOGO = 'Discriminações sucessivas (go/no-go)';
  rsComboGridTypeSD = 'Discriminações simultâneas (simples)';
  rsComboGridTypeCD = 'Discriminações simultâneas (condicional, MTS)';
  rsComboGridTypeBlocChain = 'Encadeamento de blocos';
  rsComboBoxRandomizeTrialOrder =  'Ordem das tentativas';
  rsComboBoxRandomizeTrialOrderConstraints = 'Ordem das tentativas (com restrições)';
  rsComboBoxRandomizeResponses = 'Respostas';
  rsComboBoxBlocCounterNone = 'Não';
  rsComboBoxBlocCounterShowHitMiss = 'Mostrar número de acertos e erros';


implementation


end.

