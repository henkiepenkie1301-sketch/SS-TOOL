Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Formulier instellingen (Dark Mode)
$form = New-Object System.Windows.Forms.Form
$form.Text = "MAZI SS PREMIUM"
$form.Size = New-Object System.Drawing.Size(400,300)
$form.StartPosition = "CenterScreen"
$form.BackColor = [System.Drawing.Color]::FromArgb(18,18,18) # Diep zwart
$form.FormBorderStyle = "None" # Verwijdert de lelijke witte balk bovenin
$form.Padding = New-Object System.Windows.Forms.Padding(10)

# Sleepfunctie toevoegen (omdat de balk weg is)
$form.add_MouseDown({
    if ($_.Button -eq [System.Windows.Forms.MouseButtons]::Left) {
        $script:dragging = $true
        $script:dragStart = [System.Windows.Forms.Cursor]::Position
        $script:formStart = $form.Location
    }
})
$form.add_MouseMove({
    if ($script:dragging) {
        $diff = [System.Drawing.Point]::Subtract([System.Windows.Forms.Cursor]::Position, $script:dragStart)
        $form.Location = [System.Drawing.Point]::Add($script:formStart, $diff)
    }
})
$form.add_MouseUp({ $script:dragging = $false })

# Titel Label
$title = New-Object System.Windows.Forms.Label
$title.Text = "MAZI SS"
$title.Font = New-Object System.Drawing.Font("Segoe UI", 16, [System.Drawing.FontStyle]::Bold)
$title.ForeColor = [System.Drawing.Color]::FromArgb(0, 210, 255) # Neon Blauw
$title.TextAlign = "AlignCenter"
$title.Dock = "Top"
$title.Height = 50
$form.Controls.Add($title)

# PIN Label
$label = New-Object System.Windows.Forms.Label
$label.Text = "ENTER SYSTEM PIN"
$label.ForeColor = [System.Drawing.Color]::Gray
$label.TextAlign = "AlignCenter"
$label.Dock = "Top"
$label.Height = 30
$form.Controls.Add($label)

# Input Box (Zwart met blauwe rand)
$inputBox = New-Object System.Windows.Forms.TextBox
$inputBox.BackColor = [System.Drawing.Color]::FromArgb(30,30,30)
$inputBox.ForeColor = [System.Drawing.Color]::White
$inputBox.Font = New-Object System.Drawing.Font("Consolas", 14)
$inputBox.BorderStyle = "FixedSingle"
$inputBox.TextAlign = "Center"
$inputBox.Width = 200
$inputBox.Location = New-Object System.Drawing.Point(100, 120)
$form.Controls.Add($inputBox)

# Download Knop (Strak Wit/Blauw)
$button = New-Object System.Windows.Forms.Button
$button.Text = "AUTHENTICATE"
$button.FlatStyle = "Flat"
$button.FlatAppearance.BorderSize = 0
$button.BackColor = [System.Drawing.Color]::White
$button.ForeColor = [System.Drawing.Color]::Black
$button.Font = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold)
$button.Size = New-Object System.Drawing.Size(200, 40)
$button.Location = New-Object System.Drawing.Point(100, 180)
$button.Cursor = [System.Windows.Forms.Cursors]::Hand

$button.add_Click({
    $pin = $inputBox.Text
    $url = "https://ss-mazi-default-rtdb.europe-west1.firebasedatabase.app/pins/$pin.json"
    try {
        $downloadUrl = Invoke-RestMethod -Uri $url
        if ($downloadUrl) {
            $button.Text = "SUCCESS"
            $button.BackColor = [System.Drawing.Color]::LimeGreen
            Start-Process $downloadUrl
            Start-Sleep -Seconds 2
            $form.Close()
        } else {
            $button.Text = "INVALID PIN"
            $button.BackColor = [System.Drawing.Color]::DarkRed
            $button.ForeColor = [System.Drawing.Color]::White
        }
    } catch {
        $button.Text = "ERROR"
    }
})
$form.Controls.Add($button)

# Close Knop (X rechtsboven)
$closeBtn = New-Object System.Windows.Forms.Button
$closeBtn.Text = "X"
$closeBtn.Size = New-Object System.Drawing.Size(30,30)
$closeBtn.Location = New-Object System.Drawing.Point(365, 5)
$closeBtn.FlatStyle = "Flat"
$closeBtn.ForeColor = [System.Drawing.Color]::Gray
$closeBtn.FlatAppearance.BorderSize = 0
$closeBtn.add_Click({ $form.Close() })
$form.Controls.Add($closeBtn)

$form.ShowDialog()
