#
# Schiffe Versenken
#
# Grafische Oberfläche massiv erweitert und abgeschlossen
#
# 5x5 Spielfeld
# 4 verschiedene Schiffe
#
cls
#changes the working directory to where the script is run from, ensuring that the icons will be found
cd $PSScriptRoot
[void][reflection.assembly]::LoadWithPartialName("System.Windows.Forms")
[void][reflection.assembly]::LoadWithPartialName("System.Drawing")
[System.Windows.Forms.Application]::EnableVisualStyles()
#gamegrids
$grid_player = @{"A1" = $null; "A2" = $null; "A3" = $null; "A4" = $null; "A5" = $null; "B1" = $null; "B2" = $null; "B3" = $null; "B4" = $null; "B5" = $null; "C1" = $null; "C2" = $null; "C3" = $null; "C4" = $null; "C5" = $null; "D1" = $null; "D2" = $null; "D3" = $null; "D4" = $null; "D5" = $null; "E1" = $null; "E2" = $null; "E3" = $null; "E4" = $null; "E5" = $null;}
$grid_ai = @{"A1" = $null; "A2" = $null; "A3" = $null; "A4" = $null; "A5" = $null; "B1" = $null; "B2" = $null; "B3" = $null; "B4" = $null; "B5" = $null; "C1" = $null; "C2" = $null; "C3" = $null; "C4" = $null; "C5" = $null; "D1" = $null; "D2" = $null; "D3" = $null; "D4" = $null; "D5" = $null; "E1" = $null; "E2" = $null; "E3" = $null; "E4" = $null; "E5" = $null;}
#MAIN functions
$coordinates = @("A1", "A2", "A3", "A4", "A5", "B1", "B2", "B3", "B4", "B5", "C1", "C2", "C3", "C4", "C5", "D1", "D2", "D3", "D4", "D5", "E1", "E2", "E3", "E4", "E5")
$shotAt = @()
#PLAYER FUNCTIONS
#shoot at ai gamegrid AND create new combat log tab
$tabs = New-Object System.Collections.ArrayList
$labels= New-Object System.Collections.ArrayList
$log = New-Object System.Drawing.Font("Lucida Console",9)
$img_sunk = (get-item ".\sunk.jpg")
$img_sunk_button = [system.drawing.image]::FromFile($img_sunk)
$img_splash = (get-item ".\splash.jpg")
$img_splash_button = [system.drawing.image]::FromFile($img_splash)
$img_ship = (get-item ".\ship.png")
$img_ship_button = [system.drawing.image]::FromFile($img_ship)

# ________   ___  ___   ________   ________   _________        ________   _________        ________   ___     
#|\   ____\ |\  \|\  \ |\   __  \ |\   __  \ |\___   ___\     |\   __  \ |\___   ___\     |\   __  \ |\  \    
#\ \  \___|_\ \  \\\  \\ \  \|\  \\ \  \|\  \\|___ \  \_|     \ \  \|\  \\|___ \  \_|     \ \  \|\  \\ \  \   
# \ \_____  \\ \   __  \\ \  \\\  \\ \  \\\  \    \ \  \       \ \   __  \    \ \  \       \ \   __  \\ \  \  
#  \|____|\  \\ \  \ \  \\ \  \\\  \\ \  \\\  \    \ \  \       \ \  \ \  \    \ \  \       \ \  \ \  \\ \  \ 
#    ____\_\  \\ \__\ \__\\ \_______\\ \_______\    \ \__\       \ \__\ \__\    \ \__\       \ \__\ \__\\ \__\
#   |\_________\\|__|\|__| \|_______| \|_______|     \|__|        \|__|\|__|     \|__|        \|__|\|__| \|__|
#   \|_________|                                                                                              
                                                                                                             
function Shoot_at_ai ($position,$runde)
    {
    $player_victory = $false
#add tab
    [void]$global:tabs.Add((Set-Variable -Name "tab"+[string]$runde))
    $global:tabs[([int]$runde)] = New-Object System.Windows.Forms.TabPage
    $global:tabs[([int]$runde)].TabIndex = [int]$runde
    $global:tabs[([int]$runde)].UseVisualStyleBackColor = $True
    $global:tabs[([int]$runde)].Height = 200
    $global:tabs[([int]$runde)].Width = 866
    $global:tabs[([int]$runde)].Name = "tabPage"+[string]$runde
    $global:tabs[([int]$runde)].Text = "Round "+[string]$runde
    $tabControl.SelectedTab = $global:tabs[([int]$runde)]
#add label for this tab
    [void]$global:labels.Add((Set-Variable -Name "label"+[string]$runde))
    $global:labels[([int]$runde)] = New-Object Windows.Forms.Label
    $global:labels[([int]$runde)].Width = 270
    $global:labels[([int]$runde)].height = 300
    $global:labels[([int]$runde)].font = $log
    $global:labels[([int]$runde)].Location = New-Object Drawing.Point 10,10
    $global:tabs[([int]$runde)].Controls.Add($global:labels[([int]$runde)]) #adds label to tabpage
    $tabControl.Controls.Add($global:tabs[([int]$runde)]) #adds tabpage to tabcontrol
    $global:labels[([int]$runde)].Text = "~~~~~~~~~~~~ YOUR TURN ~~~~~~~~~~~~"+"`n"+"`n"+"We're shooting at the enemy"+"`n"+"Sector $position!"+"`n"
#shoot at ai grid
    if ($grid_ai[$position] -eq $null)
        {
        $this.text = ""
        $this.image = $img_splash_button
        $global:labels[([int]$runde)].Text += "But the shot hit the waves!"+"`n"
        }
    else
        {
        foreach ($ship in $fleet_ai)
            {
            if ($ship.position -eq $position -or $ship.position1 -eq $position -or $ship.position2 -eq $position -or $ship.position3 -eq $position)
                {
                $ship.damaged = $true
                $ship.segments--
                $this.text = ""
                $this.image = $img_sunk_button
                if ($ship.segments -eq 0)
                    {
                    $global:labels[([int]$runde)].Text += "Bullseye! We sunk an enemy ship!"+"`n"
                    AddToSunk_ai($ship)
                    }
                else
                    {
                    $global:labels[([int]$runde)].Text += "The shot damaged an enemy ship!"+"`n"
                    }
                }
            }
        }
    $differenz_ai = ($fleet_ai.count - $sunk_ai.count)
    if ($differenz_ai -eq 0)
        {
        $global:labels[([int]$runde)].Text += "`n"+"We sunk all enemy ships!"
        $global:willkommen.text = "Thou art"+"`n"+"victorious!"+"`n"
        foreach ($button in $buttons)
            {
            $button.enabled = $false
            }
        gameend
        $player_victory = $true
        }
    elseif ($differenz_ai -eq 1)
        {
        $global:labels[([int]$runde)].Text += "`n"+"There is still one enemy ship left!"+"`n"
        }
    else
        {
        $global:labels[([int]$runde)].Text += "`n"+"There are still "+$differenz_ai+" enemy ships left!"+"`n"
        }
    $this.enabled = $false
    $Form.Controls.Add($this)
    $global:shotat += $position
    if ($player_victory -eq $false)
        {
        Shoot_at_player -runde $runde
        }
    }
#add ships to array $sunk_ai
[array]$sunk_ai = @()
function AddToSunk_ai
    {
    param($ship)
    $global:sunk_ai += $ship
    }
    
