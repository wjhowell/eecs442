% im1 = imread('bsq6.jpg');
% im2 = imread('puppy.jpg');
vidDevice = imaq.VideoDevice('winvideo', 1, 'YUY2_640x480', ... % Acquire input video stream
                    'ROI', [1 1 640 480], ...
                    'ReturnedColorSpace', 'rgb');
vidInfo = imaqhwinfo(vidDevice); % Acquire input video property
hVideoIn = vision.VideoPlayer('Name', 'Final Video', ... % Output video player
                                'Position', [100 100 vidInfo.MaxWidth+20 vidInfo.MaxHeight+30]);
nFrame = 0; % Frame number initialization

% red = im1(:,:,1);
% green = im1(:,:,2);
% blue = im1(:,:,3);
% detectblack = (red < 35)&(green < 35)&(blue < 35);
% smooth = medfilt2(detectblack, [5 5]);
% smooth = imfill(smooth, 'holes');
% imshow(im1); hold on

while(nFrame < 20000)
    im1 = step(vidDevice); % Acquire single frame
    im1 = flipdim(im1,2);
    red = im1(:,:,1);
    green = im1(:,:,2);
    blue = im1(:,:,3);
    detectblack = (red < 35)&(green < 35)&(blue < 35);
    smooth = medfilt2(detectblack, [5 5]);
    smooth = imfill(smooth, 'holes');
    
    step(hVideoIn, vidIn); % Output video stream
    nFrame = nFrame+1;
end

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
