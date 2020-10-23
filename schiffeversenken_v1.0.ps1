#
# Schiffe Versenken
#
# Ein Textadventure
#
# Proof of Concept
#
cls
#gamegrids
$grid_player = @{"A1" = $null; "A2" = $null; "A3" = $null; "A4" = $null; "B1" = $null; "B2" = $null; "B3" = $null; "B4" = $null; "C1" = $null; "C2" = $null; "C3" = $null; "C4" = $null; "D1" = $null; "D2" = $null; "D3" = $null; "D4" = $null;}
$grid_ai = @{"A1" = $null; "A2" = $null; "A3" = $null; "A4" = $null; "B1" = $null; "B2" = $null; "B3" = $null; "B4" = $null; "C1" = $null; "C2" = $null; "C3" = $null; "C4" = $null; "D1" = $null; "D2" = $null; "D3" = $null; "D4" = $null;}

#MAIN functions
$coordinates = @("A1", "A2", "A3", "A4", "B1", "B2", "B3", "B4", "C1", "C2", "C3", "C4", "D1", "D2", "D3", "D4")
$shotAt = @()
#PLAYER FUNCTIONS
#shoot at ai gamegrid
function Shoot_at_ai()
    {
    Write-Host `n
    $position = Read-Host "Auf welchen gegnerischen Quadranten (A1 - D4) willst du schießen?"
    $position = $position.ToUpper()
    cls
    Write-Host ""
    Write-Host "~~~~~~DEIN SPIELZUG~~~~~" `n
    if ($position -eq "gg")
        {
        for ($i = 0; $i -le 99; $i++)
            {
            Write-Host "Du hast aufgegeben. Versager." `n
            }
        break
        }
    elseif ($position -notin $coordinates)
        {
        Write-Host "Außerhalb des Spielfeldes!" `n
        }
    elseif ($grid_ai[$position] -eq $null)
        {
        Write-Host "Du schießt auf den Quadranten" $position "des Gegners!"
        Write-Host "Doch der Schuss ging ins Leere!" `n
        if($position -in $shotAt)
            {
            Write-Host "Außerdem hast du bereits auf dieses Feld geschossen!" `n
            }
        }
    elseif ($grid_ai[$position].damaged -eq $true)
        {
        Write-Host "Du schießt auf den Quadranten" $position "des Gegners!"
        Write-Host "Das Schiff an dieser Stelle hast du bereits beschossen!" `n
        }
    else
        {
        foreach ($ship in $fleet_ai)
            {
            if ($ship.position -eq $position)
                {
                $ship.damaged = $true
                $ship.AddToGrid($grid_ai)
                Write-Host "Du schießt auf den Quadranten" $position "des Gegners!"
                Write-Host "Volltreffer! Du hast das gegnerische Schiff auf Position" $position "versenkt!"  `n
                AddToSunk_ai($ship)
                }
            }
        }
    if ($fleet_ai.count -eq $sunk_ai.count)
        {
        Write-Host "Du hast alle Schiffe versenkt!" `n
        Write-Host "A winner is you!" `n
        break
        }
    else
        {
        Write-Host "Es gibt noch" (($fleet_ai.count) - ($sunk_ai.count)) "gegnerische(s) Schiff(e)!" `n
        }
    $global:shotat += $position
    }
#add ships to array $sunk_ai
[array]$sunk_ai = @()
function AddToSunk_ai
    {
    param($ship)
    $global:sunk_ai += $ship
    }
    
#all ships will be written in this array $fleet
$fleet_ai = @()
$fleet_player = @()
#define class ship 
#attributes: shipnumber, damaged, position
#methods: addtogrid, addtofleet, constructor
class ShipAI {
    #attributes
    [int]$shipnumber
    [bool]$damaged
    [string]$position
    #add ships to hashtable $grid
    [void]AddToGrid($grid_ai) {
        $global:grid_ai.set_item($this.position, $this)
        }
    #add ships to array $fleet
    [void]AddToFleet($fleet_ai) {
        $global:fleet_ai += $this
        }
    #constructor
    ShipAI([string]$shipnumber,[string]$position,$fleet_ai,$grid_ai){
        $this.shipnumber = $shipnumber
        $this.damaged = $false
        $this.position = $position
        $this.AddToGrid($grid_ai)        
        $this.AddToFleet($fleet_ai)
        }
    }

#AI FUNCTIONS
#shoot at player gamegrid
$coordinates_ai = New-Object System.Collections.ArrayList
foreach ($i in $coordinates)
    {
    [void]$coordinates_ai.Add($i)
    }
function Shoot_at_player()
    {
    $position = Get-Random -InputObject $coordinates_ai
    $coordinates_ai.Remove($position)
    Write-Host "~~~~~~SPIELZUG DES GEGNERS~~~~~"  `n
    if ($coordinates_ai.Count -eq 0)
        {
        Write-Host "Ich habe schon auf alle deine Felder geschossen!"
        break
        }
    Write-Host "Der Computer hat auf deinen Quadranten" $position "geschossen!"
    if($grid_player[$position] -eq $null)
        {
        Write-Host "Das traf jedoch keines deiner Schiffe!" `n
        }
    else
        {
        foreach ($ship in $fleet_player)
            {
            if ($ship.position -eq $position)
                {
                $ship.damaged = $true
                $ship.AddToGrid($grid_player)
                Write-Host "Volltreffer! Der Computer hat dein Schiff auf" $position "versenkt!" `n
                AddToSunk_player($ship)
                }
            }
        }
    if ($fleet_player.Count -eq $sunk_player.Count -and $sunk_player.Count -eq 3)
        {
        Write-Host "Alle deine Schiffe wurden versenkt!" `n
        Write-Host "Du hast verloren!" `n
        Write-Host "Viel Glück beim nächsten Mal!" `n
        break
        }
    else
        {
        Write-Host "Du hast noch" (($fleet_player.Count) - ($sunk_player.Count)) "Schiff(e)!" `n
        }
    }
