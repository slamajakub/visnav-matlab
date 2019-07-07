function [features, valid_points]=kazedetect(I)
    
    %'descriptor_type':cv2.AKAZE_DESCRIPTOR_MLDB, # default: cv2.AKAZE_DESCRIPTOR_MLDB
    %'descriptor_channels':3,    # default: 3
    %'descriptor_size':0,        # default: 0
    
    % Size might be 64 or 128 bits
    featureSize = 64;
    
    % Charbonnier method for diffusivity in MATLAB is not implemented.
    % Can be used 'region' (Perona and Malik 1/(1 + dL^2/k^2)),
    % 'sharpedge' (Perona and Malik exp(-|dL|^2/k^2)),
    % 'edge' (Wickert)    
    diffusivity = 'edge';
    threshold = 0.00005;
    nOctaves = 4;
    nOctaveLayers = 4;
    
    featuresLimit = 2000;
    
    points = detectKAZEFeatures(I, 'Diffusion', diffusivity, ...
        'Threshold', threshold, 'NumOctaves', nOctaveLayers, ...
        'NumScaleLevels', nOctaves);
    [features, valid_points] = extractFeatures(I, points, ...
        'Method', 'KAZE', 'FeatureSize', featureSize);
    
    if size(features, 1) > featuresLimit
        features = features(1:featuresLimit);
        valid_points = valid_points(1:featuresLimit);
    end
end