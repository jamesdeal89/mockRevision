//Skeleton Program code for the AQA A Level Paper 1 Summer 2021 examination
//this code should be used in conjunction with the Preliminary Material
//written by the AQA Programmer Team
//developed in the Lazarus programming environments

program HexBaron;

{$APPTYPE CONSOLE} 
{$MODE DELPHI}   // You can remove this line if not needed in programming environment being used

uses
  Classes, SysUtils, Math;

const
  LineEnding = chr(13) + char(10);

type
  Piece = class
  protected
    Destroyed: boolean;
    BelongsToPlayer1: boolean;
    FuelCostOfMove: integer;
    VPValue: integer;
    ConnectionsToDestroy: integer;
    PieceType: string;
  public
    constructor Init(Player1: boolean);
    function GetVPs(): integer; virtual;
    function GetBelongsToPlayer1(): boolean; virtual;
    function CheckMoveIsValid(DistanceBetweenTiles: integer;
      StartTerrain: string; EndTerrain: string): integer; virtual;
    function HasMethod(NameOfMethod: string): boolean; virtual;
    function GetConnectionsNeededToDestroy(): integer; virtual;
    function GetPieceType(): string; virtual;
    procedure DestroyPiece(); virtual;
  end;

type
  BaronPiece = class(Piece)
  public
    constructor Init(Player1: boolean);
    function CheckMoveIsValid(DistanceBetweenTiles: integer;
      StartTerrain: string; EndTerrain: string): integer; override;
  end;

type
  LESSPiece = class(Piece)
  public
    constructor Init(Player1: boolean);
    function CheckMoveIsValid(DistanceBetweenTiles: integer;
      StartTerrain: string; EndTerrain: string): integer; override;
    function Saw(Terrain: string): integer;
    function HasMethod(NameOfMethod: string): boolean; override;
  end;

type
  PBDSPiece = class(Piece)
  public
    constructor Init(Player1: boolean);
    function CheckMoveIsValid(DistanceBetweenTiles: integer;
      StartTerrain: string; EndTerrain: string): integer; override;
    function Dig(Terrain: string): integer;
    function HasMethod(NameOfMethod: string): boolean; override;
  end;

type
  Tile = class;

  TTileArray = TArray<Tile>;

  Tile = class
  protected
    Terrain: string;
    x: integer;
    y: integer;
    z: integer;
    PieceInTile: Piece;
    Neighbours: TTileArray;
  public
    constructor Init(xcoord: integer; ycoord: integer; zcoord: integer);
    function GetDistanceToTileT(T: Tile): integer;
    procedure AddToNeighbours(N: Tile);
    function GetNeighbours(): TTileArray;
    procedure SetPiece(const ThePiece: Piece);
    procedure SetTerrain(T: string);
    function Getx(): integer;
    function Gety(): integer;
    function Getz(): integer;
    function GetTerrain(): string;
    function GetPieceInTile(): Piece;
  end;

type
  TPieceArray = TArray<Piece>;

type
  TStringArray = TArray<string>;

type
  HexGrid = class
  protected
    Tiles: TTileArray;
    Pieces: TPieceArray;
    Size: integer;
    Player1Turn: boolean;
  public
    constructor Init(N: integer);
    procedure SetUpGridTerrain(ListOfTerrain: TStringArray);
    procedure AddPiece(BelongsToPlayer1: boolean; TypeOfPiece: string;
      Location: integer);
    function ExecuteCommand(Items: TStringArray; var FuelChange: integer;
      var LumberChange: integer; var SupplyChange: integer;
      FuelAvailable: integer; LumberAvailable: integer;
      PiecesInSupply: integer): string;
    function DestroyPiecesAndCountVPs(var Player1VPs: integer;
      var Player2VPs: integer): boolean;
    function GetGridAsString(P1Turn: boolean): string;
    function GetPieceTypeInTile(ID: integer): string;
  private
    function CheckTileIndexIsValid(TileToCheck: integer): boolean;
    function CheckPieceAndTileAreValid(TileToUse: integer): boolean;
    function ExecuteCommandInTile(Items: TStringArray; var Fuel: integer;
      var Lumber: integer): boolean;
    function ExecuteMoveCommand(Items: TStringArray;
      FuelAvailable: integer): integer;
    function ExecuteSpawnCommand(Items: TStringArray; LumberAvailable: integer;
      PiecesInSupply: integer): integer;
    function ExecuteUpgradeCommand(Items: TStringArray;
      LumberAvailable: integer): integer;
    procedure SetUpTiles();
    procedure MovePiece(NewIndex: integer; OldIndex: integer);
    procedure SetUpNeighbours();
    function CreateBottomLine(): string;
    function CreateTopLine(): string;
    function CreateOddLine(var ListPositionOfTile: integer): string;
    function CreateEvenLine(FirstEvenLine: boolean;
      var ListPositionOfTile: integer): string;
  end;

