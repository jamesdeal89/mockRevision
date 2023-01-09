'Skeleton Program code for the AQA A Level Paper 1 Summer 2021 examination
'this code should be used in conjunction with the Preliminary Material
'written by the AQA Programmer Team
'developed in the Visual Studio Community Edition programming environment

Imports System.IO
Imports System.Convert

Module Module1
    Public RNoGen As New Random()
    Sub Main()
        Dim FileLoaded As Boolean = True
        Dim Player1, Player2 As Player
        Dim Grid As HexGrid
        Dim Choice As String = ""
        While Choice <> "Q"
            DisplayMainMenu()
            Choice = Console.ReadLine()
            If Choice = "1" Then
                SetUpDefaultGame(Player1, Player2, Grid)
                PlayGame(Player1, Player2, Grid)
            ElseIf Choice = "2" Then
                FileLoaded = LoadGame(Player1, Player2, Grid)
                If FileLoaded Then
                    PlayGame(Player1, Player2, Grid)
                End If
            End If
        End While
    End Sub

    Function LoadGame(ByRef Player1 As Player, ByRef Player2 As Player, ByRef Grid As HexGrid) As Boolean
        Console.Write("Enter the name of the file to load: ")
        Dim FileName As String = Console.ReadLine()
        Dim Items As List(Of String)
        Dim LineFromFile As String
        Try
            Using MyStream As New StreamReader(FileName)
                LineFromFile = MyStream.ReadLine()
                Items = LineFromFile.Split(",").ToList()
                Player1 = New Player(Items(0), ToInt32(Items(1)), ToInt32(Items(2)), ToInt32(Items(3)), ToInt32(Items(4)))
                LineFromFile = MyStream.ReadLine()
                Items = LineFromFile.Split(",").ToList()
                Player2 = New Player(Items(0), ToInt32(Items(1)), ToInt32(Items(2)), ToInt32(Items(3)), ToInt32(Items(4)))
                Dim GridSize As Integer = ToInt32(MyStream.ReadLine())
                Grid = New HexGrid(GridSize)
                Dim T As List(Of String) = New List(Of String)(MyStream.ReadLine().Split(","))
                Grid.SetUpGridTerrain(T)
                LineFromFile = MyStream.ReadLine()
                While Not LineFromFile Is Nothing
                    Items = LineFromFile.Split(",").ToList()
                    If Items(0) = "1" Then
                        Grid.AddPiece(True, Items(1), ToInt32(Items(2)))
                    Else
                        Grid.AddPiece(False, Items(1), ToInt32(Items(2)))
                    End If
                    LineFromFile = MyStream.ReadLine()
                End While
            End Using
        Catch
            Console.WriteLine("File not loaded")
            Return False
        End Try
        Return True
    End Function

    Sub SetUpDefaultGame(ByRef Player1 As Player, ByRef Player2 As Player, ByRef Grid As HexGrid)
        Dim T As List(Of String) = New List(Of String)({" ", "#", "#", " ", "~", "~", " ", " ", " ", "~", " ", "#", "#", " ", " ", " " _
                                                         , " ", " ", "#", "#", "#", "#", "~", "~", "~", "~", "~", " ", "#", " ", "#", " "})
        Dim GridSize As Integer = 8
        Grid = New HexGrid(GridSize)
        Player1 = New Player("Player One", 0, 10, 10, 5)
        Player2 = New Player("Player Two", 1, 10, 10, 5)
        Grid.SetUpGridTerrain(T)
        Grid.AddPiece(True, "Baron", 0)
        Grid.AddPiece(True, "Serf", 8)
        Grid.AddPiece(False, "Baron", 31)
        Grid.AddPiece(False, "Serf", 23)
    End Sub

    Function CheckMoveCommandFormat(ByVal Items As List(Of String)) As Boolean
        Dim Result As Integer
        If Items.Count = 3 Then
            For Count = 1 To 2
                Try
                    Result = Items(Count)
                Catch
                    Return False
                End Try
            Next
            Return True
        End If
        Return False
    End Function

    Function CheckStandardCommandFormat(ByVal Items As List(Of String)) As Boolean
        Dim Result As Integer
        If Items.Count = 2 Then
            Try
                Result = Items(1)
            Catch
                Return False
            End Try
            Return True
        End If
        Return False
    End Function

    Function CheckUpgradeCommandFormat(ByVal Items As List(Of String)) As Boolean
        Dim Result As Integer
        If Items.Count = 3 Then
            If Items(1).ToUpper() <> "LESS" And Items(1).ToUpper() <> "PBDS" Then
                Return False
            End If
            Try
                Result = Items(2)
            Catch
                Return False
            End Try
            Return True
        End If
        Return False
    End Function

    Function CheckCommandIsValid(ByVal Items As List(Of String)) As Boolean
        If Items.Count > 0 Then
            Select Case Items(0)
                Case "move"
                    Return CheckMoveCommandFormat(Items)
                Case "dig", "saw", "spawn"
                    Return CheckStandardCommandFormat(Items)
                Case "upgrade"
                    Return CheckUpgradeCommandFormat(Items)
            End Select
        End If
        Return False
    End Function

    Sub PlayGame(ByVal Player1 As Player, ByVal Player2 As Player, ByVal Grid As HexGrid)
        Dim GameOver As Boolean = False
        Dim Player1Turn As Boolean = True
        Dim ValidCommand As Boolean
        Dim Commands As New List(Of String)
        Console.WriteLine("Player One current state - " & Player1.GetStateString())
        Console.WriteLine("Player Two current state - " & Player2.GetStateString())
        Do
            Console.WriteLine(Grid.GetGridAsString(Player1Turn))
            If Player1Turn Then
                Console.WriteLine(Player1.GetName() & " state your three commands, pressing enter after each one.")
            Else
                Console.WriteLine(Player2.GetName() & " state your three commands, pressing enter after each one.")
            End If
            For Count = 1 To 3
                Console.Write("Enter command: ")
                Commands.Add(Console.ReadLine().ToLower())
            Next
            For Each C In Commands
                Dim Items As List(Of String) = New List(Of String)(C.Split(" "))
                ValidCommand = CheckCommandIsValid(Items)
                If Not ValidCommand Then
                    Console.WriteLine("Invalid command")
                Else
                    Dim FuelChange As Integer = 0
                    Dim LumberChange As Integer = 0
                    Dim SupplyChange As Integer = 0
                    Dim SummaryOfResult As String
                    If Player1Turn Then
                        SummaryOfResult = Grid.ExecuteCommand(Items, FuelChange, LumberChange, SupplyChange,
                                                              Player1.GetFuel(), Player1.GetLumber(),
                                                              Player1.GetPiecesInSupply())
                        Player1.UpdateLumber(LumberChange)
                        Player1.UpdateFuel(FuelChange)
                        If SupplyChange = 1 Then
                            Player1.RemoveTileFromSupply()
                        End If
                    Else
                        SummaryOfResult = Grid.ExecuteCommand(Items, FuelChange, LumberChange, SupplyChange,
                                                              Player2.GetFuel(), Player2.GetLumber(),
                                                              Player2.GetPiecesInSupply())
                        Player2.UpdateLumber(LumberChange)
                        Player2.UpdateFuel(FuelChange)
                        If SupplyChange = 1 Then
                            Player2.RemoveTileFromSupply()
                        End If
                    End If
                    Console.WriteLine(SummaryOfResult)
                End If
            Next
            Commands.Clear()
            Player1Turn = Not Player1Turn
            Dim Player1VPsGained As Integer = 0
            Dim Player2VPsGained As Integer = 0
            If GameOver Then
                Grid.DestroyPiecesAndCountVPs(Player1VPsGained, Player2VPsGained)
            Else
                GameOver = Grid.DestroyPiecesAndCountVPs(Player1VPsGained, Player2VPsGained)
            End If
            Player1.AddToVPs(Player1VPsGained)
            Player2.AddToVPs(Player2VPsGained)
            Console.WriteLine("Player One current state - " & Player1.GetStateString())
            Console.WriteLine("Player Two current state - " & Player2.GetStateString())
            Console.Write("Press Enter to continue...")
            Console.ReadLine()
        Loop Until GameOver And Player1Turn
        Console.WriteLine(Grid.GetGridAsString(Player1Turn))
        DisplayEndMessages(Player1, Player2)
    End Sub

    Sub DisplayEndMessages(ByVal Player1 As Player, ByVal Player2 As Player)
        Console.WriteLine()
        Console.WriteLine(Player1.GetName() & " final state: " & Player1.GetStateString())
        Console.WriteLine()
        Console.WriteLine(Player2.GetName() & " final state: " & Player2.GetStateString())
        Console.WriteLine()
        If Player1.GetVPs() > Player2.GetVPs() Then
            Console.WriteLine(Player1.GetName() & " is the winner!")
        Else
            Console.WriteLine(Player2.GetName() & " is the winner!")
        End If
    End Sub

    Sub DisplayMainMenu()
        Console.WriteLine("1. Default game")
        Console.WriteLine("2. Load game")
        Console.WriteLine("Q. Quit")
        Console.WriteLine()
        Console.Write("Enter your choice: ")
    End Sub
