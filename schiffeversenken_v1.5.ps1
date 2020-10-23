#
# Schiffe Versenken
#
# Grafische Oberfläche hinzugefügt
#
# 4x4, Schiff 1 Feld
#
cls
#changes the working directory to where the script is run from, ensuring that the icons will be found
cd $PSScriptRoot
[void][reflection.assembly]::LoadWithPartialName("System.Windows.Forms")
[void][reflection.assembly]::LoadWithPartialName("System.Drawing")
[System.Windows.Forms.Application]::EnableVisualStyles()

#gamegrids
$grid_player = @{"A1" = $null; "A2" = $null; "A3" = $null; "A4" = $null; "B1" = $null; "B2" = $null; "B3" = $null; "B4" = $null; "C1" = $null; "C2" = $null; "C3" = $null; "C4" = $null; "D1" = $null; "D2" = $null; "D3" = $null; "D4" = $null;}
$grid_ai = @{"A1" = $null; "A2" = $null; "A3" = $null; "A4" = $null; "B1" = $null; "B2" = $null; "B3" = $null; "B4" = $null; "C1" = $null; "C2" = $null; "C3" = $null; "C4" = $null; "D1" = $null; "D2" = $null; "D3" = $null; "D4" = $null;}

#MAIN functions
$coordinates = @("A1", "A2", "A3", "A4", "B1", "B2", "B3", "B4", "C1", "C2", "C3", "C4", "D1", "D2", "D3", "D4")
$shotAt = @()
[bool]$victory = $false
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
function Shoot_at_ai ($position,$runde)
    {
#add tab
    [void]$global:tabs.Add((Set-Variable -Name "tab"+[string]$runde))
    $global:tabs[([int]$runde)] = New-Object System.Windows.Forms.TabPage
    $global:tabs[([int]$runde)].TabIndex = [int]$runde
    $global:tabs[([int]$runde)].UseVisualStyleBackColor = $True
    $global:tabs[([int]$runde)].Height = 200
    $global:tabs[([int]$runde)].Width = 866
    $global:tabs[([int]$runde)].Name = "tabPage"+[string]$runde
    $global:tabs[([int]$runde)].Text = "Runde "+[string]$runde
    $tabControl.SelectedTab = $global:tabs[([int]$runde)]
#add label for this tab
    [void]$global:labels.Add((Set-Variable -Name "label"+[string]$runde))
    $global:labels[([int]$runde)] = New-Object Windows.Forms.Label
    $global:labels[([int]$runde)].Width = 280
    $global:labels[([int]$runde)].height = 300
    $global:labels[([int]$runde)].font = $log
    $global:labels[([int]$runde)].Location = New-Object Drawing.Point 10,10
    $global:tabs[([int]$runde)].Controls.Add($global:labels[([int]$runde)]) #adds label to tabpage
    $tabControl.Controls.Add($global:tabs[([int]$runde)]) #adds tabpage to tabcontrol
    $global:labels[([int]$runde)].Text = "~~~~~~~~~~~~~ DEIN ZUG ~~~~~~~~~~~~~"+"`n"+"`n"
#shoot at ai grid
    if ($grid_ai[$position] -eq $null)
        {
        $this.text = ""
        $this.image = $img_splash_button
        $global:labels[([int]$runde)].Text += "Du schießt auf den Quadranten $position des Gegners!"+"`n"+"Doch der Schuss ging ins Leere!"+"`n"
        }
    else
        {
        foreach ($ship in $fleet_ai)
            {
            if ($ship.position -eq $position)
                {
                $ship.damaged = $true
                $ship.AddToGrid($grid_ai)
                $this.text = ""
                $this.image = $img_sunk_button
                $global:labels[([int]$runde)].Text += "Du schießt auf den Quadranten $position des Gegners!"+"`n"+"Volltreffer! Du hast das gegnerische Schiff auf Position $position versenkt!"+"`n"
                AddToSunk_ai($ship)
                }
            }
        }
    $differenz = ($fleet_ai.count - $sunk_ai.count)
    if ($differenz -eq 0)
        {
        $global:labels[([int]$runde)].Text += "`n"+"`n"+"Du hast alle gegnerischen Schiffe versenkt!"+"`n"
        $global:willkommen.text = "Du hast"+"`n"+"gewonnen!"+"`n"
        foreach ($button in $buttons)
            {
            $button.enabled = $false
            }
        }
    elseif ($differenz -eq 1)
        {
        $global:labels[([int]$runde)].Text += "`n"+"Es gibt noch "+$differenz+" gegnerisches Schiff!"+"`n"
        }
    else
        {
        $global:labels[([int]$runde)].Text += "`n"+"Es gibt noch "+$differenz+" gegnerische Schiffe!"+"`n"
        }
    $this.enabled = $false
    $Form.Controls.Add($this)
    $global:shotat += $position
    Shoot_at_player -runde $runde
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
function Shoot_at_player($runde)
    {
    if ($sunk_ai.count -lt 3)
    {
    $global:labels[([int]$runde)].Text += "`n"+"~~~~~~~ SPIELZUG DES GEGNERS ~~~~~~~"+"`n"+"`n"
    $position = Get-Random -InputObject $coordinates_ai
    $coordinates_ai.Remove($position)
    if ($coordinates_ai.Count -eq 0)
        {
        $global:labels[([int]$runde)].Text +=  "Ich habe schon auf alle deine Felder geschossen!"
        $position = ""
        }
    if ($position -eq "")
        {

        }
    else
        {
        $global:labels[([int]$runde)].Text += "Der Computer hat auf deinen Quadranten $position geschossen!"+"`n"
        }
    if($grid_player[$position] -eq $null)
        {
        if ($position -eq "")
            {

            }
        else
            {
            $global:labels[([int]$runde)].Text +=  "Das traf jedoch keines deiner Schiffe!"+"`n"
            switch ($position)
                    {
                    A1 {$index = 0}
                    A2 {$index = 1}
                    A3 {$index = 2}
                    A4 {$index = 3}
                    B1 {$index = 4}
                    B2 {$index = 5}
                    B3 {$index = 6}
                    B4 {$index = 7}
                    C1 {$index = 8}
                    C2 {$index = 9}
                    C3 {$index = 10}
                    C4 {$index = 11}
                    D1 {$index = 12}
                    D2 {$index = 13}
                    D3 {$index = 14}
                    D4 {$index = 15}
                    }
                $buttons_player[$index].Image = $img_splash_button
                $buttons_player[$index].Text = ""
            }
        }
    else
        {
        foreach ($ship in $fleet_player)
            {
            if ($ship.position -eq $position)
                {
                $ship.damaged = $true
                $ship.AddToGrid($grid_player)
                $global:labels[([int]$runde)].Text += "Volltreffer! Der Computer hat dein Schiff auf $position versenkt!"+"`n"
                AddToSunk_player($ship)
                $index = 0
                switch ($position)
                    {
                    A1 {$index = 0}
                    A2 {$index = 1}
                    A3 {$index = 2}
                    A4 {$index = 3}
                    B1 {$index = 4}
                    B2 {$index = 5}
                    B3 {$index = 6}
                    B4 {$index = 7}
                    C1 {$index = 8}
                    C2 {$index = 9}
                    C3 {$index = 10}
                    C4 {$index = 11}
                    D1 {$index = 12}
                    D2 {$index = 13}
                    D3 {$index = 14}
                    D4 {$index = 15}
                    }
                $buttons_player[$index].Image = $img_sunk_button
                $buttons_player[$index].Text = ""
                }
            }
        }
    if ($fleet_player.Count -eq $sunk_player.Count -and $sunk_player.Count -eq 3)
        {
        $global:labels[([int]$runde)].Text += "`n"+"Alle deine Schiffe wurden versenkt"+"`n"+"Viel Glück beim nächsten mal!"+"`n"

        foreach ($ship in $fleet_ai)
            {
            if ($ship.damaged -eq $false)
                {
                $index = 0
                switch ($ship.position)
                    {
                    A1 {$index = 0}
                    A2 {$index = 1}
                    A3 {$index = 2}
                    A4 {$index = 3}
                    B1 {$index = 4}
                    B2 {$index = 5}
                    B3 {$index = 6}
                    B4 {$index = 7}
                    C1 {$index = 8}
                    C2 {$index = 9}
                    C3 {$index = 10}
                    C4 {$index = 11}
                    D1 {$index = 12}
                    D2 {$index = 13}
                    D3 {$index = 14}
                    D4 {$index = 15}
                    }
                $global:buttons[$index].Image = $img_ship_button
                $global:buttons[$index].Text = ""
                }
            }

        $global:willkommen.text = "Du hast verloren!"
        [bool]$global:victory = $false
        foreach ($button in $buttons)
            {
            $button.enabled = $false
            }
        gameend
        }
    else
        {
        $global:labels[([int]$runde)].Text += "Du hast noch "+(($fleet_player.Count) - ($sunk_player.Count))+" Schiff(e)!"+"`n"
        }
    }
    else
    {
    $global:willkommen.text = "Du hast gewonnen!"
    [bool]$global:victory = $true
    gameend
    }
    }
#add ships to array $sunk_player
[array]$sunk_player = @()
function AddToSunk_player
    {
    param($ship)
    $global:sunk_player += $ship
    }

#close and start buttons #end
function gameend()
    {
    $forfeit.Visible = $false
    $restartbutton = New-Object System.Windows.Forms.Button
    $restartbutton.Location = New-Object Drawing.Point 800,325
    $restartbutton.Width = 100
    $restartbutton.Height = 40
    $restartbutton.Text = "Neues Spiel"
#close window and run script again
    $restartbutton.Add_Click(
        {
        $form.Close()
        $form.Dispose()
        powershell.exe -file '.\schiffeversenken_v1.5.ps1'
        }
        )
    $form.Controls.Add($restartbutton)
    $endbutton = New-Object System.Windows.Forms.button
    $endbutton.Location = New-Object Drawing.Point 800,375
    $endbutton.Width = 100
    $endbutton.Height = 40
    $endbutton.Text = "Beenden"
#close window
    $endbutton.Add_Click(
        {
        $form.Close()
        $form.Dispose()
        }
        )
    $form.Controls.Add($endbutton)
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
$coordinates_ai_shipconstructor = New-Object System.Collections.ArrayList
foreach ($i in $coordinates)
    {
    [void]$coordinates_ai_shipconstructor.Add($i)
    }
$daten_ai0 = Get-Random -InputObject $coordinates_ai_shipconstructor 
$ship_ai0 = [ShipAI]::new(0,$daten_ai0,$fleet_ai,$grid_ai)
$coordinates_ai_shipconstructor.Remove($daten_ai0)
$daten_ai1 = Get-Random -InputObject $coordinates_ai_shipconstructor
$ship_ai1 = [ShipAI]::new(1,$daten_ai1,$fleet_ai,$grid_ai)
$coordinates_ai_shipconstructor.Remove($daten_ai1)
$daten_ai2 = Get-Random -InputObject $coordinates_ai_shipconstructor
$ship_ai2 = [ShipAI]::new(2,$daten_ai2,$fleet_ai,$grid_ai)
$coordinates_ai_shipconstructor.Remove($daten_ai2)


#create the game window
$Form = New-Object "System.Windows.Forms.Form"
$runde = 1
#schrift1
$gegner=New-Object "System.Windows.Forms.Label"
$gegner.Text = "Gegnerische Schiffe"
$gegner.Width = 200
$gegner.Location = New-Object Drawing.Point 150,20
#schrift2
$spieler=New-Object "System.Windows.Forms.Label"
$spieler.Text = "Deine Schiffe"
$spieler.Width = 200
$spieler.Location = New-Object Drawing.Point 812,20
#schriftmitte
$font = New-Object System.Drawing.Font("Verdana",20,[System.Drawing.Fontstyle]::bold)
$willkommen=New-Object Windows.Forms.Label
$willkommen.Text = "Platziere"+"`n"+"deine"+"`n"+"Schiffe"+"`n"
$willkommen.Width = 300
$willkommen.Height = 120
$willkommen.AutoSize = $false
$willkommen.TextAlign = "Middlecenter"
$willkommen.font = $font
$willkommen.Location = New-Object Drawing.Point 695,300
#Buttons:
$buttons = New-Object System.Collections.ArrayList
$buttonnumber = 0
#defines the ai buttons' x-y coordinates
foreach ($i in $coordinates)
    {
    if ($buttonnumber -in (0,4,8,12)){$x = 100}
    elseif ($buttonnumber -in (1,5,9,13)){$x = 150}
    elseif ($buttonnumber -in (2,6,10,14)){$x = 200}
    elseif ($buttonnumber -in (3,7,11,15)){$x = 250}
    if ($buttonnumber -in 0,1,2,3){$y = 50}
    elseif ($buttonnumber -in 4,5,6,7){$y = 100}
    elseif ($buttonnumber -in 8,9,10,11){$y = 150}
    elseif ($buttonnumber -in 12,13,14,15){$y = 200}
    [void]$global:buttons.Add((Set-Variable -Name "$i"))
#adds buttons to form
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

#add player buttons
$buttonnumber = 0
$buttons_player = New-Object System.Collections.ArrayList
$playerShipCounter = 0
#defines the player buttons' x-y coordinates
foreach ($i in $coordinates)
    {
    if ($buttonnumber -in (0,4,8,12)){$x = 750}
    elseif ($buttonnumber -in (1,5,9,13)){$x = 800}
    elseif ($buttonnumber -in (2,6,10,14)){$x = 850}
    elseif ($buttonnumber -in (3,7,11,15)){$x = 900}
    if ($buttonnumber -in 0,1,2,3){$y = 50}
    elseif ($buttonnumber -in 4,5,6,7){$y = 100}
    elseif ($buttonnumber -in 8,9,10,11){$y = 150}
    elseif ($buttonnumber -in 12,13,14,15){$y = 200}
    [void]$global:buttons_player.Add((Set-Variable -Name "$i"))
#adds buttons to form
    $global:buttons_player[$buttonnumber] = New-Object System.Windows.Forms.button
    $global:buttons_player[$buttonnumber].Location = New-Object Drawing.Point $x,$y
    $global:buttons_player[$buttonnumber].Width = 40
    $global:buttons_player[$buttonnumber].Height = 40
    $global:buttons_player[$buttonnumber].Text = "$i"
    $global:buttons_player[$buttonnumber].enabled = $true
#what happens when you click on the button
    $global:buttons_player[$buttonnumber].Add_Click(
        {
        $ship0 = [ShipPlayer]::new(0,$this.Text,$fleet_player,$grid_player)
        $this.location
        $global:playerShipCounter++
        $this.text = ""
        $this.image = $img_ship_button
        $this.enabled = $false
        if ($playerShipCounter -eq 3)
            {
            foreach ($button in $buttons_player)
                {
                $button.enabled = $false
                }
            foreach ($button in $buttons)
                {
                $button.enabled = $true
                }
            $global:statusbar.Text = "Runde "+$runde
            $global:willkommen.Location = New-Object Drawing.Point 40,300
            $global:willkommen.Text = "Wähle das Feld, auf das du schießen willst"
            $forfeit.visible = $true
            }
        }
        )
#adds the button to the form
    $global:form.Controls.Add($global:buttons_player[$buttonnumber])
    $global:buttonnumber++
    }
#main window:
$form.TopMost = $true
$form.Controls.Add($gegner); $form.Controls.Add($willkommen);$form.Controls.Add($spieler)
$form.Controls.Add($a1);$form.Controls.Add($a2);$form.Controls.Add($a3);$form.Controls.Add($a4);$form.Controls.Add($b1);$form.Controls.Add($b2);$form.Controls.Add($b3);$form.Controls.Add($b4);$form.Controls.Add($c1);$form.Controls.Add($c2);$form.Controls.Add($c3);$form.Controls.Add($c4);$form.Controls.Add($d1);$form.Controls.Add($d2);$form.Controls.Add($d3);$form.Controls.Add($d4);$Form.Text = "Schiffe versenken"
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
        $label0.Text += $fleet_ai[0].position+$fleet_ai[1].position+$fleet_ai[2].position
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
$tabpage0.height = 300
$tabpage0.Width = 300
$tabPage0.Text = "Regeln"
$tabPage0.Location = New-Object Drawing.Point 410,130
#label0
$label0 = New-Object Windows.Forms.Label
$label0.Text = "Willkommen bei Battleship!"+"`n"+"`n"+"Regeln:"+"`n"+"`n"+"(1) Wer zuerst alle 3 Schiffe des Gegners versenkt, gewinnt."+"`n"+"`n"+"(2) Ein Schiff ist immer genau 1 Feld groß."+"`n"+"`n"+"(3) Der Spieler darf zuerst schießen."+"`n"+"`n"+"`n"+"Beginne damit, deine 3 Schiffe zu platzieren."+"`n"+"`n"
$label0.Width = 250
$label0.height = 300
$label0.Location = New-Object Drawing.Point 10,10
$label0.font = $log
$tabPage0.Controls.Add($label0) #adds label0 to tabpage0
[void]$tabs.Add($tabpage0)
[void]$labels.Add($label0)
$tabControl.Controls.Add($tabPage0) #adds tabpage0 to tabcontrol
#forfeit button
$forfeit = New-Object System.Windows.Forms.button
$forfeit.Location = New-Object Drawing.Point 800,350
$forfeit.Width = 100
$forfeit.Height = 40
$forfeit.Text = "Aufgeben"
$forfeit.Add_Click(
    {
    gameend
    }
    )
$forfeit.Visible = $false
$form.Controls.Add($forfeit)
#adds tabcontrol to the form
$form.Controls.Add($tabControl)
#shows the complete window:
$Form.ShowDialog()