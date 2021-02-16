program Testes;

uses
  System.StartUpCopy,
  FMX.Forms,
  uMain in 'uMain.pas' {main};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(Tmain, main);
  Application.Run;
end.
