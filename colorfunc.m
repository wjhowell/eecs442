function [output] = colorfunc(input)

im1 = input;
im2 = imread('puppy.jpg');

red = im1(:,:,1);
green = im1(:,:,2);
blue = im1(:,:,3);
% detectblack = (red < .3)&(green < .3)&(blue < .3);
detectblack = (red < 30)&(green < 30)&(blue < 30);
smooth = medfilt2(detectblack, [5 5]);
smooth = imfill(smooth, 'holes');

points = detectHarrisFeatures(smooth,'FilterSize',65);
if isempty(points)
    output = input;
    return
end
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

w = 40; %window
blacksum = zeros(4,1);
black = zeros(2*w+1,2*w+1,4);
corners = zeros(4,2);
for i = 1:4
    if((greatpts(i,2)-w) < 1 || (greatpts(i,2)+w) > size(im1,1) || (greatpts(i,1)-w) < 1 || (greatpts(i,1)+w) > size(im1,2))
        output = input;
        return
    end
    crop = im1(greatpts(i,2)-w:greatpts(i,2)+w,greatpts(i,1)-w:greatpts(i,1)+w,:);
%     black(:,:,i) = (crop(:,:,1) < .3)&(crop(:,:,2) < .3)&(crop(:,:,3) < .3);
    black(:,:,i) = (crop(:,:,1) < 30)&(crop(:,:,2) < 30)&(crop(:,:,3) < 30);
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
output = im1;
output(1:x,1:y,1:z) = im2single(translated) + im1(1:x,1:y,1:z);

