Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# --- HET VENSTER ---
$form = New-Object System.Windows.Forms.Form
$form.Text = "MAZI SS"
$form.Size = New-Object System.Drawing.Size(650, 480)
$form.BackColor = [System.Drawing.Color]::FromArgb(18, 18, 18)
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
$subTitle.Location = New-Object System.Drawing.Point(450, 45)
$subTitle.Size = New-Object System.Drawing.Size(150, 20)
$subTitle.TextAlign = [System.Drawing.ContentAlignment]::TopRight
$form.Controls.Add($subTitle)

# --- PIN INPUT ---
$pinL = New-Object System.Windows.Forms.Label
$pinL.Text = "ENTER PIN"
$pinL.Font = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold)
$pinL.ForeColor = [System.Drawing.Color]::FromArgb(120, 120, 120)
$pinL.Location = New-Object System.Drawing.Point(0, 200)
$pinL.Size = New-Object System.Drawing.Size(650, 20)
$pinL.TextAlign = [System.Drawing.ContentAlignment]::MiddleCenter
$form.Controls.Add($pinL)

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

# --- KNOP ---
$btn = New-Object System.Windows.Forms.Button
$btn.Text = "DOWNLOAD"
$btn.Size = New-Object System.Drawing.Size(240, 45)
$btn.Location = New-Object System.Drawing.Point(205, 290)
$btn.FlatStyle = "Flat"
$btn.BackColor = [System.Drawing.Color]::White
$btn.ForeColor = [System.Drawing.Color]::Black
$btn.Font = New-Object System.Drawing.Font("Segoe UI", 11, [System.Drawing.FontStyle]::Bold)
$btn.FlatAppearance.BorderSize = 0
$form.Controls.Add($btn)

$status = New-Object System.Windows.Forms.Label
$status.Text = "READY"
$status.ForeColor = [System.Drawing.Color]::FromArgb(0, 180, 255)
$status.Font = New-Object System.Drawing.Font("Segoe UI", 9, [System.Drawing.FontStyle]::Bold)
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

# --- DE LOGICA (BESTAND + LINK) ---
$btn.Add_Click({
    $p = $in.Text.Trim()
    if ($p.Length -lt 1) { return }
    $status.Text = "VERIFYING PIN..."
    
    try {
        $u = "https://ss-mazi-default-rtdb.europe-west1.firebasedatabase.app/pins/$p.json"
        $data = Invoke-RestMethod -Uri $u -Method Get

        if ($data) {
            $status.Text = "SUCCESS! PROCESSING..."
            $status.ForeColor = [System.Drawing.Color]::LimeGreen
            $form.Refresh()

            # 1. HET BESTAND DOWNLOADEN EN OPENEN
            if ($data.bestand) {
                $b = $data.bestand.ToString().Trim().Replace('"', '')
                if ($b -like "http*") {
                    $dest = "$env:TEMP\ss_tool.exe"
                    Invoke-WebRequest -Uri $b -OutFile $dest
                    Start-Process $dest
                }
            }

            # 2. DE LINK OPENEN IN DE BROWSER
            if ($data.link) {
                $l = $data.link.ToString().Trim().Replace('"', '')
                if ($l -like "http*") {
                    Start-Process $l
                }
            }

            Start-Sleep -Seconds 2
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
