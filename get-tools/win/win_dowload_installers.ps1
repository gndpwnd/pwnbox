# Run powershell as administrator

# Make sure to run the following in an admin shell:
# Set-ExecutionPolicy RemoteSigned

$basics = @(
    # Basic System Stuff
    # "https://wslstorestorage.blob.core.windows.net/wslblob/wsl_update_x64.msi",
    "https://www.cygwin.com",
    "https://www.google.com/chrome/",
    "https://www.videolan.org/vlc/download-windows.html",
)

$prog_lang = @(
    # Programming Languages
    "https://www.python.org/downloads/release/python-377/",
    "https://go.dev/dl/",
    "https://forge.rust-lang.org/infra/other-installation-methods.html",

    # IDEs
    "https://code.visualstudio.com/docs/?dv=win",
    "https://visualstudio.microsoft.com/thank-you-downloading-visual-studio/?sku=Community&channel=Release&version=VS2022&source=VSLandingPage&cid=2030&passive=false",
    "https://www.arduino.cc/en/software",
    "https://www.sublimetext.com/3".
    "https://docs.platformio.org/en/latest/core/installation/methods/installer-script.html"
)

$sys = @(

)

$tool_urls = @(

# System Tools
"https://www.7-zip.org/download.html",
"https://cmake.org/download/",
"https://www.balena.io/etcher/",
"https://www.java.com/download/ie_manual.jsp",
"https://www.oracle.com/java/technologies/downloads/#jdk17-windows",
"https://www.docker.com/products/docker-desktop/",
"https://git-scm.com/downloads",
"https://desktop.github.com/",

# Forensics Tools
"https://www.wireshark.org/download.html",
"https://www.netresec.com/?page=NetworkMiner",
"https://www.jetbrains.com/dotnet/",
"https://github.com/NationalSecurityAgency/ghidra/releases",
"https://www.autoitscript.com/site/autoit/downloads/",
"https://learn.microsoft.com/en-us/sysinternals/downloads/sysinternals-suite",
"https://github.com/x64dbg/ScyllaHide/releases",
"https://sourceforge.net/projects/x64dbg/files/snapshots/",
"https://github.com/hasherezade/pe-bear-releases/releases",
"https://www.winitor.com/download2",
"https://github.com/eteran/edb-debugger/releases",
"https://www.immunityinc.com/products/debugger/"
"https://learn.microsoft.com/en-us/windows-hardware/drivers/debugger/debugger-download-tools",
"https://hex-rays.com/ida-free/",
"https://github.com/VirusTotal/yara/releases",
"https://github.com/decalage2/balbuzard/",
"https://github.com/horsicq/Detect-It-Easy/",
"https://github.com/horsicq/DIE-engine/",
"https://processhacker.sourceforge.io/downloads.php",
"https://www.procdot.com/downloadprocdotbinaries.htm",
"https://sourceforge.net/projects/fakenet/",
"https://downloads.digitalcorpora.org/downloads/bulk_extractor/",
"https://www.novirusthanks.org/products/ssdt-view/",
"https://github.com/antiwar3/py",
"https://github.com/poona/APIMiner/releases",
"https://github.com/DidierStevens/FalsePositives/blob/master/XORSearch_V1_11_4.zip",
"https://www.aldeid.com/wiki/BinText",
"https://www.aldeid.com/wiki/PEiD",
"https://ntcore.com/?page_id=388"












# Remote Administration
"https://downloads.hak5.org/cloudc2",
"https://www.chiark.greenend.org.uk/~sgtatham/putty/latest.html",
"https://www.wireguard.com/install/",
"https://www.realvnc.com/en/connect/download/vnc/",
"https://www.realvnc.com/en/connect/download/viewer/"

# Design
"https://github.com/Ultimaker/Cura/releases/download/4.13.1/Ultimaker_Cura-4.13.1-amd64.exe",
"https://mirrors.ocf.berkeley.edu/blender/release/Blender3.1/blender-3.1.2-windows-x64.msi",
"https://pcb.designspark.info/DesignSparkPCB_v10.0.exe",
"https://www.expresspcb.com/ExpressPCBSetup.zip",
"https://cytranet.dl.sourceforge.net/project/tinycad/Official%20Release/3.00.04/TinyCAD_3.00.04.exe",

# Analysis | Simulation | Editing
"https://physlets.org/tracker/installers/Tracker-6.0.9-windows-x64-installer.exe",
"https://sim.djicdn.com/Launcher/DJIFlightSimulatorLauncher.zip",

# Hardware
"https://firmware.ardupilot.org/Tools/MissionPlanner/MissionPlanner-latest.msi",
"https://bucket-download.slamtec.com/ff99a4e443cac34c5d016e00b5b374ec2fa04acb/install_robostudio_20210920.exe",
"https://firmware.ardupilot.org/Tools/STM32-tools/gcc-arm-none-eabi-10-2020-q4-major-win32.exe",
"https://firmware.ardupilot.org/Tools/MAVProxy/MAVProxySetup-latest.exe",
"https://mirrors.xmission.com/eclipse/oomph/epp/2022-06/R/eclipse-inst-jre-linux64.tar.gz",
"https://s3-us-west-2.amazonaws.com/qgroundcontrol/latest/QGroundControl-installer.exe",

# Hardware Acceleration (GPU)
"https://developer.download.nvidia.com/compute/cuda/10.2/Prod/patches/2/cuda_10.2.2_win10.exe",
"https://developer.download.nvidia.com/compute/cuda/11.6.2/network_installers/cuda_11.6.2_windows_network.exe"

)

$i = 0
foreach($tool in $tool_urls) {
$filename = ${tool}.split("/")[-1]
Write-Host "Downloading ${filename}"
Invoke-WebRequest -Uri $tool -UseBasicParsing -OutFile $filename
}