# ________   ___  ___   ________   ________   _________        ________   _________        ________   ___        ________       ___    ___  _______    ________     
#|\   ____\ |\  \|\  \ |\   __  \ |\   __  \ |\___   ___\     |\   __  \ |\___   ___\     |\   __  \ |\  \      |\   __  \     |\  \  / /||\  ___ \  |\   __  \    
#\ \  \___|_\ \  \\\  \\ \  \|\  \\ \  \|\  \\|___ \  \_|     \ \  \|\  \\|___ \  \_|     \ \  \|\  \\ \  \     \ \  \|\  \    \ \  \/ / /\ \   __/| \ \  \|\  \   
# \ \_____  \\ \   __  \\ \  \\\  \\ \  \\\  \    \ \  \       \ \   __  \    \ \  \       \ \   ____\\ \  \     \ \   __  \    \ \   / /  \ \  \_|/__\ \   _  _\  
#  \|____|\  \\ \  \ \  \\ \  \\\  \\ \  \\\  \    \ \  \       \ \  \ \  \    \ \  \       \ \  \___| \ \  \____ \ \  \ \  \    \/  / /    \ \  \_|\ \\ \  \\  \| 
#    ____\_\  \\ \__\ \__\\ \_______\\ \_______\    \ \__\       \ \__\ \__\    \ \__\       \ \__\     \ \_______\\ \__\ \__\ __/  / /      \ \_______\\ \__\\ _\ 
#   |\_________\\|__|\|__| \|_______| \|_______|     \|__|        \|__|\|__|     \|__|        \|__|      \|_______| \|__|\|__||\___/ /        \|_______| \|__|\|__|
#   \|_________|                                                                                                              \|___|/                               
                                                                                                                                                                   
#AI FUNCTIONS
#shoot at player gamegrid
$index = 0
$coordinates_ai = New-Object System.Collections.ArrayList
foreach ($i in $coordinates)
    {
    [void]$coordinates_ai.Add($i)
    }
function Shoot_at_player($runde)
    {
    $global:labels[([int]$runde)].Text += "`n"+"~~~~~~~~~~~ ENEMY TURN ~~~~~~~~~~~~"+"`n"+"`n"
    $position = Get-Random -InputObject $coordinates_ai
    $coordinates_ai.Remove($position)
    $global:labels[([int]$runde)].Text += "The enemy shot at our Sector $position!"+"`n"
    if($grid_player[$position] -eq $null)
        {
        $global:labels[([int]$runde)].Text +=  "But they hit nothing but thin air!"+"`n"
        switch ($position)
            {
            A1 {$global:index = 0}
            A2 {$global:index = 1}
            A3 {$global:index = 2}
            A4 {$global:index = 3}
            A5 {$global:index = 4}
            B1 {$global:index = 5}
            B2 {$global:index = 6}
            B3 {$global:index = 7}
            B4 {$global:index = 8}
            B5 {$global:index = 9}
            C1 {$global:index = 10}
            C2 {$global:index = 11}
            C3 {$global:index = 12}
            C4 {$global:index = 13}
            C5 {$global:index = 14}
            D1 {$global:index = 15}
            D2 {$global:index = 16}
            D3 {$global:index = 17}
            D4 {$global:index = 18}
            D5 {$global:index = 19}
            E1 {$global:index = 20}
            E2 {$global:index = 21}
            E3 {$global:index = 22}
            E4 {$global:index = 23}
            E5 {$global:index = 24}
            }
        $buttons_player[$global:index].Image = $img_splash_button
        $buttons_player[$global:index].Text = ""
        }
    else
        {
        foreach ($ship in $fleet_player)
            {
            if ($ship.position -eq $position -or $ship.position1 -eq $position -or $ship.position2 -eq $position -or $ship.position3 -eq $position)
                {
                $ship.damaged = $true
                $ship.segments--
                if ($ship.segments -eq 0)
                    {
                    $global:labels[([int]$runde)].Text += "Bugger! The enemy sunk our ship cross the Sectors "+$ship.position+$ship.position1+$ship.position2+$ship.position3+"!"+"`n"
                    AddToSunk_player($ship)
                    }
                else
                    {
                    $global:labels[([int]$runde)].Text += "Blimey! The enemy damaged our ship at Sector $position!"+"`n"
                    }
                switch ($position)
                    {
                    A1 {$global:index = 0}
                    A2 {$global:index = 1}
                    A3 {$global:index = 2}
                    A4 {$global:index = 3}
                    A5 {$global:index = 4}
                    B1 {$global:index = 5}
                    B2 {$global:index = 6}
                    B3 {$global:index = 7}
                    B4 {$global:index = 8}
                    B5 {$global:index = 9}
                    C1 {$global:index = 10}
                    C2 {$global:index = 11}
                    C3 {$global:index = 12}
                    C4 {$global:index = 13}
                    C5 {$global:index = 14}
                    D1 {$global:index = 15}
                    D2 {$global:index = 16}
                    D3 {$global:index = 17}
                    D4 {$global:index = 18}
                    D5 {$global:index = 19}
                    E1 {$global:index = 20}
                    E2 {$global:index = 21}
                    E3 {$global:index = 22}
                    E4 {$global:index = 23}
                    E5 {$global:index = 24}
                    }
                $buttons_player[$global:index].Image = $img_sunk_button
                $buttons_player[$global:index].Text = ""
                }
            }
        }        
    #is the player defeated?
    if ($fleet_player.Count -eq $sunk_player.Count -and $sunk_player.Count -eq 4)
        {
        $global:labels[([int]$runde)].Text += "`n"+"All our ships have been sunk in battle!"+"`n"+"This will leave a mark"+"`n"+"of shame for many"+"`n"+"generations to come!"+"`n"
        foreach ($ship in $fleet_ai)
            {
            if ($ship.damaged -eq $false)
                {
                $global:index = 0
                switch ($ship.position)
                    {
                    A1 {$global:index = 0}
                    A2 {$global:index = 1}
                    A3 {$global:index = 2}
                    A4 {$global:index = 3}
                    A5 {$global:index = 4}
                    B1 {$global:index = 5}
                    B2 {$global:index = 6}
                    B3 {$global:index = 7}
                    B4 {$global:index = 8}
                    B5 {$global:index = 9}
                    C1 {$global:index = 10}
                    C2 {$global:index = 11}
                    C3 {$global:index = 12}
                    C4 {$global:index = 13}
                    C5 {$global:index = 14}
                    D1 {$global:index = 15}
                    D2 {$global:index = 16}
                    D3 {$global:index = 17}
                    D4 {$global:index = 18}
                    D5 {$global:index = 19}
                    E1 {$global:index = 20}
                    E2 {$global:index = 21}
                    E3 {$global:index = 22}
                    E4 {$global:index = 23}
                    E5 {$global:index = 24}
                    }
                $global:buttons[$global:index].Image = $img_ship_button
                $global:buttons[$global:index].Text = ""
                }
            }
        $global:willkommen.text = "Thou hast been"+"`n"+"defeated!"
        foreach ($button in $buttons)
            {
            $button.enabled = $false
            }
        gameend
        }
    else
        {
        $differenz_player = ($fleet_player.count - $sunk_player.count)
        if ($differenz_player -eq 1)
            {
            $global:labels[([int]$runde)].Text += "`n"+"Only one ship remains of our once glorious fleet!"+"`n"
            }
        else
            {
            $global:labels[([int]$runde)].Text += "`n"+"There are $differenz_player ships remaining in our formation!"+"`n"
            }
        }
    }
    
#add ships to array $sunk_player
[array]$sunk_player = @()
function AddToSunk_player
    {
    param($ship)
    $global:sunk_player += $ship
    }
# ________   ___  ___   ___   ________        ________   ___     
#|\   ____\ |\  \|\  \ |\  \ |\   __  \      |\   __  \ |\  \    
#\ \  \___|_\ \  \\\  \\ \  \\ \  \|\  \     \ \  \|\  \\ \  \   
# \ \_____  \\ \   __  \\ \  \\ \   ____\     \ \   __  \\ \  \  
#  \|____|\  \\ \  \ \  \\ \  \\ \  \___|      \ \  \ \  \\ \  \ 
#    ____\_\  \\ \__\ \__\\ \__\\ \__\          \ \__\ \__\\ \__\
#   |\_________\\|__|\|__| \|__| \|__|           \|__|\|__| \|__|
#   \|_________|                                                 
  
