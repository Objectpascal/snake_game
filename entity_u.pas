unit entity_u;

interface

uses system.Classes, system.SysUtils, Vcl.Graphics, Winapi.Windows,
  matrix_operation_u;

const
  SCALE_NUM = 24;

type

  TEntity = class
  private
    fx: integer;
    fy: integer;
    fwidth: integer;
    fheight: integer;
    fcolor: TColor;
  public
    constructor Create; virtual;
    property x: integer read fx write fx;
    property y: integer read fy write fy;
    property width: integer read fwidth write fwidth;
    property height: integer read fheight write fheight;
    property color: TColor read fcolor write fcolor;
    function get_rect(const dx: integer = 0; dy: integer = 0): TRect;
  end;

  TsnakeHead = class(TEntity)
  private
    FlistOfBody: Tlist;
    fbodycolor: TColor; // Tlist<TEntity>
  public
    procedure add_new();
    procedure clearAll();

    function self_hit(): boolean;
    function hit_snake(ax, ay: integer): boolean;
    procedure moveStep(dx, dy: integer);

    constructor Create; override;
    destructor Destroy; override;
    property bodyColor: TColor read fbodycolor write fbodycolor;
  end;

  Tgame = class
  private
    fscore: integer;
    fsnakeHead: TsnakeHead;
    fball: TEntity;
    fcanvas: TCanvas;
    fwidth: integer;
    fheight: integer;
    fbackgroundColor: TColor;
    flastkey: Word;
    fisRuning: boolean;
    fcan_display: boolean;
    fstrave: integer;
    fage: integer;
    procedure change_ballPostion();

  public
    function scan_map(): Tmatrix;
    function fitness(): real;
    constructor Create;
    destructor Destroy; override;
    procedure KeyDown(Key: Word);
    procedure init_game();
    procedure draw;
    procedure update;
    procedure startGame();
    procedure endGame();
    property canvas: TCanvas read fcanvas write fcanvas;
    property score: integer read fscore write fscore;
    property width: integer read fwidth write fwidth;
    property height: integer read fheight write fheight;
    property backgroundColor: TColor read fbackgroundColor
      write fbackgroundColor;
    property isRuning: boolean read fisRuning;
    property last_key: Word read flastkey write flastkey;
    property can_display: boolean read fcan_display write fcan_display;
    property age: integer read fage;

  end;

implementation

function scalledby(x: integer; scal: integer): integer;
begin
  result := (x div scal) * scal;
end;

{ TEnity }

constructor TEntity.Create;
begin
  fx := 0;
  fy := 0;
  fcolor := clBlack;
end;

function TEntity.get_rect(const dx: integer = 0; dy: integer = 0): TRect;
begin
  result := Rect(x + dx, y + dy, x + width - dx, y + height - dy);
end;

{ TsnakeHead }

procedure TsnakeHead.add_new;
var
  nbody: TEntity;
begin
  nbody := TEntity.Create;
  nbody.width := width;
  nbody.height := height;
  nbody.x := x;
  nbody.y := y;
  if FlistOfBody.Count > 0 then
  begin
    nbody.x := TEntity(FlistOfBody.Items[FlistOfBody.Count - 1]).x;
    nbody.y := TEntity(FlistOfBody.Items[FlistOfBody.Count - 1]).y;
  end;
  FlistOfBody.Add(nbody);
end;

procedure TsnakeHead.clearAll;
var
  i: integer;
begin
  for i := 0 to FlistOfBody.Count - 1 do
    TObject(FlistOfBody.Items[i]).Free;
  FlistOfBody.Clear;
end;

constructor TsnakeHead.Create;
begin
  inherited;
  FlistOfBody := Tlist.Create;
  fbodycolor := clBlack;
end;

destructor TsnakeHead.Destroy;
begin
  clearAll();
  FlistOfBody.Free;
  inherited;
end;

function TsnakeHead.hit_snake(ax, ay: integer): boolean;
var
  i: integer;
