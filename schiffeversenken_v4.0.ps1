#
# Schiffe Versenken v4
#
# changes from v3:
#
# expanded field to 8x8 
# sackarbeit eh
#
cls
#changes the working directory to where the script is run from, ensuring that the icons will be found
Set-Location $PSScriptRoot
[void][reflection.assembly]::LoadWithPartialName("System.Windows.Forms")
[void][reflection.assembly]::LoadWithPartialName("System.Drawing")
[System.Windows.Forms.Application]::EnableVisualStyles()
#gamegrids
$global:coordinates = @("A1", "A2", "A3", "A4", "A5", "A6", "A7", "A8", "B1", "B2", "B3", "B4", "B5", "B6", "B7", "B8", "C1", "C2", "C3", "C4", "C5", "C6", "C7", "C8", "D1", "D2", "D3", "D4", "D5", "D6", "D7", "D8", "E1", "E2", "E3", "E4", "E5", "E6", "E7", "E8", "F1", "F2", "F3", "F4", "F5", "F6", "F7", "F8", "G1", "G2", "G3", "G4", "G5", "G6", "G7", "G8", "H1", "H2", "H3", "H4", "H5", "H6", "H7", "H8")
$global:grid_player = @{}
foreach ($i in $global:coordinates)
    {
    $global:grid_player.Add($i, $null)
    }
$global:grid_ai = @{}
foreach ($i in $global:coordinates)
    {
    $global:grid_ai.Add($i, $null)
    }
#combat log and rules in the window center
$global:tabs = New-Object System.Collections.ArrayList
$global:labels= New-Object System.Collections.ArrayList
$global:ShotAt= New-Object System.Collections.ArrayList
$global:log = New-Object System.Drawing.Font("Lucida Console",9)
#images for the buttons
$global:img_sunk = (get-item ".\sunk.jpg")
$global:img_sunk_button = [system.drawing.image]::FromFile($global:img_sunk)
$global:img_splash = (get-item ".\splash.jpg")
$global:img_splash_button = [system.drawing.image]::FromFile($global:img_splash)
$global:img_ship = (get-item ".\ship.png")
$global:img_ship_button = [system.drawing.image]::FromFile($global:img_ship)

# ________   ___  ___   ________   ________   _________        ________   _________        ________   ___     
#|\   ____\ |\  \|\  \ |\   __  \ |\   __  \ |\___   ___\     |\   __  \ |\___   ___\     |\   __  \ |\  \    
#\ \  \___|_\ \  \\\  \\ \  \|\  \\ \  \|\  \\|___ \  \_|     \ \  \|\  \\|___ \  \_|     \ \  \|\  \\ \  \   
# \ \_____  \\ \   __  \\ \  \\\  \\ \  \\\  \    \ \  \       \ \   __  \    \ \  \       \ \   __  \\ \  \  
#  \|____|\  \\ \  \ \  \\ \  \\\  \\ \  \\\  \    \ \  \       \ \  \ \  \    \ \  \       \ \  \ \  \\ \  \ 
#    ____\_\  \\ \__\ \__\\ \_______\\ \_______\    \ \__\       \ \__\ \__\    \ \__\       \ \__\ \__\\ \__\
#   |\_________\\|__|\|__| \|_______| \|_______|     \|__|        \|__|\|__|     \|__|        \|__|\|__| \|__|
#   \|_________|
#SHOOT AT AI
function Shoot_at_ai ($position,$runde)
    {
    $player_victory = $false
#add tab
    [void]$global:tabs.Add((Set-Variable -Name ("tab"+[string]$global:runde)))
    $global:tabs[([int]$global:runde)] = New-Object System.Windows.Forms.TabPage
    $global:tabs[([int]$global:runde)].TabIndex = [int]$global:runde
    $global:tabs[([int]$global:runde)].UseVisualStyleBackColor = $True
    $global:tabs[([int]$global:runde)].Height = 600
    $global:tabs[([int]$global:runde)].Width = 270
    $global:tabs[([int]$global:runde)].Name = "tabPage"+[string]$global:runde
    $global:tabs[([int]$global:runde)].Text = "Round "+[string]$global:runde
    $tabControl.SelectedTab = $global:tabs[([int]$global:runde)]
#add label for this tab
    [void]$global:labels.Add((Set-Variable -Name ("label"+[string]$global:runde)))
    $global:labels[([int]$global:runde)] = New-Object Windows.Forms.Label
    $global:labels[([int]$global:runde)].Width = 190
    $global:labels[([int]$global:runde)].height = 600
    $global:labels[([int]$global:runde)].font = $log
    $global:labels[([int]$global:runde)].Location = New-Object Drawing.Point 10,10
    $global:tabs[([int]$global:runde)].Controls.Add($global:labels[([int]$global:runde)]) #adds label to tabpage
    $tabControl.Controls.Add($global:tabs[([int]$global:runde)]) #adds tabpage to tabcontrol
    $global:labels[([int]$global:runde)].Text = "~~~~~~ YOUR TURN ~~~~~~"+"`n"+"`n"+"We're shooting at the enemy"+"Sector $position!"+"`n"
#shoot at ai grid
    if ($global:grid_ai[$position] -eq $null) # miss
        {
        $global:welcome.Text = ""
        $global:welcome.Visible = $true
        $this.text = ""
        $this.image = $global:img_splash_button
        $global:labels[([int]$global:runde)].Text += "But the shot hit the waves!"+"`n"
        }
    else # hit
        {
        foreach ($ship in $global:fleet_ai)
            {
            if ($ship.position -eq $position -or $ship.position1 -eq $position -or $ship.position2 -eq $position -or $ship.position3 -eq $position)
                {
                $ship.damaged = $true
                $ship.segments--
                $this.text = ""
                $this.image = $global:img_sunk_button
                if ($ship.segments -eq 0) # SUNK
                    {
                    $global:welcome.Text = "We sunk an enemy Ship!"
                    $global:labels[([int]$global:runde)].Text += "Bullseye! We sunk an enemy ship across the Sectors "+$ship.position+$ship.position1+$ship.position2+$ship.position3+"!"+"`n"
                    AddToSunk_ai($ship)
                    }
                else # DAMAGED
                    {
                    $global:welcome.Text = "Enemy Ship damaged!"
                    $global:labels[([int]$global:runde)].Text += "The shot damaged an enemy ship!"+"`n"
                    }
                }
            }
        }
    $differenz_ai = ($global:fleet_ai.count - $global:sunk_ai.count)
    #checks if all enemy ships have been sunk -> victory
    if ($differenz_ai -eq 0)
        {
        $global:labels[([int]$global:runde)].Text += "`n"+"~~~~~~ VICTORY ~~~~~~"+"`n`n"+"We sunk all enemy ships across these Sectors:"+"`n"
        foreach ($ship in $global:fleet_ai)
            {
            $global:labels[([int]$global:runde)].Text += $ship.position+$ship.position1+$ship.position2+$ship.position3+"`n"
            }
        $global:labels[([int]$global:runde)].Text += "`n"+"The enemy sunk our ships across these Sectors:"+"`n"
        foreach ($ship in $global:fleet_player)
            {
            if ($ship.segments -eq 0)
                {
                $global:labels[([int]$global:runde)].Text += $ship.position+$ship.position1+$ship.position2+$ship.position3+"`n"
                }
            }
        $global:labels[([int]$global:runde)].Text += "`n"+"The enemy damaged our ships across these Sectors:"+"`n"
        foreach ($ship in $global:fleet_player)
            {
            if ($ship.segments -ne 0 -and $ship.damaged -eq $true)
                {
                $global:labels[([int]$global:runde)].Text += $ship.position+$ship.position1+$ship.position2+$ship.position3+"`n"
                }
            }
        $global:labels[([int]$global:runde)].Text += "`n"+"The enemy missed our ships across these Sectors:"+"`n"
        foreach ($ship in $global:fleet_player)
            {
            if ($ship.damaged -eq $false)
                {
                $global:labels[([int]$global:runde)].Text += $ship.position+$ship.position1+$ship.position2+$ship.position3+"`n"
                }
            }
        $global:welcome.text = "Thou art"+"`n"+"victorious!"+"`n"
        foreach ($button in $global:buttons)
            {
            $button.enabled = $false
            }
        gameend
        $player_victory = $true
        }
    elseif ($differenz_ai -eq 1)
        {
        $global:labels[([int]$global:runde)].Text += "`n"+"There is still one enemy ship left!"+"`n"
        }
    else
        {
        $global:labels[([int]$global:runde)].Text += "`n"+"There are still "+$differenz_ai+" enemy ships left!"+"`n"
        }
    $this.enabled = $false
    $global:Form.Controls.Add($this)
    if ($player_victory -eq $false) ##if the player has not won, the AI shoots
        {
        Shoot_at_player -runde $global:runde -hitcounter $global:hitcounter
        }
    }
#add ships to array $sunk_ai
[array]$global:sunk_ai = @()
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
# SHOOT AT PLAYER
$position_ai = ""
$global:hitcounter = 0
$global:index = 0
$global:temp = 0
$global:coordinates_numbers = New-Object System.Collections.ArrayList
foreach ($i in 0..63)
    {
    [void]$global:coordinates_numbers.Add($i)
    }

