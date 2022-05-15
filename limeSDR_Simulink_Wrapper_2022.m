%%via_fx_24/may 2022 this is a modification of the simulink wrapper proposed by Joe Cover.
% this version is designed for limesdr mini. The main modification is in 
% the getSampleTimeImpl function. A update of simulink in 2020 needed a
% modification of the previous code. There are also minor modifications
% and comments to help folks make it works. With this simulink wrapper,
% i'm perfectly able to make AM and FM modulation (see .slx files) and
% obtain a perfect audio sound.

% folks with the limeSDR (not the mini one) may use the file from Joe Cover
% and just take my modification of the getSampleTimeImpl function(required 
% for recent version of simulink).

% to use the wrapper in a new .slx file, one has to add a block "matlab
% system" in the .slx sheet, then click on the block to open the windows. In
% this windows, one has to choose the "limeSDR_Simulink_Wrapper_2022.m".
% Then, click again in the block to adjust parameter (gain, frequency
% etc..). Realy user friendly thanks to Joe Cover.
%


classdef limeSDR_Simulink_Wrapper_2022 < matlab.System & ...
        matlab.system.mixin.Propagates & ...
        matlab.system.mixin.CustomIcon
    
    
    %% Properties
    properties
    % not sure about what should be the max of gain. 
    
        verbosity           = 'Info'    % limeSDR verbosity
        
        rx_frequency        = 868e6;    % Frequency [0.16e6, 3.8e9]
        rx0_gain =20;			% Gain [0, 60]
        
        
        tx_frequency = 868e6;    % Frequency [0.16e6, 3.8e9]
        
        tx0_gain =30;		 % Gain [0, 60]
        


    end
    
    
    
    properties(Nontunable)
        device_string       = '';       % Device specification string
        
        rx_samplerate       = 3e6;      % Sample rate
        rx_step_size        = 16384;	% Frame
        rx_timeout_ms       = 5000;     % Stream timeout (ms)
        
        rx0_bandwidth        = '1.5';    % LPF Bandwidth (MHz)(not that important I think)
        rx0_antenna   = 3;              % "1" above 2000mhz, "3" otherwise
        
        
        tx_samplerate       = 3e6;      % Sample rate
        tx_step_size        = 16384;	% Frame
        tx_timeout_ms       = 5000;     % Stream timeout (ms)
        
        tx0_bandwidth        = '1.5';    % LPF Bandwidth (MHz)(not that important I think)
        tx0_antenna   = 2;               % "1" above 2000mhz, "2" otherwise
        
        
        
    end
    
    properties(Logical, Nontunable)
        
        enable_rx0           = true;     % Enable Receiver
        enable_tx0           = false;    % Enable Transmitter

        
    end
    
    properties(Hidden, Transient)
        rx0_bandwidthSet = matlab.system.StringSet({ ...
            '1.5',  '1.75', '2.5',  '2.75',  ...
            '3',    '3.84', '5',    '5.5',   ...
            '6',    '7',    '8.75', '10',    ...
            '12',   '14',   '20',   '28'     ...
            });
                
        tx0_bandwidthSet = matlab.system.StringSet({ ...
            '1.5',  '1.75', '2.5',  '2.75',  ...
            '3',    '3.84', '5',    '5.5',   ...
            '6',    '7',    '8.75', '10',    ...
            '12',   '14',   '20',   '28'     ...
            });
        
    end
    
    properties (Access = private)
        device = []
        running
        
        iteration=0;
        Debugging_Vector=zeros(100e6,1);

        
    end
    
    %% Static Methods
    methods (Static, Access = protected)
        function groups = getPropertyGroupsImpl