type
  Player = class
  protected
    PiecesInSupply: integer;
    Fuel: integer;
    VPs: integer;
    Lumber: integer;
    Name: string;
  public
    constructor Init(N: string; V: integer; F: integer; L: integer; T: integer);
    function GetStateString(): string; virtual;
    function GetVPs(): integer; virtual;
    function GetFuel(): integer; virtual;
    function GetLumber(): integer; virtual;
    function GetName(): string; virtual;
    procedure AddToVPs(N: integer); virtual;
    procedure UpdateFuel(N: integer); virtual;
    procedure UpdateLumber(N: integer); virtual;
    function GetPiecesInSupply(): integer; virtual;
    procedure RemoveTileFromSupply(); virtual;
  end;

constructor Piece.Init(Player1: boolean);
begin
  FuelCostOfMove := 1;
  BelongsToPlayer1 := Player1;
  Destroyed := false;
  PieceType := 'S';
  VPValue := 1;
  ConnectionsToDestroy := 2;
end;

function Piece.GetVPs(): integer;
begin
  GetVPs := VPValue;
end;

function Piece.GetBelongsToPlayer1(): boolean;
begin
  GetBelongsToPlayer1 := BelongsToPlayer1;
end;

function Piece.CheckMoveIsValid(DistanceBetweenTiles: integer;
  StartTerrain: string; EndTerrain: string): integer;
begin
  if DistanceBetweenTiles = 1 then
    if (StartTerrain = '~') or (EndTerrain = '~') then
    begin
      CheckMoveIsValid := FuelCostOfMove * 2;
      exit;
    end
    else
    begin
      CheckMoveIsValid := FuelCostOfMove;
      exit;
    end;
  CheckMoveIsValid := -1;
end;

function Piece.HasMethod(NameOfMethod: string): boolean;
begin
  HasMethod := false;
end;

function Piece.GetConnectionsNeededToDestroy(): integer;
begin
  GetConnectionsNeededToDestroy := ConnectionsToDestroy;
end;

function Piece.GetPieceType(): string;
begin
  if BelongsToPlayer1 then
    GetPieceType := PieceType
  else
    GetPieceType := lowercase(PieceType);
end;

procedure Piece.DestroyPiece();
begin
  Destroyed := true;
end;

constructor BaronPiece.Init(Player1: boolean);
begin
  inherited;
  PieceType := 'B';
  VPValue := 10;
end;

function BaronPiece.CheckMoveIsValid(DistanceBetweenTiles: integer;
  StartTerrain: string; EndTerrain: string): integer;
begin
  if DistanceBetweenTiles = 1 then
  begin
    CheckMoveIsValid := FuelCostOfMove;
    exit;
  end;
  CheckMoveIsValid := -1;
end;

constructor LESSPiece.Init(Player1: boolean);
begin
  inherited;
  PieceType := 'L';
  VPValue := 3;
end;

function LESSPiece.CheckMoveIsValid(DistanceBetweenTiles: integer;
  StartTerrain: string; EndTerrain: string): integer;
begin
  if (DistanceBetweenTiles = 1) and (StartTerrain <> '#') then
    if (StartTerrain = '~') or (EndTerrain = '~') then
    begin
      CheckMoveIsValid := FuelCostOfMove * 2;
      exit;
    end
    else
    begin
      CheckMoveIsValid := FuelCostOfMove;
      exit;
    end;
  CheckMoveIsValid := -1;
end;

function LESSPiece.Saw(Terrain: string): integer;
begin
  if Terrain <> '#' then
    Saw := 0
  else
    Saw := 1;
end;

function LESSPiece.HasMethod(NameOfMethod: string): boolean;
begin
  if NameOfMethod = 'Saw' then
    HasMethod := true
  else
    HasMethod := false;
end;

constructor PBDSPiece.Init(Player1: boolean);
begin
  inherited;
  PieceType := 'P';
  VPValue := 2;
  FuelCostOfMove := 2;
end;

function PBDSPiece.CheckMoveIsValid(DistanceBetweenTiles: integer;
  StartTerrain: string; EndTerrain: string): integer;
begin
  if (DistanceBetweenTiles <> 1) or (StartTerrain = '~') then
    CheckMoveIsValid := -1
  else
    CheckMoveIsValid := FuelCostOfMove;
end;

function PBDSPiece.Dig(Terrain: string): integer;
begin
  if Terrain <> '~' then
  begin
    Dig := 0;
    exit;
  end;
  if random() < 0.9 then
  begin
    Dig := 1;
    exit;
  end
  else
    Dig := 5;
end;

function PBDSPiece.HasMethod(NameOfMethod: string): boolean;
begin
  if NameOfMethod = 'Dig' then
    HasMethod := true
  else
    HasMethod := false
