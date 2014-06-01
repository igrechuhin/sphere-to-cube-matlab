function [ Up, Down, Left, Front, Right, Back ] = Sphere2TilesAlt( SphericalImage, TileSize )

    Up    = ProcessImage(SphericalImage, TileSize, 'up');'up'
    Front = ProcessImage(SphericalImage, TileSize, 'front');'front'
    Right = ProcessImage(SphericalImage, TileSize, 'right');'right'
    Back  = ProcessImage(SphericalImage, TileSize, 'back');'back'
    Left  = ProcessImage(SphericalImage, TileSize, 'left');'left'
    Down  = ProcessImage(SphericalImage, TileSize, 'down');'down'
end

function Image = ProcessImage(SphericalImage, TileSize, TileName)
    Image = zeros(TileSize, TileSize, size(SphericalImage, 3));
    halfSize = TileSize / 2;
    
    for tileY = 1 : TileSize
        tileY
        rectY = tileY / halfSize - 1;
        for tileX = 1 : TileSize
            rectX = tileX / halfSize - 1;
            Image(tileY, tileX, :) = ProcessCoords(SphericalImage, TileName, rectY, rectX);
        end
    end
    Image = uint8(Image);

%     imshow(Image);
end

function Pixel = ProcessCoords(SphericalImage, TileName, RectY, RectX)
    switch TileName
        case 'up'
            x = -RectY;
            y = -RectX;
            z = 1;
            piShift1 = pi;
            piShift2 = 0;
            phi01 = pi / 2;
            phi02 = - pi / 2;
        case 'down'
            x = RectY;
            y = -RectX;
            z = -1;
            piShift1 = pi;
            piShift2 = 0;
            phi01 = pi / 2;
            phi02 = - pi / 2;
        case 'front'
            x = 1;
            y = RectX;
            z = -RectY;
            piShift1 = 0;
            piShift2 = 0;
        case 'right'
            x = -RectX;
            y = 1;
            z = -RectY;
            piShift1 = 0;
            piShift2 = pi;
            phi01 = pi / 2;
            phi02 = pi / 2;
        case 'back'
            x = -1;
            y = -RectX;
            z = -RectY;
            piShift1 = pi;
            piShift2 = pi;
        case 'left'
            x = RectX;
            y = -1;
            z = -RectY;
            piShift1 = 0;
            piShift2 = pi;
            phi01 = - pi / 2;
            phi02 = - pi / 2;
    end
    
    theta = acos(z / sqrt(x^2 + y^2 + z^2));
    if x ~= 0
        phi = atan(y / x);
        if x > 0
            phi = phi + piShift1;
        else
            phi = phi + piShift2;
        end
    else
        if (y < 0)
            phi = phi01;
        else
            phi = phi02;
        end
    end
    
    [spImageHeight, spImageWidth, colors] = size(SphericalImage);
    
    spX = max(round(Phi2Width(spImageWidth, phi)), 1);    
    spY = max(round(Theta2Height(spImageHeight, theta)), 1);

    Pixel = SphericalImage(spY, spX, :);
end

function Y = Theta2Height(Height, Theta)
    Y = Height*Theta/pi;
end

function X = Phi2Width(Width, Phi)
    X = 0.5*Width*(Phi/pi + 1);
    if X < 1
        X = X + Width;
    elseif X > Width
        X = X - Width;
    end
end