%             device_section_group = matlab.system.display.SectionGroup(...
%                 'Title', 'Device', ...
%                 'PropertyList', {'device_string' } ...
%                 );
            
            %%RX
            
            rx0_group = matlab.system.display.Section(...
                'Title','RX0 parameters',...
                'PropertyList',{'enable_rx0','rx0_antenna','rx0_bandwidth','rx0_gain'});
            
            
            rx_stream_section = matlab.system.display.Section(...
                'Title', 'RX config', ...
                'PropertyList', {'rx_frequency','rx_samplerate', 'rx_timeout_ms', 'rx_step_size', } ...
                );
            
            rx_section_group = matlab.system.display.SectionGroup(...
                'Title', 'RX Configuration', ...
                'Sections', [ rx0_group, rx_stream_section] ...
                );
            
            %%TX
            
            tx0_group = matlab.system.display.Section(...
                'Title','TX0 parameters',...
                'PropertyList',{'enable_tx0','tx0_antenna','tx0_bandwidth','tx0_gain'});
            
            
            tx_stream_section = matlab.system.display.Section(...
                'Title', 'TX config', ...
                'PropertyList', {'tx_frequency','tx_samplerate', 'tx_timeout_ms', 'tx_step_size', } ...
                );
            
            tx_section_group = matlab.system.display.SectionGroup(...
                'Title', 'TX Configuration', ...
                'Sections', [ tx0_group,  tx_stream_section] ...
                );
            
            groups = [rx_section_group,tx_section_group ];
            
        end
        
        function simMode = getSimulateUsingImpl
            % Return only allowed simulation mode in System block dialog
            simMode = 'Interpreted execution';
        end
        
        function flag = showSimulateUsingImpl
            % Return false if simulation mode hidden in System block dialog
            flag = false;
        end
        
        function header = getHeaderImpl
            text = 'This block provides access to a LimeSDR mini device via limeSDR MATLAB bindings.';
            header = matlab.system.display.Header('limeSDR_Simulink_Wrapper_2022', ...
                'Title', 'limeSDR', 'Text',  text ...
                );
        end
    end
    
    methods (Access = protected)
        %% Output setup
        function count = getNumOutputsImpl(obj)
            if obj.enable_rx0 == true
                count = 1;
            else
                count = 0;
            end
            
        end
        
        function varargout = getOutputNamesImpl(obj)
            if obj.enable_rx0 == true
                varargout{1} = 'RX0 Samples';
            end
            
            
        end
        
        function varargout = getOutputDataTypeImpl(obj)
            if obj.enable_rx0 == true
                varargout{1} = 'double';    % RX0 Samples     
            end
            
        end
        
        % new implementation for compatibility with matlabR2020b and higher
        function sts = getSampleTimeImpl(obj)
            
            sts = createSampleTime(obj,'Type','Discrete',...
                'SampleTime',1/obj.rx_samplerate*obj.rx_step_size,'OffsetTime',0);
            
            
        end
        
        function varargout = getOutputSizeImpl(obj)
            if obj.enable_rx0 == true
                varargout{1} = [obj.rx_step_size 1];  % RX0 Samples
                
            end
        end
        
        function varargout = isOutputComplexImpl(obj)
            if obj.enable_rx0 == true
                varargout{1} = true;    % RX0 Samples
            end
        end
        
        function varargout  = isOutputFixedSizeImpl(obj)
            if obj.enable_rx0 == true
                varargout{1} = true;    % RX0 Samples
            end
            
        end
        
        
        %% Input setup
        function count = getNumInputsImpl(obj)
            if obj.enable_tx0 == true
                count = 1;
            else
                count = 0;
            end
            
        end
        
        function varargout = getInputNamesImpl(obj)
            if obj.enable_tx0 == true
                varargout{1} = 'TX0 Samples';
            end
            
        end
        
        %% Property and Execution Handlers
        function icon = getIconImpl(~)
            icon = sprintf('LimeSDR mini');
        end
        
        function setupImpl(obj)
            
 
            %% Device setup
            obj.device = limeSDR(obj.device_string);
            
            %% RX0 Setup
            if obj.enable_rx0 == true
                obj.device.rx0.frequency  = obj.rx_frequency;
                obj.device.rx0.gain = obj.rx0_gain;
                obj.device.rx0.samplerate=obj.rx_samplerate;
                obj.device.rx0.antenna=obj.rx0_antenna;
            end
            
            
            %% TX0 Setup
            if obj.enable_tx0 == true
                obj.device.tx0.frequency  = obj.tx_frequency;
                obj.device.tx0.samplerate=obj.tx_samplerate;
                obj.device.tx0.gain = obj.tx0_gain;
                obj.device.tx0.antenna=obj.tx0_antenna;
            end
            
            
            obj.running=false;
            
        end
        
        function releaseImpl(obj)
            delete(obj.device);
        end
        
        function resetImpl(obj)
            obj.device.stop();
        end
        
        % Perform a read of received samples and an 'overrun' array that denotes whether
        % the associated samples is invalid due to a detected overrun.
        function varargout = stepImpl(obj,varargin)
            varargout = {};

            
            if obj.enable_rx0 == true
                if obj.device.rx0.running == false
                    obj.device.rx0.enable();

                end
            end
            
            
            if obj.enable_tx0 == true
                if obj.device.tx0.running == false
                    obj.device.tx0.enable();
                end
            end
            
            
            if ~obj.running
                obj.device.start();
                obj.running=true;
            end
            
            if obj.enable_rx0 == true
                
                rx_samples0 = obj.device.receive(obj.rx_step_size,0);
                varargout{1} = rx_samples0;
                
            end
            

            
            if obj.enable_tx0 == true
                obj.device.transmit(varargin{1},0);

            end
        end
        
        function processTunedPropertiesImpl(obj)
            
            %% RX Properties
            
            if isChangedProperty(obj, 'rx_frequency')
                if obj.enable_rx0 ==true
                    obj.device.rx0.frequency = obj.rx_frequency;
                end
            end
            
            if obj.enable_rx0 ==true
                if isChangedProperty(obj, 'rx0_gain')
                    obj.device.rx0.gain = obj.rx0_gain;
                end
            end
            
            %% TX Properties
            
            if isChangedProperty(obj, 'tx_frequency')
                if obj.enable_tx0 ==true
                    obj.device.tx0.frequency = obj.tx_frequency;
                end
                
                
            end
            
            if isChangedProperty(obj, 'tx0_gain')
                obj.device.tx0.gain = obj.tx0_gain;
                
            end
            
        end
        
        
        
        function validatePropertiesImpl(obj)
            if obj.enable_rx0 == false && obj.enable_tx0 == false
                warning('LimeSDR RX and TX are not enabled. One or both should be enabled.');
            end
            
            %% Validate RX properties
            
            if obj.rx_timeout_ms < 0
                error('rx_timeout_ms must be >= 0.');
            end
            
            if obj.rx_step_size <= 0
                error('rx_step_size must be > 0.');
            end
            
            if obj.rx_samplerate < 160.0e3
                error('rx_samplerate must be >= 160 kHz.');
            elseif obj.rx_samplerate > 40e6
                error('rx_samplerate must be <= 40 MHz.')
            end
            
            if obj.rx_frequency < 10e6
                error('rx_frequency must be >= 10 MHz');
            elseif obj.rx_frequency > 3.8e9
                error('rx_frequency must be <= 3.8 GHz.');
            end
            
            %     if obj.rx0_gain < 0
            %         error('rx0_gain gain must be >= 0.');
            %     elseif obj.rx0_gain > 1
            %         error('rx0_gain gain must be <= 1.');
            %     end
            
            % new code from viafx24; not sure about it. The gain maybe be
            % above 60 (I dont exactly know the limit, maybe 61,72 or 100).
            % feel free to change the "60" and experiment with higher value
            
            if obj.rx0_gain < 0
                error('rx0_gain gain must be >= 0.');
            elseif obj.rx0_gain > 60
                error('rx0_gain gain must be <= 60.');
            end
            
            
