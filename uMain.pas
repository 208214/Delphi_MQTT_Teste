unit uMain;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, System.Json.Types,
  System.Json.Writers, REST.Types, FMX.ScrollBox, FMX.Memo, FMX.Edit, FMX.StdCtrls,
  FMX.Controls.Presentation, Data.Bind.Components, Data.Bind.ObjectScope,
  REST.Client, TMS.MQTT.Global, TMS.MQTT.Client, FMX.Objects, System.Math.Vectors;

type
  Tmain = class(TForm)
    btStartSignal: TButton;
    lbTemperatura: TLabel;
    lbUmidade: TLabel;
    edTemperatura: TEdit;
    edUmidade: TEdit;
    lbTemperaturaUnit: TLabel;
    lbUmidadeUnit: TLabel;
    Panel1: TPanel;
    MQTTClient: TTMSMQTTClient;
    Panel2: TPanel;
    lbHostName: TLabel;
    lbHostPort: TLabel;
    lbIDClient: TLabel;
    lbUser: TLabel;
    lbPassword: TLabel;
    edCredencialPassword: TEdit;
    edCredencialUser: TEdit;
    edIDDevice: TEdit;
    edHostPort: TEdit;
    edHostName: TEdit;
    btConnect: TButton;
    tDados: TMemo;
    lbStatus: TLabel;
    Panel3: TPanel;
    edTopicoTemperatura: TEdit;
    lbT�picoTemp: TLabel;
    btPublish: TButton;
    Publish_Continous: TTimer;
    tmSignal: TTimer;
    lbTopicoUmid: TLabel;
    edTopicoUmidade: TEdit;
    lbTimer: TLabel;
    edTimer: TEdit;
    lbmilisecond: TLabel;
    imTemperaturaGraf: TImage;
    imUmidadeGraf: TImage;
    pnGrafic: TPanel;
    lbTitulo1: TLabel;
    lbTitulo2: TLabel;
    Label1: TLabel;
    lbTitulo4: TLabel;
    Label2: TLabel;
    pnDataSendGraf: TPanel;
    imTempSend: TImage;
    imUmidSend: TImage;
    Label3: TLabel;
    Label4: TLabel;
    pnDisplaysGer: TPanel;
    pnDisplaySend: TPanel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    Label10: TLabel;
    edTempGer: TEdit;
    edUmidGer: TEdit;
    edTempSend: TEdit;
    edUmidSend: TEdit;
    lbFreqGen: TLabel;
    edFreqGen: TEdit;
    lbFreqGenUnit: TLabel;
    lbSampleSend: TLabel;
    edSampleSend: TEdit;
    lbSampleSendUnit: TLabel;
    procedure btConnectClick(Sender: TObject);
    procedure MQTTClientConnectedStatusChanged(ASender: TObject;
      const AConnected: Boolean; AStatus: TTMSMQTTConnectionStatus);
    procedure btPublishClick(Sender: TObject);
    procedure Publish_ContinousTimer(Sender: TObject);
    procedure tmSignalTimer(Sender: TObject);
    procedure btStartSignalClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);

  private
    { Private declarations }
  public
    { Public declarations }
    procedure PlotSignal(time_count, signal: single; image: TImage; divisor: integer);
    procedure DrawGraf(image: TImage);
    procedure ReadConfig();
    procedure WriteConfig();
 //   function CriaJSON(NomeSinal: string; valor: integer): string;
  var
    time_second   : integer;
  end;

var
  main          : Tmain;
  Writer        : TJsonTextWriter;
  StringWriter  : TStringWriter;

implementation

{$R *.fmx}
{********************************************************************************}
// Procedimento : WriteConfig - Salva as configura��o do MQTT em arquivo .txt
// Recebe       : Nada
// Retorna      : Nada
{********************************************************************************}
procedure TMain.WriteConfig();
var
  saveConfig  : TextFile;