begin
  result := false;
  for i := 0 to FlistOfBody.Count - 1 do
    if ((TEntity(FlistOfBody.Items[i]).x = ax) and
      (TEntity(FlistOfBody.Items[i]).y = ay)) then
    begin
      result := true;
      break;
    end;

end;

procedure TsnakeHead.moveStep(dx, dy: integer);
var
  i: integer;
  old_x, old_y: integer;
begin
  old_x := x;
  old_y := y;
  x := x + width * dx;
  y := y + height * dy;
  if FlistOfBody.Count > 0 then
  begin
    for i := FlistOfBody.Count - 1 downto 1 do
    begin
      TEntity(FlistOfBody.Items[i]).x := TEntity(FlistOfBody.Items[i - 1]).x;
      TEntity(FlistOfBody.Items[i]).y := TEntity(FlistOfBody.Items[i - 1]).y;
    end;
    TEntity(FlistOfBody.Items[0]).x := old_x;
    TEntity(FlistOfBody.Items[0]).y := old_y;

  end;
end;

function TsnakeHead.self_hit: boolean;
var
  i: integer;
begin
  result := false;

  for i := 1 to FlistOfBody.Count - 1 do
    if (TEntity(FlistOfBody.Items[i]).x = x) and
      (TEntity(FlistOfBody.Items[i]).y = y) then
    begin
      result := true;
      break;
    end;

end;

{ TGame }

procedure Tgame.change_ballPostion;
begin
  repeat
    fball.x := scalledby((random(width - fball.width)), SCALE_NUM);
    fball.y := scalledby((random(height - fball.height)), SCALE_NUM);
    // check if it hit's the snake
  until not fsnakeHead.hit_snake(fball.x, fball.y);

end;

constructor Tgame.Create;
begin
  randomize;
  fcanvas := nil;
  // ------init head
  fsnakeHead := TsnakeHead.Create;
  fsnakeHead.color := clBlue;
  fsnakeHead.bodyColor := $090A0B;
  fsnakeHead.width := 24;
  fsnakeHead.height := 24;
  // ----init ball
  fball := TEntity.Create;
  fball.color := $303888;
  fball.width := 24;
  fball.height := 24;
  // default values
  fwidth := 0;
  fheight := 0;
  fbackgroundColor := $80A593;
  fcan_display := false;
  fscore := 0;
end;

destructor Tgame.Destroy;
begin
  fsnakeHead.Free;
  fball.Free;
  inherited;
end;

procedure Tgame.draw;
const
  _color: array [0 .. 2] of TColor = (clYellow, clBlue, clFuchsia);
  procedure draw_middleText(acanvas: TCanvas; x, y: integer; text: string);
  begin
    with acanvas do
    begin
      TextOut(x - TextWidth(text) div 2, y - TextHeight(text) div 2, text);
    end;
  end;

var
  i: integer;
  r_w, r_h: integer;
begin
  if not can_display then
    exit;

  with fcanvas do
  begin
    Brush.Style := bsSolid;
    Brush.color := backgroundColor;
    pen.color := clBlack;
    pen.Style := TPenStyle.psSolid;
    FillRect(Rect(0, 0, width, height));
    r_w := scalledby(width, SCALE_NUM);
    r_h := scalledby(height, SCALE_NUM);

    pen.color := clWhite;
    pen.Style := TPenStyle.psDash;

    Rectangle(Rect(0, 0, r_w, r_h));
    pen.color := clBlack;
    pen.Style := TPenStyle.psSolid;
    fcanvas.Brush.color := fball.color; // _color[random(length(_color))];
    Ellipse(fball.get_rect);
    Brush.Style := bsSolid;
    Brush.color := fsnakeHead.color;
    pen.color := backgroundColor;
    Rectangle(fsnakeHead.get_rect);
    for i := 0 to fsnakeHead.FlistOfBody.Count - 1 do
    begin
      Brush.Style := bsSolid;
      Brush.color := fsnakeHead.bodyColor;
      pen.color := backgroundColor;
      Rectangle(TEntity(fsnakeHead.FlistOfBody.Items[i]).get_rect);
    end;
    // write the score
    Brush.color := backgroundColor;
    Brush.Style := bsClear;
    canvas.Font.Size := 12;

    TextOut(2, 2, format('socre:%d', [score]));
    if not fisRuning then
    begin
      canvas.Font.Size := 25;
      draw_middleText(canvas, width div 2, height div 2, 'GAME OVER');
    end;
  end;