function ShotsFired ($runde)
    {
    $global:coordinates_numbers.Remove($global:index)
    $global:position_ai = $global:coordinates[$global:index]
    $global:labels[([int]$global:runde)].Text += "The enemy shot at our Sector $global:position_ai!"+"`n"
    #NOTHINGS BEEN HIT:
    if ($global:grid_player[$global:position_ai] -eq $null)
        {
        $global:labels[([int]$global:runde)].Text +=  "But they hit nothing but thin air!"+"`n"
        $global:buttons_player[$global:index].Image = $global:img_splash_button
        $global:buttons_player[$global:index].Text = ""
        # MISS
        switch ($global:hitcounter)
            {
            0 # random shot missed
                {
                $global:hitcounter = 0 #shoot another random field
                } 
            1 # shot to the right missed
                {
                switch ($global:temp) #reset index according to the number of shots hit before the miss occured
                    {
                    0 {$global:index = $global:index - 1}
                    1 {$global:index = $global:index - 2}
                    2 {$global:index = $global:index - 3}
                    3 {$global:index = $global:index - 4}
                    4 {$global:index = $global:index - 5}
                    5 {$global:index = $global:index - 6}
                    6 {$global:index = $global:index - 7}
                    7 {$global:index = $global:index - 8}
                    }
                if ($global:index -eq 0 -and $global:index+8 -notin $ShotAt) # field top left (->can't shoot left or above) AND field below not shot at previously
                    {
                    $global:hitcounter = 4 # shoot below
                    } 
                elseif ($global:index -in (8,16,24,32,40,48,56) -and $global:index-8 -notin $ShotAt) # field on the left and not top row (->can't shoot left) AND field above not shot at previously
                    {
                    $global:hitcounter = 3 # shoot above
                    } 
                elseif  ($global:index -ne 0 -and $global:index-1 -notin $ShotAt) # field leftwise not shot at previously AND index not 0
                    {
                    $global:hitcounter = 2 # shoot left
                    } 
                elseif ($global:index -notin (0..7) -and $global:index-8 -notin $ShotAt) # field not top row AND field above not shot at previously
                    {
                    $global:hitcounter = 3 # shoot above
                    } 
                elseif ($global:index -notin (56..63) -and $global:index+8 -notin $ShotAt) # field not bottom row AND field below not shot at previously
                    {
                    $global:hitcounter = 4 # shoot below
                    } 
                else 
                    {$global:hitcounter = 0} # else shoot random field
                }
            2 # shot to the left missed
                {
                switch ($global:temp) #reset index according to the number of shots hit before the miss occured
                    {
                    0 {$global:index = $global:index + 1}
                    1 {$global:index = $global:index + 2}
                    2 {$global:index = $global:index + 3}
                    3 {$global:index = $global:index + 4}
                    4 {$global:index = $global:index + 5}
                    5 {$global:index = $global:index + 6}
                    6 {$global:index = $global:index + 7}
                    7 {$global:index = $global:index + 8}
                    }
                if ($global:index -notin (0..7) -and $global:index-8 -notin $ShotAt) # field not in top row (->can't shoot above) AND field above not shot at previously
                    {
                    $global:hitcounter = 3 # shoot above
                    } 
                elseif ($global:index -notin (56..63)  -and $global:index+8 -notin $ShotAt) # field not in bottom (->can't shoot below) AND field below not shot at previously
                    {
                    $global:hitcounter = 4 # shoot below
                    } 
                else
                    {$global:hitcounter = 0} # else shoot random field
                }
            3 # shot above missed
                {
                switch ($global:temp) #reset index according to the number of shots hit before the miss occured
                    {
                    0 {$global:index = $global:index + 5}
                    1 {$global:index = $global:index + 10}
                    2 {$global:index = $global:index + 15}
                    3 {$global:index = $global:index + 20}
                    4 {$global:index = $global:index + 25}
                    5 {$global:index = $global:index + 30}
                    6 {$global:index = $global:index + 35}
                    7 {$global:index = $global:index + 40}
                    8 {$global:index = $global:index + 45}
                    }
                if ($global:index -notin (56..63) -and $global:index+8 -notin $ShotAt) # field not bottom row AND field below not shot at previously
                    {
                    $global:hitcounter = 4 # shoot below
                    } 
                else 
                    {
                    $global:hitcounter = 0  # else shoot random field
                    }
                }
            4 # shot below missed
                {
                $global:hitcounter = 0 # shoot random field
                }
            }
        }
    #SOMETHINGS BEEN HIT:
    else 
        {
        foreach ($ship in $global:fleet_player)
            {
            # HIT
            if ($ship.position -eq $global:position_ai -or $ship.position1 -eq $global:position_ai -or $ship.position2 -eq $global:position_ai -or $ship.position3 -eq $global:position_ai)
                {
                $ship.damaged = $true
                $ship.segments--
                $global:buttons_player[$global:index].Image = $global:img_sunk_button
                $global:buttons_player[$global:index].Text = ""
                # SUNK
                if ($ship.segments -eq 0)
                    {
                    $global:labels[([int]$global:runde)].Text += "Bugger! The enemy sunk our ship cross the Sectors "+$ship.position+$ship.position1+$ship.position2+$ship.position3+"!"+"`n"
                    AddToSunk_player($ship)
                    $global:hitcounter = 0
                    }
                # DAMAGED
                else
                    {
                    $global:labels[([int]$global:runde)].Text += "Blimey! The enemy damaged our ship at Sector $global:position_ai!"+"`n"
                    switch ($global:hitcounter)
                        {
                        0 # random shot hit
                            {
                            $global:temp = 0
                            $global:hitcounter = 1 # shoot right
                                                   # change target if
                            if ($global:index -in (7,15,23,31,39,47,55,63)) # field is right column
                                {
                                if($global:index-1 -notin $ShotAt) # left field not shot at
                                    {
                                    $global:hitcounter = 2 # shoot left
                                    }
                                elseif ($global:index-8 -notin $ShotAt -and $global:index -notin (0..7)) # field above not shot at AND index not top row
                                    {
                                    $global:hitcounter = 3 # shoot above
                                    }
                                elseif ($global:index+8 -notin $ShotAt -and $global:index -notin (56..63)) # field below not shot at AND index not bottom row
                                    {
                                    $global:hitcounter = 4 # shoot below
                                    }
                                else
                                    {
                                    $global:hitcounter = 0 # else shoot random
                                    }
                                }
                            elseif ($global:index -in (0,8,16,24,32,40,48,56)) # field is left column
                                {
                                if ($global:index+1 -notin $ShotAt) # right field not shot at
                                    {
                                    $global:hitcounter = 1
                                    }
                                elseif ($global:index -ne 0 -and $global:index-8 -notin $ShotAt) # field above not shot at AND index not top row
                                    {
                                    $global:hitcounter = 3 # shoot above
                                    }
                                elseif ($global:index -ne 56 -and $global:index+8 -notin $ShotAt) # field below not shot AND index not bottom row
                                    {
                                    $global:hitcounter = 4 # shoot below
                                    }
                                }
                            else # field not left or right column
                                {
                                if ($global:index+1 -notin $ShotAt) # field to the right not shot at
                                    {
                                    $global:hitcounter = 1 # shoot right
                                    }
                                elseif ($global:index-1 -notin $ShotAt) # field to the left not shot at
                                    {
                                    $global:hitcounter = 2 # shoot left
                                    }
                                elseif ($global:index-8 -notin $ShotAt -and $global:index -notin (0..7)) # field above not shot at and not negative
                                    {
                                    $global:hitcounter = 3 # shoot above
                                    }
                                elseif ($global:index+8 -notin $ShotAt-and $global:index -notin (56..63))
                                    {
                                    $global:hitcounter = 4 # shoot below
                                    }
                                else #failsave
                                    {
                                    $global:hitcounter = 0 # shoot random
                                    }
                                }
                            }
                        1 #shot to the right hit
                            {
                            $global:temp++
                            #continue shooting right if
                            if ($global:index+1 -notin $ShotAt -and $global:index -notin (7,15,23,31,39,47,55,63)) # field  not right column and not shot at
                                {
                                $global:hitcounter = 1 # shoot right
                                }
                            else # shoot somewhere else, but first reset the index to where it was, before we started shooting right (by setting hitcounter to 1)
                                {
                                switch ($global:temp) #reset index according to the number of shots hit before the miss occured
                                    {
                                    1 {$global:index = $global:index - 1}
                                    2 {$global:index = $global:index - 2}
                                    3 {$global:index = $global:index - 3}
                                    4 {$global:index = $global:index - 4}
                                    5 {$global:index = $global:index - 5}
                                    6 {$global:index = $global:index - 6}
                                    7 {$global:index = $global:index - 7}
                                    8 {$global:index = $global:index - 8}
                                    }
                                $global:temp = 0 # indicates that the index has been reset
                                }
                            if ($global:temp -eq 0) # checks if the index has been reset and, if true, chooses another shoot option 
                                {
                                if ($global:index-1 -notin $ShotAt -and $global:index -notin (0,8,16,24,32,40,48,56)) # field to the left not shot at AND index (where the random hit occured) not left column
                                    {
                                    $global:hitcounter = 2 # shoot left
                                    }
                                elseif ($global:index-8 -notin $ShotAt -and $global:index -notin (0..7)) # field above not shot at AND index (where the random hit occured) not top row
                                    {
                                    $global:hitcounter = 3 # shoot above
                                    }
                                elseif ($global:index+8 -notin $ShotAt -and $global:index -notin (56..63)) # field below not shot at AND index (where the random hit occured) not bottom row
                                    {
                                    $global:hitcounter = 4 # shoot below
                                    }
                                else #failsave
                                    {
                                    $global:hitcounter = 0 # shoot random field
                                    }
                                }
                            }
                        2 #shot to the left hit #todo
                            {
                            $global:temp++
                            # continue shooting left if:
                            if ($global:index-1 -notin $ShotAt -and $global:index -notin (0,8,16,24,32,40,48,56)) #field not on left column and not shot at
                                {
                                $global:hitcounter = 2 # shoot left
                                }
                            else # shoot somewhere else, but first reset the index to where it was nefore we started shooting left (hitcounter = 2)
                                {
                                switch ($global:temp) #reset index according to the number of shots hit before the miss occured
                                    {
                                    1 {$global:index = $global:index + 1}
                                    2 {$global:index = $global:index + 2}
                                    3 {$global:index = $global:index + 3}
                                    4 {$global:index = $global:index + 4}
                                    5 {$global:index = $global:index + 5}
                                    6 {$global:index = $global:index + 6}
                                    7 {$global:index = $global:index + 7}
                                    8 {$global:index = $global:index + 8}
                                    }
                                $global:temp = 0 # indicates that the index has been reset
                                }
                            if ($global:temp -eq 0) # checks if the index has been reset and, if true, chooses another shoot option 
                                {
                                if ($global:index-8 -notin $ShotAt -and $global:index -notin (0..7)) # field above not shot at and index not in top row
                                    {
                                    $global:hitcounter = 3 # shoot above
                                    }
                                elseif ($global:index+8 -notin $ShotAt -and $global:index -notin (56..63)) # field below not shot at and index not bottom row
                                    {
                                    $global:hitcounter = 4 # shoot below
                                    }
                                else # failsave
                                    {
                                    $global:hitcounter = 0 # shoot random field
                                    }
                                }
                            }
                        
                        3 #shot above hit #todo
                            {
                            $global:temp++
                            if ($global:index-8 -notin $ShotAt -and $global:index -notin (0..7)) #index not on top row and field above not shot at
                                {
                                $global:hitcounter = 3 # shoot above
                                }
                            else # shoot somewhere else, but first reset the index to where it was nefore we started shooting above (hitcounter = 3)
                                {
                                switch ($global:temp) #reset index according to the number of shots hit before the miss occured
                                    {
                                    1 {$global:index = $global:index + 5}
                                    2 {$global:index = $global:index + 10}
                                    3 {$global:index = $global:index + 15}
                                    4 {$global:index = $global:index + 20}
                                    5 {$global:index = $global:index + 25}
                                    6 {$global:index = $global:index + 30}
                                    7 {$global:index = $global:index + 35}
                                    8 {$global:index = $global:index + 40}
                                    }
                                $global:temp = 0 # indicates that the index has been reset
                                }
                            if ($global:temp -eq 0) # checks if the index has been reset and, if true, chooses another shoot option
                                {
                                if ($global:index+8 -notin $ShotAt -and $global:index -notin (56..63)) # field below not shot at AND index not in bottom row
                                    {
                                    $global:hitcounter = 4 # shoot below
                                    }
                                else #failsave
                                    {
                                    $global:hitcounter = 0 # shoot random field
                                    }
                                }
                            }
                        
                        4 #shot below hit 
                            {
                            $global:temp++
                            if ($global:index -notin (56..63) -and $global:index+8 -notin $ShotAt) # if index not bottom row AND field below not shot at
                                {
                                $global:hitcounter = 4 # shoot below
                                } 
                            else #failsave
                                {
                                $global:hitcounter = 0 # shoot random field
                                }
                            }
                        }
                    }
                }
            }
        }
    #check if player has been defeated
    if ($global:fleet_player.Count -eq $sunk_player.Count -and $sunk_player.Count -eq 7)
        {
        $global:labels[([int]$global:runde)].Text += "`n"+"~~~~~~~ DEFEAT ~~~~~~~"+"`n`n"+"All our ships have been sunk in battle!"+"`n"
        $global:labels[([int]$global:runde)].Text += "`n"+"We sunk enemy ships across these Sectors:"+"`n"
        foreach ($ship in $global:fleet_ai)
            {
            if ($ship.segments -eq 0)
                {
                $global:labels[([int]$global:runde)].Text += $ship.position+$ship.position1+$ship.position2+$ship.position3+"`n"
                }
            }
        $global:labels[([int]$global:runde)].Text += "`n"+"We damaged enemy ships across these Sectors:"+"`n"
        foreach ($ship in $global:fleet_ai)
            {
            if ($ship.segments -ne 0 -and $ship.damaged -eq $true)
                {
                $global:labels[([int]$global:runde)].Text += $ship.position+$ship.position1+$ship.position2+$ship.position3+"`n"
                }
            }
        $global:labels[([int]$global:runde)].Text += "`n"+"We missed enemy ships across these Sectors:"+"`n"
        foreach ($ship in $global:fleet_ai)
            {
            if ($ship.damaged -eq $false)
                {
                $global:labels[([int]$global:runde)].Text += $ship.position+$ship.position1+$ship.position2+$ship.position3+"`n"
                }
            }
        $global:welcome.text = "Thou hast been"+"`n"+"defeated!"
        gameend
        }
    # player has not been defeated
    else
        {
        $differenz_player = ($fleet_player.count - $sunk_player.count)
        if ($differenz_player -eq 1)
            {
            $global:labels[([int]$global:runde)].Text += "`n"+"Only one ship remains of our once glorious fleet!"+"`n"
            }
        else
            {
            $global:labels[([int]$global:runde)].Text += "`n"+"There are $differenz_player ships remaining in our formation!"+"`n"
            }
        }
    }

