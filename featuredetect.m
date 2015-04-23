

%% Step 1: Read Images
% Read the reference image containing the object of interest.
tracker = imread('wolverinetracker.jpg');
tracker = rgb2gray(tracker);

%%
% Read the target image containing a cluttered scene.
sceneImage = imread('wolverinescene.jpg');
out = sceneImage;
sceneImage = rgb2gray(sceneImage);

%%
% Read the overlay image.
overlay = imread('Overlay.jpg');

%% Step 2: Detect Feature Points
% Detect feature points in both images.
trackerPoints = detectSURFFeatures(tracker);
scenePoints = detectSURFFeatures(sceneImage);

%% 
% Visualize the strongest feature points found in the reference image.
% figure; 
% imshow(tracker);
% title('100 Strongest Feature Points from Box Image');
% hold on;
% plot(selectStrongest(trackerPoints, 100));

%% 
% Visualize the strongest feature points found in the target image.
% figure; 
% imshow(sceneImage);
% title('300 Strongest Feature Points from Scene Image');
% hold on;
% plot(selectStrongest(scenePoints, 300));

%% Step 3: Extract Feature Descriptors
% Extract feature descriptors at the interest points in both images.
[boxFeatures, trackerPoints] = extractFeatures(tracker, trackerPoints);
[sceneFeatures, scenePoints] = extractFeatures(sceneImage, scenePoints);

%% Step 4: Find Putative Point Matches
% Match the features using their descriptors. 
boxPairs = matchFeatures(boxFeatures, sceneFeatures);

%% 
% Display putatively matched features. 
matchedBoxPoints = trackerPoints(boxPairs(:, 1), :);
matchedScenePoints = scenePoints(boxPairs(:, 2), :);
% figure;
% showMatchedFeatures(tracker, sceneImage, matchedBoxPoints, ...
%     matchedScenePoints, 'montage');
% title('Putatively Matched Points (Including Outliers)');

%% Step 5: Locate the Object in the Scene Using Putative Matches
% |estimateGeometricTransform| calculates the transformation relating the
% matched points, while eliminating outliers. This transformation allows us
% to localize the object in the scene.
[tform, inlierBoxPoints, inlierScenePoints] = ...
    estimateGeometricTransform(matchedBoxPoints, matchedScenePoints, 'affine');

%%
% Display the matching point pairs with the outliers removed
% figure;
% showMatchedFeatures(tracker, sceneImage, inlierBoxPoints, ...
%     inlierScenePoints, 'montage');
% title('Matched Points (Inliers Only)');

%% 
% Get the bounding polygon of the reference image.
% boxPolygon = [1, 1;...                           % top-left
%         size(tracker, 2), 1;...                 % top-right
%         size(tracker, 2), size(tracker, 1);... % bottom-right
%         1, size(tracker, 1);...                 % bottom-left
%         1, 1];                   % top-left again to close the polygon
overlayPolygon = [1, 1;...                           % top-left
    size(overlay, 2), 1;...                 % top-right
    size(overlay, 2), size(overlay, 1);... % bottom-right
    1, size(overlay, 1);...                 % bottom-left
    1, 1];                   % top-left again to close the polygon

%%
% Transform the polygon into the coordinate system of the target image.
% The transformed polygon indicates the location of the object in the
% scene.
% newBoxPolygon = transformPointsForward(tform, boxPolygon); 
final = uint8(zeros(size(out,1), size(out,2), 3));
newoverlayPolygon = transformPointsForward(tform, overlayPolygon);
imT = imwarp(overlay, tform);
translate = imtranslate(imT, [min(newoverlayPolygon(:, 1)), min(newoverlayPolygon(:, 2))], 'OutputView', 'full');
[x y z] = size(translate);
final(1:x,1:y,1:z) = translate(:,:,:) + final(1:x,1:y,1:z);
mask = (final(:,:,1) > 0 | final(:,:,2) > 0 | final(:,:,3) > 0);

layer = out(:,:,1); t = final(:,:,1);
layer(mask) = t(mask);
out(:,:,1) = layer;
layer = out(:,:,2); t = final(:,:,2);
layer(mask) = t(mask);
out(:,:,2) = layer;
layer = out(:,:,3); t = final(:,:,3);
layer(mask) = t(mask);
out(:,:,3) = layer;
%out(1:x,1:y,1:z) = translate + out(1:x,1:y,1:z);
%%
% Display the detected object.
figure;
imshow(out);
% hold on;
%line(newoverlayPolygon(:, 1), newoverlayPolygon(:, 2), 'Color', 'y');
title('Detected Box');

