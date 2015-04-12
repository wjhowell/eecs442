%% Initialization
% Create the Video Device System object.
vidDevice = imaq.VideoDevice('winvideo', 2, 'MJPG_640x480', ...
                             'ROI', [1 1 640 480], ...
                             'ReturnedColorSpace', 'rgb');

%%
% Create VideoPlayer System objects to display the videos.
% hVideoIn = vision.VideoPlayer;
% hVideoIn.Name  = 'Original Video';
hVideoOut = vision.VideoPlayer;
hVideoOut.Name  = 'Motion Detected Video';

% Set up for stream
nFrames = 0;
while (nFrames<100)     % Process for the first 100 frames.
    % Acquire single frame from imaging device.
    rgbData = step(vidDevice);
    rgb_Out = colorfunc(rgbData);

    % Send image data to video player
    % Display original video.
%     step(hVideoIn, rgbData);
    % Display video along with motion vectors.
    step(hVideoOut, rgb_Out);

    % Increment frame count
    nFrames = nFrames + 1;
end

%% Release
% Here you call the release method on the System objects to close any open 
% files and devices.
release(vidDevice);
release(hVideoIn);
release(hVideoOut);