function Shoot_at_player($runde, $hitcounter)
    {
    $global:labels[([int]$global:runde)].Text += "`n"+"~~~~ ENEMIES' TURN ~~~~"+"`n"+"`n"
    switch ($global:hitcounter)
        {
        0 #shoot random
            {
            $global:index = Get-Random -InputObject $global:coordinates_numbers
            $global:temp = 0
            $ShotAt.Add($global:index)
            ShotsFired $global:runde
            }
        1 #shoot to the right
            {
            $global:index = $global:index + 1
            $ShotAt.Add($global:index)
            ShotsFired $global:runde
            }
        2 #shoot to the left
            {
            $global:index = $global:index - 1
            $ShotAt.Add($global:index)
            ShotsFired $global:runde
            }
        3 #shoot above
            {
            $global:index = $global:index - 8
            $ShotAt.Add($global:index)
            ShotsFired $global:runde
            }
        4 #shoot below
            {
            $global:index = $global:index + 8
            $ShotAt.Add($global:index)
            ShotsFired $global:runde
            }
        }
    }

    
#add ships to array $sunk_player
[array]$global:sunk_player = @()
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
#SHIP AI
#Defining the ship classes    
#all ships will be written in these arrays
$global:fleet_ai = @()
$global:fleet_player = @()
#define class ShipAI
#attributes: shipnumber, damaged, position(s), segments
#methods: constructor variations
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
foreach ($i in (0..63))
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
        while ($temp0 -eq 63) #cannot put starting point of 2 segment ship in the bottom right corner
    if ($randomnum.Contains($temp0+8) -and ($global:coordinates[$temp0][1] -match $global:coordinates[$temp0+8][1]))
        {
        $temp1 = $temp0+8
        $check = 1
        }
    elseif ($randomnum.Contains($temp0+1) -and (($global:coordinates[$temp0][0]) -match ($global:coordinates[$temp0+1][0])))
        {
        $temp1 = $temp0+1
        $check = 1
        }
    }
    until ($check = 1)
$daten_temp0 = $global:coordinates[$temp0]
$daten_temp1 = $global:coordinates[$temp1]
$ship_ai0 = [ShipAI]::new(1,$daten_temp0,$segmentsnum,$daten_temp1)
$randomnum.Remove($temp0)
$randomnum.Remove($Temp1)
#AI ship4, 2 segments
$segmentsnum = 2
do 
    {
    do 
        {
    $temp0 = Get-Random -InputObject $randomnum
        }
        while ($temp0 -eq 63) #cannot put starting point of 2 segment ship in the bottom right corner
    if ($randomnum.Contains($temp0+8) -and ($global:coordinates[$temp0][1] -match $global:coordinates[$temp0+8][1]))
        {
        $temp1 = $temp0+8
        $check = 1
        }
    elseif ($randomnum.Contains($temp0+1) -and (($global:coordinates[$temp0][0]) -match ($global:coordinates[$temp0+1][0])))
        {
        $temp1 = $temp0+1
        $check = 1
        }
    }
    until ($check = 1)
$daten_temp0 = $global:coordinates[$temp0]
$daten_temp1 = $global:coordinates[$temp1]
$ship_ai4 = [ShipAI]::new(4,$daten_temp0,$segmentsnum,$daten_temp1)
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
        while ($temp0 -eq 63) #cannot put starting point of 2 segment ship in the bottom right corner
    if ($randomnum.Contains($temp0+1) -and (($global:coordinates[$temp0][0]) -match ($global:coordinates[$temp0+1][0])))
        {
        $temp1 = $temp0+1
        $check = 1
        }
    elseif ($randomnum.Contains($temp0+8) -and ($global:coordinates[$temp0][1] -match $global:coordinates[$temp0+8][1]))
        {
        $temp1 = $temp0+8
        $check = 1
        }
    }
    until ($check = 1)
$daten_temp0 = $global:coordinates[$temp0]
$daten_temp1 = $global:coordinates[$temp1]
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
        while ($temp0 -in (54,55,62,63)) #cannot put starting point of 3 segment ship in the 4 bottom right fields
    if ($randomnum.Contains($temp0+1) -and $randomnum.Contains($temp0+2) -and ($global:coordinates[$temp0][0] -match $global:coordinates[$temp0+1][0]) -and ($global:coordinates[$temp0][0] -match $global:coordinates[$temp0+2][0]))
        {
        $temp1 = $temp0+1
        $temp2 = $temp0+2
        $check = 1
        }
    elseif ($randomnum.Contains($temp0+8) -and $randomnum.Contains($temp0+16) -and ($global:coordinates[$temp0][1] -match $global:coordinates[$temp0+8][1]) -and ($global:coordinates[$temp0][1] -match $global:coordinates[$temp0+16][1]))
        {
        $temp1 = $temp0+8
        $temp2 = $temp0+16
        $check = 1
        }
    }
    until ($check -eq 1)
$daten_temp0 = $global:coordinates[$temp0]
$daten_temp1 = $global:coordinates[$temp1]
$daten_temp2 = $global:coordinates[$temp2]
$ship_ai2 = [ShipAI]::new(2,$daten_temp0,$segmentsnum,$daten_temp1,$daten_temp2)
$randomnum.Remove($temp0)
$randomnum.Remove($Temp1)
$randomnum.Remove($Temp2)
#AI ship5, 3 segments
$check = 0
$segmentsnum = 3
do 
    {
    do
        {
        $temp0 = Get-Random -InputObject $randomnum
        }
        while ($temp0 -in (54,55,62,63)) #cannot put starting point of 3 segment ship in the 4 bottom right fields
    if ($randomnum.Contains($temp0+1) -and $randomnum.Contains($temp0+2) -and ($global:coordinates[$temp0][0] -match $global:coordinates[$temp0+1][0]) -and ($global:coordinates[$temp0][0] -match $global:coordinates[$temp0+2][0]))
        {
        $temp1 = $temp0+1
        $temp2 = $temp0+2
        $check = 1
        }
    elseif ($randomnum.Contains($temp0+8) -and $randomnum.Contains($temp0+16) -and ($global:coordinates[$temp0][1] -match $global:coordinates[$temp0+8][1]) -and ($global:coordinates[$temp0][1] -match $global:coordinates[$temp0+16][1]))
        {
        $temp1 = $temp0+8
        $temp2 = $temp0+16
        $check = 1
        }
    }
    until ($check -eq 1)
$daten_temp0 = $global:coordinates[$temp0]
$daten_temp1 = $global:coordinates[$temp1]
$daten_temp2 = $global:coordinates[$temp2]
$ship_ai5 = [ShipAI]::new(5,$daten_temp0,$segmentsnum,$daten_temp1,$daten_temp2)
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
        while ($temp0 -in (45,46,47,53,54,55,61,62,63)) #cannot put  4 segment ship starting point the 9 bottom right fields
    if ($randomnum.Contains($temp0+1) -and $randomnum.Contains($temp0+2) -and $randomnum.Contains($temp0+3) -and ($global:coordinates[$temp0][0] -match $global:coordinates[$temp0+1][0]) -and ($global:coordinates[$temp0][0] -match $global:coordinates[$temp0+2][0]) -and ($global:coordinates[$temp0][0] -match $global:coordinates[$temp0+3][0]))
        {
        $temp1 = $temp0+1
        $temp2 = $temp0+2
        $temp3 = $temp0+3
        $check = 1
        }
    elseif ($randomnum.Contains($temp0+8) -and $randomnum.Contains($temp0+16) -and $randomnum.Contains($temp0+24) -and ($global:coordinates[$temp0][1] -match $global:coordinates[$temp0+8][1]) -and ($global:coordinates[$temp0][1] -match $global:coordinates[$temp0+16][1]) -and ($global:coordinates[$temp0][1] -match $global:coordinates[$temp0+24][1]))
        {
        $temp1 = $temp0+8
        $temp2 = $temp0+16
        $temp3 = $temp0+24
        $check = 1
        }
    }
    until ($check -eq 1)
$daten_temp0 = $global:coordinates[$temp0]
$daten_temp1 = $global:coordinates[$temp1]
$daten_temp2 = $global:coordinates[$temp2]
$daten_temp3 = $global:coordinates[$temp3]
$ship_ai3 = [ShipAI]::new(3,$daten_temp0,$segmentsnum,$daten_temp1,$daten_temp2,$daten_temp3)
$randomnum.Remove($temp0)
$randomnum.Remove($Temp1)
$randomnum.Remove($Temp2)
$randomnum.Remove($temp3)
#AI ship6, 4 segments
$check = 0
$segmentsnum = 4
do 
    {
    do
        {
        $temp0 = Get-Random -InputObject $randomnum
        }
        while ($temp0 -in (45,46,47,53,54,55,61,62,63)) #cannot put  4 segment ship starting point the 9 bottom right fields
    if ($randomnum.Contains($temp0+1) -and $randomnum.Contains($temp0+2) -and $randomnum.Contains($temp0+3) -and ($global:coordinates[$temp0][0] -match $global:coordinates[$temp0+1][0]) -and ($global:coordinates[$temp0][0] -match $global:coordinates[$temp0+2][0]) -and ($global:coordinates[$temp0][0] -match $global:coordinates[$temp0+3][0]))
        {
        $temp1 = $temp0+1
        $temp2 = $temp0+2
        $temp3 = $temp0+3
        $check = 1
        }
    elseif ($randomnum.Contains($temp0+8) -and $randomnum.Contains($temp0+16) -and $randomnum.Contains($temp0+24) -and ($global:coordinates[$temp0][1] -match $global:coordinates[$temp0+8][1]) -and ($global:coordinates[$temp0][1] -match $global:coordinates[$temp0+16][1]) -and ($global:coordinates[$temp0][1] -match $global:coordinates[$temp0+24][1]))
        {
        $temp1 = $temp0+8
        $temp2 = $temp0+16
        $temp3 = $temp0+24
        $check = 1
        }
    }
    until ($check -eq 1)
