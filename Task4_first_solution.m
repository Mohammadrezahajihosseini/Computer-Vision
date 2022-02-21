% Cleanup/initialization
clc;    % Clear the command window.cle
close all;  % Close all figures (except those of imtool.)
clear;  % Erase all existing variables. Or clearvars if you want.
workspace;

%% Task 4: Design a simple tracking system according to the following guidelines
% a. Initialize the background model

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
  
%% b. Initialize the tracking history to empty
     foregroundDetector = vision.ForegroundDetector('NumGaussians', 3, ...
    'NumTrainingFrames', 50);
    newTrack = objectTrack();
    historyLogic = trackHistoryLogic('ConfirmationThreshold',[5 5], ...
    'DeletionThreshold',[10 10]);
%% c. At each time instant

%       i. Apply the change detection to obtain the binary map
%      ii. Update the background model
% Now start the change detection while updating the background with the
% running average. For that you have to set the values for TAU and ALPHA
%     iii. Identify the connected components in the binary map (see e.g.
%          the matlab function bwconncomp)
%      iv. Try to associate each connected component with a previously seen
%          target

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
    for i = 1:size(B,1)
        for j = 1:size(B,2)
            if B(i,j) <=6
                Bcurr(i,j) = Bprev(i,j);
            else
                Bcurr(i,j) = (1-ALPHA)*Bprev(i,j) + ALPHA*double(Ig(i,j));
                
            end
        end
    end
    P = 1000; %number of pixel 
    ctr = 1; %Counter 
    %To detect foreground in an image 
    foreground = step(foregroundDetector, It);
    %Find connected components in binary image
    CC = bwconncomp(foreground);
    S = regionprops(CC, 'Area','Boundingbox','Centroid','FilledImage');
    L = labelmatrix(CC);
    BW2 = ismember(L, find([S.Area] >= P));
    % fill holes
    BW3 = imfill(BW2,'holes');
    subplot(2, 2, 1), imshow(It),title ('object detector');
        hold on 
       for ii = 1: length(S) 
         if (100 < S(ii).Area)
         BB = S(ii).BoundingBox;
         xc=floor(S(ii).Centroid(1));
         yc=floor(S(ii).Centroid(2));
         plot(xc,yc,'*y')
         rectangle('Position', [BB(1),BB(2),BB(3),BB(4)],'EdgeColor','r','LineWidth',1) ;
         ctr=ctr+1;
         newTrack(ii+1) = objectTrack();
         end
       end
        subplot(2, 2, 2), imshow(uint8(Bcurr)),title ('Background update_Bcurr');
        subplot(2, 2, 3), imshow(uint8(Mt*255)),title ('Binary map');
        subplot(2, 2, 4), imshow(BW3),title ('imfill');
        pause(0.1)
        Bprev = Bcurr;
end