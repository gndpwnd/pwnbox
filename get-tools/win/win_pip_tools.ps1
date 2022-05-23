$pip_tools = @(
"setup-tools"
"torch"
"torchvision"
"torchaudio"
"tensorflow"
)
$i = 0
for($i=0 ; $i -lt $pip_tools.Length; $i++) {
Write-Host "Installing ${pip_tools[$i]}"
pip install ${pip_tools[$i]}
}
