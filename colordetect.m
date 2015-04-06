im1 = imread('sq3.jpg');
% vidDevice = imaq.VideoDevice('winvideo', 1, 'YUY2_640x480', ... % Acquire input video stream
%                     'ROI', [1 1 640 480], ...
%                     'ReturnedColorSpace', 'rgb');
% vidInfo = imaqhwinfo(vidDevice); % Acquire input video property
% hblob = vision.BlobAnalysis('AreaOutputPort', false, ... % Set blob analysis handling
%                                 'CentroidOutputPort', true, ... 
%                                 'BoundingBoxOutputPort', true', ...
%                                 'MinimumBlobArea', 800, ...
%                                 'MaximumBlobArea', 3000, ...
%                                 'MaximumCount', 10);
% hshapeinsRedBox = vision.ShapeInserter('BorderColor', 'Custom', ... % Set Red box handling
%                                         'CustomBorderColor', [1 0 0], ...
%                                         'Fill', true, ...
%                                         'FillColor', 'Custom', ...
%                                         'CustomFillColor', [1 0 0], ...
%                                         'Opacity', 0.4);
% htextinsCent = vision.TextInserter('Text', '+      X:%4d, Y:%4d', ... % set text for centroid
%                                     'LocationSource', 'Input port', ...
%                                     'Color', [1 1 0], ... // yellow color
%                                     'FontSize', 14);
% hVideoIn = vision.VideoPlayer('Name', 'Final Video', ... % Output video player
%                                 'Position', [100 100 vidInfo.MaxWidth+20 vidInfo.MaxHeight+30]);
% nFrame = 0; % Frame number initialization





red = im1(:,:,1);
green = im1(:,:,2);
blue = im1(:,:,3);
% detectblue = (blue > 75) & (blue < 95) & (red < 10) & (green < 60);
% detectblue = (blue > 130) & (blue < 210) & (red < 130) & (red > 20) & (green < 210) & (green > 120);
detectyellow = (blue > 90) & (blue < 160) & (red < 260) & (red > 210) & (green < 250) & (green > 175);
smooth = medfilt2(detectyellow, [5 5]);
smooth = imfill(smooth, 'holes');
% brdr = edge(smooth);
imshow(smooth); hold on



% while(nFrame < 20000)
%     rgbFrame = step(vidDevice); % Acquire single frame
%     rgbFrame = flipdim(rgbFrame,2); % obtain the mirror image for displaying
%     red = rgbFrame(:,:,1);
%     green = rgbFrame(:,:,2);
%     blue = rgbFrame(:,:,3);
% %     detectblue = (blue > .75) & (blue < 1) & (red < .10) & (green < .60);
% %     detectyellow = (blue > 90) & (blue < 160) & (red < 260) & (red > 210) & (green < 250) & (green > 175);
%     detectyellow = (blue > .5) & (blue < .9) & (red < .9) & (red > .5) & (green < .9) & (green > .55);
%     smooth = medfilt2(detectyellow, [5 5]);
%     smooth = imfill(smooth, 'holes');
%     [centroid, bbox] = step(hblob, smooth);
%     centroid = uint16(centroid); % Convert the centroids into Integer for further steps 
%     vidIn = step(hshapeinsRedBox, rgbFrame, bbox); % Instert the red box
%     for object = 1:1:length(bbox(:,1)) % Write the corresponding centroids
%             centX = centroid(object,1); centY = centroid(object,2);
%             vidIn = step(htextinsCent, vidIn, [centX centY], [centX-6 centY-9]); 
%     end
%     step(hVideoIn, vidIn); % Output video stream
%     nFrame = nFrame+1;
% end


points = detectHarrisFeatures(smooth,'FilterSize',65);
%ptsloc = points.Location;
%points.plot; hold off;
strongpts = selectStrongest(points,6);
strongloc = strongpts.Location;
samecorners = dist2(strongloc,strongloc) > 50;

strongpts.plot; hold off;

% [row  col] = find(smooth);
% pts(:,1) = row;
% pts(:,2) = col;
% dist = sqrt(dist2(pts, pts));
% [d ind] = max(dist(:));
% dist = sqrt((y2-y1)^2+(x2-x1)^2);


% figure, imshow(smooth); hold on
% 
% [row  col] = find(smooth);
% 
% [minr minri] = min(row);
% [minc minci] = min(col);
% [maxr maxri] = max(row);
% [maxc maxci] = max(col);
% 
% minr2 = col(minri);
% minc2 = row(minci);
% maxr2 = col(maxri);
% maxc2 = row(maxci);
% 
% corners1 = [minr2; minc; maxr2; maxc];
% corners2 = [minr; minc2; maxr; maxc2];
% 
% plot(corners1, corners2, 'Color', 'green', 'Marker', 'x');

% corners = detectHarrisFeatures(smooth);
% [features, valid_corners] = extractFeatures(smooth, corners);
% figure; imshow(smooth); hold on
% plot(valid_corners); hold off

% stop = 1;