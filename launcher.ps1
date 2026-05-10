Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# --- VENSTER INSTELLINGEN ---
$form = New-Object System.Windows.Forms.Form
$form.Text = "MAZI SS"
$form.Size = New-Object System.Drawing.Size(650, 480)
$form.BackColor = [System.Drawing.Color]::FromArgb(18, 18, 18) # #121212
$form.StartPosition = "CenterScreen"
$form.FormBorderStyle = "FixedDialog" # Voor die strakke look

# --- HEADER: TITEL & SUBTITLE ---
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
$subTitle.ForeColor = [System.Drawing.Color]::FromArgb(68, 68, 68) # #444
$subTitle.Location = New-Object System.Drawing.Point(500, 25)
$subTitle.Size = New-Object System.Drawing.Size(120, 20)
$subTitle.TextAlign = "Right"
$form.Controls.Add($subTitle)

# --- SEARCH ICON (CENTRALE CIRKEL) ---
$iconCircle = New-Object System.Windows.Forms.Panel
$iconCircle.Size = New-Object System.Drawing.Size(80, 80)
$iconCircle.Location = New-Object System.Drawing.Point(285, 80)
$iconCircle.BackColor = [System.Drawing.Color]::FromArgb(24, 24, 24) # #181818
# Tip: Echte cirkels zijn lastig in PS, dit wordt een strak vierkant/paneel
$form.Controls.Add($iconCircle)

$icon = New-Object System.Windows.Forms.Label
$icon.Text = "🔍"
$icon.Font = New-Object System.Drawing.Font("Segoe UI", 30)
$icon.ForeColor = [System.Drawing.Color]::White
$icon.Size = New-Object System.Drawing.Size(80, 80)
$icon.TextAlign = "MiddleCenter"
$iconCircle.Controls.Add($icon)

# --- INPUT VELD ---
$input = New-Object System.Windows.Forms.TextBox
$input.Size = New-Object System.Drawing.Size(250, 40)
$input.Location = New-Object System.Drawing.Point(200, 200)
$input.BackColor = [System.Drawing.Color]::FromArgb(18, 18, 18)
$input.ForeColor = [System.Drawing.Color]::White
$input.Font = New-Object System.Drawing.Font("Segoe UI", 14)
$input.TextAlign = "Center"
$input.BorderStyle = "FixedSingle"
$input.MaxLength = 4
$form.Controls.Add($input)

# --- BUTTON ---
$btn = New-Object System.Windows.Forms.Button
$btn.Text = "CHECK & DOWNLOAD"
$btn.Size = New-Object System.Drawing.Size(200, 45)
$btn.Location = New-Object System.Drawing.Point(225, 260)
$btn.FlatStyle = "Flat"
$btn.BackColor = [System.Drawing.Color]::White
$btn.ForeColor = [System.Drawing.Color]::Black
$btn.Font = New-Object System.Drawing.Font("Segoe UI", 9, [System.Drawing.FontStyle]::Bold)
$form.Controls.Add($btn)

# --- STATUS TEXT ---
$status = New-Object System.Windows.Forms.Label
$status.Text = "SYSTEM READY"
$status.ForeColor = [System.Drawing.Color]::FromArgb(0, 210, 255) # #00d2ff
$status.Font = New-Object System.Drawing.Font("Segoe UI", 9, [System.Drawing.FontStyle]::Bold)
$status.Size = New-Object System.Drawing.Size(650, 30)
$status.Location = New-Object System.Drawing.Point(0, 320)
$status.TextAlign = "MiddleCenter"
$form.Controls.Add($status)

# --- LOG BOX ---
$logBox = New-Object System.Windows.Forms.RichTextBox
$logBox.Size = New-Object System.Drawing.Size(590, 60)
$logBox.Location = New-Object System.Drawing.Point(30, 360)
$logBox.BackColor = [System.Drawing.Color]::Black
$logBox.ForeColor = [System.Drawing.Color]::FromArgb(51, 51, 51) # #333
$logBox.Font = New-Object System.Drawing.Font("Consolas", 8)
$logBox.ReadOnly = $true
$logBox.BorderStyle = "None"
$logBox.Text = "[SYS] Awaiting input..."
$form.Controls.Add($logBox)

# --- FUNCTIE: LOGGEN ---
function Add-Log ($msg) {
    $logBox.AppendText("`n> " + $msg)
    $logBox.SelectionStart = $logBox.Text.Length
    $logBox.ScrollToCaret()
}

# --- FUNCTIE: CHECK PIN (FIREBASE) ---
$btn.Add_Click({
    $pin = $input.Text
    if ($pin.Length -lt 4) { return }

    $status.Text = "VERIFYING..."
    $status.ForeColor = [System.Drawing.Color]::White
    Add-Log "Checking database..."

    try {
        $firebaseURL = "https://ss-mazi-default-rtdb.europe-west1.firebasedatabase.app/pins/$pin.json"
        $downloadUrl = Invoke-RestMethod -Uri $firebaseURL -Method Get

        if ($downloadUrl -ne $null) {
            $status.Text = "SUCCESS - DOWNLOADING"
            $status.ForeColor = [System.Drawing.Color]::LimeGreen
            Add-Log "Link found: $downloadUrl"
            Add-Log "System triggered download folder."
            Start-Process $downloadUrl
        } else {
            $status.Text = "INVALID PIN"
            $status.ForeColor = [System.Drawing.Color]::Crimson
            Add-Log "Error: PIN expired or wrong."
        }
    } catch {
        $status.Text = "CONNECTION ERROR"
        Add-Log "Error: $($_.Exception.Message)"
    }
})

$form.ShowDialog()