begin
  AssignFile(saveConfig,'C:\Users\Willians de Almeida\Documents\Delphi Testes\Delphi_Testes\log.txt');
  Rewrite(saveConfig);
  Writeln(SaveConfig, edHostName.Text);
  Writeln(SaveConfig, edHostPort.text);
  Writeln(SaveConfig, edIDDevice.Text);
  Writeln(SaveConfig, edCredencialUser.Text);
  Writeln(SaveConfig, edCredencialPassword.Text);
  Writeln(SaveConfig, edTopicoTemperatura.Text);
  Writeln(SaveConfig, edTopicoUmidade.Text);
  CloseFile(SaveConfig);
end;

{********************************************************************************}
// Procedimento : ReadConfig - L� as configura��o do MQTT em arquivo .txt
// Recebe       : Nada
// Retorna      : Nada
{********************************************************************************}
procedure TMain.ReadConfig();
var
  saveConfig  : TextFile;
  name        : String;
  port        : String;
  idDevice    : String;
  userCred    : String;
  passCred    : String;
  topicTemp   : String;
  topicUmid   : String;
begin
  AssignFile(saveConfig,'C:\Users\Willians de Almeida\Documents\Delphi Testes\Delphi_Testes\log.txt');
  {$I-}
  Reset(saveConfig);
  {$I+}
  Readln(SaveConfig, name);
  Readln(SaveConfig, port);
  Readln(SaveConfig, idDevice);
  Readln(SaveConfig, userCred);
  Readln(SaveConfig, passCred);
  Readln(SaveConfig, topicTemp);
  Readln(SaveConfig, topicUmid);
  CloseFile(saveConfig);

  edHostName.Text             := name;
  edHostPort.text             := port;
  edIDDevice.Text             := idDevice;
  edCredencialUser.Text       := userCred;
  edCredencialPassword.Text   := passCred;
  edTopicoTemperatura.Text    := topicTemp;
  edTopicoUmidade.Text        := topicUmid;

end;

{********************************************************************************}
// Procedimento : DrawGraf - Desenha a �rea do gr�fico onde ser� plotado os valores
// Recebe       : Imagem (TImage)
// Retorna      : Nada
{********************************************************************************}
procedure TMain.DrawGraf(image: TImage);
var
  p1, p2, p3, p4 : TPointF;

begin
  p1  := TPointF.Create(round(image.Width/2),0);
  p2  := TPointF.Create(round(image.Width/2),round(image.Height));
  p3  := TPointF.Create(0, round(image.Height/2));
  p4  := TPointF.Create(round(image.Width), round(image.Height/2));
  image.Bitmap.SetSize(round(image.Width),round(image.Height));
  image.Bitmap.Clear(TAlphaColors.Black);
  image.Bitmap.Canvas.BeginScene;
  image.Bitmap.Canvas.Stroke.Thickness  := 0.5;
  image.Bitmap.Canvas.Stroke.Color := TAlphaColors.Lightgray;
  image.Bitmap.Canvas.DrawLine(p1, p2, 100);
  image.Bitmap.Canvas.DrawLine(p3, p4, 100);
  image.Bitmap.Canvas.EndScene;
end;

{********************************************************************************}
// Procedimento : PlotSignal - Plota o gr�fico em fun��o do tempo dos sinais
// Recebe       : time_count e signal: single, image: TImage e divisor: inteiro
// Retorna      : Nada
{********************************************************************************}
procedure TMain.PlotSignal (time_count, signal: single; image: TImage; divisor: integer);
var
  signalPlot  : TPointF;
  time_int    : integer;
begin
  time_int  := trunc(time_count) mod trunc(image.Width);

  if (time_int > (trunc(image.Width) - 2)) then DrawGraf(image);

  signalPlot.X  := time_int;
  signalPlot.Y  := ((-signal) / divisor) + image.Height;

  image.Bitmap.Canvas.BeginScene;
  image.Bitmap.Canvas.Stroke.Thickness  := 1.5;
  image.Bitmap.Canvas.Stroke.Color := TAlphaColors.Yellow;
  image.Bitmap.Canvas.DrawLine(signalPlot,signalPlot,100);
  image.Bitmap.Canvas.EndScene;
