Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# --- HET VENSTER (DARK THEME & MODERN) ---
$form = New-Object System.Windows.Forms.Form
$form.Text = "MAZI SS"
$form.Size = New-Object System.Drawing.Size(650, 480)
$form.BackColor = [System.Drawing.Color]::FromArgb(18, 18, 18)
$form.StartPosition = "CenterScreen"
$form.FormBorderStyle = "None" # Verwijdert de witte balk voor die strakke look

# Maak het venster sleepbaar (omdat de balk weg is)
$mouseDown = $false
$form.add_MouseDown({ $script:mouseDown = $true; $script:startPos = [System.Windows.Forms.Cursor]::Position; $script:formPos = $form.Location })
$form.add_MouseMove({
    if ($script:mouseDown) {
        $pos = [System.Windows.Forms.Cursor]::Position
        $form.Location = [System.Drawing.Point]::new($script:formPos.X + ($pos.X - $script:startPos.X), $script:formPos.Y + ($pos.Y - $script:startPos.Y))
    }
})
$form.add_MouseUp({ $script:mouseDown = $false })

# --- TITEL (MAZI SS) ---
$title = New-Object System.Windows.Forms.Label
$title.Text = "MAZI SS"
$title.Font = New-Object System.Drawing.Font("Segoe UI", 22, [System.Drawing.FontStyle]::Bold)
$title.ForeColor = [System.Drawing.Color]::White
$title.Location = New-Object System.Drawing.Point(40, 40)
$title.Size = New-Object System.Drawing.Size(200, 50)
$form.Controls.Add($title)

# --- SUBTITEL (PREMIUM TOOLS) ---
$subTitle = New-Object System.Windows.Forms.Label
$subTitle.Text = "PREMIUM TOOLS"
$subTitle.Font = New-Object System.Drawing.Font("Segoe UI", 8)
$subTitle.ForeColor = [System.Drawing.Color]::FromArgb(80, 80, 80)
$subTitle.Location = New-Object System.Drawing.Point(480, 45)
$subTitle.Size = New-Object System.Drawing.Size(120, 20)
$subTitle.TextAlign = "Right"
$form.Controls.Add($subTitle)

# --- CENTRAAL ICON (MAGNIFIER) ---
$icon = New-Object System.Windows.Forms.Label
$icon.Text = "🔍"
$icon.Font = New-Object System.Drawing.Font("Segoe UI", 45)
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

# --- INPUT VELD (STREEP DESIGN) ---
$inputBox = New-Object System.Windows.Forms.TextBox
$inputBox.Size = New-Object System.Drawing.Size(200, 30)
$inputBox.Location = New-Object System.Drawing.Point(225, 245)
$inputBox.BackColor = [System.Drawing.Color]::FromArgb(18, 18, 18)
$inputBox.ForeColor = [System.Drawing.Color]::White
$inputBox.Font = New-Object System.Drawing.Font("Segoe UI", 14)
$inputBox.BorderStyle = "None" # Geen rand voor een moderne look
$inputBox.TextAlign = "Center"
$form.Controls.Add($inputBox)

# Blauwe lijn onder input
$line = New-Object System.Windows.Forms.Label
$line.Location = New-Object System.Drawing.Point(225, 275)
$line.Size = New-Object System.Drawing.Size(200, 2)
$line.BackColor = [System.Drawing.Color]::FromArgb(0, 180, 255)
$form.Controls.Add($line)

# --- KNOP (CHECK & DOWNLOAD) ---
$btn = New-Object System.Windows.Forms.Button
$btn.Text = "CHECK & DOWNLOAD"
$btn.Size = New-Object System.Drawing.Size(220, 45)
$btn.Location = New-Object System.Drawing.Point(215, 300)
$btn.FlatStyle = "Flat"
$btn.BackColor = [System.Drawing.Color]::White
$btn.ForeColor = [System.Drawing.Color]::Black
$btn.Font = New-Object System.Drawing.Font("Segoe UI", 9, [System.Drawing.FontStyle]::Bold)
$btn.FlatAppearance.BorderSize = 0
$form.Controls.Add($btn)

# --- STATUS (SYSTEM READY) ---
$status = New-Object System.Windows.Forms.Label
$status.Text = "SYSTEM READY"
$status.ForeColor = [System.Drawing.Color]::FromArgb(0, 180, 255)
$status.Font = New-Object System.Drawing.Font("Segoe UI", 9, [System.Drawing.FontStyle]::Bold)
$status.Location = New-Object System.Drawing.Point(0, 360)
$status.Size = New-Object System.Drawing.Size(650, 20)
$status.TextAlign = "MiddleCenter"
$form.Controls.Add($status)

# --- LOG BOX (ONDERAAN) ---
$logBox = New-Object System.Windows.Forms.RichTextBox
$logBox.Size = New-Object System.Drawing.Size(570, 60)
$logBox.Location = New-Object System.Drawing.Point(40, 390)
$logBox.BackColor = [System.Drawing.Color]::FromArgb(10, 10, 10)
$logBox.ForeColor = [System.Drawing.Color]::FromArgb(60, 60, 60)
$logBox.Font = New-Object System.Drawing.Font("Consolas", 8)
$logBox.BorderStyle = "None"
$logBox.ReadOnly = $true
$logBox.Text = "[SYS] Awaiting input..."
$form.Controls.Add($logBox)

# --- SLUITEN KNOP (X) ---
$close = New-Object System.Windows.Forms.Label
$close.Text = "✕"
$close.ForeColor = [System.Drawing.Color]::Gray
$close.Location = New-Object System.Drawing.Point(610, 15)
$close.Cursor = [System.Windows.Forms.Cursors]::Hand
$close.add_Click({ $form.Close() })
$form.Controls.Add($close)

# --- FIREBASE LOGIC ---
$btn.Add_Click({
    $pin = $inputBox.Text
    if ($pin.Length -lt 1) { return }
    $status.Text = "VERIFYING..."
    $logBox.AppendText("`n[SYS] Checking database for PIN: $pin")
    
    try {
        $url = "https://ss-mazi-default-rtdb.europe-west1.firebasedatabase.app/pins/$pin.json"
        $dlLink = Invoke-RestMethod -Uri $url -Method Get
        if ($dlLink) {
            $status.Text = "SUCCESS"
            $status.ForeColor = [System.Drawing.Color]::LimeGreen
            $logBox.AppendText("`n[AUTH] Access Granted. Triggering download...")
            Start-Process $dlLink
        } else {
            $status.Text = "INVALID PIN"
            $status.ForeColor = [System.Drawing.Color]::Red
            $logBox.AppendText("`n[ERR] PIN not found.")
        }
    } catch {
        $status.Text = "ERROR"
        $logBox.AppendText("`n[ERR] Connection failed.")
    }
})

$form.ShowDialog()
