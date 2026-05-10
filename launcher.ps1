Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# --- HET VENSTER ---
$form = New-Object System.Windows.Forms.Form
$form.Text = "MAZI SS"
$form.Size = New-Object System.Drawing.Size(650, 480)
$form.BackColor = [System.Drawing.Color]::FromArgb(18, 18, 18)
$form.StartPosition = "CenterScreen"
$form.FormBorderStyle = "None" 

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

# --- PIN INPUT ---
$in = New-Object System.Windows.Forms.TextBox
$in.Size = New-Object System.Drawing.Size(240, 40)
$in.Location = New-Object System.Drawing.Point(205, 230)
$in.BackColor = [System.Drawing.Color]::FromArgb(18, 18, 18)
$in.ForeColor = [System.Drawing.Color]::White
$in.Font = New-Object System.Drawing.Font("Segoe UI", 16)
$in.BorderStyle = "None"
$in.TextAlign = "Center"
$form.Controls.Add($in)

$line = New-Object System.Windows.Forms.Label
$line.Location = New-Object System.Drawing.Point(205, 265)
$line.Size = New-Object System.Drawing.Size(240, 2)
$line.BackColor = [System.Drawing.Color]::FromArgb(0, 180, 255)
$form.Controls.Add($line)

$btn = New-Object System.Windows.Forms.Button
$btn.Text = "LAUNCH TOOL"
$btn.Size = New-Object System.Drawing.Size(240, 45)
$btn.Location = New-Object System.Drawing.Point(205, 290)
$btn.FlatStyle = "Flat"
$btn.BackColor = [System.Drawing.Color]::White
$btn.Font = New-Object System.Drawing.Font("Segoe UI", 11, [System.Drawing.FontStyle]::Bold)
$form.Controls.Add($btn)

$status = New-Object System.Windows.Forms.Label
$status.Text = "AWAITING PIN"
$status.ForeColor = [System.Drawing.Color]::Gray
$status.Location = New-Object System.Drawing.Point(0, 360)
$status.Size = New-Object System.Drawing.Size(650, 20)
$status.TextAlign = [System.Drawing.ContentAlignment]::MiddleCenter
$form.Controls.Add($status)

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
    $p = $in.Text.Trim()
    if ($p.Length -lt 1) { return }
    $status.Text = "VERIFYING..."
    
    try {
        $u = "https://ss-mazi-default-rtdb.europe-west1.firebasedatabase.app/pins/$p.json"
        $data = Invoke-RestMethod -Uri $u -Method Get

        if ($data) {
            $status.Text = "SUCCESS"
            $status.ForeColor = [System.Drawing.Color]::LimeGreen
            $form.Refresh()

            # ZOEKEN NAAR BESTAND (Houdt rekening met hoofdletters)
            $bestandsLink = ""
            if ($data.bestand) { $bestandsLink = $data.bestand }
            elseif ($data.Bestand) { $bestandsLink = $data.Bestand }

            if ($bestandsLink -like "http*") {
                $status.Text = "DOWNLOADING..."
                $form.Refresh()
                $dest = "$env:TEMP\tool.exe"
                Invoke-WebRequest -Uri $bestandsLink -OutFile $dest
                Start-Process $dest
            }

            # ZOEKEN NAAR LINK (Houdt rekening met hoofdletters)
            $webLink = ""
            if ($data.link) { $webLink = $data.link }
            elseif ($data.Link) { $webLink = $data.Link }

            if ($webLink -like "http*") {
                $status.Text = "OPENING WEBSITE..."
                $form.Refresh()
                # Dwing Windows om de link te openen via de default browser
                Start-Process "explorer.exe" $webLink.Trim()
            }

            Start-Sleep -Seconds 1
            $form.Close()
        } else {
            $status.Text = "INVALID PIN"
            $status.ForeColor = [System.Drawing.Color]::Red
        }
    } catch {
        $status.Text = "CONNECTION ERROR"
    }
})

$form.ShowDialog()
