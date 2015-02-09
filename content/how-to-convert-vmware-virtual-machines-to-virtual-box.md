Title: How to convert VMWare virtual machines to Virtual Box
Date: 2013-05-08 01:00
Category: howtos
Tags: VMWare, Virtualbox, conversion
Slug: how-to-convert-vmware-virtual-machines-to-virtual-box
Authors: csparpa
Summary: How to convert virtual machines from VMWare format (.vmx) to Virtual Box format (.ovf)

### Where I started from

This is my situation: I'm on a Windows7 x86 host, and I have an old Ubuntu 10.04 virtual machine with VMWare Tools installed on it.  
 
My need is to turn it into an OVF appliance, so that I can run it on Virtual Box, no matter where what architecture it will be run on.

### Steps

This is what I've done:

- I made sure (e.g: using VMWare Player or Workstation) that the virtual appliance is powered off;
- Opened a Command Prompt, moved to the VMWare Player/Workstation installation dir and executed the OVF conversion tool. Be aware that this conversion may take some time, depending on how big is your VMX appliance. I did it as follows (replace the paths as needed):
```cmd
$> cd "C:\Program Files\VMware\VMware Workstation\OVFTool"
$> ovftool.exe "C:\Users\claudio\Documents\Virtual Machines\ubuntu1004\ubuntu1004.vmx" "C:\Users\claudio\Documents\Virtual Machines\converted-to-virtualbox\ubuntu1004.ovf"
```
- When the conversion process was over, I imported the `ubuntu1004.ovf` appliance into Virtual Box by using the `File > Import virtual appliance..` menu element and leaving all the defaults;
- Then I booted up the `ubuntu1004.ovf` appliance and performed VMWare Tools uninstallation by opening up an SSH shell and executing:
```bash
$> sudo /usr/bin/vmware-uninstall-tools.pl
```
- Then I finished the procedure by executing the `Device > Install Guest Additions` menu item: a virtual CD is then mounted and I launched the installation process from a shell:
```bash
$> cd /media/VBOXADDITIONS_4.2.12_84980
$> sudo bash VBoxLinuxAdditions.run
```  

Not as difficult as it may seem…. Hope this helps!