end;

constructor Tile.Init(xcoord: integer; ycoord: integer; zcoord: integer);
begin
  x := xcoord;
  y := ycoord;
  z := zcoord;
  Terrain := ' ';
  PieceInTile := nil;
end;

function Tile.GetDistanceToTileT(T: Tile): integer;
begin
  GetDistanceToTileT := Max(Max(Abs(Self.Getx() - T.Getx()),
    Abs(Self.Gety - T.Gety())), Abs(Self.Getz() - T.Getz()));
end;

procedure Tile.AddToNeighbours(N: Tile);
begin
  setlength(Neighbours, length(Neighbours) + 1);
  Neighbours[high(Neighbours)] := N;
end;

function Tile.GetNeighbours(): TTileArray;
begin
  GetNeighbours := Neighbours;
end;

procedure Tile.SetPiece(const ThePiece: Piece);
begin
  PieceInTile := ThePiece;
end;

procedure Tile.SetTerrain(T: string);
begin
  Terrain := T;
end;

function Tile.Getx(): integer;
begin
  Getx := x;
end;

function Tile.Gety(): integer;
begin
  Gety := y;
end;

function Tile.Getz(): integer;
begin
  Getz := z;
end;

function Tile.GetTerrain(): string;
begin
  GetTerrain := Terrain;
end;

function Tile.GetPieceInTile(): Piece;
begin
  GetPieceInTile := PieceInTile;
end;

constructor HexGrid.Init(N: integer);
begin
  Size := N;
  SetUpTiles();
  SetUpNeighbours();
  Player1Turn := true;
end;

procedure HexGrid.SetUpGridTerrain(ListOfTerrain: TStringArray);
var
  Count: integer;
begin
  for Count := 0 to (length(ListOfTerrain) - 1) do
    Tiles[Count].SetTerrain(ListOfTerrain[Count]);
end;

procedure HexGrid.AddPiece(BelongsToPlayer1: boolean; TypeOfPiece: string;
  Location: integer);
var
  NewPiece: Piece;
begin
  if TypeOfPiece = 'Baron' then
  begin
    NewPiece := BaronPiece.Init(BelongsToPlayer1);
  end
  else if TypeOfPiece = 'LESS' then
    NewPiece := LESSPiece.Init(BelongsToPlayer1)
  else if TypeOfPiece = 'PBDS' then
    NewPiece := PBDSPiece.Init(BelongsToPlayer1)
  else
    NewPiece := Piece.Init(BelongsToPlayer1);
  setlength(Pieces, (length(Pieces) + 1));
  Pieces[high(Pieces)] := NewPiece;
  Tiles[Location].SetPiece(NewPiece);
end;

function HexGrid.ExecuteCommand(Items: TStringArray; var FuelChange: integer;
  var LumberChange: integer; var SupplyChange: integer; FuelAvailable: integer;
  LumberAvailable: integer; PiecesInSupply: integer): string;
var
  FuelCost: integer;
  LumberCost: integer;
begin
  if Items[0] = 'move' then
  begin
    FuelCost := ExecuteMoveCommand(Items, FuelAvailable);
    if FuelCost < 0 then
    begin
      ExecuteCommand := 'That move can''t be done';
      exit;
    end;
    FuelChange := -FuelCost;
  end
  else if (Items[0] = 'saw') or (Items[0] = 'dig') then
  begin
    if not(ExecuteCommandInTile(Items, FuelChange, LumberChange)) then
    begin
      ExecuteCommand := 'Couldn''t do that';
      exit;
    end;
  end
  else if Items[0] = 'spawn' then
  begin
    LumberCost := ExecuteSpawnCommand(Items, LumberAvailable, PiecesInSupply);
    if LumberCost < 0 then
    begin
      ExecuteCommand := 'Spawning did not occur';
      exit;
    end;
    LumberChange := -LumberCost;
    SupplyChange := 1;
  end
  else if Items[0] = 'upgrade' then
  begin
    LumberCost := ExecuteUpgradeCommand(Items, LumberAvailable);
    if LumberCost < 0 then
    begin
      ExecuteCommand := 'Upgrade not possible';
      exit;
    end;
    LumberChange := -LumberCost;
  end;
  ExecuteCommand := 'Command executed';
end;

function HexGrid.DestroyPiecesAndCountVPs(var Player1VPs: integer;
  var Player2VPs: integer): boolean;
var
  BaronDestroyed: boolean;
  ListOfTilesContainingDestroyedPieces: TTileArray;
  ListOfNeighbours: TTileArray;
  NoOfConnections: integer;
  ThePiece: Piece;
  N: integer;
  T: integer;