end;

{********************************************************************************}
// Fun��o   : CriaJSON - Formata os dados para o padr�o JSON
// Recebe   : NomeSinal e Unidade: String, valor: real
// Retorna  : String
{********************************************************************************}
function CriaJSON(NomeSinal: string; Unidade: string; valor: Double): string;
begin
  StringWriter        := TStringWriter.Create();
  Writer              := TJsonTextWriter.Create(StringWriter);
  Writer.Formatting   := TJsonFormatting.Indented;

//  Writer.WriteStartObject;
//  Writer.WritePropertyName('Cloud');
//  Writer.WriteStartArray;
  Writer.WriteStartObject;
  Writer.WritePropertyName(NomeSinal);
  Writer.WriteValue(valor);
  Writer.WritePropertyName('unit');
  Writer.WriteValue(Unidade);
  Writer.WriteEndObject;
//  Writer.WriteEndArray;
//  Writer.WriteEndObject;
  Result  := StringWriter.ToString;
end;

{********************************************************************************}
// Procedimento : MQTTClientConnectedStatusChange - Levanta os status durante
//                a conex�o com o broker MQTT
// Recebe       : AConnected: booleano, AStatus: TTMSMQTTConnectionStatus
// Retorna      : Nada
{********************************************************************************}
procedure TMain.MQTTClientConnectedStatusChanged(ASender: TObject;
  const AConnected: Boolean; AStatus: TTMSMQTTConnectionStatus);
begin
  if (AConnected) then
  begin
    lbStatus.Text     := 'Conectado ao Broker';
    btPublish.Enabled := true;
  end else
  Begin
    case AStatus of
      csNotConnected: ShowMessage('Sem Conex�o');
      csConnectionRejected_InvalidProtocolVersion: ShowMessage('Protocolo Invalido');
      csConnectionRejected_InvalidIdentifier: ShowMessage('Identificador Invalido');
      csConnectionRejected_ServerUnavailable: ShowMessage('Servidor Indispon�vel');
      csConnectionRejected_InvalidCredentials: ShowMessage('Credenciais Invalidas') ;
      csConnectionRejected_ClientNotAuthorized: ShowMessage('Cliente N�o Autorizado');
      csConnectionLost: ShowMessage('Conex�o Pedida');
      csConnecting: lbStatus.Text := 'Conectando';
      csReconnecting: lbStatus.Text := 'Reconectando';
      csConnected: lbStatus.Text := 'Conectado com o Broker';
    end;
  tDados.Lines.Clear;
  tDados.Lines.Add(MQTTClient.BrokerHostName);
  tDados.Lines.Add(IntToStr(MQTTClient.BrokerPort));
  tDados.Lines.Add(MQTTClient.Credentials.Username);
  tDados.Lines.Add(MQTTClient.Credentials.Password);
  tDados.Lines.Add(MQTTClient.ClientID);
  tDados.Lines.Add('');
  End;

end;

{********************************************************************************}
// Procedimento : Publish_ContinuousTimer - Atualiza os valores a serem publicados
//                no broker MQTT
// Recebe       : Nada
// Retorna      : Nada
{********************************************************************************}
procedure Tmain.Publish_ContinousTimer(Sender: TObject);
var
  packetId      : Word;
  JSONData      : String;
  timeSend      : Integer;
begin
  JSONData  := CriaJson(lbTemperatura.Text, lbTemperaturaUnit.text, StrToFloat(edTemperatura.Text));
  packetId  := MQTTClient.Publish (edTopicoTemperatura.Text, JSONData , qosAtleastOnce, true);
  tDados.Lines.Add(JSONData);
  tDados.Lines.Add('');

  JSONData  := CriaJson(lbUmidade.Text, lbUmidadeUnit.Text, StrToFloat(edUmidade.Text));
  packetId  := MQTTClient.Publish (edTopicoUmidade.Text, JSONData , qosAtleastOnce, true);
  tDados.Lines.Add(JSONData);
  tDados.Lines.Add('');

  PlotSignal((packetId / 2) , (StrToFloat(edTemperatura.Text)), imTempSend, 1);
  PlotSignal((packetId / 2), (StrToFloat(edUmidade.Text)), imUmidSend, 2);

  edTempSend.Text := edTemperatura.Text;
  edUmidSend.Text := edUmidade.Text;