End Module

Class Piece
    Protected Destroyed, BelongsToPlayer1 As Boolean
    Protected FuelCostOfMove, VPValue, ConnectionsToDestroy As Integer
    Protected PieceType As String

    Public Sub New(ByVal Player1 As Boolean)
        FuelCostOfMove = 1
        BelongsToPlayer1 = Player1
        Destroyed = False
        PieceType = "S"
        VPValue = 1
        ConnectionsToDestroy = 2
    End Sub

    Public Overridable Function GetVPs() As Integer
        Return VPValue
    End Function

    Public Overridable Function GetBelongsToPlayer1() As Boolean
        Return BelongsToPlayer1
    End Function

    Public Overridable Function CheckMoveIsValid(ByVal DistanceBetweenTiles As Integer, ByVal StartTerrain As String, ByVal EndTerrain As String) As Integer
        If DistanceBetweenTiles = 1 Then
            If StartTerrain = "~" Or EndTerrain = "~" Then
                Return FuelCostOfMove * 2
            Else
                Return FuelCostOfMove
            End If
        End If
        Return -1
    End Function

    Public Overridable Function HasMethod(ByVal MethodName As String) As Boolean
        Return Me.GetType().GetMethod(MethodName) <> Nothing
    End Function

    Public Overridable Function GetConnectionsNeededToDestroy() As Integer
        Return ConnectionsToDestroy
    End Function

    Public Overridable Function GetPieceType() As String
        If BelongsToPlayer1 Then
            Return PieceType
        Else
            Return PieceType.ToLower()
        End If
    End Function

    Public Overridable Sub DestroyPiece()
        Destroyed = True
    End Sub
