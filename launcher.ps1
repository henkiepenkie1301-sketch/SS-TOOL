Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

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

$title = New-Object System.Windows.Forms.Label
$title.Text = "MAZI SS"
$title.Font = New-Object System.Drawing.Font("Segoe UI", 22, [System.Drawing.FontStyle]::Bold)
$title.ForeColor = [System.Drawing.Color]::White
$title.Location = New-Object System.Drawing.Point(40, 40)
$title.Size = New-Object System.Drawing.Size(200, 50)
$form.Controls.Add($title)

$sub = New-Object System.Windows.Forms.Label
$sub.Text = "PREMIUM TOOLS"
$sub.Font = New-Object System.Drawing.Font("Segoe UI", 8)
$sub.ForeColor = [System.Drawing.Color]::FromArgb(80, 80, 80)
$sub.Location = New-Object System.Drawing.Point(480, 45)
$sub.Size = New-Object System.Drawing.Size(120, 20)
$sub.TextAlign = "Right"
$form.Controls.Add($sub)

$pinL = New-Object System.Windows.Forms.Label
$pinL.Text = "PIN"
$pinL.Font = New-Object System.Drawing.Font("Segoe UI", 12)
$pinL.ForeColor = [System.Drawing.Color]::FromArgb(100, 100, 100)
$pinL.Location = New-Object System.Drawing.Point(0, 200)
$pinL.Size = New-Object System.Drawing.Size(650, 30)
$pinL.TextAlign = "MiddleCenter"
$form.Controls.Add($pinL)

$in = New-Object System.Windows.Forms.TextBox
$in.Size = New-Object System.Drawing.Size(200, 30)
$in.Location = New-Object System.Drawing.Point(225, 235)
$in.BackColor = [System.Drawing.Color]::FromArgb(18, 18, 18)
$in.ForeColor = [System.Drawing.Color]::White
$in.Font = New-Object System.Drawing.Font("Segoe UI", 14)
$in.BorderStyle = "None"
$in.TextAlign = "Center"
$form.Controls.Add($in)

$line = New-Object System.Windows.Forms.Label
$line.Location = New-Object System.Drawing.Point(225, 265)
$line.Size = New-Object System.Drawing.Size(200, 2)
$line.BackColor = [System.Drawing.Color]::FromArgb(0, 180, 255)
$form.Controls.Add($line)

$btn = New-Object System.Windows.Forms.Button
$btn.Text = "DOWNLOAD"
$btn.Size = New-Object System.Drawing.Size(200, 40)
$btn.Location = New-Object System.Drawing.Point(225, 300)
$btn.FlatStyle = "Flat"
$btn.BackColor = [System.Drawing.Color]::White
$btn.Font = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold)
$btn.FlatAppearance.BorderSize = 0
$form.Controls.Add($btn)

$status = New-Object System.Windows.Forms.Label
$status.Text = "SYSTEM READY"
$status.ForeColor = [System.Drawing.Color]::FromArgb(0, 180, 255)
$status.Font = New-Object System.Drawing.Font("Segoe UI", 9, [System.Drawing.FontStyle]::Bold)
$status.Location = New-Object System.Drawing.Point(0, 360)
$status.Size = New-Object System.Drawing.Size(650, 20)
$status.TextAlign = "MiddleCenter"
$form.Controls.Add($status)

$close = New-Object System.Windows.Forms.Label
$close.Text = "X"
$close.ForeColor = [System.Drawing.Color]::Gray
$close.Location = New-Object System.Drawing.Point(610, 15)
$close.add_Click({ $form.Close() })
$form.Controls.Add($close)

$btn.Add_Click({
    if ($in.Text.Length -gt 0) {
        $status.Text = "VERIFYING..."
        try {
            $u = "https://ss-mazi-default-rtdb.europe-west1.firebasedatabase.app/pins/$($in.Text).json"
            $d = Invoke-RestMethod -Uri $u -Method Get
            if ($d) { Start-Process $d; $form.Close() } else { $status.Text = "INVALID PIN"; $status.ForeColor = [System.Drawing.Color]::Red }
        } catch { $status.Text = "ERROR" }
    }
})

$form.ShowDialog()