#Defining the ship classes    
#all ships will be written in these arrays
$fleet_ai = @()
$fleet_player = @()
#define class ShipAI
#attributes: shipnumber, damaged, position, segments
#methods: constructor
class ShipAI {
    #attributes
    [int]$shipnumber #ID number 
    [bool]$damaged
    [string]$position #grid field the ship is on
    [string]$position1
    [string]$position2
    [string]$position3
    [int]$segments #how long is the ship
    #constructorvariations(!)
    ShipAI([int]$shipnumber,[string]$position,[int]$segments)
        {
        $this.damaged = $false
        $this.shipnumber = $shipnumber
        $this.segments = $segments
        $this.position = $position
        $global:grid_ai.set_item($position, $this)
        $global:fleet_ai += $this
        }
    ShipAI([int]$shipnumber,[string]$position,[int]$segments,[string]$position1)
        {
        $this.damaged = $false
        $this.shipnumber = $shipnumber
        $this.segments = $segments
        $this.position = $position
        $this.position1 = $position1
        $global:grid_ai.set_item($position, $this)
        $global:grid_ai.set_item($position1, $this)
        $global:fleet_ai += $this
        }
    ShipAI([int]$shipnumber,[string]$position,[int]$segments,[string]$position1,[string]$position2)
        {
        $this.damaged = $false
        $this.shipnumber = $shipnumber
        $this.segments = $segments
        $this.position = $position
        $this.position1 = $position1
        $this.position2 = $position2
        $global:grid_ai.set_item($position, $this)
        $global:grid_ai.set_item($position1, $this)
        $global:grid_ai.set_item($position2, $this)
        $global:fleet_ai += $this
        }
    ShipAI([int]$shipnumber,[string]$position,[int]$segments,[string]$position1,[string]$position2,[string]$position3)
        {
        $this.damaged = $false
        $this.shipnumber = $shipnumber
        $this.segments = $segments
        $this.position = $position
        $this.position1 = $position1
        $this.position2 = $position2
        $this.position3 = $position3
        $global:grid_ai.set_item($position, $this)
        $global:grid_ai.set_item($position1, $this)
        $global:grid_ai.set_item($position2, $this)
        $global:grid_ai.set_item($position3, $this)
        $global:fleet_ai += $this
        }
    }

#random distribution of 4 AI ships onto the ai grid
#List to select random gridfields
$randomnum =  New-Object System.Collections.ArrayList
foreach ($i in (0..24))
    {
    [void]$randomnum.Add($i)
    }
$temp0 = 0
$temp1 = 0
$temp2 = 0
$temp3 = 0
$check = 0
#AI ship0, 2 segments
$segmentsnum = 2
do 
    {
    do 
        {
    $temp0 = Get-Random -InputObject $randomnum
        }
        while ($temp0 -eq 24) #cannot put starting point of 2 segment ship in the bottom right corner
    if ($randomnum.Contains($temp0+5) -and ($coordinates[$temp0][1] -match $coordinates[$temp0+5][1]))
        {
        $temp1 = $temp0+5
        $check = 1
        }
    elseif ($randomnum.Contains($temp0+1) -and (($coordinates[$temp0][0]) -match ($coordinates[$temp0+1][0])))
        {
        $temp1 = $temp0+1
        $check = 1
        }
    }
    until ($check = 1)
$daten_temp0 = $coordinates[$temp0]
$daten_temp1 = $coordinates[$temp1]
$ship_ai0 = [ShipAI]::new(1,$daten_temp0,$segmentsnum,$daten_temp1)
$randomnum.Remove($temp0)
$randomnum.Remove($Temp1)
#AI ship1, 2 segments
$segmentsnum = 2
do 
    {
    do 
        {
    $temp0 = Get-Random -InputObject $randomnum
        }
        while ($temp0 -eq 24) #cannot put starting point of 2 segment ship in the bottom right corner
    if ($randomnum.Contains($temp0+1) -and (($coordinates[$temp0][0]) -match ($coordinates[$temp0+1][0])))
        {
        $temp1 = $temp0+1
        $check = 1
        }
    elseif ($randomnum.Contains($temp0+5) -and ($coordinates[$temp0][1] -match $coordinates[$temp0+5][1]))
        {
        $temp1 = $temp0+5
        $check = 1
        }
    }
    until ($check = 1)
$daten_temp0 = $coordinates[$temp0]
$daten_temp1 = $coordinates[$temp1]
$ship_ai1 = [ShipAI]::new(1,$daten_temp0,$segmentsnum,$daten_temp1)
$randomnum.Remove($temp0)
$randomnum.Remove($Temp1)
$segmentsnum++
#AI ship2, 3 segments
$check = 0
$segmentsnum = 3
do 
    {
    do
        {
        $temp0 = Get-Random -InputObject $randomnum
        }
        while ($temp0 -in (18,19,23,24)) #cannot put starting point of 3 segment ship in the 4 bottom right fields
    if ($randomnum.Contains($temp0+1) -and $randomnum.Contains($temp0+2) -and ($coordinates[$temp0][0] -match $coordinates[$temp0+1][0]) -and ($coordinates[$temp0][0] -match $coordinates[$temp0+2][0]))
        {
        $temp1 = $temp0+1
        $temp2 = $temp0+2
        $check = 1
        }
    elseif ($randomnum.Contains($temp0+5) -and $randomnum.Contains($temp0+10) -and ($coordinates[$temp0][1] -match $coordinates[$temp0+5][1]) -and ($coordinates[$temp0][1] -match $coordinates[$temp0+10][1]))
        {
        $temp1 = $temp0+5
        $temp2 = $temp0+10
        $check = 1
        }
    }
    until ($check -eq 1)
$daten_temp0 = $coordinates[$temp0]
$daten_temp1 = $coordinates[$temp1]
$daten_temp2 = $coordinates[$temp2]
$ship_ai2 = [ShipAI]::new(2,$daten_temp0,$segmentsnum,$daten_temp1,$daten_temp2)
$randomnum.Remove($temp0)
$randomnum.Remove($Temp1)
$randomnum.Remove($Temp2)
#AI ship3, 4 segments
$check = 0
$segmentsnum = 4
do 
    {
    do
        {
        $temp0 = Get-Random -InputObject $randomnum
        }
        while ($temp0 -in (12,13,14,17,18,19,22,23,24)) #cannot put  4 segment ship starting point the 9 bottom right fields
    if ($randomnum.Contains($temp0+1) -and $randomnum.Contains($temp0+2) -and $randomnum.Contains($temp0+3) -and ($coordinates[$temp0][0] -match $coordinates[$temp0+1][0]) -and ($coordinates[$temp0][0] -match $coordinates[$temp0+2][0]) -and ($coordinates[$temp0][0] -match $coordinates[$temp0+3][0]))
        {
        $temp1 = $temp0+1
        $temp2 = $temp0+2
        $temp3 = $temp0+3
        $check = 1
        }
    elseif ($randomnum.Contains($temp0+5) -and $randomnum.Contains($temp0+10) -and $randomnum.Contains($temp0+15) -and ($coordinates[$temp0][1] -match $coordinates[$temp0+5][1]) -and ($coordinates[$temp0][1] -match $coordinates[$temp0+10][1]) -and ($coordinates[$temp0][1] -match $coordinates[$temp0+15][1]))
        {
        $temp1 = $temp0+5
        $temp2 = $temp0+10
        $temp3 = $temp0+15
        $check = 1
        }
    }
    until ($check -eq 1)
