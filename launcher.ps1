Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# --- HET VENSTER ---
$form = New-Object System.Windows.Forms.Form
$form.Text = "MAZI SS"
$form.Size = New-Object System.Drawing.Size(650, 480)
$form.BackColor = [System.Drawing.Color]::FromArgb(18, 18, 18)
$form.StartPosition = "CenterScreen"
$form.FormBorderStyle = "None" 

# Sleepfunctie (Omdat de balk weg is)
$mouseDown = $false
$form.add_MouseDown({ $script:mouseDown = $true; $script:startPos = [System.Windows.Forms.Cursor]::Position; $script:formPos = $form.Location })
$form.add_MouseMove({
    if ($script:mouseDown) {
        $pos = [System.Windows.Forms.Cursor]::Position
        $form.Location = [System.Drawing.Point]::new($script:formPos.X + ($pos.X - $script:startPos.X), $script:formPos.Y + ($pos.Y - $script:startPos.Y))
    }
})
$form.add_MouseUp({ $script:mouseDown = $false })

# --- TITEL ---
$title = New-Object System.Windows.Forms.Label
$title.Text = "MAZI SS"
$title.Font = New-Object System.Drawing.Font("Segoe UI", 22, [System.Drawing.FontStyle]::Bold)
$title.ForeColor = [System.Drawing.Color]::White
$title.Location = New-Object System.Drawing.Point(40, 40)
$title.Size = New-Object System.Drawing.Size(200, 50)
$form.Controls.Add($title)

$subTitle = New-Object System.Windows.Forms.Label
$subTitle.Text = "PREMIUM TOOLS"
$subTitle.Font = New-Object System.Drawing.Font("Segoe UI", 8)
$subTitle.ForeColor = [System.Drawing.Color]::FromArgb(80, 80, 80)
$subTitle.Location = New-Object System.Drawing.Point(480, 45)
$subTitle.Size = New-Object System.Drawing.Size(120, 20)
$subTitle.TextAlign = "Right"
$form.Controls.Add($subTitle)

# --- ICON (VEILIG SYMBOOL) ---
$icon = New-Object System.Windows.Forms.Label
$icon.Text = "O" 
$icon.Font = New-Object System.Drawing.Font("Segoe UI", 45, [System.Drawing.FontStyle]::Bold)
$icon.ForeColor = [System.Drawing.Color]::FromArgb(0, 180, 255)
$icon.Location = New-Object System.Drawing.Point(275, 100)
$icon.Size = New-Object System.Drawing.Size(100, 100)
$icon.TextAlign = "MiddleCenter"
$form.Controls.Add($icon)

# --- PIN LABEL ---
$pinText = New-Object System.Windows.Forms.Label
$pinText.Text = "PIN"
$pinText.Font = New-Object System.Drawing.Font("Segoe UI", 12)
$pinText.ForeColor = [System.Drawing.Color]::FromArgb(100, 100, 100)
$pinText.Location = New-Object System.Drawing.Point(0, 210)
$pinText.Size = New-Object System.Drawing.Size(650, 30)
$pinText.TextAlign = "MiddleCenter"
$form.Controls.Add($pinText)

# --- INPUT VELD ---
$inputBox = New-Object System.Windows.Forms.TextBox
$inputBox.Size = New-Object System.Drawing.Size(200, 30)
$inputBox.Location = New-Object System.Drawing.Point(225, 245)
$inputBox.BackColor = [System.Drawing.Color]::FromArgb(18, 18, 18)
$inputBox.ForeColor = [System.Drawing.Color]::White
$inputBox.Font = New-Object System.Drawing.Font("Segoe UI", 14)
$inputBox.BorderStyle = "None"
$inputBox.TextAlign = "Center"
$form.Controls.Add($inputBox)

$line = New-Object System.Windows.Forms.Label
$line.Location = New-Object System.Drawing.Point(225, 275)
$line.Size = New-Object System.Drawing.Size(200, 2)
$line.BackColor = [System.Drawing.Color]::FromArgb(0, 180, 255)
$form.Controls.Add($line)

# --- KNOP (ZONDER "CHECK DOWNLOAD") ---
$btn = New-Object System.Windows.Forms.Button
$btn.Text = "ENTER"
$btn.Size = New-Object System.Drawing.Size(200, 40)
$btn.Location = New-Object System.Drawing.Point(225, 300)
$btn.FlatStyle = "Flat"
$btn.BackColor = [System.Drawing.Color]::White
$btn.ForeColor = [System.Drawing.Color]::Black
$btn.Font = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold)
$btn.FlatAppearance.BorderSize = 0
$form.Controls.Add($btn)

# --- STATUS ---
$status = New-Object System.Windows.Forms.Label
$status.Text = "SYSTEM READY"
$status.ForeColor = [System.Drawing.Color]::FromArgb(0, 180, 255)
$status.Font = New-Object System.Drawing.Font("Segoe UI", 9, [System.Drawing.FontStyle]::Bold)
$status.Location = New-Object System.Drawing.Point(0, 360)
$status.Size = New-Object System.Drawing.Size(650, 20)
$status.TextAlign = "MiddleCenter"
$form.Controls.Add($status)

# --- LOGS ---
$logBox = New-Object System.Windows.Forms.Label
$logBox.Size = New-Object System.Drawing.Size(570, 40)
$logBox.Location = New-Object System.Drawing.Point(40, 400)
$logBox.ForeColor = [System.Drawing.Color]::DimGray
$logBox.Font = New-Object System.Drawing.Font("Consolas", 8)
$logBox.Text = "[SYS] Awaiting input..."
$form.Controls.Add($logBox)

# --- SLUITEN ---
$close = New-Object System.Windows.Forms.Label
$close.Text = "X"
$close.ForeColor = [System.Drawing.Color]::Gray
$close.Location = New-Object System.Drawing.Point(610, 15)
$close.Cursor = [System.Windows.Forms.Cursors]::Hand
$close.add_Click({ $form.Close() })
$form.Controls.Add($close)

# --- LOGICA ---
$btn.Add_Click({
    $p = $inputBox.Text
    if ($p.Length -lt 1) { return }
    $status.Text = "VERIFYING..."
    try {
        $u = "https://ss-mazi-default-rtdb.europe-west1.firebasedatabase.app/pins/$p.json"
        $d = Invoke-WebRequest -Uri $u -UseBasicParsing | ConvertFrom-Json
        if ($d) {
            $status.Text = "SUCCESS"
            $status.ForeColor = [System.Drawing.Color]::LimeGreen
            Start-Process $d
            $form.Close()
        } else {
            $status.Text = "INVALID PIN"
            $status.ForeColor = [System.Drawing.Color]::Red
        }
    } catch {
        $status.Text = "ERROR"
    }
})

$form.ShowDialog()
