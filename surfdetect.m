function [features, valid_points]=surfdetect(I)
    
    % Parameters setup for SURF features detector
    hessianThreshold = 100.0;
    nOctaves = 4;
    nOctaveLayers = 3;
    %extended = false;
    % SURF uses 64 bits for feature descriptor, allows also 128 bits. 
    % Thus, I assume that extended = False means 64 bits descriptor size.
    featureSize = 64;
    upright = true;
    
    featuresLimit = 2000;
    
    points = detectSURFFeatures(I, 'MetricThreshold', hessianThreshold, ...
        'NumOctaves', nOctaveLayers, 'NumScaleLevels', nOctaves);
    [features, valid_points] = extractFeatures(I, points, ...
        'Method', 'SURF', 'Upright', upright, 'FeatureSize', featureSize);
    
    if size(features, 1) > featuresLimit
        features = features(1:featuresLimit);
        valid_points = valid_points(1:featuresLimit);
    end
end