$daten_temp0 = $coordinates[$temp0]
$daten_temp1 = $coordinates[$temp1]
$daten_temp2 = $coordinates[$temp2]
$daten_temp3 = $coordinates[$temp3]
$ship_ai3 = [ShipAI]::new(3,$daten_temp0,$segmentsnum,$daten_temp1,$daten_temp2,$daten_temp3)
$randomnum.Remove($temp0)
$randomnum.Remove($Temp1)
$randomnum.Remove($Temp2)
$randomnum.Remove($temp3)

# ________   ___  ___   ___   ________        ________   ___        ________       ___    ___  _______    ________     
#|\   ____\ |\  \|\  \ |\  \ |\   __  \      |\   __  \ |\  \      |\   __  \     |\  \  / /||\  ___ \  |\   __  \    
#\ \  \___|_\ \  \\\  \\ \  \\ \  \|\  \     \ \  \|\  \\ \  \     \ \  \|\  \    \ \  \/ / /\ \   __/| \ \  \|\  \   
# \ \_____  \\ \   __  \\ \  \\ \   ____\     \ \   ____\\ \  \     \ \   __  \    \ \   / /  \ \  \_|/__\ \   _  _\  
#  \|____|\  \\ \  \ \  \\ \  \\ \  \___|      \ \  \___| \ \  \____ \ \  \ \  \    \/  / /    \ \  \_|\ \\ \  \\  \| 
#    ____\_\  \\ \__\ \__\\ \__\\ \__\          \ \__\     \ \_______\\ \__\ \__\ __/  / /      \ \_______\\ \__\\ _\ 
#   |\_________\\|__|\|__| \|__| \|__|           \|__|      \|_______| \|__|\|__||\___/ /        \|_______| \|__|\|__|
#   \|_________|                                                                 \|___|/                               
                                                                                                                      
class ShipPlayer {
    #attributes
    [int]$shipnumber
    [bool]$damaged
    [string]$position
    [string]$position1
    [string]$position2
    [string]$position3
    [int]$segments
    #constructor
    ShipPlayer([int]$shipnumber,[string]$position,[int]$segments){
        $this.damaged = $false
        $this.shipnumber = $shipnumber
        $this.segments = $segments
        $this.position = $position
        $global:grid_player.set_item($this.position, $this)
        $global:fleet_player += $this
        }
    ShipPlayer([int]$shipnumber,[string]$position,[int]$segments,[string]$position1)
        {
        $this.damaged = $false
        $this.shipnumber = $shipnumber
        $this.segments = $segments
        $this.position = $position
        $this.position1 = $position1
        $global:grid_player.set_item($position, $this)
        $global:grid_player.set_item($position1, $this)
        $global:fleet_player += $this
        }
    ShipPlayer([int]$shipnumber,[string]$position,[int]$segments,[string]$position1,[string]$position2)
        {
        $this.damaged = $false
        $this.shipnumber = $shipnumber
        $this.segments = $segments
        $this.position = $position
        $this.position1 = $position1
        $this.position2 = $position2
        $global:grid_player.set_item($position, $this)
        $global:grid_player.set_item($position1, $this)
        $global:grid_player.set_item($position2, $this)
        $global:fleet_player += $this
        }
    ShipPlayer([int]$shipnumber,[string]$position,[int]$segments,[string]$position1,[string]$position2,[string]$position3)
        {
        $this.damaged = $false
        $this.shipnumber = $shipnumber
        $this.segments = $segments
        $this.position = $position
        $this.position1 = $position1
        $this.position2 = $position2
        $this.position3 = $position3
        $global:grid_player.set_item($position, $this)
        $global:grid_player.set_item($position1, $this)
        $global:grid_player.set_item($position2, $this)
        $global:grid_player.set_item($position3, $this)
        $global:fleet_player += $this
        }
    }
$ship_player0 = $null
$ship_player1 = $null
$ship_player2 = $null
$ship_player3 = $null

# ________   ________   _____ ______    _______           ___       __    ___   ________    ________   ________   ___       __      
#|\   ____\ |\   __  \ |\   _ \  _   \ |\  ___ \         |\  \     |\  \ |\  \ |\   ___  \ |\   ___ \ |\   __  \ |\  \     |\  \    
#\ \  \___| \ \  \|\  \\ \  \\\__\ \  \\ \   __/|        \ \  \    \ \  \\ \  \\ \  \\ \  \\ \  \_|\ \\ \  \|\  \\ \  \    \ \  \   
# \ \  \  ___\ \   __  \\ \  \\|__| \  \\ \  \_|/__       \ \  \  __\ \  \\ \  \\ \  \\ \  \\ \  \ \\ \\ \  \\\  \\ \  \  __\ \  \  
#  \ \  \|\  \\ \  \ \  \\ \  \    \ \  \\ \  \_|\ \       \ \  \|\__\_\  \\ \  \\ \  \\ \  \\ \  \_\\ \\ \  \\\  \\ \  \|\__\_\  \ 
#   \ \_______\\ \__\ \__\\ \__\    \ \__\\ \_______\       \ \____________\\ \__\\ \__\\ \__\\ \_______\\ \_______\\ \____________\
#    \|_______| \|__|\|__| \|__|     \|__| \|_______|        \|____________| \|__| \|__| \|__| \|_______| \|_______| \|____________|

#create the game window
$Form = New-Object "System.Windows.Forms.Form"
$runde = 1
#schrift1
$gegner=New-Object "System.Windows.Forms.Label"
$gegner.Text = "Enemy Sectors"
$gegner.Width = 200
$gegner.Location = New-Object Drawing.Point 130,20
#schrift2
$spieler=New-Object "System.Windows.Forms.Label"
$spieler.Text = "Our Sectors"
$spieler.Width = 200
$spieler.Location = New-Object Drawing.Point 837,20
#schriftmitte
$font = New-Object System.Drawing.Font("Verdana",16,[System.Drawing.Fontstyle]::bold)
$willkommen=New-Object Windows.Forms.Label
$willkommen.Text = ""
$willkommen.Width = 200
$willkommen.Height = 120
$willkommen.AutoSize = $false
$willkommen.TextAlign = "Middlecenter"
$willkommen.font = $font
$willkommen.Location = New-Object Drawing.Point 65,350

#   ______      ______                 ____                __       __                               
#  /\  _  \    /\__  _\               /\  _`\             /\ \__   /\ \__                            
#  \ \ \L\ \   \/_/\ \/               \ \ \L\ \   __  __  \ \ ,_\  \ \ ,_\    ___     ___      ____  
#   \ \  __ \     \ \ \                \ \  _ <' /\ \/\ \  \ \ \/   \ \ \/   / __`\ /' _ `\   /',__\ 
#    \ \ \/\ \     \_\ \__              \ \ \L\ \\ \ \_\ \  \ \ \_   \ \ \_ /\ \L\ \/\ \/\ \ /\__, `\
#     \ \_\ \_\    /\_____\              \ \____/ \ \____/   \ \__\   \ \__\\ \____/\ \_\ \_\\/\____/
#      \/_/\/_/    \/_____/               \/___/   \/___/     \/__/    \/__/ \/___/  \/_/\/_/ \/___/ 

