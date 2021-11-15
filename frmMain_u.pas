unit frmMain_u;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.StdCtrls, entity_u;

type
  TForm1 = class(TForm)
    Timer1: TTimer;
    Panel1: TPanel;
    Memo1: TMemo;
    Panel2: TPanel;
    PaintBox1: TPaintBox;
    Label1: TLabel;
    Label2: TLabel;
    procedure Timer1Timer(Sender: TObject);
  private
    fgame: Tgame;
  protected
    procedure KeyDown(var Key: Word; Shift: TShiftState); override;
    procedure DoShow; override;
    { Private declarations }
  public

    procedure init_game;
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}


procedure TForm1.init_game;
begin
  fgame.canvas := PaintBox1.canvas;
  fgame.can_display := true;
  fgame.width := (PaintBox1.ClientWidth div SCALE_NUM) * SCALE_NUM;
  fgame.height := (PaintBox1.ClientHeight div SCALE_NUM) * SCALE_NUM;
  fgame.startGame();
  Timer1.Enabled := true;
end;

procedure TForm1.DoShow;
begin
  inherited;
  init_game();
end;

constructor TForm1.Create(AOwner: TComponent);
begin
  inherited;
  fgame := Tgame.Create;
end;

destructor TForm1.Destroy;
begin
  Timer1.Enabled := false;
  fgame.Free;

  inherited;
end;

procedure TForm1.KeyDown(var Key: Word; Shift: TShiftState);
begin
  inherited;
  if fgame.isRuning then
  begin
    fgame.last_key := 0;
    fgame.KeyDown(Key);
    Memo1.Text := (fgame.scan_map.ToString);
  end
  else
  begin
    fgame.startGame();

  end;
end;

procedure TForm1.Timer1Timer(Sender: TObject);
begin
  // if fgame.isRuning then
  fgame.draw;
end;

end.
