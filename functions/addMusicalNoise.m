function [sDis,fs] = addMusicalNoise(s,fs,SNR,k)
% OSS_LICENSE
%
% This function adds musical noise distortions to a clean speech signal
%
% For more information see:
% Goesswein JA. Kollmeier B. & Rennies J. 2023.
% Method to control the amount of musical noise for speech quality assessments.
% Acta Acoustica, 7, 18.
% DOI: 10.1051/aacus/2023016
%
% This function requires the speech processing toolbox "voicebox"
% (https://github.com/ImperialCollegeLondon/sap-voicebox)
% and the large time frequency analysis toolbox "LTFAT"
% (https://github.com/ltfat/ltfat)
%
% If you are using OCTAVE instead of MATLAB and your signal does not have
% a sampling frequency of 16kHz, this function requires the OCTAVE
% signal package to resample the signal
% (https://gnu-octave.github.io/packages/signal/)
%
% _inputs_
% s - input clean speech signal
% fs - sampling frequency of input signal in Hz
% SNR - signal-to-noise-ratio in dB
% k - subtraction parameter >= 0
%
% The input parameters SNR and k control
% the amount of musical noise distortions
%
% _output_
% sDis - input speech signal with musical noise distortions
% fs - sampling frequency of output signal
%
% Copyright (C) 2022 Fraunhofer IDMT, Jonathan Albert Goesswein
%
% This program is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with this program. If not, see <https://www.gnu.org/licenses/>.
%
% author          : Jonathan Albert Goesswein
% email           : jonathan.goesswein@idmt.fraunhofer.de
% date            : 16-November-2022
% Matlab          : 9.3.0.713579 (R2017b)
% Octave          : 7.2.0
%
% See also: main, spectralSubtractionAlgo
%

%% checks

if size(s,2) > 1
  s = s(:,1);
  warning('input signal has multiple channels, channel 1 selected')
end
if fs ~= 16000 % Hz
  % the function "resample" is part of the signal package for OCTAVE
  s = resample(s,16000,fs);
  fs = 16000; % Hz
  warning('sampling frequency not 16kHz, signal resampled at 16kHz')
end
if k < 0
   error('k is < than 0! k has to be >= 0!')
end

%% calculation

IS = 0.25; % s

% speech signal
s = s(:);
% the function 'v_activlev' is part of the
% speech processing toolbox "voicebox"
level_s = v_activlev(s,fs,'d');
s = [zeros(IS*fs,1);s];
signalLength = length(s);

% noise signal
% the function 'noise' is part of the
% Large Time/Frequency Analysis Toolbox (LTFAT)
w = noise(signalLength,'white');
level_w = 10*log10(mean(w.^2));
targetLevel_w = level_s - SNR;
gain = targetLevel_w - level_w;
w = w .* 10.^(gain / 20);

% mixed signals
x_plus = s + w;
x_minus = s - w;

% spectral subtraction
a = 2; % 2 - power spectrum subtraction, 1 - magnitude spectral subtraction
alpha = 0; % 0 - no "noise floor", otherwise small positive value
sHat_plus = spectralSubtractionAlgo(x_plus,fs,IS,a,k,alpha);
sHat_minus = spectralSubtractionAlgo(x_minus,fs,IS,a,k,alpha);
sDis = sHat_plus + sHat_minus;
sDis = sDis(IS*fs+1:end);

% calibration
level_sDis = activlev(sDis,fs,'d');
gain = level_s - level_sDis;
sDis = sDis .* 10.^(gain / 20);
end
