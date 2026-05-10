Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# --- HET VENSTER ---
$form = New-Object System.Windows.Forms.Form
$form.Text = "MAZI SS"
$form.Size = New-Object System.Drawing.Size(650, 480)
$form.BackColor = [System.Drawing.Color]::FromArgb(18, 18, 18)
$form.StartPosition = "CenterScreen"
$form.FormBorderStyle = "FixedDialog"
$form.MaximizeBox = $false

# --- HEADER ---
$title = New-Object System.Windows.Forms.Label
$title.Text = "MAZI SS"
$title.Font = New-Object System.Drawing.Font("Segoe UI", 20, [System.Drawing.FontStyle]::Bold)
$title.ForeColor = [System.Drawing.Color]::White
$title.Location = New-Object System.Drawing.Point(30, 20)
$title.Size = New-Object System.Drawing.Size(200, 40)
$form.Controls.Add($title)

$subTitle = New-Object System.Windows.Forms.Label
$subTitle.Text = "PREMIUM TOOLS"
$subTitle.Font = New-Object System.Drawing.Font("Segoe UI", 8)
$subTitle.ForeColor = [System.Drawing.Color]::Gray
$subTitle.Location = New-Object System.Drawing.Point(480, 25)
$subTitle.Size = New-Object System.Drawing.Size(120, 20)
$subTitle.TextAlign = "Right"
$form.Controls.Add($subTitle)

# --- ICON ---
$icon = New-Object System.Windows.Forms.Label
$icon.Text = "🔍"
$icon.Font = New-Object System.Drawing.Font("Segoe UI", 40)
$icon.Location = New-Object System.Drawing.Point(275, 80)
$icon.Size = New-Object System.Drawing.Size(100, 100)
$icon.TextAlign = "MiddleCenter"
$icon.ForeColor = [System.Drawing.Color]::White
$form.Controls.Add($icon)

# --- INPUT ---
$inputBox = New-Object System.Windows.Forms.TextBox
$inputBox.Size = New-Object System.Drawing.Size(250, 40)
$inputBox.Location = New-Object System.Drawing.Point(200, 200)
$inputBox.BackColor = [System.Drawing.Color]::FromArgb(30, 30, 30)
$inputBox.ForeColor = [System.Drawing.Color]::White
$inputBox.Font = New-Object System.Drawing.Font("Segoe UI", 14)
$inputBox.TextAlign = "Center"
$inputBox.BorderStyle = "FixedSingle"
$form.Controls.Add($inputBox)

# --- BUTTON ---
$btn = New-Object System.Windows.Forms.Button
$btn.Text = "CHECK & DOWNLOAD"
$btn.Size = New-Object System.Drawing.Size(250, 45)
$btn.Location = New-Object System.Drawing.Point(200, 260)
$btn.FlatStyle = "Flat"
$btn.BackColor = [System.Drawing.Color]::White
$btn.ForeColor = [System.Drawing.Color]::Black
$btn.Font = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold)
$btn.Cursor = [System.Windows.Forms.Cursors]::Hand
$form.Controls.Add($btn)

# --- STATUS ---
$status = New-Object System.Windows.Forms.Label
$status.Text = "SYSTEM READY"
$status.ForeColor = [System.Drawing.Color]::FromArgb(0, 210, 255)
$status.Font = New-Object System.Drawing.Font("Segoe UI", 9, [System.Drawing.FontStyle]::Bold)
$status.Size = New-Object System.Drawing.Size(650, 30)
$status.Location = New-Object System.Drawing.Point(0, 320)
$status.TextAlign = "MiddleCenter"
$form.Controls.Add($status)

# --- LOGS ---
$logBox = New-Object System.Windows.Forms.RichTextBox
$logBox.Size = New-Object System.Drawing.Size(590, 60)
$logBox.Location = New-Object System.Drawing.Point(30, 360)
$logBox.BackColor = [System.Drawing.Color]::Black
$logBox.ForeColor = [System.Drawing.Color]::Gray
$logBox.BorderStyle = "None"
$logBox.Font = New-Object System.Drawing.Font("Consolas", 8)
$logBox.Text = "[SYS] Awaiting input..."
$form.Controls.Add($logBox)

# --- DE ACTIE ---
$btn.Add_Click({
    $pin = $inputBox.Text
    if ($pin.Length -lt 1) { return }

    $status.Text = "VERIFYING..."
    $logBox.AppendText("`n> Checking PIN: $pin")

    try {
        $url = "https://ss-mazi-default-rtdb.europe-west1.firebasedatabase.app/pins/$pin.json"
        $response = Invoke-RestMethod -Uri $url -Method Get

        if ($null -ne $response) {
            $status.Text = "SUCCESS"
            $status.ForeColor = [System.Drawing.Color]::LimeGreen
            $logBox.AppendText("`n> Download started.")
            Start-Process $response
        } else {
            $status.Text = "INVALID PIN"
            $status.ForeColor = [System.Drawing.Color]::Red
            $logBox.AppendText("`n> Error: PIN not found.")
        }
    } catch {
        $status.Text = "DATABASE ERROR"
        $logBox.AppendText("`n> Error: " + $_.Exception.Message)
    }
})

# Toon het formulier
$form.ShowDialog()
