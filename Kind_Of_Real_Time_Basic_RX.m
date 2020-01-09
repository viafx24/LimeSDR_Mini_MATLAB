
% Simple example to receive signal using LimeSDR_Mini in kind of real time.
% It is more rapid than the other basicRx program.
% Author: viafx24, Jan 2020

% Modified from Author:
%    Damir Rakhimov, CRL, TU Ilmenau, Dec 2019
%    

clearvars -except obj_specwaterfall

dev = limeSDR(); % Open device

% Setup device parameters. These may be changed while the device
% is actively streaming.

TotalTime   = 12;       % Time of observation, s
Fc          = 100e6;   % Carrier Frequency, Hz (test in the FM radio band)
Fs          = 5e6;     % Frequency of sampling frequency, Hz
Frmlen = Fs/100;       %  output data frame size( 10ms ???)
BW          = 5e6;     % Bandwidth of the signal, Hz (5-40MHz and 50-130Mhz)
Gain        = 30;      % Receiver Gain, dB

dev.rx0.frequency  = Fc;
dev.rx0.samplerate = Fs;
dev.rx0.bandwidth = BW;
dev.rx0.gain = Gain;
dev.rx0.antenna = 3; % LNA_W(LNA_L doesn't work on limeSDR mini)
ChipTemp    = dev.chiptemp;
fprintf('Rx Device temperature: %3.1fC\n', ChipTemp);

% create SpectrumAnalyzer: it takes a lot of time thus, i added an "if exist" to do
% not have to execute this code each time the script is started.
% if accidentely, one close the windows of the waterfall, one need to
% delete the object in the workspace to recreate the following object.

if ~exist('obj_specwaterfall','var')
    
    obj_specwaterfall = dsp.SpectrumAnalyzer(...
        'Name', 'Spectrum Analyzer Waterfall',...
        'Title', 'Spectrum Analyzer Waterfall',...
        'SpectrumType', 'Spectrogram',...
        'FrequencySpan', 'Full',...
        'SampleRate', Fs);
    
end

% Enable stream parameters. These may NOT be changed while the device
% is streaming.

dev.rx0.enable;

% (4) Start the module

dev.start();

Frmtime = Frmlen/Fs; % the tiny increment of time 
run_time = 0;

% run while run_time is less than TotalTime
while run_time < TotalTime
    
    [samples, ~, samplesLength] = dev.receive(Frmlen,0); % (5) Receive Fs*Ts samples on RX0 channel
    step(obj_specwaterfall, samples);% refresh the waterfall
    run_time = run_time + Frmtime;
    
end

% (6) Cleanup and shutdown by stopping the RX stream and having MATLAB
%     delete the handle object.
dev.stop();
clear dev;