$daten_temp0 = $global:coordinates[$temp0]
$daten_temp1 = $global:coordinates[$temp1]
$daten_temp2 = $global:coordinates[$temp2]
$daten_temp3 = $global:coordinates[$temp3]
$ship_ai6 = [ShipAI]::new(6,$daten_temp0,$segmentsnum,$daten_temp1,$daten_temp2,$daten_temp3)
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
#SHIP PLAYER
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
# ________   ________   _____ ______    _______           ___       __    ___   ________    ________   ________   ___       __      
#|\   ____\ |\   __  \ |\   _ \  _   \ |\  ___ \         |\  \     |\  \ |\  \ |\   ___  \ |\   ___ \ |\   __  \ |\  \     |\  \    
#\ \  \___| \ \  \|\  \\ \  \\\__\ \  \\ \   __/|        \ \  \    \ \  \\ \  \\ \  \\ \  \\ \  \_|\ \\ \  \|\  \\ \  \    \ \  \   
# \ \  \  ___\ \   __  \\ \  \\|__| \  \\ \  \_|/__       \ \  \  __\ \  \\ \  \\ \  \\ \  \\ \  \ \\ \\ \  \\\  \\ \  \  __\ \  \  
#  \ \  \|\  \\ \  \ \  \\ \  \    \ \  \\ \  \_|\ \       \ \  \_\_\\_\  \\ \  \\ \  \\ \  \\ \  \_\\ \\ \  \\\  \\ \  \|\__\_\  \ 
#   \ \_______\\ \__\ \__\\ \__\    \ \__\\ \_______\       \ \____________\\ \__\\ \__\\ \__\\ \_______\\ \_______\\ \____________\
#    \|_______| \|__|\|__| \|__|     \|__| \|_______|        \|____________| \|__| \|__| \|__| \|_______| \|_______| \|____________|
#GAME WINDOW
#create the game window
$global:Form = New-Object "System.Windows.Forms.Form"
$global:runde = 1
#label1
$enemy=New-Object "System.Windows.Forms.Label"
$enemy.Text = "Enemy Sectors"
$enemy.Width = 200
$enemy.Location = New-Object Drawing.Point 205,20
#label2
$player=New-Object "System.Windows.Forms.Label"
$player.Text = "Our Sectors"
$player.Width = 200
$player.Location = New-Object Drawing.Point 1065,20
#label3
$combatlog=New-Object "System.Windows.Forms.Label"
$combatlog.Text = "Combat Log"
$combatlog.Width = 200
$combatlog.Location = New-Object Drawing.Point 637,20
#schriftmitte
$font = New-Object System.Drawing.Font("Verdana",16,[System.Drawing.Fontstyle]::bold)
$global:welcome=New-Object Windows.Forms.Label
$global:welcome.Text = "Place your Ships!"
$global:welcome.Width = 200
$global:welcome.Height = 120
$global:welcome.AutoSize = $false
$global:welcome.TextAlign = "Middlecenter"
$global:welcome.font = $font
$global:welcome.Location = New-Object Drawing.Point 140,475

#   ______      ______                 ____                __      __                               
#  /\  _  \    /\__  _\               /\  _`\             /\ \__  /\ \__                            
#  \ \ \L\ \   \/_/\ \/               \ \ \L\ \   __  __  \ \ ,_\ \ \ ,_\    ___     ___      ____  
#   \ \  __ \     \ \ \                \ \  _ <' /\ \/\ \  \ \ \/  \ \ \/   / __`\ /' _ `\   /',__\ 
#    \ \ \/\ \     \_\ \__              \ \ \L\ \\ \ \_\ \  \ \ \_  \ \ \_ /\ \L\ \/\ \/\ \ /\__, `\
#     \ \_\ \_\    /\_____\              \ \____/ \ \____/   \ \__\  \ \__\\ \____/\ \_\ \_\\/\____/
#      \/_/\/_/    \/_____/               \/___/   \/___/     \/__/   \/__/ \/___/  \/_/\/_/ \/___/ 
#
#AI BUTTONS
$global:buttons = New-Object System.Collections.ArrayList
$buttonnumber = 0
#defines the ai buttons' x-y coordinates
foreach ($i in $global:coordinates)
    {
    if     ($buttonnumber -in (0,8,16,24,32,40,48,56)) {$x = 50}
    elseif ($buttonnumber -in (1,9,17,25,33,41,49,57)) {$x = 100}
    elseif ($buttonnumber -in (2,10,18,26,34,42,50,58)){$x = 150}
    elseif ($buttonnumber -in (3,11,19,27,35,43,51,59)){$x = 200}
    elseif ($buttonnumber -in (4,12,20,28,36,44,52,60)){$x = 250}
    elseif ($buttonnumber -in (5,13,21,29,37,45,53,61)){$x = 300}
    elseif ($buttonnumber -in (6,14,22,30,38,46,54,62)){$x = 350}
    elseif ($buttonnumber -in (7,15,23,31,39,47,55,63)){$x = 400}
    if     ($buttonnumber -in (0..7))  {$y = 50}
    elseif ($buttonnumber -in (8..15)) {$y = 100}
    elseif ($buttonnumber -in (16..23)){$y = 150}
    elseif ($buttonnumber -in (24..31)){$y = 200}
    elseif ($buttonnumber -in (32..39)){$y = 250}
    elseif ($buttonnumber -in (40..47)){$y = 300}
    elseif ($buttonnumber -in (48..55)){$y = 350}
    elseif ($buttonnumber -in (56..63)){$y = 400}
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
        Shoot_at_ai -runde $global:runde -position $this.text
        $global:runde++;
        $global:statusbar.text ="Runde "+$global:runde
        }
        )
    $global:form.Controls.Add($global:buttons[$buttonnumber])
    $buttonnumber++
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
#SHIP BUTTONS
$global:shipnum = 0
$segmentsnum = 0
$click = 0 #check if a shipbutton has previously been clicked
$global:horv = ""
#shipbutton 0
$shipbutton0 = New-Object System.Windows.Forms.button
$shipbutton0.Location = New-Object Drawing.Point 900,500
$shipbutton0.Width = 140
$shipbutton0.Height = 40
$shipbutton0.Text = "Battleship Alpha"
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
        $button_vertical.Location = New-Object Drawing.Point 900,500
        $button_horizontal.Location = New-Object Drawing.Point 975,500
        $button_back.Location = New-Object Drawing.Point 1050,500
        }
    }
    )
$global:form.Controls.Add($shipbutton0)

#shipbutton 4
$shipbutton4 = New-Object System.Windows.Forms.button
$shipbutton4.Location = New-Object Drawing.Point 1100,500
$shipbutton4.Width = 140
$shipbutton4.Height = 40
$shipbutton4.Text = "Battleship Bravo"
$shipbutton4.enabled = $true
#what happens when you click on the button
$shipbutton4.Add_Click(
    {
    if ($click -eq 0)
        {
        $global:click = 1
        $global:segmentsnum = 3
        $global:shipnum = 4
        $shipbutton4.Visible = $false
        $button_vertical.visible = $true
        $button_horizontal.Visible = $true
        $button_back.Visible = $true
        $button_vertical.Location = New-Object Drawing.Point 1100,500
        $button_horizontal.Location = New-Object Drawing.Point 1175,500
        $button_back.Location = New-Object Drawing.Point 1250,500
        }
    }
    )
$global:form.Controls.Add($shipbutton4)

#shipbutton 1
$shipbutton1 = New-Object System.Windows.Forms.button
$shipbutton1.Location = New-Object Drawing.Point 900,550
$shipbutton1.Width = 90
$shipbutton1.Height = 40
$shipbutton1.Text = "Submarine Alpha"
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
        $button_vertical.Location = New-Object Drawing.Point 900,550
        $button_horizontal.Location = New-Object Drawing.Point 975,550
        $button_back.Location = New-Object Drawing.Point 1050,550
        }
    }
    )
$global:form.Controls.Add($shipbutton1)

#shipbutton 2
$shipbutton2 = New-Object System.Windows.Forms.button
$shipbutton2.Location = New-Object Drawing.Point 900,600
$shipbutton2.Width = 90
$shipbutton2.Height = 40
$shipbutton2.Text = "Submarine Charlie"
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
        $button_vertical.Location = New-Object Drawing.Point 900,600
        $button_horizontal.Location = New-Object Drawing.Point 975,600
        $button_back.Location = New-Object Drawing.Point 1050,600
        }
    }
    )
$global:form.Controls.Add($shipbutton2)

#shipbutton 6
$shipbutton6 = New-Object System.Windows.Forms.button
$shipbutton6.Location = New-Object Drawing.Point 1100,550
$shipbutton6.Width = 90
$shipbutton6.Height = 40
$shipbutton6.Text = "Submarine Bravo"
$shipbutton6.enabled = $true
#what happens when you click on the button
$shipbutton6.Add_Click(
    {
    if ($click -eq 0)
        {
        $global:click = 1
        $global:segmentsnum = 2
        $global:shipnum = 6
        $shipbutton6.Visible = $false
        $button_vertical.visible = $true
        $button_horizontal.Visible = $true
        $button_back.Visible = $true
        $button_vertical.Location = New-Object Drawing.Point 1100,550
        $button_horizontal.Location = New-Object Drawing.Point 1175,550
        $button_back.Location = New-Object Drawing.Point 1250,550
        }
    }
    )
$global:form.Controls.Add($shipbutton6)

#shipbutton 3
$shipbutton3 = New-Object System.Windows.Forms.button
$shipbutton3.Location = New-Object Drawing.Point 900,450
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
        $button_vertical.Location = New-Object Drawing.Point 900,450
        $button_horizontal.Location = New-Object Drawing.Point 975,450
        $button_back.Location = New-Object Drawing.Point 1050,450
        }
    }
    )
$global:form.Controls.Add($shipbutton3)

#shipbutton 5
$shipbutton5 = New-Object System.Windows.Forms.button
$shipbutton5.Location = New-Object Drawing.Point 1100,450
$shipbutton5.Width = 190
$shipbutton5.Height = 40
$shipbutton5.Text = "Admiral's Flagship"
$shipbutton5.enabled = $true
#what happens when you click on the button
$shipbutton5.Add_Click(
    {
    if ($click -eq 0)
        {
        $global:click = 1
        $global:segmentsnum = 4
        $global:shipnum = 5
        $shipbutton5.Visible = $false
        $button_vertical.visible = $true
        $button_horizontal.Visible = $true
        $button_back.Visible = $true
        $button_vertical.Location = New-Object Drawing.Point 1100,450
        $button_horizontal.Location = New-Object Drawing.Point 1175,450
        $button_back.Location = New-Object Drawing.Point 1250,450
        }
    }
    )
$global:form.Controls.Add($shipbutton5)

