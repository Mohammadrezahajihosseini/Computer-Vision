% Cleanup/initialization
clc;    % Clear the command window.
close all;  % Close all figures (except those of imtool.)
clear;  % Erase all existing variables. Or clearvars if you want.
workspace;

%% Task 3: Repeat the above experiment with the sequence frames_evento1 observing what happens as you change 
% the parameters TAU and ALPHA
% ... FILL HERE ...
% Let's use the first N  frames to initialize the background

FIRST_IDX = 4728; %index of first image
LAST_IDX = 6698; % index of last image

N = 5;

filename = sprintf('frames_evento1/frame%4.4d.jpg', FIRST_IDX);
B = double(rgb2gray(imread(filename)));
for t = FIRST_IDX+1 : FIRST_IDX + N-1
    
    filename = sprintf('frames_evento1/frame%4.4d.jpg', t);
    B = B + double(rgb2gray(imread(filename)));
    
end

B = B / N;

% Play with these parameters
TAU = 15; 
ALPHA = 0.1;

% Now start the change detection while updating the background with the
% running average. For that you have to set the values for TAU and ALPHA

Bprev = B;
for t = FIRST_IDX+N : LAST_IDX
    
    filename = sprintf('frames_evento1/frame%4.4d.jpg', t);
    
    It = imread(filename);
    Ig = rgb2gray(It);
    
    Mt = (abs(double(Ig) - Bprev) > TAU);
    
    % Implement the background update as a running average
    %Bcurr = % ... FILL HERE ...
    for i = 1:size(B,1)
        for j = 1:size(B,2)
            if B(i,j) <=6
                Bcurr(i,j) = Bprev(i,j);
            else
                Bcurr(i,j) = (1-ALPHA)*Bprev(i,j) + ALPHA*double(Ig(i,j));
                
            end
        end
    end
   %keyboard
    subplot(1, 3, 1), imshow(It),title('Orginal image');
    subplot(1, 3, 2), imshow(uint8(Bcurr)),title('Background update_Bcurr');
    subplot(1, 3, 3), imshow(uint8(Mt*255)),title('Binary map');
    pause(0.1)
    Bprev = Bcurr;
    
end