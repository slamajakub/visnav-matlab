clear, close all, clc

folder = '../rose_data/';
filenames = 'rose';
img_type = 'png';
meta_type = 'csv';
depth_type = 'bin';

maxRansacIter = 10000;
maxReproErr = 25;

% Select detector and descriptor type: SURF, KAZE
% ORB does not exists in MATLAB, it would have to imported from openCV
% SIFT detector can be obtained from fileexchange and it is implemented 
% by other users
detectType = 'SURF';

% Number of image to be processed
count = 1;

% Setup up depth map creation info
renderDist = 70;
camera.width = 512;
camera.height = 512;
camera.x_fov = 5;
camera.y_fov = 5;
focalLength = [(tan(degtorad(camera.x_fov))) / camera.width, (tan(degtorad(camera.y_fov))) / camera.height];
imageSize = [512, 512];
intrinsicMatrix = [11726.728, 0,         0;
                       0,         11726.728, 0;
                       512,       512,       1];

for i=24:25%0:count-1
    % Read navcam image
    navcam = imread(strcat(folder, filenames, '_', num2str(i, '%04d'), '.', img_type));
    
    % Read low resolution reference image
    ref_low = imread(strcat(folder, filenames, '_', num2str(i, '%04d'), '_med.', img_type));
    
    % Read depth image
    fid = fopen(strcat(folder, filenames, '_', num2str(i, '%04d'), '_med.', depth_type));
    depth = fread(fid, [512 512], 'float');
    depth = depth * -1;
    
    % Read metadata ommiting labels
    meta = dlmread(strcat(folder, filenames, '_', num2str(i, '%04d'), '_meta.', meta_type), '\t', 1, 1);

    
    % Scale ref_low to navcam resolution
    % Upscale to 1024x1024 px using bicubic interpolation
    ref = imresize(ref_low, size(navcam));
    scaleFactor = size(navcam) ./ size(ref_low);
    
    % Detect features
    if strcmp(detectType, 'SURF')
        [navcam_features, navcam_validPoints] = surfdetect(navcam);
        [ref_features, ref_validPoints] = surfdetect(ref);
        metrics = @EuclideanDist;
    elseif strcmp(detectType, 'KAZE')
        [navcam_features, navcam_validPoints] = kazedetect(navcam);
        [ref_features, ref_validPoints] = kazedetect(ref);
        metrics = @HammingDist;
    end
    
    % Match features between navcam and ref images
    [navcamFeatureMatch, navcamValidPtsMatch, refFeatureMatch, refValidPtsMatch] = ...
        matchFeatures(navcam_features, navcam_validPoints, ref_features, ref_validPoints, metrics);
    
    
    
    locs = refValidPtsMatch.Location ./ scaleFactor;
    xyzCoords = getRealCoords(locs, depth, renderDist, camera, intrinsicMatrix);

    % Get camera position
    cameraParams = cameraParameters('IntrinsicMatrix', intrinsicMatrix);
    [worldOrientation,worldLocation, inlierIdx] = estimateWorldCameraPose(double(locs), xyzCoords, cameraParams, 'MaxNumTrials', maxRansacIter, 'MaxReprojectionError', maxReproErr);
    worldOriQuat = qGetQ(worldOrientation);
        
    inlierIdx = find(inlierIdx);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Visualization
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % Print images
    figure, subplot(221), imshow([navcam, ref]); hold on
    
    
    % Print images with detected features
    subplot(223), imshow([navcam, ref]); hold on
    off = size(navcam,2);
    plot(navcamValidPtsMatch.Location(:,1),navcamValidPtsMatch.Location(:,2), 'g+')
    plot(refValidPtsMatch.Location(:,1) + off,refValidPtsMatch.Location(:,2), 'g+')
    hold off
    
    % Print images and corresponding features
    subplot(224), imshow([navcam, ref]); hold on
    plot(navcamValidPtsMatch.Location(:,1),navcamValidPtsMatch.Location(:,2), 'g+')
    plot(refValidPtsMatch.Location(:,1) + off,refValidPtsMatch.Location(:,2), 'g+')
    
    for ii=1:size(navcamValidPtsMatch.Location, 1)
        plot([navcamValidPtsMatch.Location(ii, 1), refValidPtsMatch.Location(ii, 1) + off],...
        [navcamValidPtsMatch.Location(ii, 2), refValidPtsMatch.Location(ii, 2)])
    end
    hold off
    
    disp(size(inlierIdx))
    % Print images and corresponding features
    subplot(222), imshow([navcam, ref]); hold on
    plot(navcamValidPtsMatch.Location(inlierIdx,1),navcamValidPtsMatch.Location(inlierIdx,2), 'g+')
    plot(refValidPtsMatch.Location(inlierIdx,1) + off,refValidPtsMatch.Location(inlierIdx,2), 'g+')
    
    for jj=1:size(inlierIdx)
        ii = inlierIdx(jj);
        plot([navcamValidPtsMatch.Location(ii, 1), refValidPtsMatch.Location(ii, 1) + off],...
        [navcamValidPtsMatch.Location(ii, 2), refValidPtsMatch.Location(ii, 2)])
    end
    hold off
    
    q1 = meta(1, 5:8);
    q2 = meta(2, 5:8);
    q2c = q2 .* [-1 1 1 1];
    des = qMul2(q1, q2c)
    worldOriQuat
  
end