im1 = imread('bsq2.jpg');
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
% detectyellow = (blue > 90) & (blue < 160) & (red < 260) & (red > 210) & (green < 250) & (green > 175);
detectblack = (red < 35)&(green < 35)&(blue < 35);
smooth = medfilt2(detectblack, [5 5]);
smooth = imfill(smooth, 'holes');
% brdr = edge(smooth);
imshow(im1); hold on



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
strongpts = selectStrongest(points,6);
strongloc = strongpts.Location;
% strongloc = sortrows(strongloc);
samecorners = dist2(strongloc,strongloc) > 3550;
goodpts = zeros(4,2);
j = 1;
i = 1;
for loop = 1:4
   summed = sum(samecorners==0);
   goodpts(j,:) = strongloc(i,:);
   if(summed(:,i)>1)%duplicate
       i = i+1;
   end
   j = j+1;
   i = i+1;
end
% plot(goodpts(:,1), goodpts(:,2), '+g'); hold off;

plotloc(1:3,:) = strongloc(1:3,:);
plotloc(4,:) = strongloc(5,:);
plotloc([4 2],:) = plotloc([2 4],:);
plotloc([4 3],:) = plotloc([3 4],:);
fill(plotloc(:,1), plotloc(:,2),'r'); hold off;
stop = 1;
