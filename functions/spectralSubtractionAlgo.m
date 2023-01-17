function sHat = spectralSubtractionAlgo(x,fs,IS,a,k,alpha)
% OSS_LICENSE
%
% This function is a spectral subtraction noise reduction algorithm
% 
% Calculation according to [1] and [2]
% This is a modified version of [3]
%
% _inputs_
% x - noisy speech signal
% fs - sampling frequency
% IS - initial silence (noise only) in seconds
% a - Magnitude Power 
% (a = 1 for magnitude spectral subtraction, 
%  a = 2 for power spectrum subtraction)
% k - controls the amount of subtraction
% alpha - 0 or some small positive value to create a "noise floor"
%
% _output_
% sHat - estimated speech
% contains clean speech, residual noise and musical noise artifacts
%
% [1] Boll, S. (1979)
% Suppression of acoustic noise in speech using spectral subtration
% IEEE Transactions on Acoustics, Speech, and Signal Processing, 27(2), 113-120
% https://doi.org/10.1109/TASSP.1979.1163209
%
% [2] Thiemann, J. (2001)
% Acoustic Noise Supression for Speech Signals using Auditory Masking Effects [Master Thesis]
% McGill University, Montreal, Canada
% https://escholarship.mcgill.ca/concern/theses/vm40xt64p
%
% [3] Zavarehei, Esfandiar (2022)
% Multi-band Spectral Subtraction
% https://www.mathworks.com/matlabcentral/fileexchange/7674-multi-band-spectral-subtraction
% MATLAB Central File Exchange. Retrieved November 15, 2022.
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

%%

windowLength = fix(0.025*fs);
shiftPerc = 0.4;
window = hamming(windowLength);

numSilSegs = fix((IS*fs-windowLength)/(shiftPerc*windowLength) +1);

xSeg = segment(x,windowLength,shiftPerc,window);
Xseg = fft(xSeg,windowLength);
phiXseg = angle(Xseg(1:fix(end/2)+1,:));
absXseg = abs(Xseg(1:fix(end/2)+1,:)).^a;
numFrames = size(absXseg,2);

absWhatSeg = mean(absXseg(:,1:numSilSegs),2);

Tmp2 = zeros(windowLength/2+1,numFrames); % init
for indFrame = 1:numFrames
  Tmp = absXseg(:,indFrame)-(k*absWhatSeg);
  Tmp2(:,indFrame) = max(Tmp,alpha);
end

sHat = overlapAdd(Tmp2.^(1/a),phiXseg,windowLength,shiftPerc*windowLength);

function signal = overlapAdd(y,yPhase,windowLength,shiftLength)

if fix(shiftLength) ~= shiftLength
    shiftLength = fix(shiftLength);
end

[~,sizeY2] = size(y);

Spectrum = y.*exp(1i*yPhase);

if mod(windowLength,2)
    Spectrum = [Spectrum ; flipud(conj(Spectrum(2:end,:)))];
else
    Spectrum = [Spectrum ; flipud(conj(Spectrum(2:end-1,:)))];
end

signal = zeros((sizeY2-1)*shiftLength+windowLength,1);

for ind = 1:sizeY2
    start = (ind-1) * shiftLength + 1;
    spectrum = Spectrum(:,ind);
    signal(start:start+windowLength-1) = signal(start:start+windowLength-1)+real(ifft(spectrum,windowLength));
end

end

function Segment = segment(signal,windowLength,shiftPerc,Window)

Window = Window(:);

lengthSignal = length(signal);
shiftPerc = fix(windowLength.*shiftPerc);
numberOfSegments = fix((lengthSignal-windowLength)/shiftPerc +1);

Index = (repmat(...
  1:windowLength,...
  numberOfSegments,1)+repmat((0:(numberOfSegments-1))'*shiftPerc,...
  1,...
  windowLength))';

repWindow = repmat(Window,1,numberOfSegments);
Segment = signal(Index) .* repWindow;
end
end