#vertical horizontal and back buttons
#vertical
$button_vertical= New-Object System.Windows.Forms.button
$button_vertical.Location = New-Object Drawing.Point 0,0
$button_vertical.Width = 65
$button_vertical.Height = 40
$button_vertical.Text = "Vertical"
$button_vertical.Visible = $false
$button_vertical.Add_Click(
    {
    $global:HorV = "V"
    $button_vertical.enabled = $false
    $button_horizontal.enabled = $false
    #activate the buttons where you VERTICALLY can put a ship of certain length, determined by the $global:shipnum written by a shipbutton(0..3)'s Click action
    switch ($global:shipnum)
        {
        0 #3 fields
            {  
            foreach ($i in (0..47))
                {
                if ($global:buttons_player[$i].Text -ne "")
                    {
                    $global:buttons_player[$i].enabled = $true
                    }
                elseif ($global:buttons_player[$i].Text -eq "")
                    {
                    $global:buttons_player[$i].enabled = $false
                    if ($i-8 -ge 0) {$global:buttons_player[$i-8].enabled = $false}
                    if ($i-16 -ge 0) {$global:buttons_player[$i-16].enabled = $false}
                    }
                }
            foreach ($i in (48..63))
                {
                if ($global:buttons_player[$i].Text -eq "")
                    {
                    $global:buttons_player[$i].enabled = $false
                    if ($i-8 -ge 0) {$global:buttons_player[$i-8].enabled = $false}
                    if ($i-16 -ge 0) {$global:buttons_player[$i-16].enabled = $false}
                    }
                }
            }
        4 #3 fields
            {  
            foreach ($i in (0..47))
                {
                if ($global:buttons_player[$i].Text -ne "")
                    {
                    $global:buttons_player[$i].enabled = $true
                    }
                elseif ($global:buttons_player[$i].Text -eq "")
                    {
                    $global:buttons_player[$i].enabled = $false
                    if ($i-8 -ge 0) {$global:buttons_player[$i-8].enabled = $false}
                    if ($i-16 -ge 0) {$global:buttons_player[$i-16].enabled = $false}
                    }
                }
            foreach ($i in (48..63))
                {
                if ($global:buttons_player[$i].Text -eq "")
                    {
                    $global:buttons_player[$i].enabled = $false
                    if ($i-8 -ge 0) {$global:buttons_player[$i-8].enabled = $false}
                    if ($i-16 -ge 0) {$global:buttons_player[$i-16].enabled = $false}
                    }
                }
            }
        1 #2 fields
            {  
            foreach ($i in (0..55))
                {
                if ($global:buttons_player[$i].Text -ne "")
                    {
                    $global:buttons_player[$i].enabled = $true
                    }
                elseif ($global:buttons_player[$i].Text -eq "")
                    {
                    $global:buttons_player[$i].enabled = $false
                    if ($i-8 -ge 0) {$global:buttons_player[$i-8].enabled = $false}
                    }
                }
            foreach ($i in (56..63))
                {
                if ($global:buttons_player[$i].Text -eq "")
                    {
                    $global:buttons_player[$i].enabled = $false
                    if ($i-8 -ge 0) {$global:buttons_player[$i-8].enabled = $false}
                    }
                }
            }
        2 #2 fields
            {  
            foreach ($i in (0..55))
                {
                if ($global:buttons_player[$i].Text -ne "")
                    {
                    $global:buttons_player[$i].enabled = $true
                    }
                elseif ($global:buttons_player[$i].Text -eq "")
                    {
                    $global:buttons_player[$i].enabled = $false
                    if ($i-8 -ge 0) {$global:buttons_player[$i-8].enabled = $false}
                    }
                }
            foreach ($i in (56..63))
                {
                if ($global:buttons_player[$i].Text -eq "")
                    {
                    $global:buttons_player[$i].enabled = $false
                    if ($i-8 -ge 0) {$global:buttons_player[$i-8].enabled = $false}
                    }
                }
            }
        6 #2 fields
            {  
            foreach ($i in (0..55))
                {
                if ($global:buttons_player[$i].Text -ne "")
                    {
                    $global:buttons_player[$i].enabled = $true
                    }
                elseif ($global:buttons_player[$i].Text -eq "")
                    {
                    $global:buttons_player[$i].enabled = $false
                    if ($i-8 -ge 0) {$global:buttons_player[$i-8].enabled = $false}
                    }
                }
            foreach ($i in (56..63))
                {
                if ($global:buttons_player[$i].Text -eq "")
                    {
                    $global:buttons_player[$i].enabled = $false
                    if ($i-8 -ge 0) {$global:buttons_player[$i-8].enabled = $false}
                    }
                }
            }
        3 #4 fields
            {  
            foreach ($i in (0..39))
                {
                if ($global:buttons_player[$i].Text -ne "")
                    {
                    $global:buttons_player[$i].enabled = $true
                    }
                elseif ($global:buttons_player[$i].Text -eq "")
                    {
                    $global:buttons_player[$i].enabled = $false
                    if ($i-8 -ge 0) {$global:buttons_player[$i-8].enabled = $false}
                    if ($i-16 -ge 0) {$global:buttons_player[$i-16].enabled = $false}
                    if ($i-24 -ge 0) {$global:buttons_player[$i-24].enabled = $false}
                    }
                }
            foreach ($i in (40..63))
                {
                if ($global:buttons_player[$i].Text -eq "")
                    {
                    $global:buttons_player[$i].enabled = $false
                    if ($i-8 -ge 0) {$global:buttons_player[$i-8].enabled = $false}
                    if ($i-16 -ge 0) {$global:buttons_player[$i-16].enabled = $false}
                    if ($i-24 -ge 0) {$global:buttons_player[$i-24].enabled = $false}
                    }
                }
            }
        5 #4 fields
            {  
            foreach ($i in (0..39))
                {
                if ($global:buttons_player[$i].Text -ne "")
                    {
                    $global:buttons_player[$i].enabled = $true
                    }
                elseif ($global:buttons_player[$i].Text -eq "")
                    {
                    $global:buttons_player[$i].enabled = $false
                    if ($i-8 -ge 0) {$global:buttons_player[$i-8].enabled = $false}
                    if ($i-16 -ge 0) {$global:buttons_player[$i-16].enabled = $false}
                    if ($i-24 -ge 0) {$global:buttons_player[$i-24].enabled = $false}
                    }
                }
            foreach ($i in (40..63))
                {
                if ($global:buttons_player[$i].Text -eq "")
                    {
                    $global:buttons_player[$i].enabled = $false
                    if ($i-8 -ge 0) {$global:buttons_player[$i-8].enabled = $false}
                    if ($i-16 -ge 0) {$global:buttons_player[$i-16].enabled = $false}
                    if ($i-24 -ge 0) {$global:buttons_player[$i-24].enabled = $false}
                    }
                }
            }
        }
    }
    )
$global:form.Controls.Add($button_vertical)
#horizontal
$button_horizontal= New-Object System.Windows.Forms.button
$button_horizontal.Location = New-Object Drawing.Point 0,0
$button_horizontal.Width = 65
$button_horizontal.Height = 40
$button_horizontal.Text = "Horizontal"
$button_horizontal.Visible = $false
$button_horizontal.Add_Click(
    {
    $global:HorV = "H"
    $button_vertical.enabled = $false
    $button_horizontal.enabled = $false
    #activate the buttons where you can HORIZONTALLY put a ship of certain length, determined by the $global:shipnum written on ShipClick
    switch ($global:shipnum)
        {
        0 #3 fields
            {  
            foreach ($i in (0,1,2,3,4,5,8,9,10,11,12,13,16,17,18,19,20,21,24,25,26,27,28,29,32,33,34,35,36,37,40,41,42,43,44,45,48,49,50,51,52,53,56,57,58,59,60,61))
                {
                if ($global:buttons_player[$i].Text -ne "" -and $global:buttons_player[$i+1].Text -ne "" -and $global:buttons_player[$i+2].Text -ne "")
                    {
                    $global:buttons_player[$i].enabled = $true
                    }
                }
            }
        4 #3 fields
            {  
            foreach ($i in (0,1,2,3,4,5,8,9,10,11,12,13,16,17,18,19,20,21,24,25,26,27,28,29,32,33,34,35,36,37,40,41,42,43,44,45,48,49,50,51,52,53,56,57,58,59,60,61))
                {
                if ($global:buttons_player[$i].Text -ne "" -and $global:buttons_player[$i+1].Text -ne "" -and $global:buttons_player[$i+2].Text -ne "")
                    {
                    $global:buttons_player[$i].enabled = $true
                    }
                }
            }
        1 #2 fields
            {  
            foreach ($i in (0,1,2,3,4,5,6,8,9,10,11,12,13,14,16,17,18,19,20,21,22,24,25,26,27,28,29,30,32,33,34,35,36,37,38,40,41,42,43,44,45,46,48,49,50,51,52,53,54,56,57,58,59,60,61,62))
                {
                if ($global:buttons_player[$i].Text -ne "" -and $global:buttons_player[$i+1].Text -ne "")
                    {
                    $global:buttons_player[$i].enabled = $true
                    }
                }
            }
        2 #2 fields
            {  
            foreach ($i in (0,1,2,3,4,5,6,8,9,10,11,12,13,14,16,17,18,19,20,21,22,24,25,26,27,28,29,30,32,33,34,35,36,37,38,40,41,42,43,44,45,46,48,49,50,51,52,53,54,56,57,58,59,60,61,62))
                {
                if ($global:buttons_player[$i].Text -ne "" -and $global:buttons_player[$i+1].Text -ne "")
                    {
                    $global:buttons_player[$i].enabled = $true
                    }
                }
            }
        6 #2 fields
            {  
            foreach ($i in (0,1,2,3,4,5,6,8,9,10,11,12,13,14,16,17,18,19,20,21,22,24,25,26,27,28,29,30,32,33,34,35,36,37,38,40,41,42,43,44,45,46,48,49,50,51,52,53,54,56,57,58,59,60,61,62))
                {
                if ($global:buttons_player[$i].Text -ne "" -and $global:buttons_player[$i+1].Text -ne "")
                    {
                    $global:buttons_player[$i].enabled = $true
                    }
                }
            }
        3 #4 fields
            {  
            foreach ($i in (0,1,2,3,4,8,9,10,11,12,16,17,18,19,20,24,25,26,27,28,32,33,34,35,36,40,41,42,43,44,48,49,50,51,52,56,57,58,59,60))
                {
                if ($global:buttons_player[$i].Text -ne "" -and $global:buttons_player[$i+1].Text -ne "" -and $global:buttons_player[$i+2].Text -ne "" -and $global:buttons_player[$i+3].Text -ne "")
                    {
                    $global:buttons_player[$i].enabled = $true
                    }
                }
            }
        5 #4 fields
            {  
            foreach ($i in (0,1,2,3,4,8,9,10,11,12,16,17,18,19,20,24,25,26,27,28,32,33,34,35,36,40,41,42,43,44,48,49,50,51,52,56,57,58,59,60))
                {
                if ($global:buttons_player[$i].Text -ne "" -and $global:buttons_player[$i+1].Text -ne "" -and $global:buttons_player[$i+2].Text -ne "" -and $global:buttons_player[$i+3].Text -ne "")
                    {
                    $global:buttons_player[$i].enabled = $true
                    }
                }
            }
        }
    }
    )