begin
  BaronDestroyed := false;
  setlength(ListOfTilesContainingDestroyedPieces, 0);
  for T := low(Tiles) to high(Tiles) do
  begin
    if not(Tiles[T].GetPieceInTile() = nil) then
    begin
      ListOfNeighbours := Tiles[T].GetNeighbours();
      NoOfConnections := 0;
      for N := low(ListOfNeighbours) to high(ListOfNeighbours) do
        if not(ListOfNeighbours[N].GetPieceInTile() = nil) then
          inc(NoOfConnections);
      ThePiece := Tiles[T].GetPieceInTile();
      if (NoOfConnections >= ThePiece.GetConnectionsNeededToDestroy()) then
      begin
        ThePiece.DestroyPiece();
        if uppercase(ThePiece.GetPieceType()) = 'B' then
          BaronDestroyed := true;
        setlength(ListOfTilesContainingDestroyedPieces,
          length(ListOfTilesContainingDestroyedPieces) + 1);
        ListOfTilesContainingDestroyedPieces
          [high(ListOfTilesContainingDestroyedPieces)] := Tiles[T];
        if ThePiece.GetBelongsToPlayer1() then
          Player2VPs := Player2VPs + ThePiece.GetVPs()
        else
          Player1VPs := Player1VPs + ThePiece.GetVPs();
      end;
    end;
  end;
  for T := low(ListOfTilesContainingDestroyedPieces)
    to high(ListOfTilesContainingDestroyedPieces) do
    ListOfTilesContainingDestroyedPieces[T].SetPiece(nil);
  DestroyPiecesAndCountVPs := BaronDestroyed;
end;

function HexGrid.GetGridAsString(P1Turn: boolean): string;
var
  ListPositionOfTile: integer;
  GridAsString: string;
  Count: integer;
begin
  ListPositionOfTile := 0;
  Player1Turn := P1Turn;
  GridAsString := CreateTopLine() + CreateEvenLine(true, ListPositionOfTile);
  inc(ListPositionOfTile);
  GridAsString := GridAsString + CreateOddLine(ListPositionOfTile);
  for Count := 1 to Size - 2 do
  begin
    if (Count mod 2 = 1) then
    begin
      inc(ListPositionOfTile);
      GridAsString := GridAsString + CreateEvenLine(false, ListPositionOfTile);
      inc(ListPositionOfTile);
      GridAsString := GridAsString + CreateOddLine(ListPositionOfTile);
    end;
  end;
  GetGridAsString := GridAsString + CreateBottomLine();
end;

function HexGrid.GetPieceTypeInTile(ID: integer): string;
var
  ThePiece: Piece;
begin
  ThePiece := Tiles[ID].GetPieceInTile();
  if (ThePiece = nil) then
    GetPieceTypeInTile := ' '
  else
    GetPieceTypeInTile := ThePiece.GetPieceType();
end;

function HexGrid.CheckTileIndexIsValid(TileToCheck: integer): boolean;
begin
  CheckTileIndexIsValid := (TileToCheck >= 0) and (TileToCheck < length(Tiles));
end;

function HexGrid.CheckPieceAndTileAreValid(TileToUse: integer): boolean;
var
  ThePiece: Piece;
  Valid: boolean;
begin
  Valid := false;
  if CheckTileIndexIsValid(TileToUse) then
  begin
    ThePiece := Tiles[TileToUse].GetPieceInTile();
    if not(ThePiece = nil) then
      if ThePiece.GetBelongsToPlayer1() = Player1Turn then
        Valid := true;
  end;
  CheckPieceAndTileAreValid := Valid;
end;

function HexGrid.ExecuteCommandInTile(Items: TStringArray; var Fuel: integer;
  var Lumber: integer): boolean;
var
  TileToUse: integer;
  MethodToCall: string;
begin
  TileToUse := strtoint(Items[1]);
  if CheckPieceAndTileAreValid(TileToUse) = false then
  begin
    ExecuteCommandInTile := false;
    exit;
  end;
  Items[0] := uppercase(Items[0][1]) + copy(Items[0], 2, length(Items[0]) - 1);
  MethodToCall := Items[0];
  if Tiles[TileToUse].GetPieceInTile.HasMethod(MethodToCall) then
  begin
    if Items[0] = 'Saw' then
      inc(Lumber, LESSPiece(Tiles[TileToUse].GetPieceInTile).Saw(Tiles[TileToUse].GetTerrain))
    else if Items[0] = 'Dig' then
    begin
      inc(Fuel, PBDSPiece(Tiles[TileToUse].GetPieceInTile).Dig(Tiles[TileToUse].GetTerrain));
      if Abs(Fuel) > 2 then
        Tiles[TileToUse].SetTerrain(' ');
    end;
    ExecuteCommandInTile := true;
  end
  else
    ExecuteCommandInTile := false;
end;

function HexGrid.ExecuteMoveCommand(Items: TStringArray;
  FuelAvailable: integer): integer;
