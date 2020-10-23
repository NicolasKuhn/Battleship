#
# Schiffe Versenken v3.0
#
# changes from v2.0:
#
# ♥ coded and integrated AI behaviour
#
# ♥ runs natively without ISE now
# 
cls
#changes the working directory to where the script is run from, ensuring that the icons will be found
cd $PSScriptRoot
[void][reflection.assembly]::LoadWithPartialName("System.Windows.Forms")
[void][reflection.assembly]::LoadWithPartialName("System.Drawing")
[System.Windows.Forms.Application]::EnableVisualStyles()
#gamegrids
$global:grid_player = @{"A1" = $null; "A2" = $null; "A3" = $null; "A4" = $null; "A5" = $null; "B1" = $null; "B2" = $null; "B3" = $null; "B4" = $null; "B5" = $null; "C1" = $null; "C2" = $null; "C3" = $null; "C4" = $null; "C5" = $null; "D1" = $null; "D2" = $null; "D3" = $null; "D4" = $null; "D5" = $null; "E1" = $null; "E2" = $null; "E3" = $null; "E4" = $null; "E5" = $null;}
$global:grid_ai = @{"A1" = $null; "A2" = $null; "A3" = $null; "A4" = $null; "A5" = $null; "B1" = $null; "B2" = $null; "B3" = $null; "B4" = $null; "B5" = $null; "C1" = $null; "C2" = $null; "C3" = $null; "C4" = $null; "C5" = $null; "D1" = $null; "D2" = $null; "D3" = $null; "D4" = $null; "D5" = $null; "E1" = $null; "E2" = $null; "E3" = $null; "E4" = $null; "E5" = $null;}
$global:coordinates = @("A1", "A2", "A3", "A4", "A5", "B1", "B2", "B3", "B4", "B5", "C1", "C2", "C3", "C4", "C5", "D1", "D2", "D3", "D4", "D5", "E1", "E2", "E3", "E4", "E5")
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
    $global:tabs[([int]$global:runde)].Height = 200
    $global:tabs[([int]$global:runde)].Width = 866
    $global:tabs[([int]$global:runde)].Name = "tabPage"+[string]$global:runde
    $global:tabs[([int]$global:runde)].Text = "Round "+[string]$global:runde
    $tabControl.SelectedTab = $global:tabs[([int]$global:runde)]
#add label for this tab
    [void]$global:labels.Add((Set-Variable -Name ("label"+[string]$global:runde)))
    $global:labels[([int]$global:runde)] = New-Object Windows.Forms.Label
    $global:labels[([int]$global:runde)].Width = 270
    $global:labels[([int]$global:runde)].height = 400
    $global:labels[([int]$global:runde)].font = $log
    $global:labels[([int]$global:runde)].Location = New-Object Drawing.Point 10,10
    $global:tabs[([int]$global:runde)].Controls.Add($global:labels[([int]$global:runde)]) #adds label to tabpage
    $tabControl.Controls.Add($global:tabs[([int]$global:runde)]) #adds tabpage to tabcontrol
    $global:labels[([int]$global:runde)].Text = "~~~~~~~~~~~~ YOUR TURN ~~~~~~~~~~~~"+"`n"+"`n"+"We're shooting at the enemy"+"`n"+"Sector $position!"+"`n"