#Buttons:
$buttons = New-Object System.Collections.ArrayList
$buttonnumber = 0
#defines the ai buttons' x-y coordinates
foreach ($i in $coordinates)
    {
    if ($buttonnumber -in (0,5,10,15,20)){$x = 50}
    elseif ($buttonnumber -in (1,6,11,16,21)){$x = 100}
    elseif ($buttonnumber -in (2,7,12,17,22)){$x = 150}
    elseif ($buttonnumber -in (3,8,13,18,23)){$x = 200}
    elseif ($buttonnumber -in (4,9,14,19,24)){$x = 250}
    if ($buttonnumber -in 0,1,2,3,4){$y = 50}
    elseif ($buttonnumber -in 5,6,7,8,9){$y = 100}
    elseif ($buttonnumber -in 10,11,12,13,14){$y = 150}
    elseif ($buttonnumber -in 15,16,17,18,19){$y = 200}
    elseif ($buttonnumber -in 20,21,22,23,24){$y = 250}
    [void]$global:buttons.Add((Set-Variable -Name "$i"))
#adds ai buttons to form
    $global:buttons[$buttonnumber] = New-Object System.Windows.Forms.button
    $global:buttons[$buttonnumber].Location = New-Object Drawing.Point $x,$y
    $global:buttons[$buttonnumber].Width = 40
    $global:buttons[$buttonnumber].Height = 40
    $global:buttons[$buttonnumber].Text = "$i"
    $global:buttons[$buttonnumber].enabled = $false
#what happens when you click on the button -> shoot_at_ai()
    $global:buttons[$buttonnumber].Add_Click(
        {
        Shoot_at_ai -runde $runde -position $this.text
        $global:runde++;
        $global:statusbar.text ="Runde "+$runde
        }
        )
    $global:form.Controls.Add($global:buttons[$buttonnumber])
    $global:buttonnumber++
    }

#   ____        __                                     ____                __       __                               
#  /\  _`\     /\ \         __                        /\  _`\             /\ \__   /\ \__                            
#  \ \,\L\_\   \ \ \___    /\_\    _____              \ \ \L\ \   __  __  \ \ ,_\  \ \ ,_\    ___     ___      ____  
#   \/_\__ \    \ \  _ `\  \/\ \  /\ '__`\             \ \  _ <' /\ \/\ \  \ \ \/   \ \ \/   / __`\ /' _ `\   /',__\ 
#     /\ \L\ \   \ \ \ \ \  \ \ \ \ \ \L\ \             \ \ \L\ \\ \ \_\ \  \ \ \_   \ \ \_ /\ \L\ \/\ \/\ \ /\__, `\
#     \ `\____\   \ \_\ \_\  \ \_\ \ \ ,__/              \ \____/ \ \____/   \ \__\   \ \__\\ \____/\ \_\ \_\\/\____/
#      \/_____/    \/_/\/_/   \/_/  \ \ \/                \/___/   \/___/     \/__/    \/__/ \/___/  \/_/\/_/ \/___/ 
#                                    \ \_\                                                                           
#                                     \/_/  
#set playership buttons
$shipnum = 0
$segmentsnum = 0
$click = 0 #check if a shipbutton has previously been clicked
$HorV = ""
#shipbutton 0
$shipbutton0 = New-Object System.Windows.Forms.button
$shipbutton0.Location = New-Object Drawing.Point 750,350
$shipbutton0.Width = 140
$shipbutton0.Height = 40
$shipbutton0.Text = "Battleship"
$shipbutton0.enabled = $true
#what happens when you click on the button
$shipbutton0.Add_Click(
    {
    if ($click -eq 0)
        {
        $global:click = 1
        $global:segmentsnum = 3
        $global:shipnum = 0
        $shipbutton0.Visible = $false
        $button_vertical.visible = $true
        $button_horizontal.Visible = $true
        $button_back.Visible = $true
        $button_vertical.Location = New-Object Drawing.Point 750,350
        $button_horizontal.Location = New-Object Drawing.Point 850,350
        $button_back.Location = New-Object Drawing.Point 950,350
        }
    }
    )
$global:form.Controls.Add($shipbutton0)

#shipbutton 1
$shipbutton1 = New-Object System.Windows.Forms.button
$shipbutton1.Location = New-Object Drawing.Point 750,400
$shipbutton1.Width = 90
$shipbutton1.Height = 40
$shipbutton1.Text = "Submarine"
$shipbutton1.enabled = $true
#what happens when you click on the button
$shipbutton1.Add_Click(
    {
    if ($click -eq 0)
        {
        $global:click = 1
        $global:segmentsnum = 2
        $global:shipnum = 1
        $shipbutton1.Visible = $false    
        $button_vertical.visible = $true
        $button_horizontal.Visible = $true
        $button_back.Visible = $true
        $button_vertical.Location = New-Object Drawing.Point 750,400
        $button_horizontal.Location = New-Object Drawing.Point 850,400
        $button_back.Location = New-Object Drawing.Point 950,400
        }
    }
    )
$global:form.Controls.Add($shipbutton1)

#shipbutton 2
$shipbutton2 = New-Object System.Windows.Forms.button
$shipbutton2.Location = New-Object Drawing.Point 750,450
$shipbutton2.Width = 90
$shipbutton2.Height = 40
$shipbutton2.Text = "Destroyer"
$shipbutton2.enabled = $true
#what happens when you click on the button
$shipbutton2.Add_Click(
    {
    if ($click -eq 0)
        {
        $global:click = 1
        $global:segmentsnum = 2
        $global:shipnum = 2
        $shipbutton2.Visible = $false
        $button_vertical.visible = $true
        $button_horizontal.Visible = $true
        $button_back.Visible = $true
        $button_vertical.Location = New-Object Drawing.Point 750,450
        $button_horizontal.Location = New-Object Drawing.Point 850,450
        $button_back.Location = New-Object Drawing.Point 950,450
        }
    }
    )
$global:form.Controls.Add($shipbutton2)

#shipbutton 3
$shipbutton3 = New-Object System.Windows.Forms.button
$shipbutton3.Location = New-Object Drawing.Point 750,300
$shipbutton3.Width = 190
$shipbutton3.Height = 40
$shipbutton3.Text = "Aircraft Carrier"
$shipbutton3.enabled = $true
#what happens when you click on the ship button
$shipbutton3.Add_Click(
    {
    if ($click -eq 0)
        {
        $global:click = 1
        $global:segmentsnum = 4
        $global:shipnum = 3
        $shipbutton3.Visible = $false
        $button_vertical.visible = $true
        $button_horizontal.Visible = $true
        $button_back.Visible = $true
        $button_vertical.Location = New-Object Drawing.Point 750,300
        $button_horizontal.Location = New-Object Drawing.Point 850,300
        $button_back.Location = New-Object Drawing.Point 950,300
        }
    }
    )
$global:form.Controls.Add($shipbutton3)

