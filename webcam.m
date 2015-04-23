%% Initialization
% Create the Video Device System object.
vidDevice = imaq.VideoDevice('winvideo', 2, 'YUY2_640x480',...
                             'ReturnedColorSpace', 'rgb');
%%
% Create VideoPlayer System objects to display the videos.
hVideoOut = vision.VideoPlayer;
hVideoOut.Name  = 'Augmented Reality';

% Set up for stream
nFrames = 0;
while (nFrames<150)
    % Acquire single frame from imaging device.
    rgbData = step(vidDevice);% get input
%     rgb_Out = colorfunc(rgbData);% calculate augmented reality
    rgb_Out = featurefunc(rgbData);% calculate augmented reality
    step(hVideoOut, rgb_Out);% Display output video
    nFrames = nFrames + 1;% Increment frame count
end

%% Release
release(vidDevice);
release(hVideoOut);