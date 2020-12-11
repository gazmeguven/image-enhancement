I = imread('C:\Users\Gamze\Desktop\3.tif')
figure,imshow(I);
title('Noisy Image');

% Close the original image
% PROCESS 1
% Determine good padding for Fourier transform
PQ = paddedsize(size(I));

% Create Notch filters corresponding to extra peaks in the Fourier transform
H1 = notch('btw', PQ(1), PQ(2), 5, 979, 712);
H2 = notch('btw', PQ(1), PQ(2), 5, 25, 45);
figure,imshow(fftshift(H1.*H2));

% Calculate the discrete Fourier transform of the image
F = fft2(double(I),PQ(1),PQ(2));

% Apply the notch filters to the Fourier spectrum of the image
FS_I = F.*H1.*H2;

% Convert the result to the spacial domain
F_I=real(ifft2(FS_I)); 

% Crop the image to undo padding
F_I=F_I(1:size(I,1), 1:size(I,2));

% Display the blurred image
figure, imshow(F_I,[])

% Display the Fourier Spectrum 
% Move the origin of the transform to the center of the frequency rectangle.
%Fc=(F);

Fc=fftshift(F);
Fcf=fftshift(FS_I);

% Use abs to compute the magnitude and use log to brighten display
S1=log(1+abs(Fc)); 
S2=log(1+abs(Fcf));
figure, imshow(S1,[])
title('Fourier Spectrum of Image')
figure, imshow(S2,[])
title('Spectrum of image with Gaussian highpass filter')


% PROCESS 2
% Apply 3x3 median filter to remove salt&pepper noise
Isp = medfilt2(F_I, [3 3]) % 3x3 median filter gives the best result
figure, imshow(Isp, [])
title('After Applying Median Filter for Salt & Pepper Noise');


% PROCESS 3
% Brighten the image by using Power Law(Gamma) Transformation
r = double(Isp);
[m,n] = size(r); % m = row, n = column

% Apply the Power Law Transformation
gamma = 0.3; % for brighter image 0.3 is given
s = abs((1*r).^gamma); % s=c*r.^gamma, c is constant and equals to 1

% Normalization of s on an intensity scale of [0,255]
maxm = max(s(:));
minm = min(s(:));
for i=1:m
  for j=1:n
    s(i,j) = (255*s(i,j))/(maxm-minm);
  end
end

s = uint8(s);
figure, imshow(s)
title('Brighten Image')


% PROCESS 4
% Sharpen the image by using Highboost Filtering
w = fspecial('average', [3 3]);
a = imfilter(s,w,'replicate'); %smooth filter
mask = s-a; % apply mask
unsharp = s+mask; % apply unsharp masking
figure,imshow(mask)
title('Applying Mask')
figure,imshow(unsharp)
title('Applying Unsharp Mask')

h_boost = s+mask*3;
figure,imshow(h_boost)
title('Final State')