End Class

Class BaronPiece
    Inherits Piece
    Public Sub New(ByVal Player1 As Boolean)
        MyBase.New(Player1)
        PieceType = "B"
        VPValue = 10
    End Sub

    Public Overrides Function CheckMoveIsValid(ByVal DistanceBetweenTiles As Integer, ByVal StartTerrain As String, ByVal EndTerrain As String) As Integer
        If DistanceBetweenTiles = 1 Then
            Return FuelCostOfMove
        End If
        Return -1
    End Function
End Class

Class LESSPiece
    Inherits Piece
    Public Sub New(ByVal Player1 As Boolean)
        MyBase.New(Player1)
        PieceType = "L"
        VPValue = 3
    End Sub

    Public Overrides Function CheckMoveIsValid(ByVal DistanceBetweenTiles As Integer, ByVal StartTerrain As String, ByVal EndTerrain As String) As Integer
        If DistanceBetweenTiles = 1 And StartTerrain <> "#" Then
            If StartTerrain = "~" Or EndTerrain = "~" Then
                Return FuelCostOfMove * 2
            Else
                Return FuelCostOfMove
            End If
        End If
        Return -1
    End Function

    Public Function Saw(ByVal Terrain As String) As Integer
        If Terrain <> "#" Then
            Return 0
        End If
        Return 1
    End Function
End Class

Class PBDSPiece
    Inherits Piece
    Public Sub New(ByVal Player1 As Boolean)
        MyBase.New(Player1)
        PieceType = "P"
        VPValue = 2
        FuelCostOfMove = 2
    End Sub

    Public Overrides Function CheckMoveIsValid(ByVal DistanceBetweenTiles As Integer, ByVal StartTerrain As String, ByVal EndTerrain As String) As Integer
        If DistanceBetweenTiles <> 1 Or StartTerrain = "~" Then
            Return -1
        End If
        Return FuelCostOfMove
    End Function

    Public Function Dig(ByVal Terrain As String) As Integer
        If Terrain <> "~" Then
            Return 0
        End If
        If RNoGen.NextDouble() < 0.9 Then
            Return 1
        Else
            Return 5
        End If
    End Function