#vertical horizontal and back buttons
#vertical
$button_vertical= New-Object System.Windows.Forms.button
$button_vertical.Location = New-Object Drawing.Point 750,300
$button_vertical.Width = 90
$button_vertical.Height = 40
$button_vertical.Text = "Vertical"
$button_vertical.Visible = $false
$button_vertical.Add_Click(
    {
    $global:HorV = "V"
    $button_vertical.enabled = $false
    $button_horizontal.enabled = $false
    #activate the buttons where you can put a ship of certain length, determined by the $shipnum written on ShipClick
    switch ($shipnum)
        {
        0 #3 fields
            {  
            foreach ($i in (0..14))
                {
                if ($buttons_player[$i].Text -ne "")
                    {
                    $buttons_player[$i].enabled = $true
                    }
                elseif ($buttons_player[$i].Text -eq "")
                    {
                    $buttons_player[$i].enabled = $false
                    if ($i-5 -ge 0) {$buttons_player[$i-5].enabled = $false}
                    if ($i-10 -ge 0) {$buttons_player[$i-10].enabled = $false}
                    }
                }
            foreach ($i in (15..24))
                {
                if ($buttons_player[$i].Text -eq "")
                    {
                    $buttons_player[$i].enabled = $false
                    if ($i-5 -ge 0) {$buttons_player[$i-5].enabled = $false}
                    if ($i-10 -ge 0) {$buttons_player[$i-10].enabled = $false}
                    }
                }
            }
        1 #2 fields
            {  
            foreach ($i in (0..19))
                {
                if ($buttons_player[$i].Text -ne "")
                    {
                    $buttons_player[$i].enabled = $true
                    }
                elseif ($buttons_player[$i].Text -eq "")
                    {
                    $buttons_player[$i].enabled = $false
                    if ($i-5 -ge 0) {$buttons_player[$i-5].enabled = $false}
                    }
                }
            foreach ($i in (20..24))
                {
                if ($buttons_player[$i].Text -eq "")
                    {
                    $buttons_player[$i].enabled = $false
                    if ($i-5 -ge 0) {$buttons_player[$i-5].enabled = $false}
                    }
                }
            }
        2 #2 fields
            {  
            foreach ($i in (0..19))
                {
                if ($buttons_player[$i].Text -ne "")
                    {
                    $buttons_player[$i].enabled = $true
                    }
                elseif ($buttons_player[$i].Text -eq "")
                    {
                    $buttons_player[$i].enabled = $false
                    if ($i-5 -ge 0) {$buttons_player[$i-5].enabled = $false}
                    }
                }
            foreach ($i in (20..24))
                {
                if ($buttons_player[$i].Text -eq "")
                    {
                    $buttons_player[$i].enabled = $false
                    if ($i-5 -ge 0) {$buttons_player[$i-5].enabled = $false}
                    }
                }
            }
        3 #4 fields
            {  
            foreach ($i in (0..9))
                {
                if ($buttons_player[$i].Text -ne "")
                    {
                    $buttons_player[$i].enabled = $true
                    }
                elseif ($buttons_player[$i].Text -eq "")
                    {
                    $buttons_player[$i].enabled = $false
                    if ($i-5 -ge 0) {$buttons_player[$i-5].enabled = $false}
                    if ($i-10 -ge 0) {$buttons_player[$i-5].enabled = $false}
                    if ($i-15 -ge 0) {$buttons_player[$i-5].enabled = $false}
                    }
                }
            foreach ($i in (10..24))
                {
                if ($buttons_player[$i].Text -eq "")
                    {
                    $buttons_player[$i].enabled = $false
                    if ($i-5 -ge 0) {$buttons_player[$i-5].enabled = $false}
                    if ($i-10 -ge 0) {$buttons_player[$i-5].enabled = $false}
                    if ($i-15 -ge 0) {$buttons_player[$i-5].enabled = $false}
                    }
                }
            }
        }
    }
    )
$global:form.Controls.Add($button_vertical)
#horizontal
$button_horizontal= New-Object System.Windows.Forms.button
$button_horizontal.Location = New-Object Drawing.Point 850,300
$button_horizontal.Width = 90
$button_horizontal.Height = 40
$button_horizontal.Text = "Horizontal"
$button_horizontal.Visible = $false
$button_horizontal.Add_Click(
    {
    $global:HorV = "H"
    $button_vertical.enabled = $false
    $button_horizontal.enabled = $false
    #activate the buttons where you can put a ship of certain length, determined by the $shipnum written on ShipClick
    switch ($shipnum)
        {
        0 #3 fields
            {  
            foreach ($i in (0,1,2,5,6,7,10,11,12,15,16,17,20,21,22))
                {
                if ($buttons_player[$i].Text -ne "" -and $buttons_player[$i+1].Text -ne "" -and $buttons_player[$i+2].Text -ne "")
                    {
                    $buttons_player[$i].enabled = $true
                    }
                }
            }
        1 #2 fields
            {  
            foreach ($i in (0,1,2,3,5,6,7,8,10,11,12,13,15,16,17,18,20,21,22,23))
                {
                if ($buttons_player[$i].Text -ne "" -and $buttons_player[$i+1].Text -ne "")
                    {
                    $buttons_player[$i].enabled = $true
                    }
                }
            }
        2 #2 fields
            {  
            foreach ($i in (0,1,2,3,5,6,7,8,10,11,12,13,15,16,17,18,20,21,22,23))
                {
                if ($buttons_player[$i].Text -ne "" -and $buttons_player[$i+1].Text -ne "")
                    {
                    $buttons_player[$i].enabled = $true
                    }
                }
            }
        3 #4 fields
            {  
            foreach ($i in (0,1,5,6,10,11,15,16,20,21))
                {
                if ($buttons_player[$i].Text -ne "" -and $buttons_player[$i+1].Text -ne "" -and $buttons_player[$i+2].Text -ne "" -and $buttons_player[$i+3].Text -ne "")
                    {
                    $buttons_player[$i].enabled = $true
                    }
                }
            }
        }
    }
    )
$global:form.Controls.Add($button_horizontal)
#back
$button_back= New-Object System.Windows.Forms.button
$button_back.Location = New-Object Drawing.Point 950,300
$button_back.Width = 40
$button_back.Height = 40
$button_back.Text = "Back"
$button_back.Visible = $false
$button_back.Add_Click(
    {
    if ($shipnum -eq 3)
        {
        $shipbutton3.Visible = $true
        }
    if ($shipnum -eq 2)
        {
        $shipbutton2.Visible = $true
        }
    if ($shipnum -eq 1)
        {
        $shipbutton1.Visible = $true
        }
    if ($shipnum -eq 0)
        {
        $shipbutton0.Visible = $true
        }
    $global:click = 0
    $button_vertical.enabled = $true
    $button_horizontal.enabled = $true
    $button_vertical.visible = $false
    $button_horizontal.Visible = $false
    $button_back.Visible = $false
    foreach ($button in $buttons_player)
        {
        $button.enabled = $false
        }
    switch ($shipnum)
        {
        0 {$shipbutton0.Enabled = $true}
        1 {$shipbutton1.Enabled = $true}
        2 {$shipbutton2.Enabled = $true}
        3 {$shipbutton3.Enabled = $true}
        }
    }
    )