var
  StartID: integer;
  EndID: integer;
  ThePiece: Piece;
  Distance: integer;
  FuelCost: integer;
begin
  StartID := strtoint(Items[1]);
  EndID := strtoint(Items[2]);
  if (not(CheckPieceAndTileAreValid(StartID))) or
    (not(CheckTileIndexIsValid(EndID))) then
  begin
    ExecuteMoveCommand := -1;
    exit;
  end;
  if not(Tiles[EndID].GetPieceInTile() = nil) then
  begin
    ExecuteMoveCommand := -1;
    exit;
  end;
  ThePiece := Tiles[StartID].GetPieceInTile;
  Distance := Tiles[StartID].GetDistanceToTileT(Tiles[EndID]);
  FuelCost := ThePiece.CheckMoveIsValid(Distance, Tiles[StartID].GetTerrain(),
    Tiles[EndID].GetTerrain());
  if (FuelCost = -1) or (FuelAvailable < FuelCost) then
  begin
    ExecuteMoveCommand := -1;
    exit;
  end;
  MovePiece(EndID, StartID);
  ExecuteMoveCommand := FuelCost;
end;

function HexGrid.ExecuteSpawnCommand(Items: TStringArray;
  LumberAvailable: integer; PiecesInSupply: integer): integer;
var
  TileToUse: integer;
  ThePiece: Piece;
  OwnBaronIsNeighbour: boolean;
  ListOfNeighbours: TTileArray;
  NewPiece: Piece;
  N: integer;
begin
  TileToUse := strtoint(Items[1]);
  if (PiecesInSupply < 1) or (LumberAvailable < 3) or
    not(CheckTileIndexIsValid(TileToUse)) then
  begin
    ExecuteSpawnCommand := -1;
    exit;
  end;
  ThePiece := Tiles[TileToUse].GetPieceInTile();
  if not(ThePiece = nil) then
  begin
    ExecuteSpawnCommand := -1;
    exit;
  end;
  OwnBaronIsNeighbour := false;
  ListOfNeighbours := Tiles[TileToUse].GetNeighbours();
  for N := low(ListOfNeighbours) to high(ListOfNeighbours) do
  begin
    ThePiece := ListOfNeighbours[N].GetPieceInTile();
    if not(ThePiece = nil) then
      if ((Player1Turn) and (ThePiece.GetPieceType() = 'B')) or
        (not(Player1Turn) and (ThePiece.GetPieceType() = 'b')) then
      begin
        OwnBaronIsNeighbour := true;
        break;
      end;
  end;
  if not(OwnBaronIsNeighbour) then
  begin
    ExecuteSpawnCommand := -1;
    exit;
  end;
  NewPiece := Piece.Init(Player1Turn);
  setlength(Pieces, (length(Pieces) + 1));
  Pieces[high(Pieces)] := NewPiece;
  Tiles[TileToUse].SetPiece(NewPiece);
  ExecuteSpawnCommand := 3;
end;

function HexGrid.ExecuteUpgradeCommand(Items: TStringArray;
  LumberAvailable: integer): integer;
var
  ThePiece: Piece;
  TileToUse: integer;
begin
  TileToUse := strtoint(Items[2]);
  if (not(CheckPieceAndTileAreValid(TileToUse))) or (LumberAvailable < 5) or
    (not((Items[1] = 'pbds') or (Items[1] = 'less'))) then
  begin
    ExecuteUpgradeCommand := -1;
    exit;
  end
  else
  begin
    ThePiece := Tiles[TileToUse].GetPieceInTile();
    if uppercase(ThePiece.GetPieceType()) <> 'S' then
    begin
      ExecuteUpgradeCommand := -1;
      exit;
    end;
    ThePiece.DestroyPiece();
    if Items[1] = 'pbds' then
      ThePiece := PBDSPiece.Init(Player1Turn)
    else
      ThePiece := LESSPiece.Init(Player1Turn);
    setlength(Pieces, (length(Pieces) + 1));
    Pieces[high(Pieces)] := ThePiece;
    Tiles[TileToUse].SetPiece(ThePiece);
    ExecuteUpgradeCommand := 5;
  end;
end;

procedure HexGrid.SetUpTiles();
var
  EvenStartY: integer;
  EvenStartZ: integer;
  OddStartZ: integer;
  OddStartY: integer;
  x: integer;
  y: integer;
  z: integer;
  Count: integer;
  TempTile: Tile;
