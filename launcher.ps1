Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$form = New-Object System.Windows.Forms.Form
$form.Text = "MAZI SS"
$form.Size = New-Object System.Drawing.Size(650, 480)
$form.BackColor = [System.Drawing.Color]::FromArgb(18, 18, 18)
$form.StartPosition = "CenterScreen"
$form.FormBorderStyle = "FixedDialog"

$title = New-Object System.Windows.Forms.Label
$title.Text = "MAZI SS"
$title.Font = New-Object System.Drawing.Font("Segoe UI", 20, [System.Drawing.FontStyle]::Bold)
$title.ForeColor = [System.Drawing.Color]::White
$title.Location = New-Object System.Drawing.Point(30, 20)
$title.Size = New-Object System.Drawing.Size(200, 40)
$form.Controls.Add($title)

$inputBox = New-Object System.Windows.Forms.TextBox
$inputBox.Location = New-Object System.Drawing.Point(200, 200)
$inputBox.Size = New-Object System.Drawing.Size(250, 40)
$inputBox.BackColor = [System.Drawing.Color]::FromArgb(30, 30, 30)
$inputBox.ForeColor = [System.Drawing.Color]::White
$inputBox.Font = New-Object System.Drawing.Font("Segoe UI", 14)
$inputBox.BorderStyle = "FixedSingle"
$inputBox.TextAlign = "Center"
$form.Controls.Add($inputBox)

$btn = New-Object System.Windows.Forms.Button
$btn.Text = "CHECK & DOWNLOAD"
$btn.Size = New-Object System.Drawing.Size(250, 45)
$btn.Location = New-Object System.Drawing.Point(200, 260)
$btn.FlatStyle = "Flat"
$btn.BackColor = [System.Drawing.Color]::White
$btn.Font = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold)
$form.Controls.Add($btn)

$status = New-Object System.Windows.Forms.Label
$status.Text = "SYSTEM READY"
$status.ForeColor = [System.Drawing.Color]::Cyan
$status.Location = New-Object System.Drawing.Point(0, 320)
$status.Size = New-Object System.Drawing.Size(650, 30)
$status.TextAlign = "MiddleCenter"
$form.Controls.Add($status)

$btn.Add_Click({
    $pin = $inputBox.Text
    $url = "https://ss-mazi-default-rtdb.europe-west1.firebasedatabase.app/pins/$pin.json"
    try {
        $res = Invoke-RestMethod -Uri $url -Method Get
        if ($res) {
            $status.Text = "SUCCESS"
            Start-Process $res
        } else {
            $status.Text = "INVALID PIN"
        }
    } catch { $status.Text = "ERROR" }
})

$form.ShowDialog()