$global:form.Controls.Add($button_horizontal)
#back button
$button_back= New-Object System.Windows.Forms.button
$button_back.Location = New-Object Drawing.Point 0,0
$button_back.Width = 40
$button_back.Height = 40
$button_back.Text = "Back"
$button_back.Visible = $false
$button_back.Add_Click(
    {
    switch ($global:shipnum)
        {
        0 {$shipbutton0.Visible = $true}
        1 {$shipbutton1.Visible = $true}
        2 {$shipbutton2.Visible = $true}
        3 {$shipbutton3.Visible = $true}
        4 {$shipbutton4.Visible = $true}
        5 {$shipbutton5.Visible = $true}
        6 {$shipbutton6.Visible = $true}
        }
    $global:click = 0
    $button_vertical.enabled = $true
    $button_horizontal.enabled = $true
    $button_vertical.visible = $false
    $button_horizontal.Visible = $false
    $button_back.Visible = $false
    foreach ($button in $global:buttons_player)
        {
        $button.enabled = $false
        }
    switch ($global:shipnum)
        {
        0 {$shipbutton0.Enabled = $true}
        1 {$shipbutton1.Enabled = $true}
        2 {$shipbutton2.Enabled = $true}
        3 {$shipbutton3.Enabled = $true}
        4 {$shipbutton4.Enabled = $true}
        5 {$shipbutton5.Enabled = $true}
        6 {$shipbutton6.Enabled = $true}
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
#PLAYER BUTTONS
$buttonnumber = 0
$global:buttons_player = New-Object System.Collections.ArrayList
$global:playerShipCounter = 0
$ship_player0 = $null
$ship_player1 = $null
$ship_player2 = $null
$ship_player3 = $null
$ship_player4 = $null
$ship_player5 = $null
$ship_player6 = $null
$segmentsnum = 0
$playerbool = $false
#defines the player buttons' x-y coordinates
foreach ($i in $global:coordinates)
    {
    if     ($buttonnumber -in (0,8,16,24,32,40,48,56)) {$x = 900}
    elseif ($buttonnumber -in (1,9,17,25,33,41,49,57)) {$x = 950}
    elseif ($buttonnumber -in (2,10,18,26,34,42,50,58)){$x = 1000}
    elseif ($buttonnumber -in (3,11,19,27,35,43,51,59)){$x = 1050}
    elseif ($buttonnumber -in (4,12,20,28,36,44,52,60)){$x = 1100}
    elseif ($buttonnumber -in (5,13,21,29,37,45,53,61)){$x = 1150}
    elseif ($buttonnumber -in (6,14,22,30,38,46,54,62)){$x = 1200}
    elseif ($buttonnumber -in (7,15,23,31,39,47,55,63)){$x = 1250}
    if     ($buttonnumber -in (0..7))  {$y = 50}
    elseif ($buttonnumber -in (8..15)) {$y = 100}
    elseif ($buttonnumber -in (16..23)){$y = 150}
    elseif ($buttonnumber -in (24..31)){$y = 200}
    elseif ($buttonnumber -in (32..39)){$y = 250}
    elseif ($buttonnumber -in (40..47)){$y = 300}
    elseif ($buttonnumber -in (48..55)){$y = 350}
    elseif ($buttonnumber -in (56..63)){$y = 400}
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
                    A1 {$global:index = 0}
                    A2 {$global:index = 1}
                    A3 {$global:index = 2}
                    A4 {$global:index = 3}
                    A5 {$global:index = 4}
                    A6 {$global:index = 5}
                    A7 {$global:index = 6}
                    A8 {$global:index = 7}
                    B1 {$global:index = 8}
                    B2 {$global:index = 9}
                    B3 {$global:index = 10}
                    B4 {$global:index = 11}
                    B5 {$global:index = 12}
                    B6 {$global:index = 13}
                    B7 {$global:index = 14}
                    B8 {$global:index = 15}
                    C1 {$global:index = 16}
                    C2 {$global:index = 17}
                    C3 {$global:index = 18}
                    C4 {$global:index = 19}
                    C5 {$global:index = 20}
                    C6 {$global:index = 21}
                    C7 {$global:index = 22}
                    C8 {$global:index = 23}
                    D1 {$global:index = 24}
                    D2 {$global:index = 25}
                    D3 {$global:index = 26}
                    D4 {$global:index = 27}
                    D5 {$global:index = 28}
                    D6 {$global:index = 29}
                    D7 {$global:index = 30}
                    D8 {$global:index = 31}
                    E1 {$global:index = 32}
                    E2 {$global:index = 33}
                    E3 {$global:index = 34}
                    E4 {$global:index = 35}
                    E5 {$global:index = 36}
                    E6 {$global:index = 37}
                    E7 {$global:index = 38}
                    E8 {$global:index = 39}
                    F1 {$global:index = 40}
                    F2 {$global:index = 41}
                    F3 {$global:index = 42}
                    F4 {$global:index = 43}
                    F5 {$global:index = 44}
                    F6 {$global:index = 45}
                    F7 {$global:index = 46}
                    F8 {$global:index = 47}
                    G1 {$global:index = 48}
                    G2 {$global:index = 49}
                    G3 {$global:index = 50}
                    G4 {$global:index = 51}
                    G5 {$global:index = 52}
                    G6 {$global:index = 53}
                    G7 {$global:index = 54}
                    G8 {$global:index = 55}
                    H1 {$global:index = 56}
                    H2 {$global:index = 57}
                    H3 {$global:index = 58}
                    H4 {$global:index = 59}
                    H5 {$global:index = 60}
                    H6 {$global:index = 61}
                    H7 {$global:index = 62}
                    H8 {$global:index = 63}
                    }
        switch ($global:shipnum)
            {
            0 
                {
                if ($global:horv -eq "H")
                    {
                    $global:ship_player0 = [ShipPlayer]::new(0,$global:coordinates[$global:index],3,$global:coordinates[$global:index+1],$global:coordinates[$global:index+2])
                    $global:buttons_player[$global:index].Text = ""
                    $global:buttons_player[$global:index+1].Text = ""
                    $global:buttons_player[$global:index+2].Text = ""
                    $global:buttons_player[$global:index].image = $global:img_ship_button
                    $global:buttons_player[$global:index+1].image = $global:img_ship_button
                    $global:buttons_player[$global:index+2].image = $global:img_ship_button
                    }
                elseif ($global:horv -eq "V")
                    {
                    $global:ship_player0 = [ShipPlayer]::new(0,$global:coordinates[$global:index],3,$global:coordinates[$global:index+8],$global:coordinates[$global:index+16])
                    $global:buttons_player[$global:index].Text = ""
                    $global:buttons_player[$global:index+8].Text = ""
                    $global:buttons_player[$global:index+16].Text = ""
                    $global:buttons_player[$global:index].image = $global:img_ship_button
                    $global:buttons_player[$global:index+8].image = $global:img_ship_button
                    $global:buttons_player[$global:index+16].image = $global:img_ship_button
                    }
                }
            4 
                {
                if ($global:horv -eq "H")
                    {
                    $global:ship_player0 = [ShipPlayer]::new(4,$global:coordinates[$global:index],3,$global:coordinates[$global:index+1],$global:coordinates[$global:index+2])
                    $global:buttons_player[$global:index].Text = ""
                    $global:buttons_player[$global:index+1].Text = ""
                    $global:buttons_player[$global:index+2].Text = ""
                    $global:buttons_player[$global:index].image = $global:img_ship_button
                    $global:buttons_player[$global:index+1].image = $global:img_ship_button
                    $global:buttons_player[$global:index+2].image = $global:img_ship_button
                    }
                elseif ($global:horv -eq "V")
                    {
                    $global:ship_player0 = [ShipPlayer]::new(4,$global:coordinates[$global:index],3,$global:coordinates[$global:index+8],$global:coordinates[$global:index+16])
                    $global:buttons_player[$global:index].Text = ""
                    $global:buttons_player[$global:index+8].Text = ""
                    $global:buttons_player[$global:index+16].Text = ""
                    $global:buttons_player[$global:index].image = $global:img_ship_button
                    $global:buttons_player[$global:index+8].image = $global:img_ship_button
                    $global:buttons_player[$global:index+16].image = $global:img_ship_button
                    }
                }
            1
                {
                if ($global:horv -eq "H")
                    {
                    $global:ship_player1 = [ShipPlayer]::new(1,$global:coordinates[$global:index],2,$global:coordinates[$global:index+1])
                    $global:buttons_player[$global:index].Text = ""
                    $global:buttons_player[$global:index+1].Text = ""
                    $global:buttons_player[$global:index].image = $global:img_ship_button
                    $global:buttons_player[$global:index+1].image = $global:img_ship_button
                    }
                elseif ($global:horv -eq "V")
                    {
                    $global:ship_player1 = [ShipPlayer]::new(1,$global:coordinates[$global:index],2,$global:coordinates[$global:index+8])
                    $global:buttons_player[$global:index].Text = ""
                    $global:buttons_player[$global:index+8].Text = ""
                    $global:buttons_player[$global:index].image = $global:img_ship_button
                    $global:buttons_player[$global:index+8].image = $global:img_ship_button
                    }
                }
            2
                {
                if ($global:horv -eq "H")
                    {
                    $global:ship_player2 = [ShipPlayer]::new(2,$global:coordinates[$global:index],2,$global:coordinates[$global:index+1])
                    $global:buttons_player[$global:index].Text = ""
                    $global:buttons_player[$global:index+1].Text = ""
                    $global:buttons_player[$global:index].image = $global:img_ship_button
                    $global:buttons_player[$global:index+1].image = $global:img_ship_button
                    }
                elseif ($global:horv -eq "V")
                    {
                    $global:ship_player2 = [ShipPlayer]::new(2,$global:coordinates[$global:index],2,$global:coordinates[$global:index+8])
                    $global:buttons_player[$global:index].Text = ""
                    $global:buttons_player[$global:index+8].Text = ""
                    $global:buttons_player[$global:index].image = $global:img_ship_button
                    $global:buttons_player[$global:index+8].image = $global:img_ship_button
                    }
                }
            6
                {
                if ($global:horv -eq "H")
                    {
                    $global:ship_player2 = [ShipPlayer]::new(6,$global:coordinates[$global:index],2,$global:coordinates[$global:index+1])
                    $global:buttons_player[$global:index].Text = ""
                    $global:buttons_player[$global:index+1].Text = ""
                    $global:buttons_player[$global:index].image = $global:img_ship_button
                    $global:buttons_player[$global:index+1].image = $global:img_ship_button
                    }
                elseif ($global:horv -eq "V")
                    {
                    $global:ship_player2 = [ShipPlayer]::new(6,$global:coordinates[$global:index],2,$global:coordinates[$global:index+8])
                    $global:buttons_player[$global:index].Text = ""
                    $global:buttons_player[$global:index+8].Text = ""
                    $global:buttons_player[$global:index].image = $global:img_ship_button
                    $global:buttons_player[$global:index+8].image = $global:img_ship_button
                    }
                }
            3
                {
                if ($global:horv -eq "H")
                    {
                    $global:ship_player3 = [ShipPlayer]::new(3,$global:coordinates[$global:index],4,$global:coordinates[$global:index+1],$global:coordinates[$global:index+2],$global:coordinates[$global:index+3])
                    $global:buttons_player[$global:index].Text = ""
                    $global:buttons_player[$global:index+1].Text = ""
                    $global:buttons_player[$global:index+2].Text = ""
                    $global:buttons_player[$global:index+3].Text = ""
                    $global:buttons_player[$global:index].image = $global:img_ship_button
                    $global:buttons_player[$global:index+1].image = $global:img_ship_button
                    $global:buttons_player[$global:index+2].image = $global:img_ship_button
                    $global:buttons_player[$global:index+3].image = $global:img_ship_button
                    }
                elseif ($global:horv -eq "V")
                    {
                    $global:ship_player3 = [ShipPlayer]::new(3,$global:coordinates[$global:index],4,$global:coordinates[$global:index+5],$global:coordinates[$global:index+10],$global:coordinates[$global:index+15])
                    $global:buttons_player[$global:index].Text = ""
                    $global:buttons_player[$global:index+8].Text = ""
                    $global:buttons_player[$global:index+16].Text = ""
                    $global:buttons_player[$global:index+24].Text = ""
                    $global:buttons_player[$global:index].image = $global:img_ship_button
                    $global:buttons_player[$global:index+8].image = $global:img_ship_button
                    $global:buttons_player[$global:index+16].image = $global:img_ship_button
                    $global:buttons_player[$global:index+24].image = $global:img_ship_button
                    }
                }
            5
                {
                if ($global:horv -eq "H")
                    {
                    $global:ship_player3 = [ShipPlayer]::new(5,$global:coordinates[$global:index],4,$global:coordinates[$global:index+1],$global:coordinates[$global:index+2],$global:coordinates[$global:index+3])
                    $global:buttons_player[$global:index].Text = ""
                    $global:buttons_player[$global:index+1].Text = ""
                    $global:buttons_player[$global:index+2].Text = ""
                    $global:buttons_player[$global:index+3].Text = ""
                    $global:buttons_player[$global:index].image = $global:img_ship_button
                    $global:buttons_player[$global:index+1].image = $global:img_ship_button
                    $global:buttons_player[$global:index+2].image = $global:img_ship_button
                    $global:buttons_player[$global:index+3].image = $global:img_ship_button
                    }
                elseif ($global:horv -eq "V")
                    {
                    $global:ship_player3 = [ShipPlayer]::new(5,$global:coordinates[$global:index],4,$global:coordinates[$global:index+8],$global:coordinates[$global:index+16],$global:coordinates[$global:index+24])
                    $global:buttons_player[$global:index].Text = ""
                    $global:buttons_player[$global:index+8].Text = ""
                    $global:buttons_player[$global:index+16].Text = ""
                    $global:buttons_player[$global:index+24].Text = ""
                    $global:buttons_player[$global:index].image = $global:img_ship_button
                    $global:buttons_player[$global:index+8].image = $global:img_ship_button
                    $global:buttons_player[$global:index+16].image = $global:img_ship_button
                    $global:buttons_player[$global:index+24].image = $global:img_ship_button
                    }
                }
            }
        foreach ($button in $global:buttons_player)
            {
            $button.enabled = $false
            }
        switch ($global:shipnum)
            {
        0 {$shipbutton0.Enabled = $false; $shipbutton0.Visible = $true}
        1 {$shipbutton1.Enabled = $false; $shipbutton1.Visible = $true}
        2 {$shipbutton2.Enabled = $false; $shipbutton2.Visible = $true}
        3 {$shipbutton3.Enabled = $false; $shipbutton3.Visible = $true}
        4 {$shipbutton4.Enabled = $false; $shipbutton4.Visible = $true}
        5 {$shipbutton5.Enabled = $false; $shipbutton5.Visible = $true}
        6 {$shipbutton6.Enabled = $false; $shipbutton6.Visible = $true}
            }
        $button_vertical.enabled = $true
        $button_horizontal.enabled = $true
        $button_vertical.visible = $false
        $button_horizontal.Visible = $false
        $button_back.Visible = $false
        $global:click = 0
        $global:playershipcounter++
        if ($global:playerShipCounter -eq 7)
            {
            $shipbutton0.Visible = $false
            $shipbutton1.Visible = $false
            $shipbutton2.Visible = $false
            $shipbutton3.Visible = $false
            $shipbutton4.Visible = $false
            $shipbutton5.Visible = $false
            $shipbutton6.Visible = $false
            $forfeit.Visible = $true
            foreach ($button in $global:buttons)
                {
                $button.enabled = $true
                }
            }
        }
        )
#adds the button to the form+
    $global:form.Controls.Add($global:buttons_player[$buttonnumber])
    $buttonnumber++
    }
