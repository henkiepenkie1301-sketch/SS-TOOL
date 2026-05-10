Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$form = New-Object System.Windows.Forms.Form
$form.Text = "MAZI SS"
$form.Size = New-Object System.Drawing.Size(400,250)
$form.StartPosition = "CenterScreen"
$form.BackColor = [System.Drawing.Color]::FromArgb(13,13,13)
$form.FormBorderStyle = "FixedDialog"

$label = New-Object System.Windows.Forms.Label
$label.Text = "ENTER PIN"
$label.ForeColor = [System.Drawing.Color]::White
$label.Location = New-Object System.Drawing.Point(150,30)
$form.Controls.Add($label)

$inputBox = New-Object System.Windows.Forms.TextBox
$inputBox.Location = New-Object System.Drawing.Point(150,70)
$inputBox.Size = New-Object System.Drawing.Size(100,20)
$form.Controls.Add($inputBox)

$button = New-Object System.Windows.Forms.Button
$button.Text = "CHECK & DOWNLOAD"
$button.Location = New-Object System.Drawing.Point(125,120)
$button.Size = New-Object System.Drawing.Size(150,30)
$button.BackColor = [System.Drawing.Color]::White
$button.add_Click({
    $pin = $inputBox.Text
    $url = "https://ss-mazi-default-rtdb.europe-west1.firebasedatabase.app/pins/$pin.json"
    try {
        $downloadUrl = Invoke-RestMethod -Uri $url
        if ($downloadUrl) {
            [System.Windows.Forms.MessageBox]::Show("ACCESS GRANTED. Download start...")
            Start-Process $downloadUrl
            $form.Close()
        } else {
            [System.Windows.Forms.MessageBox]::Show("INVALID PIN")
        }
    } catch {
        [System.Windows.Forms.MessageBox]::Show("Error connecting to database")
    }
})
$form.Controls.Add($button)

$form.ShowDialog()