#add ships to array $sunk_player
[array]$sunk_player = @()
function AddToSunk_player
    {
    param($ship)
    $global:sunk_player += $ship
    }
    
#all ships will be written in these arrays
$fleet_ai = @()
$fleet_player = @()
#define class ship 
#attributes: shipnumber, damaged, position
#methods: addtogrid, addtofleet, constructor
class ShipPlayer {
    #attributes
    [int]$shipnumber
    [bool]$damaged
    [string]$position
    #add ships to hashtable $grid
    [void]AddToGrid($grid_player) {
        $global:grid_player.set_item($this.position, $this)
        }
    #add ships to array $fleet
    [void]AddToFleet($fleet_player) {
        $global:fleet_player += $this
        }
    #constructor
    ShipPlayer([string]$shipnumber,[string]$position,$fleet_player,$grid_player){
        $this.shipnumber = $shipnumber
        $this.damaged = $false
        $this.position = $position
        $this.AddToGrid($grid_player)        
        $this.AddToFleet($fleet_player)
        }
    }

#random distribution of 3 ships onto the ai grid
$daten_ai0 = Get-Random -InputObject $coordinates 
$ship_ai0 = [ShipAI]::new(0,$daten_ai0,$fleet_ai,$grid_ai)
do
    {
    $daten_ai1 = Get-Random -InputObject $coordinates 
    }
    while ($daten_ai0 -eq $daten_ai1)
$ship_ai1 = [ShipAI]::new(1,$daten_ai1,$fleet_ai,$grid_ai)
do
    {
    $daten_ai2 = Get-Random -InputObject $coordinates
    }
    while ($daten_ai2 -eq $daten_ai1 -and $datem_ai2 -eq $daten_ai0)
$ship_ai2 = [ShipAI]::new(2,$daten_ai2,$fleet_ai,$grid_ai)

Write-Host ("Willkommen bei Battleship!"+"`n"+"`n"+"Regeln:"+"`n"+"Wer zuerst alle 3 Schiffe des Gegners versenkt, gewinnt."+"`n"+"Ein Schiff ist immer genau 1 Feld groß."+"`n"+"Der User beginnt."+"`n"+"")

#set player ships
#ship0
do
    {
    $daten0 = Read-Host "Bitte gib die Position (A1 - D4) deines ersten Schiffs ein"
    if ($coordinates -inotcontains $daten0)
        {
        Write-Host "Bitte gib ein gültiges Feld (A1 - D4) an!"
        }
    }
    while ($coordinates -inotcontains $daten0)
$ship_player0 = [ShipPlayer]::new(0,$daten0,$fleet_player,$grid_player)
#ship1
do
    {
    $daten1 = Read-Host "Bitte gib die Position (A1 - D4) deines zweiten Schiffs ein"
    if ($coordinates -inotcontains $daten1)
        {
        Write-Host "Bitte gib ein gültiges Feld (A1 - D4) an!"
        $daten1 = $daten0
        }
    elseif ($daten0 -eq $daten1)
        {
        Write-Host "Bitte wähle ein Feld, auf dem du noch kein Schiff platziert hast!"
        }
    }
    while ($daten0 -eq $daten1)
$ship_player1 = [ShipPlayer]::new(1,$daten1,$fleet_player,$grid_player)
#ship2
do
    {
    $daten2 = Read-Host "Bitte gib die Position (A1 - D4) deines dritten Schiffs ein"
    if ($coordinates -inotcontains $daten2)
        {
        Write-Host "Bitte gib ein gültiges Feld (A1 - D4) an!"
        $daten2 = $daten0
        }
    elseif ($daten0 -eq $daten2 -or $daten1 -eq $daten2)
        {
        Write-Host "Bitte wähle ein Feld, auf dem du noch kein Schiff platziert hast!"
        $daten2 = $daten0
        }
    }
    while ($daten0 -eq $daten2)
$ship_player2 = [ShipPlayer]::new(2,$daten2,$fleet_player,$grid_player)




#TIME TO PLAY
Write-Host ""
Write-Host "Du hast alle deine Schiffe gesetzt!" `n
Write-Host "Um aufzugeben, gib einfach 'gg' ein." `n
Write-Host "Es gilt" $fleet_ai.count "gegnerische Schiffe zu versenken!" `n
do
    {
    [string]$start = Read-Host "Gib 'Start' ein, um das Spiel zu starten"
    if ($start -eq "marco polo")
        {
        Write-Host ""
        Write-Host "Die Koordinaten der gegnerischen Schiffe:"
        Write-Host $daten_ai0
        Write-Host $daten_ai1
        Write-Host $daten_ai2 `n
        }
    }
until ($start -eq "start")
cls
while ($sunk_ai.Count -lt 3 -and $sunk_player.Count -lt 3)
    {
    Shoot_at_ai
    Shoot_at_player
    }
Write-Host "Drücke F5 um ein neues Match zu starten" `n