End Class

Class Tile
    Protected Terrain As String
    Protected x, y, z As Integer
    Protected PieceInTile As Piece
    Protected Neighbours As New List(Of Tile)

    Public Sub New(ByVal xcoord As Integer, ByVal ycoord As Integer, ByVal zcoord As Integer)
        x = xcoord
        y = ycoord
        z = zcoord
        Terrain = " "
        PieceInTile = Nothing
    End Sub

    Public Function GetDistanceToTileT(ByVal T As Tile) As Integer
        Return Math.Max(Math.Max(Math.Abs(Me.Getx() - T.Getx()), Math.Abs(Me.Gety() - T.Gety())), Math.Abs(Me.Getz() - T.Getz()))
    End Function

    Public Sub AddToNeighbours(ByVal N As Tile)
        Neighbours.Add(N)
    End Sub

    Public Function GetNeighbours() As List(Of Tile)
        Return Neighbours
    End Function

    Public Sub SetPiece(ByVal ThePiece As Piece)
        PieceInTile = ThePiece
    End Sub

    Public Sub SetTerrain(ByVal T As String)
        Terrain = T
    End Sub

    Public Function Getx() As Integer
        Return x
    End Function

    Public Function Gety() As Integer
        Return y
    End Function

    Public Function Getz() As Integer
        Return z
    End Function

    Public Function GetTerrain() As String
        Return Terrain
    End Function

    Public Function GetPieceInTile() As Piece
        Return PieceInTile
    End Function
End Class

