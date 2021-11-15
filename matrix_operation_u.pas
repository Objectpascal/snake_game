unit matrix_operation_u;

interface

uses system.Classes, system.SysUtils, winapi.Windows;

type
  _arrType = array of array of real;
  _callbackFun = reference to function(x: real): real;

  // ----------------Matrix
  PTmatrix = ^Tmatrix;

  Tmatrix = record
  private
    farr: _arrType;
    frow: integer;
    fcol: integer;
    procedure set_data(i, j: integer; const Value: real);
    function get_data(i, j: integer): real;
  public
    procedure init(Arow, Acol: integer; randomValues: boolean = false);
    procedure copy(b: Tmatrix);
    procedure performFun(callback: _callbackFun);
    procedure clearAll();

    // ----------operator -----------------------//
    class operator multiply(a, b: Tmatrix): Tmatrix; overload;
    class operator multiply(a: real; b: Tmatrix): Tmatrix; overload;
    class operator multiply(a: Tmatrix; b: real): Tmatrix; overload;
    class operator add(a, b: Tmatrix): Tmatrix;
    class operator subtract(a, b: Tmatrix): Tmatrix;
    function ToString: string;
    // -----------------------------------------------
    property row: integer read frow;
    property col: integer read fcol;
    property data[i, j: integer]: real read get_data write set_data; default;
  end;

  TlistofMatrix = class(Tlist)
  private
    function get_matrixAt(index: integer): PTmatrix;

  public
    procedure Clear; override;

    property item[index: integer]: PTmatrix read get_matrixAt;

  end;

  // -----------------------------------
implementation

{ Tmatrix }

procedure Tmatrix.clearAll;
begin
  farr := nil;
  frow := 0;
  fcol := 0;
end;

procedure Tmatrix.set_data(i, j: integer; const Value: real);
begin
  farr[i, j] := Value;
end;

function Tmatrix.get_data(i, j: integer): real;
begin
  result := farr[i, j];
end;

procedure Tmatrix.init(Arow, Acol: integer; randomValues: boolean);
var
  i: integer;
  j: integer;
begin
  Randomize;
  clearAll;
  frow := Arow;
  fcol := Acol;
  // create rows
  setlength(farr, frow);
  for i := 0 to frow - 1 do
  begin
    // create columns
    setlength(farr[i], fcol);
    if randomValues then
    begin
      // random values
      for j := 0 to fcol - 1 do
        farr[i, j] := random(80) * 0.01;
    end
    else
    begin
      // zero memory
      ZeroMemory(@farr[i][0], sizeof(real) * fcol);
    end;

  end;

end;

procedure Tmatrix.copy(b: Tmatrix);
var
  i: integer;
  j: integer;
begin
  if (row <> b.row) or (col <> b.col) then
    raise Exception.create
      (format('[Tmatrix.subtract]: self(%d,%d) can not subtract b(%d,%d)',
      [row, col, b.row, b.col]));
  for i := 0 to frow - 1 do
    for j := 0 to fcol - 1 do
      farr[i, j] := b[i, j];
end;

class operator Tmatrix.multiply(a, b: Tmatrix): Tmatrix;
var
  i, j, k: integer;
begin
  // can not perform multiply wen a.col <> b.row
  if (a.col <> b.row) then
    raise Exception.create
      (format('[Tmatrix.multiply] :  (a.col(%d) <> b.row(%d)) ',
      [a.col, b.row]));
  // result matrix c.row=a.row, c.col=b.col
  result.init(a.row, b.col, false);
  for i := 0 to result.row - 1 do
    for j := 0 to result.col - 1 do
      for k := 0 to b.col - 1 do
      begin
        result[i, j] := result[i, j] + a[i, k] * b[k, i];
      end;

end;

class operator Tmatrix.multiply(a: Tmatrix; b: real): Tmatrix;
var
  i, j: integer;
begin
  result.init(a.row, a.col, false);
  for i := 0 to result.row - 1 do
    for j := 0 to result.col - 1 do
      result[i, j] := a[i, j] * b;
end;

class operator Tmatrix.multiply(a: real; b: Tmatrix): Tmatrix;
begin
  result := b * a;
end;

class operator Tmatrix.subtract(a, b: Tmatrix): Tmatrix;
var
  i, j: integer;
begin
  if (a.row <> a.row) or (a.col <> b.col) then
    raise Exception.create
      (format('[Tmatrix.subtract]: a(%d,%d) can not subtract b(%d,%d)',
      [a.row, a.col, b.row, b.col]));
  result.init(a.row, a.col, false);
  for i := 0 to result.row - 1 do
    for j := 0 to result.col - 1 do
      result[i, j] := a[i, j] - b[i, j];
end;

function Tmatrix.ToString: string;
var
  i, j: integer;
begin
  result := ' [ ' + sLineBreak;
  for i := 0 to frow - 1 do
  begin
    result := result + ' [ ';
    for j := 0 to fcol - 1 do
    begin
      result := result + FloatToStr(farr[i, j]) + ',';

    end;
    result := result + ' ], ' + sLineBreak;

  end;
  result := result + ' ] ' + sLineBreak;
end;

class operator Tmatrix.add(a, b: Tmatrix): Tmatrix;
var
  i, j: integer;
begin
  if (a.row <> a.row) or (a.col <> b.col) then
    raise Exception.create
      (format('[Tmatrix.add]: a(%d,%d) can not add b(%d,%d)',
      [a.row, a.col, b.row, b.col]));
  result.init(a.row, a.col, false);
  for i := 0 to result.row - 1 do
    for j := 0 to result.col - 1 do
      result[i, j] := a[i, j] + b[i, j];
end;

procedure Tmatrix.performFun(callback: _callbackFun);
var
  i: integer;
  j: integer;
begin
  // perform call back function to all elemnt in array
  for i := 0 to frow - 1 do
    for j := 0 to fcol - 1 do
      farr[i, j] := callback(farr[i, j]);
end;

{ TlistofMatrix }

procedure TlistofMatrix.Clear;
var
  i: integer;
begin
  for i := 0 to Count - 1 do
  begin
    (PTmatrix(get(i))^).clearAll();
    // free matrix
    Dispose(Items[i]);
  end;
  inherited;

end;

function TlistofMatrix.get_matrixAt(index: integer): PTmatrix;
begin
  result := PTmatrix(get(index));
end;

end.