begin
  EvenStartY := 0;
  EvenStartZ := 0;
  OddStartZ := 0;
  OddStartY := -1;
  for Count := 1 to Size div 2 do
  begin
    y := EvenStartY;
    z := EvenStartZ;
    for x := 0 to Size - 2 do
    begin
      if (x mod 2 = 0) then
      begin
        TempTile := Tile.Init(x, y, z);
        setlength(Tiles, (length(Tiles) + 1));
        Tiles[high(Tiles)] := TempTile;
        dec(y);
        dec(z);
      end;
    end;
    inc(EvenStartZ);
    dec(EvenStartY);
    y := OddStartY;
    z := OddStartZ;
    for x := 1 to Size - 1 do
    begin
      if (x mod 2 = 1) then
      begin
        TempTile := Tile.Init(x, y, z);
        setlength(Tiles, (length(Tiles) + 1));
        Tiles[high(Tiles)] := TempTile;
        dec(y);
        dec(z);
      end;
    end;
    inc(OddStartZ);
    dec(OddStartY);
  end;
end;

procedure HexGrid.MovePiece(NewIndex: integer; OldIndex: integer);
begin
  Tiles[NewIndex].SetPiece(Tiles[OldIndex].GetPieceInTile());
  Tiles[OldIndex].SetPiece(nil);
end;

procedure HexGrid.SetUpNeighbours();
var
  FromTile: integer;
  ToTile: integer;
begin
  for FromTile := low(Tiles) to high(Tiles) do
    for ToTile := low(Tiles) to high(Tiles) do
      if Tiles[FromTile].GetDistanceToTileT(Tiles[ToTile]) = 1 then
        Tiles[FromTile].AddToNeighbours(Tiles[ToTile])
end;

function HexGrid.CreateBottomLine(): string;
var
  Line: string;
  Count: integer;
begin
  Line := '   ';
  for Count := 1 to Size div 2 do
    Line := Line + ' \__/ ';
  CreateBottomLine := Line + LineEnding;
end;

function HexGrid.CreateTopLine: string;
var
  Line: string;
  Count: integer;
begin
  Line := LineEnding + '  ';
  for Count := 1 to Size div 2 do
    Line := Line + '__    ';
  CreateTopLine := Line + LineEnding;
end;

function HexGrid.CreateOddLine(var ListPositionOfTile: integer): string;
var
  Line: string;
  Count: integer;
begin
  Line := '';
  for Count := 1 to Size div 2 do
  begin
    if (Count > 1) and (Count < Size / 2) then
    begin
      Line := Line + GetPieceTypeInTile(ListPositionOfTile) + '\__/';
      inc(ListPositionOfTile);
      Line := Line + Tiles[ListPositionOfTile].GetTerrain();
    end
    else if Count = 1 then
      Line := Line + ' \__/' + Tiles[ListPositionOfTile].GetTerrain();
  end;
  Line := Line + GetPieceTypeInTile(ListPositionOfTile) + '\__/';
  inc(ListPositionOfTile);
  if ListPositionOfTile < length(Tiles) then
  begin
    Line := Line + Tiles[ListPositionOfTile].GetTerrain() +
      GetPieceTypeInTile(ListPositionOfTile) + '\' + LineEnding
  end
  else
    Line := Line + '\' + LineEnding;
  CreateOddLine := Line;
end;

function HexGrid.CreateEvenLine(FirstEvenLine: boolean;
  var ListPositionOfTile: integer): string;
var
  Line: string;
  Count: integer;
begin
  Line := ' /' + Tiles[ListPositionOfTile].GetTerrain();
  for Count := 1 to (Size div 2) - 1 do
  begin
    Line := Line + GetPieceTypeInTile(ListPositionOfTile);
    inc(ListPositionOfTile);
    Line := Line + '\__/' + Tiles[ListPositionOfTile].GetTerrain();
  end;
  if FirstEvenLine then
    Line := Line + GetPieceTypeInTile(ListPositionOfTile) + '\__' + LineEnding
  else
    Line := Line + GetPieceTypeInTile(ListPositionOfTile) + '\__/' + LineEnding;
  CreateEvenLine := Line;
end;

constructor Player.Init(N: string; V: integer; F: integer; L: integer;
  T: integer);
begin
  Name := N;
  VPs := V;
  Fuel := F;
  Lumber := L;
  PiecesInSupply := T;
end;

function Player.GetStateString(): string;
begin
  GetStateString := 'VPs: ' + inttostr(VPs) + '   Pieces in supply: ' +
    inttostr(PiecesInSupply) + '   Lumber: ' + inttostr(Lumber) + '   Fuel: ' +
    inttostr(Fuel);
end;

function Player.GetVPs(): integer;
begin
  GetVPs := VPs;
end;

function Player.GetFuel(): integer;
begin
  GetFuel := Fuel;
end;

function Player.GetLumber(): integer;
begin
  GetLumber := Lumber;
end;

function Player.GetName(): string;
begin
  GetName := Name;
end;

procedure Player.AddToVPs(N: integer);
begin
  VPs := VPs + N;
end;

procedure Player.UpdateFuel(N: integer);
begin
  Fuel := Fuel + N;
end;

procedure Player.UpdateLumber(N: integer);
begin
  Lumber := Lumber + N;
