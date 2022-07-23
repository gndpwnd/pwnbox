$repos = @(
"GhostPack/Rubeus"
"GhostPack/Seatbelt"
"cobbr/Covenant"
"cobbr/SharpSploit"
"hfiref0x/UACME"
"SecWiki/windows-kernel-exploits"
"dnSpy/dnSpy"
"erocarrera/pefile"
"stephenfewer/ReflectiveDLLInjection"
"monoxgas/sRDI"
"volatilityfoundation/volatility"
)

$i = 0
foreach($repo in $repos) {
Write-Host "Cloning into ${repo}"
git clone https://github.com/${repo}.git
}