$global:form.Controls.Add($button_back)
#   ____     ___                                                      ____                __       __                               
#  /\  _`\  /\_ \                                                    /\  _`\             /\ \__   /\ \__                            
#  \ \ \L\ \\//\ \       __      __  __       __    _ __             \ \ \L\ \   __  __  \ \ ,_\  \ \ ,_\    ___     ___      ____  
#   \ \ ,__/  \ \ \    /'__`\   /\ \/\ \    /'__`\ /\`'__\            \ \  _ <' /\ \/\ \  \ \ \/   \ \ \/   / __`\ /' _ `\   /',__\ 
#    \ \ \/    \_\ \_ /\ \L\.\_ \ \ \_\ \  /\  __/ \ \ \/              \ \ \L\ \\ \ \_\ \  \ \ \_   \ \ \_ /\ \L\ \/\ \/\ \ /\__, `\
#     \ \_\    /\____\\ \__/.\_\ \/`____ \ \ \____\ \ \_\               \ \____/ \ \____/   \ \__\   \ \__\\ \____/\ \_\ \_\\/\____/
#      \/_/    \/____/ \/__/\/_/  `/___/> \ \/____/  \/_/                \/___/   \/___/     \/__/    \/__/ \/___/  \/_/\/_/ \/___/ 
#                                    /\___/                                                                                         
#                                    \/__/         
#add player buttons
$buttonnumber = 0
$buttons_player = New-Object System.Collections.ArrayList
$playerShipCounter = 0
$playershipnum = 0
$segmentsnum = 0
$playerbool = $false
#defines the player buttons' x-y coordinates
foreach ($i in $coordinates)
    {
    if ($buttonnumber -in (0,5,10,15,20)){$x = 750}
    elseif ($buttonnumber -in (1,6,11,16,21)){$x = 800}
    elseif ($buttonnumber -in (2,7,12,17,22)){$x = 850}
    elseif ($buttonnumber -in (3,8,13,18,23)){$x = 900}
    elseif ($buttonnumber -in (4,9,14,19,24)){$x = 950}
    if ($buttonnumber -in 0,1,2,3,4){$y = 50}
    elseif ($buttonnumber -in 5,6,7,8,9){$y = 100}
    elseif ($buttonnumber -in 10,11,12,13,14){$y = 150}
    elseif ($buttonnumber -in 15,16,17,18,19){$y = 200}
    elseif ($buttonnumber -in 20,21,22,23,24){$y = 250}
    [void]$global:buttons_player.Add((Set-Variable -Name "$i"))
#adds playerbuttons to form
    $global:buttons_player[$buttonnumber] = New-Object System.Windows.Forms.button
    $global:buttons_player[$buttonnumber].Location = New-Object Drawing.Point $x,$y
    $global:buttons_player[$buttonnumber].Width = 40
    $global:buttons_player[$buttonnumber].Height = 40
    $global:buttons_player[$buttonnumber].Text = "$i"
    $global:buttons_player[$buttonnumber].enabled = $false
#what happens when you click on the playerbutton:
#add a player ship
    $global:buttons_player[$buttonnumber].Add_Click(
        {
         switch ($this.Text)
                    {
                    A1 {$index = 0}
                    A2 {$index = 1}
                    A3 {$index = 2}
                    A4 {$index = 3}
                    A5 {$index = 4}
                    B1 {$index = 5}
                    B2 {$index = 6}
                    B3 {$index = 7}
                    B4 {$index = 8}
                    B5 {$index = 9}
                    C1 {$index = 10}
                    C2 {$index = 11}
                    C3 {$index = 12}
                    C4 {$index = 13}
                    C5 {$index = 14}
                    D1 {$index = 15}
                    D2 {$index = 16}
                    D3 {$index = 17}
                    D4 {$index = 18}
                    D5 {$index = 19}
                    E1 {$index = 20}
                    E2 {$index = 21}
                    E3 {$index = 22}
                    E4 {$index = 23}
                    E5 {$index = 24}
                    }
        switch ($shipnum)
            {
            0 
                {
                if ($HorV -eq "H")
                    {
                    $global:ship_player0 = [ShipPlayer]::new(0,$coordinates[$index],3,$coordinates[$index+1],$coordinates[$index+2])
                    $buttons_player[$index].Text = ""
                    $buttons_player[$index+1].Text = ""
                    $buttons_player[$index+2].Text = ""
                    $buttons_player[$index].image = $img_ship_button
                    $buttons_player[$index+1].image = $img_ship_button
                    $buttons_player[$index+2].image = $img_ship_button
                    }
                elseif ($HorV -eq "V")
                    {
                    $global:ship_player0 = [ShipPlayer]::new(0,$coordinates[$index],3,$coordinates[$index+5],$coordinates[$index+10])
                    $buttons_player[$index].Text = ""
                    $buttons_player[$index+5].Text = ""
                    $buttons_player[$index+10].Text = ""
                    $buttons_player[$index].image = $img_ship_button
                    $buttons_player[$index+5].image = $img_ship_button
                    $buttons_player[$index+10].image = $img_ship_button
                    }
                }
            1
                {
                if ($HorV -eq "H")
                    {
                    $global:ship_player1 = [ShipPlayer]::new(1,$coordinates[$index],2,$coordinates[$index+1])
                    $buttons_player[$index].Text = ""
                    $buttons_player[$index+1].Text = ""
                    $buttons_player[$index].image = $img_ship_button
                    $buttons_player[$index+1].image = $img_ship_button
                    }
                elseif ($HorV -eq "V")
                    {
                    $global:ship_player1 = [ShipPlayer]::new(1,$coordinates[$index],2,$coordinates[$index+5])
                    $buttons_player[$index].Text = ""
                    $buttons_player[$index+5].Text = ""
                    $buttons_player[$index].image = $img_ship_button
                    $buttons_player[$index+5].image = $img_ship_button
                    }
                }
            2
                {
                if ($HorV -eq "H")
                    {
                    $global:ship_player2 = [ShipPlayer]::new(2,$coordinates[$index],2,$coordinates[$index+1])
                    $buttons_player[$index].Text = ""
                    $buttons_player[$index+1].Text = ""
                    $buttons_player[$index].image = $img_ship_button
                    $buttons_player[$index+1].image = $img_ship_button
                    }
                elseif ($HorV -eq "V")
                    {
                    $global:ship_player2 = [ShipPlayer]::new(2,$coordinates[$index],2,$coordinates[$index+5])
                    $buttons_player[$index].Text = ""
                    $buttons_player[$index+5].Text = ""
                    $buttons_player[$index].image = $img_ship_button
                    $buttons_player[$index+5].image = $img_ship_button
                    }
                }
            3
                {
                if ($HorV -eq "H")
                    {
                    $global:ship_player3 = [ShipPlayer]::new(3,$coordinates[$index],4,$coordinates[$index+1],$coordinates[$index+2],$coordinates[$index+3])
                    $buttons_player[$index].Text = ""
                    $buttons_player[$index+1].Text = ""
                    $buttons_player[$index+2].Text = ""
                    $buttons_player[$index+3].Text = ""
                    $buttons_player[$index].image = $img_ship_button
                    $buttons_player[$index+1].image = $img_ship_button
                    $buttons_player[$index+2].image = $img_ship_button
                    $buttons_player[$index+3].image = $img_ship_button
                    }
                elseif ($HorV -eq "V")
                    {
                    $global:ship_player3 = [ShipPlayer]::new(3,$coordinates[$index],4,$coordinates[$index+5],$coordinates[$index+10],$coordinates[$index+15])
                    $buttons_player[$index].Text = ""
                    $buttons_player[$index+5].Text = ""
                    $buttons_player[$index+10].Text = ""
                    $buttons_player[$index+15].Text = ""
                    $buttons_player[$index].image = $img_ship_button
                    $buttons_player[$index+5].image = $img_ship_button
                    $buttons_player[$index+10].image = $img_ship_button
                    $buttons_player[$index+15].image = $img_ship_button
                    }
                }
            }
        foreach ($button in $buttons_player)
            {
            $button.enabled = $false
            }
        switch ($shipnum)
            {
        0 {$shipbutton0.Enabled = $false; $shipbutton0.Visible = $true}
        1 {$shipbutton1.Enabled = $false; $shipbutton1.Visible = $true}
        2 {$shipbutton2.Enabled = $false; $shipbutton2.Visible = $true}
        3 {$shipbutton3.Enabled = $false; $shipbutton3.Visible = $true}
            }
        $button_vertical.enabled = $true
        $button_horizontal.enabled = $true
        $button_vertical.visible = $false
        $button_horizontal.Visible = $false
        $button_back.Visible = $false
        $global:click = 0
        $global:playershipcounter++
        if ($playerShipCounter -eq 4)
            {
            $shipbutton0.Visible = $false
            $shipbutton1.Visible = $false
            $shipbutton2.Visible = $false
            $shipbutton3.Visible = $false
            $forfeit.Visible = $true
            foreach ($button in $buttons)
                {
                $button.enabled = $true
                }
            }
        }
        )
#adds the button to the form
    $global:form.Controls.Add($global:buttons_player[$buttonnumber])
    $global:buttonnumber++
    }