end;

function Player.GetPiecesInSupply(): integer;
begin
  GetPiecesInSupply := PiecesInSupply;
end;

procedure Player.RemoveTileFromSupply();
begin
  dec(PiecesInSupply);
end;

function CheckMoveCommandFormat(Items: TStringArray): boolean;
var
  Ignored: integer;
  Count: integer;
begin
  if length(Items) = 3 then
  begin
    for Count := 1 to 2 do
    begin
      try
        Ignored := strtoint(Items[Count]);
      except
        CheckMoveCommandFormat := false;
        exit;
      end;
    end;
    CheckMoveCommandFormat := true;
    exit;
  end;
  CheckMoveCommandFormat := false;
end;

function CheckStandardCommandFormat(Items: TStringArray): boolean;
var
  Ignored: integer;
begin
  if length(Items) = 2 then
  begin
    try
      Ignored := strtoint(Items[1]);
    except
      CheckStandardCommandFormat := false;
      exit;
    end;
    CheckStandardCommandFormat := true;
    exit;
  end;
  CheckStandardCommandFormat := false;
end;

function CheckUpgradeCommandFormat(Items: TStringArray): boolean;
var
  Ignored: integer;
begin
  if length(Items) = 3 then
  begin
    if (uppercase(Items[1]) <> 'LESS') and (uppercase(Items[1]) <> 'PBDS') then
    begin
      CheckUpgradeCommandFormat := false;
      exit;
    end;
    try
      Ignored := strtoint(Items[2]);
    except
      CheckUpgradeCommandFormat := false;
      exit;
    end;
    CheckUpgradeCommandFormat := true;
    exit;
  end;
  CheckUpgradeCommandFormat := false;
end;

function CheckCommandIsValid(Items: TStringArray) : boolean;
begin
  if length(Items) > 0 then
  begin
    if Items[0] = 'move' then
    begin
      CheckCommandIsValid := CheckMoveCommandFormat(Items);
      exit;
    end
    else if (Items[0] = 'dig') or (Items[0] = 'saw') or (Items[0] = 'spawn')
    then
    begin
      CheckCommandIsValid := CheckStandardCommandFormat(Items);
      exit;
    end
    else if Items[0] = 'upgrade' then
    begin
      CheckCommandIsValid := CheckUpgradeCommandFormat(Items);
      exit;
    end;
  end;
  CheckCommandIsValid := false;
end;

procedure DisplayEndMessages(Player1: Player; Player2: Player);
begin
  writeln;
  writeln(Player1.GetName() + ' final state: ' + Player1.GetStateString());
  writeln;
  writeln(Player2.GetName() + ' final state: ' + Player2.GetStateString());
  writeln;
  if Player1.GetVPs() > Player2.GetVPs() then
    writeln(Player1.GetName() + ' is the winner!')
  else
    writeln(Player2.GetName() + ' is the winner!');
end;

procedure DisplayMainMenu();
begin
  writeln('1. Default game');
  writeln('2. Load game');
  writeln('Q. Quit');
  writeln;
  write('Enter your choice: ');
end;

procedure SetUpDefaultGame(var Player1: Player; var Player2: Player;
  var Grid: HexGrid);
var
  GridSize: integer;
  T: string;
begin
  GridSize := 8;
  Grid := HexGrid.Init(GridSize);
  Player1 := Player.Init('Player One', 0, 10, 10, 5);
  Player2 := Player.Init('Player Two', 1, 10, 10, 5);
  T := ' ,#,#, ,~,~, , , ,~, ,#,#, , , , , ,#,#,#,#,~,~,~,~,~, ,#, ,#, ';
  Grid.SetUpGridTerrain(T.Split([',']));
  Grid.AddPiece(true, 'Baron', 0);
  Grid.AddPiece(true, 'Serf', 8);
  Grid.AddPiece(false, 'Baron', 31);
  Grid.AddPiece(false, 'Serf', 23);
end;

function LoadGame(var Player1: Player; var Player2: Player;
  var Grid: HexGrid): boolean;
var
  FileName: string;
  Items: TStringArray;
  T: TStringArray;
  LineFromFile: string;
  GridSize: integer;
  TextFile: text;