Class HexGrid
    Protected Tiles As New List(Of Tile)
    Protected Pieces As New List(Of Piece)
    Protected Size As Integer
    Protected Player1Turn As Boolean

    Sub New(ByVal n As Integer)
        Size = n
        SetUpTiles()
        SetUpNeighbours()
        Player1Turn = True
    End Sub

    Public Sub SetUpGridTerrain(ByVal ListOfTerrain As List(Of String))
        For Count = 0 To ListOfTerrain.Count - 1
            Tiles(Count).SetTerrain(ListOfTerrain(Count))
        Next
    End Sub

    Public Sub AddPiece(ByVal BelongsToPlayer1 As Boolean, ByVal TypeOfPiece As String, ByVal Location As Integer)
        Dim NewPiece As Piece
        If TypeOfPiece = "Baron" Then
            NewPiece = New BaronPiece(BelongsToPlayer1)
        ElseIf TypeOfPiece = "LESS" Then
            NewPiece = New LESSPiece(BelongsToPlayer1)
        ElseIf TypeOfPiece = "PBDS" Then
            NewPiece = New PBDSPiece(BelongsToPlayer1)
        Else
            NewPiece = New Piece(BelongsToPlayer1)
        End If
        Pieces.Add(NewPiece)
        Tiles(Location).SetPiece(NewPiece)
    End Sub

    Public Function ExecuteCommand(ByVal Items As List(Of String), ByRef FuelChange As Integer, ByRef LumberChange As Integer,
                                   ByRef SupplyChange As Integer, ByVal FuelAvailable As Integer, ByVal LumberAvailable As Integer,
                                   ByVal PiecesInSupply As Integer) As String
        Select Case Items(0)
            Case "move"
                Dim FuelCost As Integer = ExecuteMoveCommand(Items, FuelAvailable)
                If FuelCost < 0 Then
                    Return "That move can't be done"
                End If
                FuelChange = -FuelCost
            Case "saw", "dig"
                If Not ExecuteCommandInTile(Items, FuelChange, LumberChange) Then
                    Return "Couldn't do that"
                End If
            Case "spawn"
                Dim LumberCost As Integer = ExecuteSpawnCommand(Items, LumberAvailable, PiecesInSupply)
                If LumberCost < 0 Then
                    Return "Spawning did not occur"
                End If
                LumberChange = -LumberCost
                SupplyChange = 1
            Case "upgrade"
                Dim LumberCost As Integer = ExecuteUpgradeCommand(Items, LumberAvailable)
                If LumberCost < 0 Then
                    Return "Upgrade not possible"
                End If
                LumberChange = -LumberCost
        End Select
        Return "Command executed"
    End Function

    Private Function CheckTileIndexIsValid(ByVal TileToCheck As Integer) As Boolean
        Return TileToCheck >= 0 And TileToCheck < Tiles.Count
    End Function

    Private Function CheckPieceAndTileAreValid(ByVal TileToUse As Integer) As Boolean
        If CheckTileIndexIsValid(TileToUse) Then
            Dim ThePiece As Piece = Tiles(TileToUse).GetPieceInTile()
            If ThePiece IsNot Nothing Then
                If ThePiece.GetBelongsToPlayer1() = Player1Turn Then
                    Return True
                End If
            End If
        End If
        Return False
    End Function

    Private Function ExecuteCommandInTile(ByVal Items As List(Of String), ByRef Fuel As Integer,
                                          ByRef Lumber As Integer) As Boolean
        Dim TileToUse As Integer = ToInt32(Items(1))
        If CheckPieceAndTileAreValid(TileToUse) = False Then
            Return False
        End If
        Dim ThePiece As Piece = Tiles(TileToUse).GetPieceInTile()
        Items(0) = Items(0)(0).ToString().ToUpper() & Items(0).ToString().Substring(1)
        If ThePiece.HasMethod(Items(0)) Then
            Dim MethodToCall As String = Items(0)
            Dim T As Type = ThePiece.GetType()
            Dim Method As System.Reflection.MethodInfo = T.GetMethod(MethodToCall)
            Dim Parameters() As Object = {Tiles(TileToUse).GetTerrain()}
            If Items(0) = "Saw" Then
                Lumber += Method.Invoke(ThePiece, Parameters)
            ElseIf Items(0) = "Dig" Then
                Fuel += Method.Invoke(ThePiece, Parameters)
                If Math.Abs(Fuel) > 2 Then
                    Tiles(TileToUse).SetTerrain(" ")
                End If
            End If
            Return True
        End If
        Return False
    End Function

    Private Function ExecuteMoveCommand(ByVal Items As List(Of String), ByVal FuelAvailable As Integer) As Integer
        Dim StartID As Integer = ToInt32(Items(1))
        Dim EndID As Integer = ToInt32(Items(2))
        If Not CheckPieceAndTileAreValid(StartID) Or Not CheckTileIndexIsValid(EndID) Then
            Return -1
        End If
        Dim ThePiece As Piece = Tiles(StartID).GetPieceInTile()
        If Tiles(EndID).GetPieceInTile() IsNot Nothing Then
            Return -1
        End If
        Dim Distance As Integer = Tiles(StartID).GetDistanceToTileT(Tiles(EndID))
        Dim FuelCost As Integer = ThePiece.CheckMoveIsValid(Distance, Tiles(StartID).GetTerrain(), Tiles(EndID).GetTerrain())
        If FuelCost = -1 Or FuelAvailable < FuelCost Then
            Return -1
        End If
        MovePiece(EndID, StartID)
        Return FuelCost
    End Function

    Private Function ExecuteSpawnCommand(ByVal Items As List(Of String), ByVal LumberAvailable As Integer,
                                         ByVal PiecesInSupply As Integer) As Integer
        Dim TileToUse As Integer = ToInt32(Items(1))
        If PiecesInSupply < 1 Or LumberAvailable < 3 Or Not CheckTileIndexIsValid(TileToUse) Then
            Return -1
        End If
        Dim ThePiece As Piece = Tiles(TileToUse).GetPieceInTile()
        If ThePiece IsNot Nothing Then
            Return -1
        End If
        Dim OwnBaronIsNeighbour As Boolean = False
        Dim ListOfNeighbours As List(Of Tile) = New List(Of Tile)(Tiles(TileToUse).GetNeighbours())
        For Each N In ListOfNeighbours
            ThePiece = N.GetPieceInTile()
            If ThePiece IsNot Nothing Then
                If Player1Turn And ThePiece.GetPieceType() = "B" Or Not Player1Turn And ThePiece.GetPieceType() = "b" Then
                    OwnBaronIsNeighbour = True
                    Exit For
                End If
            End If
        Next
        If Not OwnBaronIsNeighbour Then
            Return -1
        End If
        Dim NewPiece As New Piece(Player1Turn)
        Pieces.Add(NewPiece)
        Tiles(TileToUse).SetPiece(NewPiece)
        Return 3
    End Function

    Private Function ExecuteUpgradeCommand(ByVal Items As List(Of String), ByVal LumberAvailable As Integer) As Integer
        Dim TileToUse As Integer = ToInt32(Items(2))
        If Not CheckPieceAndTileAreValid(TileToUse) Or LumberAvailable < 5 Or Not (Items(1) = "pbds" Or Items(1) = "less") Then
            Return -1
        Else
            Dim ThePiece As Piece = Tiles(TileToUse).GetPieceInTile()
            If ThePiece.GetPieceType().ToUpper <> "S" Then
                Return -1
            End If
            ThePiece.DestroyPiece()
            If Items(1) = "pbds" Then
                ThePiece = New PBDSPiece(Player1Turn)
            Else
                ThePiece = New LESSPiece(Player1Turn)
            End If
            Pieces.Add(ThePiece)
            Tiles(TileToUse).SetPiece(ThePiece)
            Return 5
        End If
    End Function

    Private Sub SetUpTiles()
        Dim EvenStartY As Integer = 0
        Dim EvenStartZ As Integer = 0
        Dim OddStartZ As Integer = 0
        Dim OddStartY As Integer = -1
        Dim x, y, z As Integer
        For count = 1 To Size / 2
            y = EvenStartY
            z = EvenStartZ
            For x = 0 To Size - 2 Step 2
                Dim TempTile As New Tile(x, y, z)
                Tiles.Add(TempTile)
                y -= 1
                z -= 1
            Next
            EvenStartZ += 1
            EvenStartY -= 1
            y = OddStartY
            z = OddStartZ
            For x = 1 To Size - 1 Step 2
                Dim TempTile As New Tile(x, y, z)
                Tiles.Add(TempTile)
                y -= 1
                z -= 1
            Next
            OddStartZ += 1
            OddStartY -= 1
        Next
    End Sub

    Private Sub SetUpNeighbours()
        For Each FromTile In Tiles
            For Each ToTile In Tiles
                If FromTile.GetDistanceToTileT(ToTile) = 1 Then
                    FromTile.AddToNeighbours(ToTile)
                End If
            Next
        Next
    End Sub

    Public Function DestroyPiecesAndCountVPs(ByRef Player1VPs As Integer, ByRef Player2VPs As Integer) As Boolean
        Dim BaronDestroyed As Boolean = False
        Dim ListOfTilesContainingDestroyedPieces As New List(Of Tile)
        For Each T In Tiles
            If T.GetPieceInTile() IsNot Nothing Then
                Dim ListOfNeighbours As List(Of Tile) = New List(Of Tile)(T.GetNeighbours())
                Dim NoOfConnections As Integer = 0
                For Each N In ListOfNeighbours
                    If N.GetPieceInTile() IsNot Nothing Then
                        NoOfConnections += 1
                    End If
                Next
                Dim ThePiece As Piece = T.GetPieceInTile()
                If NoOfConnections >= ThePiece.GetConnectionsNeededToDestroy() Then
                    ThePiece.DestroyPiece()
                    If ThePiece.GetPieceType().ToUpper() = "B" Then
                        BaronDestroyed = True
                    End If
                    ListOfTilesContainingDestroyedPieces.Add(T)
                    If ThePiece.GetBelongsToPlayer1() Then
                        Player2VPs += ThePiece.GetVPs()
                    Else
                        Player1VPs += ThePiece.GetVPs()
                    End If
                End If
            End If
        Next
        For Each T In ListOfTilesContainingDestroyedPieces
            T.SetPiece(Nothing)
        Next
        Return BaronDestroyed
    End Function

    Public Function GetGridAsString(ByVal P1Turn As Boolean) As String
        Dim ListPositionOfTile As Integer = 0
        Player1Turn = P1Turn
        Dim GridAsString As String = CreateTopLine() & CreateEvenLine(True, ListPositionOfTile)
        ListPositionOfTile += 1
        GridAsString &= CreateOddLine(ListPositionOfTile)
        For count = 1 To Size - 2 Step 2
            ListPositionOfTile += 1
            GridAsString &= CreateEvenLine(False, ListPositionOfTile)
            ListPositionOfTile += 1
            GridAsString &= CreateOddLine(ListPositionOfTile)
        Next
        Return GridAsString & CreateBottomLine()
    End Function

    Private Sub MovePiece(ByVal NewIndex As Integer, ByVal OldIndex As Integer)
        Tiles(NewIndex).SetPiece(Tiles(OldIndex).GetPieceInTile())
        Tiles(OldIndex).SetPiece(Nothing)
    End Sub

    Public Function GetPieceTypeInTile(ByVal ID As Integer) As String
        Dim ThePiece As Piece = Tiles(ID).GetPieceInTile()
        If ThePiece Is Nothing Then
            Return " "
        Else
            Return ThePiece.GetPieceType()
        End If
    End Function

    Private Function CreateBottomLine() As String
        Dim Line As String = "   "
        For count = 1 To Size / 2
            Line &= " \__/ "
        Next
        Return Line & Environment.NewLine
    End Function

    Private Function CreateTopLine() As String
        Dim Line As String = Environment.NewLine & "  "
        For count = 1 To Size / 2
            Line &= "__    "
        Next
        Return Line & Environment.NewLine
    End Function

    Private Function CreateOddLine(ByRef ListPositionOfTile As Integer) As String
        Dim Line As String = ""
        For count = 1 To Size / 2
            If count > 1 And count < Size / 2 Then
                Line &= GetPieceTypeInTile(ListPositionOfTile) & "\__/"
                ListPositionOfTile += 1
                Line &= Tiles(ListPositionOfTile).GetTerrain()
            ElseIf count = 1 Then
                Line &= " \__/" & Tiles(ListPositionOfTile).GetTerrain()
            End If
        Next
        Line &= GetPieceTypeInTile(ListPositionOfTile) & "\__/"
        ListPositionOfTile += 1
        If ListPositionOfTile < Tiles.Count() Then
            Line &= Tiles(ListPositionOfTile).GetTerrain() & GetPieceTypeInTile(ListPositionOfTile) & "\" & Environment.NewLine
        Else
            Line &= "\" & Environment.NewLine
        End If
        Return Line
    End Function

    Private Function CreateEvenLine(ByVal FirstEvenLine As Boolean, ByRef ListPositionOfTile As Integer) As String
        Dim Line As String = " /" & Tiles(ListPositionOfTile).GetTerrain()
        For count = 1 To Size / 2 - 1
            Line &= GetPieceTypeInTile(ListPositionOfTile)
            ListPositionOfTile += 1
            Line &= "\__/" & Tiles(ListPositionOfTile).GetTerrain()
        Next
        If FirstEvenLine Then
            Line &= GetPieceTypeInTile(ListPositionOfTile) & "\__" & Environment.NewLine
        Else
            Line &= GetPieceTypeInTile(ListPositionOfTile) & "\__/" & Environment.NewLine
        End If
        Return Line
    End Function