#                                                    __      __                      __                          
#   /'\_/`\               __                        /\ \  __/\ \    __              /\ \                         
#  /\  \   \      __     /\_\     ___               \ \ \/\ \ \ \  /\_\     ___     \_\ \     ___    __  __  __  
#  \ \ \__\ \   /'__`\   \/\ \  /' _ `\              \ \ \ \ \ \ \ \/\ \  /' _ `\   /'_` \   / __`\ /\ \/\ \/\ \ 
#   \ \ \_/\ \ /\ \L\.\_  \ \ \ /\ \/\ \              \ \ \_/ \_\ \ \ \ \ /\ \/\ \ /\ \L\ \ /\ \L\ \\ \ \_/ \_/ \
#    \ \_\\ \_\\ \__/.\_\  \ \_\\ \_\ \_\              \ `\___x___/  \ \_\\ \_\ \_\\ \___,_\\ \____/ \ \___x___/'
#     \/_/ \/_/ \/__/\/_/   \/_/ \/_/\/_/               '\/__//__/    \/_/ \/_/\/_/ \/__,_ / \/___/   \/__//__/  
#
#main window:
$form.TopMost = $true
$form.Controls.Add($gegner)
$form.Controls.Add($willkommen)
$form.Controls.Add($spieler)
$Form.Text = "Battleship"
$Form.Height = 600
$Form.Width = 1066
$Form.FormBorderStyle = "Fixed3D"
$form.maximizebox = $false
$form.MinimizeBox = $false
$form.StartPosition = "CenterScreen"
$form.KeyPreview = $true
$Form.Add_KeyDown(
    {
    if ($_.KeyCode -eq "Escape") 
        {
        $Form.Close()
        }
    if ($_.KeyCode -eq "O") 
        {
        foreach ($i in $fleet_ai)
            {
            $label0.Text += $i.position+$i.position1+$i.position2+$i.position3+"`n"
            }
        }
    }
    )
#add icon
$Icon = New-Object system.drawing.icon (get-item ".\favicon.ico")
$Form.Icon = $Icon
#round number status bar
$statusBar = New-Object System.Windows.Forms.StatusBar
$statusBar.text = "Pregame"
$form.controls.add($statusBar)
#   __  __                           __                   __       ___                        
#  /\ \/\ \                         /\ \                 /\ \__   /\_ \                       
#  \ \ \/'/'     ___     ___ ___    \ \ \____     __     \ \ ,_\  \//\ \      ___      __     
#   \ \ , <     / __`\ /' __` __`\   \ \ '__`\  /'__`\    \ \ \/    \ \ \    / __`\  /'_ `\   
#    \ \ \\`\  /\ \L\ \/\ \/\ \/\ \   \ \ \L\ \/\ \L\.\_   \ \ \_    \_\ \_ /\ \L\ \/\ \L\ \  
#     \ \_\ \_\\ \____/\ \_\ \_\ \_\   \ \_,__/\ \__/.\_\   \ \__\   /\____\\ \____/\ \____ \ 
#      \/_/\/_/ \/___/  \/_/\/_/\/_/    \/___/  \/__/\/_/    \/__/   \/____/ \/___/  \/___L\ \
#                                                                                      /\____/
#                                                                                      \_/__/ 
#tabcontrol
$tabControl = New-Object System.Windows.Forms.TabControl
$tabControl.TabIndex = 0
$tabControl.Height = 450
$tabControl.Width = 350
$tabcontrol.Location = New-Object Drawing.Point 350,50
$tabControl.Name = "tabControl"
$tabControl.SelectedIndex = 0
$tabControl.Alignment = "Right"
$tabControl.Multiline = $true

#tabpage0
$tabPage0 = New-Object System.Windows.Forms.TabPage
$tabPage0.TabIndex = 0
$tabPage0.UseVisualStyleBackColor = $True
$tabpage0.height = 400
$tabpage0.Width = 300
$tabPage0.Text = "Rules"
$tabPage0.Location = New-Object Drawing.Point 410,130
#label0
$label0 = New-Object Windows.Forms.Label
$label0.Text = "Welcome to Battleship!"+"`n"+"`n"+"Rules:"+"`n"+"`n"+"(1) First to sink all enemy ships wins."+"`n"+"`n"+"(2) A fleet consists of four different ships:"+"`n"+" a) Aircraft Carrier (Length: 4)"+"`n"+" b) Battleship (Length: 3)"+"`n"+" c) Submarine (Length: 2)"+"`n"+" d) Destroyer (Length: 2)"+"`n"+"`n"+"(3) Player shoots first."+"`n"+"`n"+"`n"+"Choose a ship, its orientation and then the coordinate where the ship should be situated!"+"`n"+"The selected coordinate is always the top- and leftmost point of the ship."+"`n"+"`n"+"When you're done placing our fleet, shoot at an enemy sector by clicking on it!"+"`n"+"`n"
$label0.Width = 250
$label0.height = 400
$label0.Location = New-Object Drawing.Point 10,10
$label0.font = $log
$tabPage0.Controls.Add($label0) #adds label0 to tabpage0
[void]$tabs.Add($tabpage0)
[void]$labels.Add($label0)
$tabControl.Controls.Add($tabPage0) #adds tabpage0 to tabcontrol
#   ____                                                        __              __                  __       __                               
#  /\  _`\                                                     /\ \            /\ \                /\ \__   /\ \__                            
#  \ \ \L\_\     __       ___ ___       __      __     ___     \_\ \           \ \ \____   __  __  \ \ ,_\  \ \ ,_\    ___     ___      ____  
#   \ \ \L_L   /'__`\   /' __` __`\   /'__`\  /'__`\ /' _ `\   /'_` \           \ \ '__`\ /\ \/\ \  \ \ \/   \ \ \/   / __`\ /' _ `\   /',__\ 
#    \ \ \/, \/\ \L\.\_ /\ \/\ \/\ \ /\  __/ /\  __/ /\ \/\ \ /\ \L\ \           \ \ \L\ \\ \ \_\ \  \ \ \_   \ \ \_ /\ \L\ \/\ \/\ \ /\__, `\
#     \ \____/\ \__/.\_\\ \_\ \_\ \_\\ \____\\ \____\\ \_\ \_\\ \___,_\           \ \_,__/ \ \____/   \ \__\   \ \__\\ \____/\ \_\ \_\\/\____/
#      \/___/  \/__/\/_/ \/_/\/_/\/_/ \/____/ \/____/ \/_/\/_/ \/__,_ /            \/___/   \/___/     \/__/    \/__/ \/___/  \/_/\/_/ \/___/ 
#                                                                                                                                                
#                                                                                                                                                
#forfeit button
$forfeit = New-Object System.Windows.Forms.button
$forfeit.Location = New-Object Drawing.Point 825,390
$forfeit.Width = 100
$forfeit.Height = 40
$forfeit.Text = "Forfeit"
$forfeit.Add_Click(
    {
    gameend
    }
    )
$forfeit.Visible = $false
$form.Controls.Add($forfeit)
#close and start buttons #end
function gameend()
    {
    foreach ($button in $buttons)
        {
        $button.enabled = $false
        }
    $forfeit.Visible = $false
    $restartbutton = New-Object System.Windows.Forms.Button
    $restartbutton.Location = New-Object Drawing.Point 825,375
    $restartbutton.Width = 100
    $restartbutton.Height = 40
    $restartbutton.Text = "Rematch"
#close window and run script again
    $restartbutton.Add_Click(
        {
        $form.Close()
        $form.Dispose()
        powershell.exe -file '.\schiffeversenken_v2.0.ps1'
        }
        )
    $form.Controls.Add($restartbutton)
    $endbutton = New-Object System.Windows.Forms.button
    $endbutton.Location = New-Object Drawing.Point 825,425
    $endbutton.Width = 100
    $endbutton.Height = 40
    $endbutton.Text = "Quit"
#close window
    $endbutton.Add_Click(
        {
        $form.Close()
        $form.Dispose()
        }
        )
    $form.Controls.Add($endbutton)
    }
#adds tabcontrol to the form
$form.Controls.Add($tabControl)
#shows the complete window:
$Form.ShowDialog()