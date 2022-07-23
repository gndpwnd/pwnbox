# Run powershell as administrator

# Make sure to run the following in an admin shell:
# Set-ExecutionPolicy RemoteSigned

$tool_urls = @(

# Basic System Stuff
"https://wslstorestorage.blob.core.windows.net/wslblob/wsl_update_x64.msi",
"https://www.cygwin.com/setup-x86_64.exe",
"https://dl.google.com/tag/s/appguid%3D%7B8A69D345-D564-463C-AFF1-A69D9E530F96%7D%26iid%3D%7BBAFC6A1A-804E-0EE1-2E53-B51033C1DC88%7D%26lang%3Den%26browser%3D4%26usagestats%3D1%26appname%3DGoogle%2520Chrome%26needsadmin%3Dprefers%26ap%3Dx64-stable-statsdef_1%26brand%3DJJTC%26installdataindex%3Dempty/update2/installers/ChromeSetup.exe",
"https://vlc.freemirror.org/vlc/3.0.17.4/win32/vlc-3.0.17.4-win32.exe",

# Programming Languages
"https://www.python.org/ftp/python/3.7.7/python-3.7.7-amd64.exe",
"https://www.python.org/ftp/python/3.10.5/python-3.10.5-amd64.exe",
"https://go.dev/dl/go1.18.1.windows-amd64.msi",
"https://static.rust-lang.org/rustup/dist/i686-pc-windows-gnu/rustup-init.exe",

# IDEs
"https://az764295.vo.msecnd.net/stable/dfd34e8260c270da74b5c2d86d61aee4b6d56977/VSCodeUserSetup-x64-1.66.2.exe",
"https://aka.ms/vs/17/release/vs_community.exe",
"https://downloads.arduino.cc/arduino-1.8.19-windows.exe",

# System Tools
"https://www.7-zip.org/a/7z2107-x64.exe",
"https://github.com/Kitware/CMake/releases/download/v3.23.1/cmake-3.23.1-windows-x86_64.msi",
"https://github.com/balena-io/etcher/releases/download/v1.7.9/balenaEtcher-Setup-1.7.9.exe",
"https://www.oracle.com/webapps/redirect/signon?nexturl=https://download.oracle.com/otn/java/jdk/11.0.13%2B10/bdde8881e2e3437baa70044f884d2d67/jdk-11.0.13_windows-x64_bin.exe",
"https://download.sublimetext.com/Sublime%20Text%20Build%203211%20x64%20Setup.exe",
"https://download.oracle.com/java/17/latest/jdk-17_windows-x64_bin.exe",
"https://desktop.docker.com/win/main/amd64/Docker%20Desktop%20Installer.exe",
"https://github.com/git-for-windows/git/releases/download/v2.35.1.windows.2/Git-2.35.1.2-64-bit.exe",

# Advanced System Tools
"https://1.na.dl.wireshark.org/win64/Wireshark-win64-3.4.14.exe",
"https://iweb.dl.sourceforge.net/project/networkminer/networkminer/NetworkMiner-1.6.1/NetworkMiner_1-6-1.zip",
"https://download.jetbrains.com/resharper/dotUltimate.2021.3.3/JetBrains.dotUltimate.2021.3.3.exe",
"https://github.com/NationalSecurityAgency/ghidra/releases/download/Ghidra_10.1.4_build/ghidra_10.1.4_PUBLIC_20220519.zip",
"https://www.autoitscript.com/cgi-bin/getfile.pl?autoit3/autoit-v3-setup.zip",
"https://download.sysinternals.com/files/SysinternalsSuite.zip",
"https://www.python.org/ftp/python/3.10.2/python-3.10.2-amd64.exe",
"https://github.com/x64dbg/ScyllaHide/releases/download/snapshot-2021-08-23_13-27-50/ScyllaHide.7z",
"https://github.com/x64dbg/x64dbg/releases/download/snapshot/snapshot_2022-03-02_15-55.zip",
"https://github.com/hasherezade/pe-bear-releases/releases/download/0.5.5.3/PE-bear_0.5.5.3_x64_win_vs17.zip",
"https://www.winitor.com/tools/pestudio/current/pestudio.zip",
"https://github.com/eteran/edb-debugger/archive/refs/tags/1.3.0.zip",

# Remote Administration
"https://storage.googleapis.com/hak5-dl.appspot.com/cloudc2/firmwares/3.1.2-stable/c2-3.1.2.zip",
"https://downloads.realvnc.com/download/file/viewer.files/VNC-Viewer-6.22.207-Windows-64bit.exe",
"https://the.earth.li/~sgtatham/putty/0.77/w64/putty-64bit-0.77-installer.msi",
"https://download.wireguard.com/windows-client/wireguard-installer.exe",

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