function [f1match, pts1match, f2match, pts2match] = matchFeatures(f1, pts1, f2, pts2, metrics)

    idx1 = zeros([size(f1, 1), 1]);
    idx2 = zeros([size(f1, 1), 1]);
    
    for i=1:size(f1, 1)
        best1dist = realmax('double');
        best2dist = realmax('double');
        
        % Find best 2 matching descriptors using bruteforce
        for j=1:size(f2, 1)
            
            % Use Euclidean norm
            dist = metrics(f2(j), f1(i));
            %dist = sum((f2(j) - f1(i)).^2);
            if dist < best1dist
                best2dist = best1dist;
                bestIdx = j;
                best1dist = dist;
            elseif dist < best2dist
                best2dist = dist;
            end            
        end
        
        if best1dist / best2dist < 0.85
            idx1(i) = i;
            idx2(i) = bestIdx;
        end 
    end        

    f1match = f1(idx1(idx1 > 0));
    pts1match = pts1(idx1(idx1 > 0));
    f2match = f2(idx2(idx2 > 0));
    pts2match = pts2(idx2(idx2 > 0));
end