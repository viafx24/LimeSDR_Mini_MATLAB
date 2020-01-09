# LimeSDR_Mini_MATLAB

### General
This repository contains a wrapper for LimeSDR Mini drivers that allows to work from Matlab with windows 10 64bit.

### consideration for Linux and Mac users
It is probably possible to make it works with mac or linux by generating the thunk file (see the references with the github of RakhDamir)
leadind to the file "libLimeSuite_thunk_<arch>.<library extension> files" but i did not succeed to generate this file using my compiler on matlab (MinGW64). If one is able to generate this file using the files from the github of Rakhdamir, then the file generated can be paste directly on this directory (i.e LimeSDR_Mini_MATLAB) and this could allow the LimeSDR Mini to work.

### Prerequisites

1. Matlab with DSP toolbox installed (I have used MATLAB R2018B)
2. LimeSuite 19.04 (i have installed the pothos environnement (PothosSDR-2019.06.09-vc14-x64.exe) to get it installed).
3. LimeSDR Mini
4. Windows 10 (I used family edition 64 bit with 4go RAM and an intel processor inferior to i3 i.e a not very powerful processor)

### Installation

Steps for the successfull installation:

1. Maybe you should update the Firmware `limeutil --update` in the command line or with powershell.
2. locate YOUR LimeSuite.dll file (mine was here: C:\Program Files\PothosSDR\bin) and copy it and paste it in place of mine (in the directory LimeSDR_Mini_MATLAB). It's a very important step. I was able to work with the files of RakhDamir (see references) only after i did that. But do not touch to the 'libLimeSuite_thunk_pcwin64.dll' that is present unless you really need to generate your own one (and if so, you will have to do it by using the LimeSDR-MATLAB-master of RakhDamir).
3. launch MATLAB and Connect LimeSDR_Mini
4. Run one of the examples (Kind_Of_Real_Time_Basic_RX.m, basicRx.m or basicTxRx.m)

### Main différence with the LimeSDR-MATLAB-master of RakhDamir
1. I commented all references to RX1 and TX1 of the limeSDR-USB (LimeSDR Mini only has RX0 and TX0). Without that, Matlab generated an error.
2. I changed the following parameter: dev.rx0.antenna to 3. Previously it was set to 2 (LNA_L) but the LNA_L doesn't work in the LimeSDR Mini. One should use the LNA_W in place of LNA_L and thus set the parameter to 3.
3. I added a  file called Kind_Of_Real_Time_Basic_RX.m that allows rapid/real time visualization of the waterfall/spectogram.

### Reference
The code is based on the work from [RakhDamir](https://github.com/RakhDamir/LimeSDR-Matlab)
itself based on the work from [Jockover](https://github.com/jocover/Simulink-MATLAB-LimeSDR)

# License #
This code is distributed under an [MIT License](LICENSE.MIT).