#shoot at ai grid
    if ($global:grid_ai[$position] -eq $null)
        {
        $this.text = ""
        $this.image = $global:img_splash_button
        $global:labels[([int]$global:runde)].Text += "But the shot hit the waves!"+"`n"
        }
    else
        {
        foreach ($ship in $global:fleet_ai)
            {
            if ($ship.position -eq $position -or $ship.position1 -eq $position -or $ship.position2 -eq $position -or $ship.position3 -eq $position)
                {
                $ship.damaged = $true
                $ship.segments--
                $this.text = ""
                $this.image = $global:img_sunk_button
                if ($ship.segments -eq 0)
                    {
                    $global:labels[([int]$global:runde)].Text += "Bullseye! We sunk an enemy ship across the Sectors "+$ship.position+$ship.position1+$ship.position2+$ship.position3+"!"+"`n"
                    AddToSunk_ai($ship)
                    }
                else
                    {
                    $global:labels[([int]$global:runde)].Text += "The shot damaged an enemy ship!"+"`n"
                    }
                }
            }
        }
    $differenz_ai = ($global:fleet_ai.count - $global:sunk_ai.count)
    #checks if all enemy ships have been sunk -> victory
    if ($differenz_ai -eq 0)
        {
        $global:labels[([int]$global:runde)].Text += "`n"+"~~~~~~~~~~~~~ VICTORY ~~~~~~~~~~~~~"+"`n`n"+"We sunk all enemy ships across these Sectors:"+"`n"
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
        $global:willkommen.text = "Thou art"+"`n"+"victorious!"+"`n"
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
foreach ($i in 0..24)
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
                    }
                if ($global:index -eq 0 -and $global:index+5 -notin $ShotAt) # field top left (->can't shoot left or above) AND field below not shot at previously
                    {
                    $global:hitcounter = 4 # shoot below
                    } 
                elseif ($global:index -in (5,10,15,20) -and $global:index-5 -notin $ShotAt) # field on the left and not top row (->can't shoot left) AND field above not shot at previously
                    {
                    $global:hitcounter = 3 # shoot above
                    } 
                elseif  ($global:index -ne 0 -and $global:index-1 -notin $ShotAt) # field leftwise not shot at previously and not -1
                    {
                    $global:hitcounter = 2 # shoot left
                    } 
                elseif ($global:index -notin (0..4) -and $global:index-5 -notin $ShotAt) # field not top row AND field above not shot at previously
                    {
                    $global:hitcounter = 3 # shoot above
                    } 
                elseif ($global:index -notin (20..24) -and $global:index+5 -notin $ShotAt) # field not bottom row AND field below not shot at previously
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
                    }
                if ($global:index -notin (0..4) -and $global:index-5 -notin $ShotAt) # field not in top row (->can't shoot above) AND field above not shot at previously
                    {
                    $global:hitcounter = 3 # shoot above
                    } 
                elseif ($global:index -notin (20..24)  -and $global:index+5 -notin $ShotAt) # field not in bottom (->can't shoot below) AND field below not shot at previously
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
                    }
                if ($global:index -notin (20..24) -and $global:index+5 -notin $ShotAt) # field not bottom row AND field below not shot at previously
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
                            if ($global:index -in (4,9,14,19,24)) # field is right column
                                {
                                if($global:index-1 -notin $ShotAt) # left field not shot at
                                    {
                                    $global:hitcounter = 2 # shoot left
                                    }
                                elseif ($global:index-5 -notin $ShotAt -and $global:index -notin (0..4)) # field above not shot at AND not -1
                                    {
                                    $global:hitcounter = 3 # shoot above
                                    }
                                elseif ($global:index+5 -notin $ShotAt -and $global:index -notin (20..24)) # field below not shot at AND not 24
                                    {
                                    $global:hitcounter = 4 # shoot below
                                    }
                                else
                                    {
                                    $global:hitcounter = 0 # else shoot random
                                    }
                                }
                            elseif ($global:index -in (0,5,10,15,20)) # field is left column
                                {
                                if ($global:index+1 -notin $ShotAt) # right field not shot at
                                    {
                                    $global:hitcounter = 1
                                    }
                                elseif ($global:index -ne 0 -and $global:index-5 -notin $ShotAt) # field above not shot at AND not negative
                                    {
                                    $global:hitcounter = 3 # shoot above
                                    }
                                elseif ($global:index -ne 20 -and $global:index+5 -notin $ShotAt) # field below not shot AND < 20
                                    {
                                    $global:hitcounter = 4 # shoot below
                                    }
                                }
                            else # field not left or right column (-> 1,2,3,6,7,8,11,12,13,16,17,18,21,22,23)
                                {
                                if ($global:index+1 -notin $ShotAt) # field to the right not shot at
                                    {
                                    $global:hitcounter = 1 # shoot right
                                    }
                                elseif ($global:index-1 -notin $ShotAt) # field to the left not shot at
                                    {
                                    $global:hitcounter = 2 # shoot left
                                    }
                                elseif ($global:index-5 -notin $ShotAt -and $global:index -notin (0..4)) # field above not shot at and not negative
                                    {
                                    $global:hitcounter = 3 # shoot above
                                    }
                                elseif ($global:index+5 -notin $ShotAt-and $global:index -notin (20..24))
                                    {
                                    $global:hitcounter = 4 # shoot below
                                    }
                                else
                                    {
                                    $global:hitcounter = 0 # shoot random
                                    }
                                }
                            }
                        1 #shot to the right hit
                            {
                            $global:temp++
                            #continue shooting right if
                            if ($global:index+1 -notin $ShotAt -and $global:index -notin (4,9,14,19,24)) # field  not right column and not shot at
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
                                    }
                                $global:temp = 0 # indicates that the index has been reset
                                }
                            if ($global:temp -eq 0) # checks if the index has been reset and, if true, chooses another shoot option 
                                {
                                if ($global:index-1 -notin $ShotAt -and $global:index -notin (0,5,10,15,20)) # field to the left not shot at AND index (where the random hit occured) not left column
                                    {
                                    $global:hitcounter = 2 # shoot left
                                    }
                                elseif ($global:index-5 -notin $ShotAt -and $global:index -notin (0..4)) # field above not shot at AND index (where the random hit occured) not top row
                                    {
                                    $global:hitcounter = 3 # shoot above
                                    }
                                elseif ($global:index+5 -notin $ShotAt -and $global:index -notin (20..24)) # field below not shot at AND index (where the random hit occured) not bottom row
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
                            if ($global:index-1 -notin $ShotAt -and $global:index -notin (0,5,10,15,20)) #field not on left column and not shot at
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
                                    }
                                $global:temp = 0 # indicates that the index has been reset
                                }
                            if ($global:temp -eq 0) # checks if the index has been reset and, if true, chooses another shoot option 
                                {
                                if ($global:index-5 -notin $ShotAt -and $global:index -notin (0..4)) # field above not shot at and index not in top row
                                    {
                                    $global:hitcounter = 3 # shoot above
                                    }
                                elseif ($global:index+5 -notin $ShotAt -and $global:index -notin (20..24)) # field below not shot at and index not bottom row
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
                            if ($global:index-5 -notin $ShotAt -and $global:index -notin (0..4)) #index not on top row and field above not shot at
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
                                    }
                                $global:temp = 0 # indicates that the index has been reset
                                }
                            if ($global:temp -eq 0) # checks if the index has been reset and, if true, chooses another shoot option
                                {
                                if ($global:index+5 -notin $ShotAt -and $global:index -notin (20..24)) # field below not shot at AND index not in bottom row
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
                            if ($global:index -notin (20..24) -and $global:index+5 -notin $ShotAt) # if index not bottom row AND field below not sho at
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
    if ($global:fleet_player.Count -eq $sunk_player.Count -and $sunk_player.Count -eq 4)
        {
        $global:labels[([int]$global:runde)].Text += "`n"+"~~~~~~~~~~~~~ DEFEAT ~~~~~~~~~~~~~"+"`n`n"+"All our ships have been sunk in battle!"+"`n"
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
        $global:willkommen.text = "Thou hast been"+"`n"+"defeated!"
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
    $global:labels[([int]$global:runde)].Text += "`n"+"~~~~~~~~~~~ ENEMY TURN ~~~~~~~~~~~~"+"`n"+"`n"
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
            $global:index = $global:index - 5
            $ShotAt.Add($global:index)
            ShotsFired $global:runde
            }
        4 #shoot below
            {
            $global:index = $global:index + 5
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
    if ($randomnum.Contains($temp0+5) -and ($global:coordinates[$temp0][1] -match $global:coordinates[$temp0+5][1]))
        {
        $temp1 = $temp0+5
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
#AI ship1, 2 segments
$segmentsnum = 2
do 
    {
    do 
        {
    $temp0 = Get-Random -InputObject $randomnum
        }
        while ($temp0 -eq 24) #cannot put starting point of 2 segment ship in the bottom right corner
    if ($randomnum.Contains($temp0+1) -and (($global:coordinates[$temp0][0]) -match ($global:coordinates[$temp0+1][0])))
        {
        $temp1 = $temp0+1
        $check = 1
        }
    elseif ($randomnum.Contains($temp0+5) -and ($global:coordinates[$temp0][1] -match $global:coordinates[$temp0+5][1]))
        {
        $temp1 = $temp0+5
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
        while ($temp0 -in (18,19,23,24)) #cannot put starting point of 3 segment ship in the 4 bottom right fields
    if ($randomnum.Contains($temp0+1) -and $randomnum.Contains($temp0+2) -and ($global:coordinates[$temp0][0] -match $global:coordinates[$temp0+1][0]) -and ($global:coordinates[$temp0][0] -match $global:coordinates[$temp0+2][0]))
        {
        $temp1 = $temp0+1
        $temp2 = $temp0+2
        $check = 1
        }
    elseif ($randomnum.Contains($temp0+5) -and $randomnum.Contains($temp0+10) -and ($global:coordinates[$temp0][1] -match $global:coordinates[$temp0+5][1]) -and ($global:coordinates[$temp0][1] -match $global:coordinates[$temp0+10][1]))
        {
        $temp1 = $temp0+5
        $temp2 = $temp0+10
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
    if ($randomnum.Contains($temp0+1) -and $randomnum.Contains($temp0+2) -and $randomnum.Contains($temp0+3) -and ($global:coordinates[$temp0][0] -match $global:coordinates[$temp0+1][0]) -and ($global:coordinates[$temp0][0] -match $global:coordinates[$temp0+2][0]) -and ($global:coordinates[$temp0][0] -match $global:coordinates[$temp0+3][0]))
        {
        $temp1 = $temp0+1
        $temp2 = $temp0+2
        $temp3 = $temp0+3
        $check = 1
        }
    elseif ($randomnum.Contains($temp0+5) -and $randomnum.Contains($temp0+10) -and $randomnum.Contains($temp0+15) -and ($global:coordinates[$temp0][1] -match $global:coordinates[$temp0+5][1]) -and ($global:coordinates[$temp0][1] -match $global:coordinates[$temp0+10][1]) -and ($global:coordinates[$temp0][1] -match $global:coordinates[$temp0+15][1]))
        {
        $temp1 = $temp0+5
        $temp2 = $temp0+10
        $temp3 = $temp0+15
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
#GAME WINDOW
#create the game window
$global:Form = New-Object "System.Windows.Forms.Form"
$global:runde = 1
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
$global:willkommen=New-Object Windows.Forms.Label
$global:willkommen.Text = ""
$global:willkommen.Width = 200
$global:willkommen.Height = 120
$global:willkommen.AutoSize = $false
$global:willkommen.TextAlign = "Middlecenter"
$global:willkommen.font = $font
$global:willkommen.Location = New-Object Drawing.Point 65,350

#   ______      ______                 ____                __       __                               
#  /\  _  \    /\__  _\               /\  _`\             /\ \__   /\ \__                            
#  \ \ \L\ \   \/_/\ \/               \ \ \L\ \   __  __  \ \ ,_\  \ \ ,_\    ___     ___      ____  
#   \ \  __ \     \ \ \                \ \  _ <' /\ \/\ \  \ \ \/   \ \ \/   / __`\ /' _ `\   /',__\ 
#    \ \ \/\ \     \_\ \__              \ \ \L\ \\ \ \_\ \  \ \ \_   \ \ \_ /\ \L\ \/\ \/\ \ /\__, `\
#     \ \_\ \_\    /\_____\              \ \____/ \ \____/   \ \__\   \ \__\\ \____/\ \_\ \_\\/\____/
#      \/_/\/_/    \/_____/               \/___/   \/___/     \/__/    \/__/ \/___/  \/_/\/_/ \/___/ 
#
#AI BUTTONS
$global:buttons = New-Object System.Collections.ArrayList
$buttonnumber = 0
#defines the ai buttons' x-y coordinates
foreach ($i in $global:coordinates)
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
    #activate the buttons where you can put a ship of certain length, determined by the $global:shipnum written by a shipbutton(0..3)'s Click action
    switch ($global:shipnum)
        {
        0 #3 fields
            {  
            foreach ($i in (0..14))
                {
                if ($global:buttons_player[$i].Text -ne "")
                    {
                    $global:buttons_player[$i].enabled = $true
                    }
                elseif ($global:buttons_player[$i].Text -eq "")
                    {
                    $global:buttons_player[$i].enabled = $false
                    if ($i-5 -ge 0) {$global:buttons_player[$i-5].enabled = $false}
                    if ($i-10 -ge 0) {$global:buttons_player[$i-10].enabled = $false}
                    }
                }
            foreach ($i in (15..24))
                {
                if ($global:buttons_player[$i].Text -eq "")
                    {
                    $global:buttons_player[$i].enabled = $false
                    if ($i-5 -ge 0) {$global:buttons_player[$i-5].enabled = $false}
                    if ($i-10 -ge 0) {$global:buttons_player[$i-10].enabled = $false}
                    }
                }
            }
        1 #2 fields
            {  
            foreach ($i in (0..19))
                {
                if ($global:buttons_player[$i].Text -ne "")
                    {
                    $global:buttons_player[$i].enabled = $true
                    }
                elseif ($global:buttons_player[$i].Text -eq "")
                    {
                    $global:buttons_player[$i].enabled = $false
                    if ($i-5 -ge 0) {$global:buttons_player[$i-5].enabled = $false}
                    }
                }
            foreach ($i in (20..24))
                {
                if ($global:buttons_player[$i].Text -eq "")
                    {
                    $global:buttons_player[$i].enabled = $false
                    if ($i-5 -ge 0) {$global:buttons_player[$i-5].enabled = $false}
                    }
                }
            }
        2 #2 fields
            {  
            foreach ($i in (0..19))
                {
                if ($global:buttons_player[$i].Text -ne "")
                    {
                    $global:buttons_player[$i].enabled = $true
                    }
                elseif ($global:buttons_player[$i].Text -eq "")
                    {
                    $global:buttons_player[$i].enabled = $false
                    if ($i-5 -ge 0) {$global:buttons_player[$i-5].enabled = $false}
                    }
                }
            foreach ($i in (20..24))
                {
                if ($global:buttons_player[$i].Text -eq "")
                    {
                    $global:buttons_player[$i].enabled = $false
                    if ($i-5 -ge 0) {$global:buttons_player[$i-5].enabled = $false}
                    }
                }
            }
        3 #4 fields
            {  
            foreach ($i in (0..9))
                {
                if ($global:buttons_player[$i].Text -ne "")
                    {
                    $global:buttons_player[$i].enabled = $true
                    }
                elseif ($global:buttons_player[$i].Text -eq "")
                    {
                    $global:buttons_player[$i].enabled = $false
                    if ($i-5 -ge 0) {$global:buttons_player[$i-5].enabled = $false}
                    if ($i-10 -ge 0) {$global:buttons_player[$i-5].enabled = $false}
                    if ($i-15 -ge 0) {$global:buttons_player[$i-5].enabled = $false}
                    }
                }
            foreach ($i in (10..24))
                {
                if ($global:buttons_player[$i].Text -eq "")
                    {
                    $global:buttons_player[$i].enabled = $false
                    if ($i-5 -ge 0) {$global:buttons_player[$i-5].enabled = $false}
                    if ($i-10 -ge 0) {$global:buttons_player[$i-5].enabled = $false}
                    if ($i-15 -ge 0) {$global:buttons_player[$i-5].enabled = $false}
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
    #activate the buttons where you can put a ship of certain length, determined by the $global:shipnum written on ShipClick
    switch ($global:shipnum)
        {
        0 #3 fields
            {  
            foreach ($i in (0,1,2,5,6,7,10,11,12,15,16,17,20,21,22))
                {
                if ($global:buttons_player[$i].Text -ne "" -and $global:buttons_player[$i+1].Text -ne "" -and $global:buttons_player[$i+2].Text -ne "")
                    {
                    $global:buttons_player[$i].enabled = $true
                    }
                }
            }
        1 #2 fields
            {  
            foreach ($i in (0,1,2,3,5,6,7,8,10,11,12,13,15,16,17,18,20,21,22,23))
                {
                if ($global:buttons_player[$i].Text -ne "" -and $global:buttons_player[$i+1].Text -ne "")
                    {
                    $global:buttons_player[$i].enabled = $true
                    }
                }
            }
        2 #2 fields
            {  
            foreach ($i in (0,1,2,3,5,6,7,8,10,11,12,13,15,16,17,18,20,21,22,23))
                {
                if ($global:buttons_player[$i].Text -ne "" -and $global:buttons_player[$i+1].Text -ne "")
                    {
                    $global:buttons_player[$i].enabled = $true
                    }
                }
            }
        3 #4 fields
            {  
            foreach ($i in (0,1,5,6,10,11,15,16,20,21))
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
$button_back.Location = New-Object Drawing.Point 950,300
$button_back.Width = 40
$button_back.Height = 40
$button_back.Text = "Back"
$button_back.Visible = $false
$button_back.Add_Click(
    {
    if ($global:shipnum -eq 3)
        {
        $shipbutton3.Visible = $true
        }
    if ($global:shipnum -eq 2)
        {
        $shipbutton2.Visible = $true
        }
    if ($global:shipnum -eq 1)
        {
        $shipbutton1.Visible = $true
        }
    if ($global:shipnum -eq 0)
        {
        $shipbutton0.Visible = $true
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
#$playershipnum = 0
$segmentsnum = 0
$playerbool = $false
#defines the player buttons' x-y coordinates
foreach ($i in $global:coordinates)
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
                    $global:ship_player0 = [ShipPlayer]::new(0,$global:coordinates[$global:index],3,$global:coordinates[$global:index+5],$global:coordinates[$global:index+10])
                    $global:buttons_player[$global:index].Text = ""
                    $global:buttons_player[$global:index+5].Text = ""
                    $global:buttons_player[$global:index+10].Text = ""
                    $global:buttons_player[$global:index].image = $global:img_ship_button
                    $global:buttons_player[$global:index+5].image = $global:img_ship_button
                    $global:buttons_player[$global:index+10].image = $global:img_ship_button
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
                    $global:ship_player1 = [ShipPlayer]::new(1,$global:coordinates[$global:index],2,$global:coordinates[$global:index+5])
                    $global:buttons_player[$global:index].Text = ""
                    $global:buttons_player[$global:index+5].Text = ""
                    $global:buttons_player[$global:index].image = $global:img_ship_button
                    $global:buttons_player[$global:index+5].image = $global:img_ship_button
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
                    $global:ship_player2 = [ShipPlayer]::new(2,$global:coordinates[$global:index],2,$global:coordinates[$global:index+5])
                    $global:buttons_player[$global:index].Text = ""
                    $global:buttons_player[$global:index+5].Text = ""
                    $global:buttons_player[$global:index].image = $global:img_ship_button
                    $global:buttons_player[$global:index+5].image = $global:img_ship_button
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
                    $global:buttons_player[$global:index+5].Text = ""
                    $global:buttons_player[$global:index+10].Text = ""
                    $global:buttons_player[$global:index+15].Text = ""
                    $global:buttons_player[$global:index].image = $global:img_ship_button
                    $global:buttons_player[$global:index+5].image = $global:img_ship_button
                    $global:buttons_player[$global:index+10].image = $global:img_ship_button
                    $global:buttons_player[$global:index+15].image = $global:img_ship_button
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
            }
        $button_vertical.enabled = $true
        $button_horizontal.enabled = $true
        $button_vertical.visible = $false
        $button_horizontal.Visible = $false
        $button_back.Visible = $false
        $global:click = 0
        $global:playershipcounter++
        if ($global:playerShipCounter -eq 4)
            {
            $shipbutton0.Visible = $false
            $shipbutton1.Visible = $false
            $shipbutton2.Visible = $false
            $shipbutton3.Visible = $false
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
$global:form.Controls.Add($gegner)
$global:form.Controls.Add($global:willkommen)
$global:form.Controls.Add($spieler)
$global:Form.Text = "Battleship"
$global:Form.Height = 600
$global:Form.Width = 1066
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
#   __  __                           __                   __       ___                        
#  /\ \/\ \                         /\ \                 /\ \__   /\_ \                       
#  \ \ \/'/'     ___     ___ ___    \ \ \____     __     \ \ ,_\  \//\ \      ___      __     
#   \ \ , <     / __`\ /' __` __`\   \ \ '__`\  /'__`\    \ \ \/    \ \ \    / __`\  /'_ `\   
#    \ \ \\`\  /\ \L\ \/\ \/\ \/\ \   \ \ \L\ \/\ \L\.\_   \ \ \_    \_\ \_ /\ \L\ \/\ \L\ \  
#     \ \_\ \_\\ \____/\ \_\ \_\ \_\   \ \_,__/\ \__/.\_\   \ \__\   /\____\\ \____/\ \____ \ 
#      \/_/\/_/ \/___/  \/_/\/_/\/_/    \/___/  \/__/\/_/    \/__/   \/____/ \/___/  \/___L\ \
#                                                                                      /\____/
#                                                                                      \_/__/ 
# Combat Log
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
$tabpage0.height = 440
$tabpage0.Width = 300
$tabPage0.Text = "Rules"
$tabPage0.Location = New-Object Drawing.Point 410,130
#label0
$label0 = New-Object Windows.Forms.Label
$label0.Text = "Welcome to Battleship!"+"`n"+"`n"+"Rules:"+"`n"+"`n"+"(1) First to sink all enemy ships wins."+"`n"+"`n"+"(2) A fleet consists of four different ships:"+"`n"+" a) Aircraft Carrier (Length: 4)"+"`n"+" b) Battleship (Length: 3)"+"`n"+" c) Submarine (Length: 2)"+"`n"+" d) Destroyer (Length: 2)"+"`n"+"`n"+"(3) Player shoots first."+"`n"+"`n"+"`n"+"Choose a ship, its orientation and then the coordinate where the ship should be situated!"+"`n"+"The selected coordinate is always the top- and leftmost point of the ship."+"`n"+"`n"+"When you're done placing our fleet, shoot at an enemy sector by clicking on it!"+"`n"+"`n"
$label0.Width = 250
$label0.height = 440
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
$global:form.Controls.Add($forfeit)
#close and start buttons #end
function gameend()
    {
    foreach ($button in $global:buttons)
        {
        $button.enabled = $false
        }
    foreach ($ship in $fleet_ai)
            {
                switch ($ship.position)
                    {
                    A1 {$gameend = 0}
                    A2 {$gameend = 1}
                    A3 {$gameend = 2}
                    A4 {$gameend = 3}
                    A5 {$gameend = 4}
                    B1 {$gameend = 5}
                    B2 {$gameend = 6}
                    B3 {$gameend = 7}
                    B4 {$gameend = 8}
                    B5 {$gameend = 9}
                    C1 {$gameend = 10}
                    C2 {$gameend = 11}
                    C3 {$gameend = 12}
                    C4 {$gameend = 13}
                    C5 {$gameend = 14}
                    D1 {$gameend = 15}
                    D2 {$gameend = 16}
                    D3 {$gameend = 17}
                    D4 {$gameend = 18}
                    D5 {$gameend = 19}
                    E1 {$gameend = 20}
                    E2 {$gameend = 21}
                    E3 {$gameend = 22}
                    E4 {$gameend = 23}
                    E5 {$gameend = 24}
                    }
                if ($global:buttons[$gameend].Image -eq $null)
                    {
                    $global:buttons[$gameend].Image = $img_ship_button
                    $global:buttons[$gameend].Text = ""
                    }

                switch ($ship.position1)
                    {
                    A1 {$gameend = 0}
                    A2 {$gameend = 1}
                    A3 {$gameend = 2}
                    A4 {$gameend = 3}
                    A5 {$gameend = 4}
                    B1 {$gameend = 5}
                    B2 {$gameend = 6}
                    B3 {$gameend = 7}
                    B4 {$gameend = 8}
                    B5 {$gameend = 9}
                    C1 {$gameend = 10}
                    C2 {$gameend = 11}
                    C3 {$gameend = 12}
                    C4 {$gameend = 13}
                    C5 {$gameend = 14}
                    D1 {$gameend = 15}
                    D2 {$gameend = 16}
                    D3 {$gameend = 17}
                    D4 {$gameend = 18}
                    D5 {$gameend = 19}
                    E1 {$gameend = 20}
                    E2 {$gameend = 21}
                    E3 {$gameend = 22}
                    E4 {$gameend = 23}
                    E5 {$gameend = 24}
                    }
                if ($global:buttons[$gameend].Image -eq $null)
                    {
                    $global:buttons[$gameend].Image = $img_ship_button
                    $global:buttons[$gameend].Text = ""
                    }

                switch ($ship.position2)
                    {
                    A1 {$gameend = 0}
                    A2 {$gameend = 1}
                    A3 {$gameend = 2}
                    A4 {$gameend = 3}
                    A5 {$gameend = 4}
                    B1 {$gameend = 5}
                    B2 {$gameend = 6}
                    B3 {$gameend = 7}
                    B4 {$gameend = 8}
                    B5 {$gameend = 9}
                    C1 {$gameend = 10}
                    C2 {$gameend = 11}
                    C3 {$gameend = 12}
                    C4 {$gameend = 13}
                    C5 {$gameend = 14}
                    D1 {$gameend = 15}
                    D2 {$gameend = 16}
                    D3 {$gameend = 17}
                    D4 {$gameend = 18}
                    D5 {$gameend = 19}
                    E1 {$gameend = 20}
                    E2 {$gameend = 21}
                    E3 {$gameend = 22}
                    E4 {$gameend = 23}
                    E5 {$gameend = 24}
                    }
                if ($global:buttons[$gameend].Image -eq $null)
                    {
                    $global:buttons[$gameend].Image = $img_ship_button
                    $global:buttons[$gameend].Text = ""
                    }

                switch ($ship.position3)
                    {
                    A1 {$gameend = 0}
                    A2 {$gameend = 1}
                    A3 {$gameend = 2}
                    A4 {$gameend = 3}
                    A5 {$gameend = 4}
                    B1 {$gameend = 5}
                    B2 {$gameend = 6}
                    B3 {$gameend = 7}
                    B4 {$gameend = 8}
                    B5 {$gameend = 9}
                    C1 {$gameend = 10}
                    C2 {$gameend = 11}
                    C3 {$gameend = 12}
                    C4 {$gameend = 13}
                    C5 {$gameend = 14}
                    D1 {$gameend = 15}
                    D2 {$gameend = 16}
                    D3 {$gameend = 17}
                    D4 {$gameend = 18}
                    D5 {$gameend = 19}
                    E1 {$gameend = 20}
                    E2 {$gameend = 21}
                    E3 {$gameend = 22}
                    E4 {$gameend = 23}
                    E5 {$gameend = 24}
                    }
                if ($global:buttons[$gameend].Image -eq $null)
                    {
                    $global:buttons[$gameend].Image = $img_ship_button
                    $global:buttons[$gameend].Text = ""
                    }
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
        $global:form.Close()
        $global:form.Dispose()
        powershell.exe -file '.\schiffeversenken_v3.0.ps1'
        }
        )
    $global:form.Controls.Add($restartbutton)
    $endbutton = New-Object System.Windows.Forms.button
    $endbutton.Location = New-Object Drawing.Point 825,425
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
#shows the complete window:
$global:Form.ShowDialog()