end;

{********************************************************************************}
// Procedimento : tmSignalTimer - Gera os sinais a serem publicados no broker
//                MQTT
// Recebe       : Nada
// Retorna      : Nada
{********************************************************************************}
procedure Tmain.tmSignalTimer(Sender: TObject);
var
  temperatura   : double;
  umidade       : double;
  omega         : double;
  frequencia    : double;

begin
  frequencia          := StrToFloat(edFreqGen.Text);
  omega               := 2 * pi * frequencia;
  time_second         := time_second + 1;
  temperatura         := ((25 * sin (omega * (time_second/(1000/tmSignal.Interval))))+ 25);
  umidade             := ((50 * cos (omega * (time_second/(1000/tmSignal.Interval))))+ 50);

  edTemperatura.Text  := format('%0.2f',[temperatura]);
  edUmidade.Text      := format('%0.2f',[umidade]);

  PlotSignal(time_second, temperatura,imTemperaturaGraf, 1);
  PlotSignal(time_second, umidade,imUmidadeGraf, 1);

  edTempGer.Text    := edTemperatura.Text;
  edUmidGer.Text    := edUmidade.Text;

end;

{********************************************************************************}
// Procedimento : btConnectClick - Conecta ao borker MQTT Configurado
// Recebe       : Nada
// Retorna      : Nada
{********************************************************************************}
procedure Tmain.btConnectClick(Sender: TObject);
begin
  WriteConfig();

  MQTTClient.BrokerHostName       := edHostName.Text;
  MQTTClient.BrokerPort           := strToint (edHostPort.text);
  MQTTClient.ClientID             := edIDDevice.Text;
  MQTTClient.Credentials.Username := edCredencialUser.Text;
  MQTTClient.Credentials.Password := edCredencialPassword.Text;

  MQTTClient.Connect(True);

end;

{********************************************************************************}
// Procedimento : btPublishClick - Habilita / Para publica��es no broker MQTT -
//                Publish_ContinousTimer
// Recebe       : Nada
// Retorna      : Nada
{********************************************************************************}
procedure Tmain.btPublishClick(Sender: TObject);
begin
  if (Publish_Continous.Enabled = false) then
  begin
    Publish_Continous.Interval  := (StrToInt(edSampleSend.Text) * 1000);
    btPublish.Text              := 'Para Publicar';
    Publish_Continous.Enabled   := true;

  end else
  if (Publish_Continous.Enabled = true) then
  begin
    btPublish.Text            := 'Publicar';
    Publish_Continous.Enabled := false;
  end else

end;

{********************************************************************************}
// Procedimento : btStartSignalClick - Habilita / Para gerador de sinais
//                configurado - tmSignalTimer
// Recebe       : Nada
// Retorna      : Nada
{********************************************************************************}
procedure Tmain.btStartSignalClick(Sender: TObject);
begin
  if (tmSignal.Enabled = false) then
  begin
    tmSignal.Interval     := StrToInt(edTimer.Text);
    btStartSignal.Text    := 'Parar Sinal';
    tmSignal.Enabled      := true;
  end else
  if (tmSignal.Enabled = true) then
  begin
    btStartSignal.Text    := 'Geral Sinal';
    tmSignal.Enabled      := false;
  end;

end;

{********************************************************************************}
// Procedimento : FormCreate - Configura��es durante a inicializa��o do software
// Recebe       : Nada
// Retorna      : Nada
{********************************************************************************}
procedure Tmain.FormCreate(Sender: TObject);
begin
  btPublish.Enabled := false;
  DrawGraf(imTemperaturaGraf);
  DrawGraf(imUmidadeGraf);
  DrawGraf(imTempSend);
  DrawGraf(imUmidSend);
  ReadConfig();
end;

end.