End Class

Class Player
    Protected PiecesInSupply, Fuel, VPs, Lumber As Integer
    Protected Name As String

    Public Sub New(ByVal N As String, ByVal V As Integer, ByVal F As Integer, ByVal L As Integer, ByVal T As Integer)
        Name = N
        VPs = V
        Fuel = F
        Lumber = L
        PiecesInSupply = T
    End Sub

    Public Overridable Function GetStateString() As String
        Return "VPs: " & VPs.ToString() & "   Pieces in supply: " & PiecesInSupply.ToString() & "   Lumber: " & Lumber.ToString() & "   Fuel: " & Fuel.ToString()
    End Function

    Public Overridable Function GetVPs() As Integer
        Return VPs
    End Function

    Public Overridable Function GetFuel() As Integer
        Return Fuel
    End Function

    Public Overridable Function GetLumber() As Integer
        Return Lumber
    End Function

    Public Overridable Function GetName() As String
        Return Name
    End Function

    Public Overridable Sub AddToVPs(ByVal n As Integer)
        VPs += n
    End Sub

    Public Overridable Sub UpdateFuel(ByVal n As Integer)
        Fuel += n
    End Sub

    Public Overridable Sub UpdateLumber(ByVal n As Integer)
        Lumber += n
    End Sub

    Public Overridable Function GetPiecesInSupply() As Integer
        Return PiecesInSupply
    End Function

    Public Overridable Sub RemoveTileFromSupply()
        PiecesInSupply -= 1
    End Sub
End Class