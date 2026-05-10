Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Het venster (Dark Mode & Geen Randen)
$form = New-Object System.Windows.Forms.Form
$form.Text = "MAZI SS"
$form.BackColor = [System.Drawing.Color]::FromArgb(15, 15, 15)
$form.Size = New-Object System.Drawing.Size(400, 280)
$form.FormBorderStyle = "None" # Verwijdert de lelijke witte Windows balk
$form.StartPosition = "CenterScreen"

# Zorg dat je het venster kunt slepen (omdat de balk weg is)
$mouseDown = $false
$form.add_MouseDown({ $script:mouseDown = $true; $script:startPos = [System.Windows.Forms.Cursor]::Position; $script:formPos = $form.Location })
$form.add_MouseMove({
    if ($script:mouseDown) {
        $currentPos = [System.Windows.Forms.Cursor]::Position
        $form.Location = [System.Drawing.Point]::new($script:formPos.X + ($currentPos.X - $script:startPos.X), $script:formPos.Y + ($currentPos.Y - $script:startPos.Y))
    }
})
$form.add_MouseUp({ $script:mouseDown = $false })

# Titel (Neon Blauw)
$title = New-Object System.Windows.Forms.Label
$title.Text = "MAZI SS"
$title.ForeColor = [System.Drawing.Color]::FromArgb(0, 210, 255)
$title.Font = New-Object System.Drawing.Font("Segoe UI", 20, [System.Drawing.FontStyle]::Bold)
$title.Size = New-Object System.Drawing.Size(400, 50)
$title.Location = New-Object System.Drawing.Point(0, 30)
$title.TextAlign = "MiddleCentered"
$form.Controls.Add($title)

# Input Veld (Strak grijs)
$input = New-Object System.Windows.Forms.TextBox
$input.Size = New-Object System.Drawing.Size(200, 40)
$input.Location = New-Object System.Drawing.Point(100, 110)
$input.BackColor = [System.Drawing.Color]::FromArgb(30, 30, 30)
$input.ForeColor = [System.Drawing.Color]::White
$input.BorderStyle = "FixedSingle"
$input.Font = New-Object System.Drawing.Font("Consolas", 14)
$input.TextAlign = "Center"
$form.Controls.Add($input)

# Download Knop
$btn = New-Object System.Windows.Forms.Button
$btn.Size = New-Object System.Drawing.Size(200, 45)
$btn.Location = New-Object System.Drawing.Point(100, 170)
$btn.Text = "AUTHENTICATE"
$btn.FlatStyle = "Flat"
$btn.FlatAppearance.BorderSize = 0
$btn.BackColor = [System.Drawing.Color]::White
$btn.Cursor = [System.Windows.Forms.Cursors]::Hand
$btn.Font = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold)

$btn.add_Click({
    $pin = $input.Text
    $url = "https://ss-mazi-default-rtdb.europe-west1.firebasedatabase.app/pins/$pin.json"
    $btn.Text = "CHECKING..."
    try {
        $link = Invoke-RestMethod -Uri $url
        if ($link) {
            $btn.BackColor = [System.Drawing.Color]::LimeGreen
            $btn.Text = "SUCCESS"
            Start-Process $link
            Start-Sleep -Seconds 2
            $form.Close()
        } else {
            $btn.BackColor = [System.Drawing.Color]::Crimson
            $btn.ForeColor = [System.Drawing.Color]::White
            $btn.Text = "INVALID PIN"
        }
    } catch { $btn.Text = "ERROR" }
})
$form.Controls.Add($btn)

# Sluiten knop (X)
$close = New-Object System.Windows.Forms.Label
$close.Text = "X"
$close.ForeColor = [System.Drawing.Color]::Gray
$close.Location = New-Object System.Drawing.Point(370, 10)
$close.Cursor = [System.Windows.Forms.Cursors]::Hand
$close.add_Click({ $form.Close() })
$form.Controls.Add($close)

$form.ShowDialog()
