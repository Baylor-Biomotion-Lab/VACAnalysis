function [ dataResamp ] = resampleCFI( data, varargin )
%Take in data and upscale it to 1500 points using cubic interpolation
% dataResamp = resampleCFI(data) will output the resampled data at 1500
% points
%
% dataResamp = resampleCFI(data,n) will output the resampled data at n
% points. This is not guaranteed to work. 
%
data(data==0) = [];
n = 1500;
% option to scale it up higher
if ~isempty(varargin)
    n = varargin{1};
end
xold = linspace(0,100,length(data));
xnew = linspace(0,100,n); % 0 to 100 in 1500 points
dataResamp = interp1(xold, data, xnew, 'pchip');
end

