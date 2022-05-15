%Via_Fx_24 / May 2022. Maltab code to test limeSDR mini.

%this is an update version of RXTX initially writed by Damir Rakhimov
%and Joe Cover. the goal is to test the functionning of the limeSDR mini
%under matlab. One may choose a carrier frequency, a signal frequency,
%a waveform type (sinus, sawtooth or square), adapt the gain and the
%antenna and check that the waveform is correct in the time domain
%(and also plot a spectrum in frequency domain).
% One should avoid to go above 5e6 for sample rate to avoid
% exceeding computing ressources. If MCU 5 loopback error occurs (or
% something like that), try increase either TX and RX gain.

% some comments are from me; other from previous version of this code.

% if this code doesn't work: check that you have:
% limeSDR.m, limeSDR_XCVR.m, libLimeSuite_proto.m in the working folder,
% your own "LimeSuite.dll" in the working folder or in the matlab path,
% your own generated libLimeSuite_thunk_pcwin64.dll or (the easier way) 
% copy and paste directly mine (i.e the one i took from Damir Rakhimov) in 
% the working folder.

% One may also directly use the code from Damir Rakhimov or Joe Cover. the
% main difference is that i changed the place of the "enable" call, 
% I commented all references to TX1 and RX1 (absent in limeSDR mini) and
% I made some changes in the simulink wrapper to adapt to Simulink version
% of matlab r2020b. 

% this code may also works with the limesdr (not the mini). Just be sure to
% uncomment all references to TX1 and RX1. I didn't test it since i dont
% have the limeSDR.

clc;
close all force;
clear all force;

% Folks may uncomment the line below to include the LimeSuite.dll
% in the matlab path. Alternatively, one may copy and paste the
% LimeSuite.dll directly in the working folder. An example of path 
% under windows could be: addpath('E:\PothosSDR\bin')

%addpath('../_library') % add path with LimeSuite library 

% Initialize parameters

Fc          = 868e6;   % Carrier Frequency, Hz
Fs          = 1e6;      % Frequency of sampling frequency, Hz
Ts          = 0.0164;      % Signal duration, s
Fsig        = 1e3;    % Frequency of desired signal, Hz
Asig        = 1;        % Amplitude of signal, [-1,1]

% BW: Related to low pass filter chosen. should be automa
% tically chosen close to the sample rate. Thus, i let it at the same value
% than the sample rate.

BW          = 1e6;      

RxGain      = 20;       % Receiver Gain, dB
TxGain      = 40;       % Transmitter Gain, dB

% (1) Open a device handle:
dev = limeSDR(); % Open device

% VERY IMPORTANT: the "enable" call has to be placed here to get a correct sinus
%(difference with Damir Rakhimov and Joe Cover code; i dont know exactly why))

dev.tx0.enable; 

% (2) Setup device parameters. These may be changed while the device is actively streaming.
dev.tx0.frequency   = Fc;    % when set to 2450e6, samples are real, not complex.
dev.tx0.samplerate  = Fs;    % when set to 40e6, 50e6, overflow may occur.
dev.tx0.bandwidth   = BW;
dev.tx0.gain        = TxGain; 


%Concerning Antenna to choose: what works best fo me: at 27mhz, 433mhz or 868mh, 
% I should use LNA_W thus "3" for RX and "2"  for TX. However, at 2400mhz
% I use LNA_L thus "1" for RX and "1" also fot TX.

dev.tx0.antenna     = 2;     % my advise: "2" below 2000 mhz, "1" above

dev.rx0.frequency   = Fc;
dev.rx0.samplerate  = Fs;
dev.rx0.bandwidth   = BW;
dev.rx0.gain        = RxGain;

dev.rx0.antenna     = 3;     %  my advise: "3" below 2000 mhz, "1" above;

% (3) Read parameters from the devices
ChipTemp       = dev.chiptemp;

Fs_dev_tx      = dev.tx0.samplerate;  % in SPS
Fc_dev_tx      = dev.tx0.frequency;
BW_dev_tx      = dev.tx0.bandwidth;
Ant_dev_tx     = dev.tx0.antenna;
TxGain_dev     = dev.tx0.gain;

% VERY IMPORTANT: the "enable" call has to be placed here to get a correct sinus
%(difference with Damir Rakhimov and Joe Cover code ; i dont know exactly why)
dev.rx0.enable;

Fs_dev_rx      = dev.rx0.samplerate;  % in SPS
Fc_dev_rx      = dev.rx0.frequency;
BW_dev_rx      = dev.rx0.bandwidth;
Ant_dev_rx     = dev.rx0.antenna;
RxGain_dev    = dev.rx0.gain;

fprintf('Device temperature: %3.1fC\n', ChipTemp);

fprintf('Tx Device sampling frequency: %3.1fHz, Initial sampling frequency: %3.1fHz\n', Fs_dev_tx, Fs);
fprintf('Tx Device carrier frequency: %3.1fHz, Initial carrier frequency: %3.1fHz\n', Fc_dev_tx, Fc);
fprintf('Tx Device bandwidth: %3.1fHz, Initial bandwith: %3.1fHz\n', BW_dev_tx, BW);
fprintf('Tx Device antenna: %d \n', Ant_dev_tx);
fprintf('Tx Device gain: %3.1fdB, Initial gain: %3.1fdB\n', TxGain_dev, TxGain);

fprintf('Rx Device sampling frequency: %3.1fHz, Initial sampling frequency: %3.1fHz\n', Fs_dev_rx, Fs);
fprintf('Rx Device carrier frequency: %3.1fHz, Initial carrier frequency: %3.1fHz\n', Fc_dev_rx, Fc);
fprintf('Rx Device bandwidth: %3.1fHz, Initial bandwith: %3.1fHz\n', BW_dev_rx, BW);
fprintf('Rx Device antenna: %d \n', Ant_dev_rx);
fprintf('Rx Device gain: %3.1fdB, Initial gain: %3.1fdB\n', RxGain_dev, RxGain);

% (4) Generate test signal


t=0:1/Fs:Ts;

waveform  = sin(2*pi*Fsig*t);

%waveform = sawtooth(2*pi*Fsig*t);
%waveform = square(2*pi*Fsig*t);

% (5) Create empty array for the received signal

samples    = complex(zeros(Fs*Ts,1));

% (6) Calibrate TX and RX channels
dev.tx0.calibrate;
dev.rx0.calibrate;

% (7) Start the module

dev.start();
fprintf('Start of LimeSDR\n');

dev.transmit(waveform);
[samples, ~ , actual_count] = dev.receive(1024 * 16,0);

% (8) Cleanup and shutdown by stopping the RX stream and having MATLAB delete the handle object.

dev.stop();
clear dev;

fprintf('Stop of LimeSDR\n');

% (9) Plot either in time domain or frequency domain

% since it is a very basic example: the wave form may begin after a delay
% and it may result imperfections. however, waveform should be correct and
% frequency also. If the sample rate is too high, "cut" in the signal may 
% occur due to limited computing ressources.  
% The spectrum may also be imperfect due to the delay among other but
% should show the correct signal frequency.


figure
hold on
plot(real(samples),'-+b')

%I/Q samples from limesdr mini produces 2 signal. one may also want to plot
%the imaginary signal.

%plot(imag(samples),'r')

% if one may take a look to the frequency spectrum.
% figure
% pspectrum(real(samples),Fs)



