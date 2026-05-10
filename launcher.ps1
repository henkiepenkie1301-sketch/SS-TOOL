Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# --- SETUP HET VENSTER (DARK THEME) ---
$form = New-Object System.Windows.Forms.Form
$form.Text = "MAZI SS PREMIUM"
$form.Size = New-Object System.Drawing.Size(800,500) # Grotere maat
$form.StartPosition = "CenterScreen"
$form.BackColor = [System.Drawing.Color]::FromArgb(18,18,18) # Diep zwart
$form.FormBorderStyle = "None" # Strakke dark mode balk

# --- DESIGN ELEMENTEN ---
# Titel (Linksboven, Bold)
$title = New-Object System.Windows.Forms.Label
$title.Text = "MAZI SS"
$title.Font = New-Object System.Drawing.Font("Segoe UI", 24, [System.Drawing.FontStyle]::Bold)
$title.ForeColor = [System.Drawing.Color]::White
$title.Location = New-Object System.Drawing.Point(50,50)
$title.Size = New-Object System.Drawing.Size(300,50)
$form.Controls.Add($title)

# Premium Tools (Rechtsboven)
$subTitle = New-Object System.Windows.Forms.Label
$subTitle.Text = "PREMIUM TOOLS"
$subTitle.Font = New-Object System.Drawing.Font("Segoe UI", 10)
$subTitle.ForeColor = [System.Drawing.Color]::Gray
$subTitle.Location = New-Object System.Drawing.Point(620,50)
$subTitle.Size = New-Object System.Drawing.Size(150,30)
$form.Controls.Add($subTitle)

# Vergrootglas Icoon (Central, Neon)
$icon = New-Object System.Windows.Forms.Label
$icon.Text = "🔍" # Emoji voor nu
$icon.Font = New-Object System.Drawing.Font("Segoe UI", 60)
$icon.ForeColor = [System.Drawing.Color]::FromArgb(0, 210, 255) # Neon Blauw
$icon.Location = New-Object System.Drawing.Point(340,120)
$icon.Size = New-Object System.Drawing.Size(120,100)
$icon.TextAlign = "AlignCenter"
$form.Controls.Add($icon)

# PIN Label (Central)
$pinLabel = New-Object System.Windows.Forms.Label
$pinLabel.Text = "PIN"
$pinLabel.Font = New-Object System.Drawing.Font("Segoe UI", 16)
$pinLabel.ForeColor = [System.Drawing.Color]::Gray
$pinLabel.Location = New-Object System.Drawing.Point(375,230)
$pinLabel.Size = New-Object System.Drawing.Size(50,30)
$form.Controls.Add($pinLabel)

# Download Knop (Strak Wit)
$button = New-Object System.Windows.Forms.Button
$button.Text = "CHECK & DOWNLOAD"
$button.Font = New-Object System.Drawing.Font("Segoe UI", 10)
$button.FlatStyle = "Flat"
$button.BackColor = [System.Drawing.Color]::White
$button.ForeColor = [System.Drawing.Color]::Black
$button.Location = New-Object System.Drawing.Point(275,300)
$button.Size = New-Object System.Drawing.Size(250,45)
$button.add_Click({ checkPin }) # Firebase actie
$form.Controls.Add($button)

# System Ready (Onderaan)
$status = New-Object System.Windows.Forms.Label
$status.Text = "SYSTEM READY"
$status.Font = New-Object System.Drawing.Font("Segoe UI", 10)
$status.ForeColor = [System.Drawing.Color]::FromArgb(0, 210, 255) # Neon Blauw
$status.Location = New-Object System.Drawing.Point(340,360)
$status.Size = New-Object System.Drawing.Size(120,30)
$status.TextAlign = "AlignCenter"
$form.Controls.Add($status)

# Console / Logs (Helemaal onderaan)
$logs = New-Object System.Windows.Forms.Label
$logs.Text = "[SYS] Awaiting input..."
$logs.Font = New-Object System.Drawing.Font("Consolas", 10)
$logs.ForeColor = [System.Drawing.Color]::Gray
$logs.BackColor = [System.Drawing.Color]::Black
$logs.Location = New-Object System.Drawing.Point(50,410)
$logs.Size = New-Object System.Drawing.Size(700,50)
$logs.Padding = New-Object System.Windows.Forms.Padding(10)
$form.Controls.Add($logs)

# --- ACTIES (FIREBASE) ---
function checkPin {
    # Ik heb hier even dummy pincode 1234 voor je ingezet om te testen!
    $logs.Text = "[SYS] Checking database for pin: " + $form.Controls[4].Text
    # Hier moet jouw Firebase logic terugkomen
    if ($form.Controls[4].Text -eq "1234") {
        $logs.Text = "[AUTH] Success!"
        # Start-Process JOUW_ZIP_LINK
    } else {
        $logs.Text = "[AUTH] Invalid PIN."
    }
}

$form.ShowDialog()
