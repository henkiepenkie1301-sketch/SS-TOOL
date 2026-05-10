Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# --- HET VENSTER ---
$form = New-Object System.Windows.Forms.Form
$form.Text = "MAZI SS"
$form.Size = New-Object System.Drawing.Size(650, 480)
$form.BackColor = [System.Drawing.Color]::FromArgb(18, 18, 18)
$form.StartPosition = "CenterScreen"
$form.FormBorderStyle = "None" 

# Sleep-functie voor het venster
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

# --- INPUT ---
$in = New-Object System.Windows.Forms.TextBox
$in.Size = New-Object System.Drawing.Size(240, 40)
$in.Location = New-Object System.Drawing.Point(205, 230)
$in.BackColor = [System.Drawing.Color]::FromArgb(25, 25, 25)
$in.ForeColor = [System.Drawing.Color]::White
$in.Font = New-Object System.Drawing.Font("Segoe UI", 14)
$in.BorderStyle = "FixedSingle"
$in.TextAlign = "Center"
$form.Controls.Add($in)

# --- KNOP ---
$btn = New-Object System.Windows.Forms.Button
$btn.Text = "EXECUTE"
$btn.Size = New-Object System.Drawing.Size(240, 45)
$btn.Location = New-Object System.Drawing.Point(205, 290)
$btn.FlatStyle = "Flat"
$btn.BackColor = [System.Drawing.Color]::White
$btn.Font = New-Object System.Drawing.Font("Segoe UI", 11, [System.Drawing.FontStyle]::Bold)
$form.Controls.Add($btn)

# --- STATUS ---
$status = New-Object System.Windows.Forms.Label
$status.Text = "READY TO LAUNCH"
$status.ForeColor = [System.Drawing.Color]::Gray
$status.Location = New-Object System.Drawing.Point(0, 360)
$status.Size = New-Object System.Drawing.Size(650, 20)
$status.TextAlign = "MiddleCenter"
$form.Controls.Add($status)

# --- SLUITEN ---
$close = New-Object System.Windows.Forms.Label
$close.Text = "X"
$close.ForeColor = [System.Drawing.Color]::Gray
$close.Location = New-Object System.Drawing.Point(610, 15)
$close.add_Click({ $form.Close() })
$form.Controls.Add($close)

# --- DE ACTIE ---
$btn.Add_Click({
    $p = $in.Text.Trim()
    if ($p.Length -lt 1) { return }
    $status.Text = "FETCHING DATA..."
    
    try {
        # Stap 1: Haal de rauwe data op
        $u = "https://ss-mazi-default-rtdb.europe-west1.firebasedatabase.app/pins/$p.json"
        $rawJson = (New-Object System.Net.WebClient).DownloadString($u)
        
        if ($rawJson -eq "null" -or -not $rawJson) {
            $status.Text = "INVALID PIN"
            $status.ForeColor = [System.Drawing.Color]::Red
            return
        }

        # Converteer naar een object dat we kunnen lezen
        $data = $rawJson | ConvertFrom-Json

        # Stap 2: Zoek de download link (bestand)
        # We kijken naar 'bestand', 'Bestand', of 'download'
        $fileUrl = ""
        if ($data.bestand) { $fileUrl = $data.bestand }
        elseif ($data.Bestand) { $fileUrl = $data.Bestand }
        elseif ($data.download) { $fileUrl = $data.download }

        if ($fileUrl -like "http*") {
            $status.Text = "DOWNLOADING..."
            $form.Refresh()
            $dest = "$env:TEMP\tool_installer.exe"
            (New-Object System.Net.WebClient).DownloadFile($fileUrl, $dest)
            Start-Process $dest
        }

        # Stap 3: Zoek de website link
        # We kijken naar 'link', 'Link', of 'url'
        $webUrl = ""
        if ($data.link) { $webUrl = $data.link }
        elseif ($data.Link) { $webUrl = $data.Link }
        elseif ($data.url) { $webUrl = $data.url }

        if ($webUrl -like "http*") {
            $status.Text = "OPENING WEBSITE..."
            $form.Refresh()
            # De meest krachtige manier om de browser te openen:
            [System.Diagnostics.Process]::Start($webUrl.Trim().Replace('"', ''))
        }

        $status.Text = "SUCCESS"
        $status.ForeColor = [System.Drawing.Color]::LimeGreen
        Start-Sleep -Seconds 2
        $form.Close()

    } catch {
        $status.Text = "CRITICAL ERROR"
        $status.ForeColor = [System.Drawing.Color]::Red
    }
})

$form.ShowDialog()
