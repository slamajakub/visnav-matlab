function dist = EuclideanDist(o1, o2)

    dist = sqrt(sum((o1 - o2).^2));

end