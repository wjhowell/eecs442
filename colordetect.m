tic;
im1 = imread('bsq6.jpg');
im2 = imread('puppy.jpg');
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
detectblack = (red < 35)&(green < 35)&(blue < 35);
smooth = medfilt2(detectblack, [5 5]);
smooth = imfill(smooth, 'holes');
% imshow(im1); hold on

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
samecorners = dist2(strongloc,strongloc) > 3550;
goodpts = zeros(6,2);

goodpts(1,:) = strongloc(1,:);
j = 2;
count = 0;
for i = 2:6
    skip = 0;
    for loop = 1:j-1
        if(samecorners(:,j) == samecorners(:,j-loop))
           skip = 1;
           break; 
        end
    end
    if(skip == 0)
        goodpts(i,:) = strongloc(j,:);
        count = count + 1;
        if(count == 3)
            break;
        end
    else
       goodpts(i,:) = [0 0]; 
    end
    j = j+1;
end

j = 1;
greatpts = zeros(4,2);
for i = 1:6;
   if(goodpts(i,:) > 0)
       greatpts(j,:) = goodpts(i,:);
       j = j+1;
   end
end

% plot(greatpts(:,1), greatpts(:,2), '+g');

w = 40; %window
blacksum = zeros(4,1);
black = zeros(2*w+1,2*w+1,4);
corners = zeros(4,2);
for i = 1:4
    crop = im1(greatpts(i,2)-w:greatpts(i,2)+w,greatpts(i,1)-w:greatpts(i,1)+w,:);
    black(:,:,i) = (crop(:,:,1) < 35)&(crop(:,:,2) < 35)&(crop(:,:,3) < 35);
    blacksum(i,1) = sum(sum(black(:,:,i)));
end

[~, whitecorner] = min(blacksum);

for i = 1:4 
    if i == whitecorner
        continue;
    end
    
    if black(1,1,i) == 1 % bottom right
        corners(3,:) = greatpts(i,:);        
    elseif black(1,2*w+1,i) == 1 % bottom left
        corners(2,:) = greatpts(i,:);
    elseif black(2*w+1,1,i) == 1 % top right
        corners(4,:) = greatpts(i,:);
    elseif black(2*w+1,2*w+1,i) == 1 % top left
        corners(1,:) = greatpts(i,:);
    end    
end

shift = find(corners(:,1) == 0);
corners(shift,:) = greatpts(whitecorner,:);
corners = circshift(corners,-(shift-1));

squarepts = [1 1; 1 500; 500 500; 500 1]; % top left, bottom left, bottom right, top right
H = calcH(squarepts, corners);
H = H';
T = maketform('projective', H); %use affine2d
imT = imtransform(im2,T);

translated = imtranslate(imT, [min(greatpts(:,1)), min(greatpts(:,2))], 'OutputView', 'full');
[x, y, z] = size(translated);
test = im1;
test(1:x,1:y,1:z) = translated + im1(1:x,1:y,1:z);
figure, imshow(test);

toc;
