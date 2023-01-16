% OSS_LICENSE
%
% This script adds musical noise distortions to a clean speech signal
%
% First, a sound file is read. To the signal, musical noise distortions
% are added. The distorted signal is then written in a sound file.
%
% For further information, see:
% Goesswein, Jonathan Albert; Kollmeier, Birger & Rennies, Jan
% Method to control the amount of "musical" noise for speech quality assessments
% JASA express letters
%
% The example speech material is taken from:
% Nuesse, T.; Wiercinski, B.; Brand, T. & Holube, I.
% Measuring Speech Recognition With a Matrix Test Using Synthetic Speech.
% Trends in Hearing. 2019;23.
% doi:10.1177/2331216519862982
%
% The example speech matrial can be found here:
% doi: 10.5281/zenodo.4522088
%
% The function addMusicalNoise requires the speech processing toolbox
% "voicebox" (https://github.com/ImperialCollegeLondon/sap-voicebox)
% and the large time frequency analysis toolbox "LTFAT"
% (https://github.com/ltfat/ltfat)
%
% If you are using OCTAVE instead of MATLAB and your signal does not have
% a sampling frequency of 16kHz, addMusicalNoise requires the OCTAVE
% signal package to resample the signal
% (https://gnu-octave.github.io/packages/signal/)
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
% See also: addMusicalNoise, spectralSubtractionAlgo
%
%%

clear all
close all
clc

addpath('functions')

%%

[s,fs] = audioread('audio/sentenceOriginal.wav');
% you can also read your own speech-audio-file here
% fs should be 16kHz, otherwise signal will be resampled!
% if multiple channels, only channel 1 will be considered!

SNR = -20.3; % in dB
k = 3.6;

% suggested values for SNR and k:
% SNR = 0 dB, k = 0 : no distortions
% SNR = -3.1, k = 0.6
% SNR = -7.0, k = 1.4
% SNR = -11.5, k = 2.1
% SNR = -15.1, k = 2.7
% SNR = -17.6, k = 3.2
% SNR = -20.3, k = 3.6
% SNR = -23.3, k = 4.0
% SNR = -26.3, k = 4.4
% SNR = -29.8, k = 5.0 : maximum distortions

[sDis,fs] = addMusicalNoise(s,fs,SNR,k);

audiowrite(['audio/sentenceDistorted_SNR_' num2str(round(SNR)) '_k_' num2str(round(k)) '.wav'],sDis,fs)

