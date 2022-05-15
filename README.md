# LimeSDR_Mini_MATLAB
 
### General
This repository contains a matlab AND Simulink wrapper for LimeSDR Mini that work on windows 10 64 bit. It is mainly based on previous works of Damir Rakhimov and Joe Cover. I’m not an engineer neither an expert in this area, just a hobbyist with limited knowledge. Keep that in mind.
 
### consideration for Linux and Mac users 
It is probably possible to make it works with mac or linux by generating the thunk file (see the references with the github of RakhDamir). 
Under windows, this wrapper uses “.dll” . Under Linux /mac, it is another extension (maybe “.so”). Adaptations are probably possible.


### consideration for LimeSDR (NOT Mini version) owners:
Some tips and tricks that I used to make the wrapper working on my computer should also work and be useful for LimeSDR (NOT Mini version) owners. In particular, take a look about the consideration of the place of the “enable” call under matlab. Under Simulink, check the main difference between the Joe Cover Simulink wrapper (2017) and mine (2022) in the function “getSampleTimeImpl” which has been update by the mathworks company and thus required a small modification in the code. 

### Prerequisites
 
1. Matlab (I have used MATLAB R2020B). Simulink and DSP toolbox if needed but not mandatory.
2. LimeSuite.dll. I have installed the pothos environment (PothosSDR-2021.07.25-vc16-x64.exe) to get it installed and thus, on my computer, it was on the following directory: E:\PothosSDR\bin
3. LimeSDR Mini
4. Windows 10 (I used family edition 64 bit with 20go RAM and an intel processor i3). Also work with smaller configuration (4go RAM).
 
### Installation
 
Steps for the successful installation and make it work with Matlab:
 
1. Maybe you should update the Firmware of the limeSDR mini `limeutil --update` in the command line or with powershell.
2. locate YOUR LimeSuite.dll file (mine was here: E:\PothosSDR\bin) and copy it and paste it in your matlab working directory. 
3. Copy and paste the 'libLimeSuite_thunk_pcwin64.dll' that is present in this github repository (it’s the same as the one of Damir Rakhimov thus you may also use his file). Alternatively, if you really need to generate your own one, follow the procedure proposed in the github of RakhDamir. I have succeeded to do it using Microsoft visual studio C++ compiler (not mingw64) but I also encounter some problems. Thus, it looks to me far easier to just copy and paste the existing dll.
3. launch MATLAB and Connect LimeSDR_Mini
4. Run the example “Very_basicTxRx.m”

Steps to make it work with Simulink:

1.	create a new blank sheet (.slx).
2.	 add a block called “matlab system”. 
3.	Once the block in the sheet, double click to open it and choose “limeSDR_Simulink_Wrapper_2022.m”.
4.	 Then open again the block and you will be able to choose your parameter (RX, TX, gainRx, gainTX, carrier frequency, sample rate etc…).
5.	Add the block that fit your need: audio sink, scope, downsample and upsample, FIR filter, modulator/demodulator, from multimedia file, spectrum analyzer etc… and enjoy!
6.	Don’t forget that frame-based computation is preferred to sample-base computation (see block buffer and unbuffer for instance). When using the scope with frame, in the parameter of the scope, don’t forget to choose “frame based”. If using high sample rate (30M), one may encounter “pause” or problems due to difficulty to compute in real time. For this same reason, using spectrum analyser in real time is not recommended since it consumes lot of computation and thus impact the signal.

7.	Alternatively, one can test the 4 files .slx that are presents in this repository: AM and FM examples (with both TX and RX) with respectively a single tone at 440 hz (sinus) and a song.

 
### Main difference with the LimeSDR-MATLAB-master of RakhDamir and Joe Cover
1. I commented all references to RX1 and TX1 of the limeSDR-USB (LimeSDR Mini only has RX0 and TX0). Without that, Matlab (obviously) generates errors.
2. In my case, in the matlab file example “Very_basicTxRx.m”, it was important that the “enable” call (for rx and tx) was placed just after the creation of limeSDR() object (and not after the calibration call).
dev = limeSDR(); 
dev.tx0.enable;
3. In the limeSDR.XCVR.m, sometimes it was interesting to change the oversampling to 2 or 1 (in place of 4 or 8) in the function set.samplerate. This allows, in matlab, to limit “cut” in the signal. On the other hand, setting back to 4 allows to use smaller sample rate (below 1M) and this is convenient.
4. In the Simulink wrapper, I had to modify the function getSampleTimeImpl due to a recent update of Simulink that requires this modification.
5. Below 2000mhz, I recommend using antenna 2 in TX and 3 in RX. Above 2000 mhz, I recommend using antenna 1 in TX and 1 in RX.
6. if one encounter MCU 5 loopback error (or something like that), increasing the gain in TX or RX may solve the problem.


### Why a matlab wrapper for the lime SDR mini ?
Folks may have multiples reasons to use matlab to perform software defined radio. In my case, gnu radio was working perfectly (maybe even faster and more user friendly). Thus why ? Since I don’t have much knowledge about SDR and radio, I needed a good tutorial. I found a free matlab ebook (“Software defined radio using matlab and Simulink” that looks great to understand things at a low level:
https://fr.mathworks.com/campaigns/offers/download-rtl-sdr-ebook.html
however, to complete the exercises proposed in this ebook in TX/RX, the author uses an expensive USRP hardware. LimeSDR Mini was a much cheaper option (200 euros vs 2000 euros), and thus I needed a matlab/simulink wrapper to follow the ebook with limeSDR Mini in place of USRP. The 4 files .slx proposed in this repository are partly based on this ebook and also the audio file .wav. Credit for this high-quality free ebook should be given to the authors named Bob Stewart, Kenneth Barlee, Dale Atkinson, Louise Crockett. For Dummies like me, it was just a high level and didactic introduction. Many free .slx are provided with the ebook including digital communication examples, AM and FM examples and PLL examples among others.

Of course, I don’t pay for matlab that is very expensive. Cracked versions can be easily found on torrent website and there are probably directly provided by the Mathworks company itself since the crack is the same since 20 years and provided approximately one week/month after the new release twice a year! Experts in applied mathematics can easily protect a software if they want! This “gray” method (since truth is directly impacted) may allow students, hackers, makers, hobbyists to use this incredibly good software for free and then asking for it (for a payed version) when working in industry /academic institutions. Just a hypothesis of course, but in a world where shadow, lies and secret violence and persecutions are everywhere, every second, I don’t think I take a big risk with this theory.

### Reference
The code is based on the work from [RakhDamir](https://github.com/RakhDamir/LimeSDR-Matlab)
itself based on the work from [Jockover](https://github.com/jocover/Simulink-MATLAB-LimeSDR)


 
# License #
This code is distributed under an [MIT License](LICENSE.MIT).

