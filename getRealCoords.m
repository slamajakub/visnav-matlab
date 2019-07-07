function coords =  getRealCoords(pts, depthMap, renderDist, camera, intc)

    coords = zeros(size(pts, 1), 3);
    
    for j = 1:size(pts, 1)

        x = [floor(pts(j, 1)), ceil(pts(j,1))];
        y = [floor(pts(j, 2)), ceil(pts(j,2))];
        [X, Y] = meshgrid(x, y);
        vals = depthMap(x, y);
        z_off = interp2(X, Y, vals, pts(j, 1), pts(j, 2));

        xh = pts(j, 1) + 0.5;
        yh = pts(j, 2) + 0.5;
        zh = -z_off;

        cx = xh / camera.width - 0.5;
        cy = yh / camera.height - 0.5;

        h_angle = cx * degtorad(camera.x_fov);
        x_off = zh * tan(h_angle);

        v_angle = cy * degtorad(camera.y_fov);
        y_off = zh * tan(v_angle);

        coords(j, :) = [x_off, y_off, z_off - renderDist];

    end
end