#                                                    __      __                      __                          
#   /'\_/`\               __                        /\ \  __/\ \    __              /\ \                         
#  /\  \   \      __     /\_\     ___               \ \ \/\ \ \ \  /\_\     ___     \_\ \     ___    __  __  __  
#  \ \ \__\ \   /'__`\   \/\ \  /' _ `\              \ \ \ \ \ \ \ \/\ \  /' _ `\   /'_` \   / __`\ /\ \/\ \/\ \ 
#   \ \ \_/\ \ /\ \L\.\_  \ \ \ /\ \/\ \              \ \ \_/ \_\ \ \ \ \ /\ \/\ \ /\ \L\ \ /\ \L\ \\ \ \_/ \_/ \
#    \ \_\\ \_\\ \__/.\_\  \ \_\\ \_\ \_\              \ `\___x___/  \ \_\\ \_\ \_\\ \___,_\\ \____/ \ \___x___/'
#     \/_/ \/_/ \/__/\/_/   \/_/ \/_/\/_/               '\/__//__/    \/_/ \/_/\/_/ \/__,_ / \/___/   \/__//__/  
#
#MAIN WINDOW
$global:form.TopMost = $true
$global:form.Controls.Add($enemy)
$global:form.Controls.Add($global:welcome)
$global:form.Controls.Add($player)
$global:form.Controls.Add($combatlog)
$global:Form.Text = "Battleship"
$global:Form.Height = 750
$global:Form.Width = 1366
$global:Form.FormBorderStyle = "Fixed3D"
$global:form.maximizebox = $false
$global:form.MinimizeBox = $false
$global:form.StartPosition = "CenterScreen"
$global:form.KeyPreview = $true
$global:Form.Add_KeyDown(
    {
    if ($_.KeyCode -eq "Escape") 
        {
        $global:Form.Close()
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
$global:Form.Icon = $Icon
#round number status bar
$global:statusBar = New-Object System.Windows.Forms.StatusBar
$global:statusBar.text = "Pregame"
$global:form.controls.add($global:statusBar)
#   __  __                           __                  __       ___                        
#  /\ \/\ \                         /\ \                /\ \__   /\_ \                       
#  \ \ \/'/'     ___     ___ ___    \ \ \____     __    \ \ ,_\  \//\ \      ___      __     
#   \ \ , <     / __`\ /' __` __`\   \ \ '__`\  /'__`\   \ \ \/    \ \ \    / __`\  /'_ `\   
#    \ \ \\`\  /\ \L\ \/\ \/\ \/\ \   \ \ \L\ \/\ \L\.\_  \ \ \_    \_\ \_ /\ \L\ \/\ \L\ \  
#     \ \_\ \_\\ \____/\ \_\ \_\ \_\   \ \_,__/\ \__/.\_\  \ \__\   /\____\\ \____/\ \____ \ 
#      \/_/\/_/ \/___/  \/_/\/_/\/_/    \/___/  \/__/\/_/   \/__/   \/____/ \/___/  \/___L\ \
#                                                                                      /\____/
#                                                                                      \_/__/ 
# Combat Log
#tabcontrol
$tabControl = New-Object System.Windows.Forms.TabControl
$tabControl.TabIndex = 0
$tabControl.Height = 600
$tabControl.Width = 350
$tabcontrol.Location = New-Object Drawing.Point 500,50
$tabControl.Name = "tabControl"
$tabControl.SelectedIndex = 0
$tabControl.Alignment = "Right"
$tabControl.Multiline = $true

#tabpage0
$tabPage0 = New-Object System.Windows.Forms.TabPage
$tabPage0.TabIndex = 0
$tabPage0.UseVisualStyleBackColor = $True
$tabpage0.height = 600
$tabpage0.Width = 300
$tabPage0.Text = "Rules"
$tabPage0.Location = New-Object Drawing.Point 500,50
#label0
$label0 = New-Object Windows.Forms.Label
$label0.Text = "Welcome to Battleship!"+"`n"+"`n"+"Rules:"+"`n"+"`n"+"(1) First to sink all enemy ships wins."+"`n"+"`n"+"(2) A fleet consists of Seven different ships:"+"`n"+" a) Admiral's Flagship"+"`n"+"    Length: 4"+"`n"+" b) One Aircraft Carrier"+"`n"+"    Length: 4"+"`n"+" c) Two Battleships"+"`n"+"    Length: 3 each"+"`n"+" d) Three Submarines"+"`n"+"    Length: 2 each"+"`n"+"`n"+"(3) The Player shoots first."+"`n"+"`n"+"`n"+"Choose a ship, its orientation and then the coordinate where the ship should be situated!"+"`n"+"The selected coordinate is always the top- and leftmost point of the ship."+"`n"+"`n"+"When you're done placing our fleet, shoot at an enemy sector by clicking on it!"+"`n"+"`n"
$label0.Width = 190
$label0.height = 600
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
#GAMEEND BUTTONS
#forfeit button
$forfeit = New-Object System.Windows.Forms.button
$forfeit.Location = New-Object Drawing.Point 1047,500
$forfeit.Width = 100
$forfeit.Height = 40
$forfeit.Text = "Forfeit"
$forfeit.Add_Click(
    {
    gameend
    }
    )
$forfeit.Visible = $false
$global:form.Controls.Add($forfeit)
# what happens when the game ends in any way
function gameend()
    {
    foreach ($button in $global:buttons) # disables all AI buttons
        {
        $button.enabled = $false
        }
    foreach ($ship in $fleet_ai) # iterates all AI ships and changes the image on the corresponding field to a ship, if it hasn't been hit
            {
                switch ($ship.position) # ship position 0
                    {
                    A1 {$global:gameend = 0}
                    A2 {$global:gameend = 1}
                    A3 {$global:gameend = 2}
                    A4 {$global:gameend = 3}
                    A5 {$global:gameend = 4}
                    A6 {$global:gameend = 5}
                    A7 {$global:gameend = 6}
                    A8 {$global:gameend = 7}
                    B1 {$global:gameend = 8}
                    B2 {$global:gameend = 9}
                    B3 {$global:gameend = 10}
                    B4 {$global:gameend = 11}
                    B5 {$global:gameend = 12}
                    B6 {$global:gameend = 13}
                    B7 {$global:gameend = 14}
                    B8 {$global:gameend = 15}
                    C1 {$global:gameend = 16}
                    C2 {$global:gameend = 17}
                    C3 {$global:gameend = 18}
                    C4 {$global:gameend = 19}
                    C5 {$global:gameend = 20}
                    C6 {$global:gameend = 21}
                    C7 {$global:gameend = 22}
                    C8 {$global:gameend = 23}
                    D1 {$global:gameend = 24}
                    D2 {$global:gameend = 25}
                    D3 {$global:gameend = 26}
                    D4 {$global:gameend = 27}
                    D5 {$global:gameend = 28}
                    D6 {$global:gameend = 29}
                    D7 {$global:gameend = 30}
                    D8 {$global:gameend = 31}
                    E1 {$global:gameend = 32}
                    E2 {$global:gameend = 33}
                    E3 {$global:gameend = 34}
                    E4 {$global:gameend = 35}
                    E5 {$global:gameend = 36}
                    E6 {$global:gameend = 37}
                    E7 {$global:gameend = 38}
                    E8 {$global:gameend = 39}
                    F1 {$global:gameend = 40}
                    F2 {$global:gameend = 41}
                    F3 {$global:gameend = 42}
                    F4 {$global:gameend = 43}
                    F5 {$global:gameend = 44}
                    F6 {$global:gameend = 45}
                    F7 {$global:gameend = 46}
                    F8 {$global:gameend = 47}
                    G1 {$global:gameend = 48}
                    G2 {$global:gameend = 49}
                    G3 {$global:gameend = 50}
                    G4 {$global:gameend = 51}
                    G5 {$global:gameend = 52}
                    G6 {$global:gameend = 53}
                    G7 {$global:gameend = 54}
                    G8 {$global:gameend = 55}
                    H1 {$global:gameend = 56}
                    H2 {$global:gameend = 57}
                    H3 {$global:gameend = 58}
                    H4 {$global:gameend = 59}
                    H5 {$global:gameend = 60}
                    H6 {$global:gameend = 61}
                    H7 {$global:gameend = 62}
                    H8 {$global:gameend = 63}
                    }
                if ($global:buttons[$global:gameend].Image -eq $null)
                    {
                    $global:buttons[$global:gameend].Image = $img_ship_button
                    $global:buttons[$global:gameend].Text = ""
                    }
                    switch ($ship.position1) # ship position 1
                    {
                    A1 {$global:gameend = 0}
                    A2 {$global:gameend = 1}
                    A3 {$global:gameend = 2}
                    A4 {$global:gameend = 3}
                    A5 {$global:gameend = 4}
                    A6 {$global:gameend = 5}
                    A7 {$global:gameend = 6}
                    A8 {$global:gameend = 7}
                    B1 {$global:gameend = 8}
                    B2 {$global:gameend = 9}
                    B3 {$global:gameend = 10}
                    B4 {$global:gameend = 11}
                    B5 {$global:gameend = 12}
                    B6 {$global:gameend = 13}
                    B7 {$global:gameend = 14}
                    B8 {$global:gameend = 15}
                    C1 {$global:gameend = 16}
                    C2 {$global:gameend = 17}
                    C3 {$global:gameend = 18}
                    C4 {$global:gameend = 19}
                    C5 {$global:gameend = 20}
                    C6 {$global:gameend = 21}
                    C7 {$global:gameend = 22}
                    C8 {$global:gameend = 23}
                    D1 {$global:gameend = 24}
                    D2 {$global:gameend = 25}
                    D3 {$global:gameend = 26}
                    D4 {$global:gameend = 27}
                    D5 {$global:gameend = 28}
                    D6 {$global:gameend = 29}
                    D7 {$global:gameend = 30}
                    D8 {$global:gameend = 31}
                    E1 {$global:gameend = 32}
                    E2 {$global:gameend = 33}
                    E3 {$global:gameend = 34}
                    E4 {$global:gameend = 35}
                    E5 {$global:gameend = 36}
                    E6 {$global:gameend = 37}
                    E7 {$global:gameend = 38}
                    E8 {$global:gameend = 39}
                    F1 {$global:gameend = 40}
                    F2 {$global:gameend = 41}
                    F3 {$global:gameend = 42}
                    F4 {$global:gameend = 43}
                    F5 {$global:gameend = 44}
                    F6 {$global:gameend = 45}
                    F7 {$global:gameend = 46}
                    F8 {$global:gameend = 47}
                    G1 {$global:gameend = 48}
                    G2 {$global:gameend = 49}
                    G3 {$global:gameend = 50}
                    G4 {$global:gameend = 51}
                    G5 {$global:gameend = 52}
                    G6 {$global:gameend = 53}
                    G7 {$global:gameend = 54}
                    G8 {$global:gameend = 55}
                    H1 {$global:gameend = 56}
                    H2 {$global:gameend = 57}
                    H3 {$global:gameend = 58}
                    H4 {$global:gameend = 59}
                    H5 {$global:gameend = 60}
                    H6 {$global:gameend = 61}
                    H7 {$global:gameend = 62}
                    H8 {$global:gameend = 63}
                    }
                if ($global:buttons[$global:gameend].Image -eq $null) # ship position 2
                    {
                    $global:buttons[$global:gameend].Image = $img_ship_button
                    $global:buttons[$global:gameend].Text = ""
                    }
                    switch ($ship.position2)
                    {
                    A1 {$global:gameend = 0}
                    A2 {$global:gameend = 1}
                    A3 {$global:gameend = 2}
                    A4 {$global:gameend = 3}
                    A5 {$global:gameend = 4}
                    A6 {$global:gameend = 5}
                    A7 {$global:gameend = 6}
                    A8 {$global:gameend = 7}
                    B1 {$global:gameend = 8}
                    B2 {$global:gameend = 9}
                    B3 {$global:gameend = 10}
                    B4 {$global:gameend = 11}
                    B5 {$global:gameend = 12}
                    B6 {$global:gameend = 13}
                    B7 {$global:gameend = 14}
                    B8 {$global:gameend = 15}
                    C1 {$global:gameend = 16}
                    C2 {$global:gameend = 17}
                    C3 {$global:gameend = 18}
                    C4 {$global:gameend = 19}
                    C5 {$global:gameend = 20}
                    C6 {$global:gameend = 21}
                    C7 {$global:gameend = 22}
                    C8 {$global:gameend = 23}
                    D1 {$global:gameend = 24}
                    D2 {$global:gameend = 25}
                    D3 {$global:gameend = 26}
                    D4 {$global:gameend = 27}
                    D5 {$global:gameend = 28}
                    D6 {$global:gameend = 29}
                    D7 {$global:gameend = 30}
                    D8 {$global:gameend = 31}
                    E1 {$global:gameend = 32}
                    E2 {$global:gameend = 33}
                    E3 {$global:gameend = 34}
                    E4 {$global:gameend = 35}
                    E5 {$global:gameend = 36}
                    E6 {$global:gameend = 37}
                    E7 {$global:gameend = 38}
                    E8 {$global:gameend = 39}
                    F1 {$global:gameend = 40}
                    F2 {$global:gameend = 41}
                    F3 {$global:gameend = 42}
                    F4 {$global:gameend = 43}
                    F5 {$global:gameend = 44}
                    F6 {$global:gameend = 45}
                    F7 {$global:gameend = 46}
                    F8 {$global:gameend = 47}
                    G1 {$global:gameend = 48}
                    G2 {$global:gameend = 49}
                    G3 {$global:gameend = 50}
                    G4 {$global:gameend = 51}
                    G5 {$global:gameend = 52}
                    G6 {$global:gameend = 53}
                    G7 {$global:gameend = 54}
                    G8 {$global:gameend = 55}
                    H1 {$global:gameend = 56}
                    H2 {$global:gameend = 57}
                    H3 {$global:gameend = 58}
                    H4 {$global:gameend = 59}
                    H5 {$global:gameend = 60}
                    H6 {$global:gameend = 61}
                    H7 {$global:gameend = 62}
                    H8 {$global:gameend = 63}
                    }
                if ($global:buttons[$global:gameend].Image -eq $null) # ship position 3
                    {
                    $global:buttons[$global:gameend].Image = $img_ship_button
                    $global:buttons[$global:gameend].Text = ""
                    }
                switch ($ship.position3)
                    {
                    A1 {$global:gameend = 0}
                    A2 {$global:gameend = 1}
                    A3 {$global:gameend = 2}
                    A4 {$global:gameend = 3}
                    A5 {$global:gameend = 4}
                    A6 {$global:gameend = 5}
                    A7 {$global:gameend = 6}
                    A8 {$global:gameend = 7}
                    B1 {$global:gameend = 8}
                    B2 {$global:gameend = 9}
                    B3 {$global:gameend = 10}
                    B4 {$global:gameend = 11}
                    B5 {$global:gameend = 12}
                    B6 {$global:gameend = 13}
                    B7 {$global:gameend = 14}
                    B8 {$global:gameend = 15}
                    C1 {$global:gameend = 16}
                    C2 {$global:gameend = 17}
                    C3 {$global:gameend = 18}
                    C4 {$global:gameend = 19}
                    C5 {$global:gameend = 20}
                    C6 {$global:gameend = 21}
                    C7 {$global:gameend = 22}
                    C8 {$global:gameend = 23}
                    D1 {$global:gameend = 24}
                    D2 {$global:gameend = 25}
                    D3 {$global:gameend = 26}
                    D4 {$global:gameend = 27}
                    D5 {$global:gameend = 28}
                    D6 {$global:gameend = 29}
                    D7 {$global:gameend = 30}
                    D8 {$global:gameend = 31}
                    E1 {$global:gameend = 32}
                    E2 {$global:gameend = 33}
                    E3 {$global:gameend = 34}
                    E4 {$global:gameend = 35}
                    E5 {$global:gameend = 36}
                    E6 {$global:gameend = 37}
                    E7 {$global:gameend = 38}
                    E8 {$global:gameend = 39}
                    F1 {$global:gameend = 40}
                    F2 {$global:gameend = 41}
                    F3 {$global:gameend = 42}
                    F4 {$global:gameend = 43}
                    F5 {$global:gameend = 44}
                    F6 {$global:gameend = 45}
                    F7 {$global:gameend = 46}
                    F8 {$global:gameend = 47}
                    G1 {$global:gameend = 48}
                    G2 {$global:gameend = 49}
                    G3 {$global:gameend = 50}
                    G4 {$global:gameend = 51}
                    G5 {$global:gameend = 52}
                    G6 {$global:gameend = 53}
                    G7 {$global:gameend = 54}
                    G8 {$global:gameend = 55}
                    H1 {$global:gameend = 56}
                    H2 {$global:gameend = 57}
                    H3 {$global:gameend = 58}
                    H4 {$global:gameend = 59}
                    H5 {$global:gameend = 60}
                    H6 {$global:gameend = 61}
                    H7 {$global:gameend = 62}
                    H8 {$global:gameend = 63}
                    }
                if ($global:buttons[$global:gameend].Image -eq $null)
                    {
                    $global:buttons[$global:gameend].Image = $img_ship_button
                    $global:buttons[$global:gameend].Text = ""
                    }
        }
    # makes the forfeit button invisible and shows the restart/close buttons            
    $forfeit.Visible = $false
    $restartbutton = New-Object System.Windows.Forms.Button
    $restartbutton.Location = New-Object Drawing.Point 1050,475
    $restartbutton.Width = 100
    $restartbutton.Height = 40
    $restartbutton.Text = "Rematch"
    #close window and run script again
    $restartbutton.Add_Click(
        {
        $global:form.Close()
        $global:form.Dispose()
        powershell.exe -file '.\schiffeversenken_v4.0.ps1'
        }
        )
    $global:form.Controls.Add($restartbutton)
    $endbutton = New-Object System.Windows.Forms.button
    $endbutton.Location = New-Object Drawing.Point 1050,525
    $endbutton.Width = 100
    $endbutton.Height = 40
    $endbutton.Text = "Quit"
    #close window
    $endbutton.Add_Click(
        {
        $global:form.Close()
        $global:form.Dispose()
        }
        )
    $global:form.Controls.Add($endbutton)
    }
#adds tabcontrol to the form
$global:form.Controls.Add($tabControl)
#shows the complete window and runs the game!
$global:Form.ShowDialog()