begin
  write('Enter the name of the file to load: ');
  readln(FileName);
  try
    assign(TextFile, FileName);
    reset(TextFile);
    readln(TextFile, LineFromFile);
    Items := LineFromFile.split([',']);
    Player1 := Player.Init(Items[0], strtoint(Items[1]), strtoint(Items[2]),
      strtoint(Items[3]), strtoint(Items[4]));
    readln(TextFile, LineFromFile);
    Items := LineFromFile.split([',']);
    Player2 := Player.Init(Items[0], strtoint(Items[1]), strtoint(Items[2]),
      strtoint(Items[3]), strtoint(Items[4]));
    readln(TextFile, LineFromFile);
    GridSize := strtoint(LineFromFile);
    Grid := HexGrid.Init(GridSize);
    readln(TextFile, LineFromFile);
    T := LineFromFile.split([',']);
    Grid.SetUpGridTerrain(T);
    while not eof(TextFile) do
    begin
      readln(TextFile, LineFromFile);
      Items := LineFromFile.split([',']);
      if Items[0] = '1' then
        Grid.AddPiece(true, Items[1], strtoint(Items[2]))
      else
        Grid.AddPiece(false, Items[1], strtoint(Items[2]));
    end;
    closeFile(TextFile);
  except
    writeln('File not loaded');
    LoadGame := false;
    exit;
  end;
  LoadGame := true;
end;

procedure PlayGame(Player1: Player; Player2: Player; Grid: HexGrid);
var
  GameOver: boolean;
  Player1Turn: boolean;
  ValidCommand: boolean;
  Commands: TStringArray;
  Count: integer;
  FuelChange: integer;
  LumberChange: integer;
  SupplyChange: integer;
  SummaryOfResult: string;
  C: string;
  Items: TStringArray;
  Player1VPsGained: integer;
  Player2VPsGained: integer;
begin
  GameOver := false;
  Player1Turn := true;
  writeln('Player One current state - ' + Player1.GetStateString());
  writeln('Player Two current state - ' + Player2.GetStateString());
  setlength(Commands, 0);
  repeat
    writeln(Grid.GetGridAsString(Player1Turn));
    if Player1Turn = true then
      writeln(Player1.GetName() +
        ' state your three commands, pressing enter after each one.')
    else
      writeln(Player2.GetName() +
        ' state your three commands, pressing enter after each one.');
    for Count := 1 to 3 do
    begin
      setlength(Commands, length(Commands) + 1);
      write('Enter command: ');
      readln(Commands[high(Commands)]);
      Commands[high(Commands)] := lowercase(Commands[high(Commands)]);
    end;
    for Count := low(Commands) to high(Commands) do
    begin
      C := Commands[Count];
      Items := C.split([' ']);
      ValidCommand := CheckCommandIsValid(Items);
      if not(ValidCommand) then
        writeln('Invalid command')
      else
      begin
        FuelChange := 0;
        LumberChange := 0;
        SupplyChange := 0;
        if Player1Turn then
        begin
          SummaryOfResult := Grid.ExecuteCommand(Items, FuelChange,
            LumberChange, SupplyChange, Player1.GetFuel(), Player1.GetLumber(),
            Player1.GetPiecesInSupply());
          Player1.UpdateLumber(LumberChange);
          Player1.UpdateFuel(FuelChange);
          if SupplyChange = 1 then
            Player1.RemoveTileFromSupply();
        end
        else
        begin
          SummaryOfResult := Grid.ExecuteCommand(Items, FuelChange,
            LumberChange, SupplyChange, Player2.GetFuel(), Player2.GetLumber(),
            Player2.GetPiecesInSupply());
          Player2.UpdateLumber(LumberChange);
          Player2.UpdateFuel(FuelChange);
          if SupplyChange = 1 then
            Player2.RemoveTileFromSupply();
        end;
        writeln(SummaryOfResult);
      end;
    end;
    setlength(Commands, 0);
    Player1Turn := not(Player1Turn);
    Player1VPsGained := 0;
    Player2VPsGained := 0;
    if GameOver = true then
      Grid.DestroyPiecesAndCountVPs(Player1VPsGained, Player2VPsGained)
    else
      GameOver := Grid.DestroyPiecesAndCountVPs(Player1VPsGained,
        Player2VPsGained);
    Player1.AddToVPs(Player1VPsGained);
    Player2.AddToVPs(Player2VPsGained);
    writeln('Player One current state - ' + Player1.GetStateString());
    writeln('Player Two current state - ' + Player2.GetStateString());
    writeln('Press Enter to continue...');
    readln;
  until (GameOver = true) and (Player1Turn = true);
  writeln(Grid.GetGridAsString(Player1Turn));
  DisplayEndMessages(Player1, Player2);
end;

var
  FileLoaded: boolean;
  Player1: Player;
  Player2: Player;
  Grid: HexGrid;
  Choice: string;
begin
  FileLoaded := true;
  Choice := '';
  while not(Choice = 'Q') do
  begin
    DisplayMainMenu();
    readln(Choice);
    if Choice = '1' then
    begin
      SetUpDefaultGame(Player1, Player2, Grid);
      PlayGame(Player1, Player2, Grid);
    end
    else if Choice = '2' then
    begin
      FileLoaded := LoadGame(Player1, Player2, Grid);
      if FileLoaded = true then
        PlayGame(Player1, Player2, Grid);
    end;
  end;
end.