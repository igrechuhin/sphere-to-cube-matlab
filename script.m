% [ Up, Down, Left, Front, Right, Back ] = ...
%     Sphere2TilesAlt(imread('panoramaSpherical.jpg'), 2400);
% 
% imwrite(    Up, 'panoramaSpherical_u.jpg', 'jpg');
% imwrite(  Down, 'panoramaSpherical_d.jpg', 'jpg');
% imwrite(  Left, 'panoramaSpherical_l.jpg', 'jpg');
% imwrite( Front, 'panoramaSpherical_f.jpg', 'jpg');
% imwrite( Right, 'panoramaSpherical_r.jpg', 'jpg');
% imwrite(  Back, 'panoramaSpherical_b.jpg', 'jpg');

[ Up, Down, Left, Front, Right, Back ] = ...
    Sphere2TilesAltMap(imread('panoramaSphericalGray.jpg'), 800);

imwrite(    Up, 'panoramaSphericalGray_u.jpg', 'jpg');
imwrite(  Down, 'panoramaSphericalGray_d.jpg', 'jpg');
imwrite(  Left, 'panoramaSphericalGray_l.jpg', 'jpg');
imwrite( Front, 'panoramaSphericalGray_f.jpg', 'jpg');
imwrite( Right, 'panoramaSphericalGray_r.jpg', 'jpg');
imwrite(  Back, 'panoramaSphericalGray_b.jpg', 'jpg');

% [ Up, Down, Left, Front, Right, Back ] = ...
%     Sphere2TilesAlt(imread('panorama.jpg'), 500);
% 
% imwrite(    Up, 'panorama_u.jpg', 'jpg');
% imwrite(  Down, 'panorama_d.jpg', 'jpg');
% imwrite(  Left, 'panorama_l.jpg', 'jpg');
% imwrite( Front, 'panorama_f.jpg', 'jpg');
% imwrite( Right, 'panorama_r.jpg', 'jpg');
% imwrite(  Back, 'panorama_b.jpg', 'jpg');
