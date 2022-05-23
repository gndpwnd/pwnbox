$urls_to_visit = @(
"https://developer.nvidia.com/compute/cudnn/secure/8.4.0/local_installers/10.2/cudnn-windows-x86_64-8.4.0.27_cuda10.2-archive.zip",
"https://www.blackmagicdesign.com/products/davinciresolve/",
"https://forum.dji.com/thread-176969-1-1.html",
"https://www.youtube.com/watch?v=tL1H-OjOMlY",
"https://forum.dji.com/thread-171161-1-1.html".
"https://www.youtube.com/watch?v=60lhb2D-VdU",
"https://communities.vmware.com/t5/VMware-Workstation-Player/Win10-Guest-vs-Xbox-One-Controller-wired/td-p/2234516"
)
foreach($url in $urls_to_visit){
    Start-Process $url
}