end;

procedure Tgame.endGame;
begin
  // draw last one
  draw;
  fisRuning := false;
end;

function Tgame.fitness: real;
begin
  result := (fsnakeHead.FlistOfBody.Count * score + 1) / (fage + score);
end;

procedure Tgame.init_game;
begin
  flastkey := 0;
  fscore := 0;
  fage := 0;
  fstrave := 500;
  fsnakeHead.clearAll();
  fsnakeHead.x := scalledby((random(width - fsnakeHead.width)), SCALE_NUM);
  fsnakeHead.y := scalledby((random(height - fsnakeHead.height)), SCALE_NUM);
  change_ballPostion();
end;

procedure Tgame.KeyDown(Key: Word);
begin
  case Key of
    VK_LEFT:
      // move left
      fsnakeHead.moveStep(-1, 0);
    VK_RIGHT:
      // move right
      fsnakeHead.moveStep(1, 0);
    VK_UP:
      // move up
      fsnakeHead.moveStep(0, -1);
    VK_DOWN:
      // move down
      fsnakeHead.moveStep(0, 1);
  end;
  // update move check score
  update();
  flastkey := Key;
end;

function Tgame.scan_map: Tmatrix;
var
  i: integer;
  j: integer;
begin
  // map size(n,m)
  result.init(height div SCALE_NUM, width div SCALE_NUM, false);
  for i := 0 to result.row - 1 do
    for j := 0 to result.col - 1 do
    begin
      if ((fball.x = (j * SCALE_NUM)) and (fball.y = (i * SCALE_NUM))) then
      begin
        // food
        result[i, j] := 3;
      end
      else if ((fsnakeHead.x = (j * SCALE_NUM)) and
        (fsnakeHead.y = (i * SCALE_NUM))) then
      begin
        // head
        result[i, j] := 1;
      end
      else if fsnakeHead.hit_snake(j * SCALE_NUM, i * SCALE_NUM) then
      begin
        // snake body
        result[i, j] := 2;
      end

      else

        // nothing
        result[i, j] := 0;
    end;
end;

procedure Tgame.startGame;
begin
  init_game();
  fisRuning := true;

end;

procedure Tgame.update;
var
  i: integer;
begin
  // check if you hit the ball
  if (fsnakeHead.x = fball.x) and (fsnakeHead.y = fball.y) then
  begin
    fstrave := 500;
    fscore := fscore + 100;
    fsnakeHead.add_new();
    change_ballPostion();
  end;
  // check if you hit the wall left
  if (fsnakeHead.x < 0) then
  begin
    fsnakeHead.x := 0;
    endGame();
  end;
  // check if you hit the wall right
  if ((fsnakeHead.x + fsnakeHead.width) > width) then
  begin

    fsnakeHead.x := width - fsnakeHead.width;
    endGame();
  end;
  // check if you hit the wall top
  if (fsnakeHead.y < 0) then
  begin
    fsnakeHead.y := 0;
    endGame();
  end;
  // check if you hit the wall down
  if ((fsnakeHead.y + fsnakeHead.height) > height) then
  begin
    fsnakeHead.y := height - fsnakeHead.height;
    endGame();
  end;
  if fsnakeHead.self_hit then
  begin
    endGame();
  end;
  inc(fage); // +1
  dec(fstrave); // -1 ovoid ending loops
  if (fstrave < 0) then
  begin
    endGame();
  end;
end;

end.