%             if obj.rx0_antenna ~= 3 || obj.rx0_antenna ~= 1
%                 error('rx0_antenna must be 3 or 1.');
%             end
            
            %% Validate TX0 Properties
            
            if obj.tx_timeout_ms < 0
                error('tx_timeout_ms must be >= 0.');
            end
            
            if obj.tx_step_size <= 0
                error('tx_step_size must be > 0.');
            end
            
            if obj.tx_samplerate < 160.0e3
                error('tx_samplerate must be >= 160 kHz.');
            elseif obj.tx_samplerate > 40e6
                error('tx_samplerate must be <= 40 MHz.')
            end
            
            if obj.tx_frequency < 10e6;
                error('tx_frequency must be >= 10 MHz.');
            elseif obj.tx_frequency > 3.8e9
                error('tx_frequency must be <= 3.8 GHz.');
            end
            
            %     if obj.tx0_gain < 0
            %         error('tx_vga2 gain must be >= 0.');
            %     elseif obj.tx0_gain > 1
            %         error('tx_vga2 gain must be <= 1.');
            %     end
            
            % new code from viafx24; not sure about it. The gain maybe be
            % above 60 (I dont exactly know the limit, maybe 61,72 or 100).
            % feel free to change the "60" and experiment with higher value
            
            if obj.tx0_gain < 0
                error('tx_vga2 gain must be >= 0.');
            elseif obj.tx0_gain > 60
                error('tx_vga2 gain must be <= 60.');
            end
            
            
%             if obj.tx0_antenna ~=1
%                 error('tx0_antenna must be equal to 1.');
%             end
            
            
            
        end     
    end    
end


