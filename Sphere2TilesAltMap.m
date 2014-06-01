function [ Up, Down, Left, Front, Right, Back ] = Sphere2TilesAltMap( SphericalImage, TileSize )

    cache = CacheAngles(TileSize);
    
    Up    = ProcessImage(SphericalImage, TileSize, 'up', cache);'up'
    Down  = ProcessImage(SphericalImage, TileSize, 'down', cache);'down'
    Front = ProcessImage(SphericalImage, TileSize, 'front', cache);'front'
    Right = ProcessImage(SphericalImage, TileSize, 'right', cache);'right'
    Back  = ProcessImage(SphericalImage, TileSize, 'back', cache);'back'
    Left  = ProcessImage(SphericalImage, TileSize, 'left', cache);'left'
end

function Cache = CacheAngles(TileSize)
    range = TileSize - 1;
    halfSize = range / 2;
    
    Cache.Zp = zeros(TileSize, TileSize);
    Cache.Zm = zeros(TileSize, TileSize);
    Cache.XYpm = zeros(TileSize, TileSize);
    Cache.Phi = zeros(TileSize, TileSize);

    for tileY = 0 : range
        y = tileY / halfSize - 1;
        for tileX = 0 : range
            x = tileX / halfSize - 1;
            Cache.Zp(tileY + 1, tileX + 1) = acos(1 / sqrt(x^2 + y^2 + 1));
            Cache.Zm(tileY + 1, tileX + 1) = acos(-1 / sqrt(x^2 + y^2 + 1));
            Cache.XYpm(tileY + 1, tileX + 1) = acos(y / sqrt(x^2 + y^2 + 1));
            if x ~= 0
                Cache.Phi(tileY + 1, tileX + 1) = atan(y / x);
            end
        end
    end
end

function Image = ProcessImage(SphericalImage, TileSize, TileName, cache)
    Image = zeros(TileSize, TileSize, size(SphericalImage, 3), 'uint8');
    for tileY = 1 : TileSize
%         tileY
        for tileX = 1 : TileSize
            Image(tileY, tileX, :) = ProcessCoords(SphericalImage, TileSize, TileName, cache, tileY, tileX);
        end
    end
%     imshow(Image);
end

function Phi = UpdatePhi(HalfSize, Phi, MajorDir, MinorDir, MajorM, MajorP, MinorM, MinorP)
    if MajorDir < HalfSize
        Phi = Phi + MajorM;
    elseif MajorDir > HalfSize
        Phi = Phi + MajorP;
    else
        if MinorDir < HalfSize
            Phi = MinorM;
        else
            Phi = MinorP;
        end
    end
end

function Pixel = ProcessCoords(SphericalImage, TileSize, TileName, cache, tileY, tileX)
    halfSize = TileSize / 2;
    switch TileName
        case 'up'            
            theta = cache.Zp(tileY, tileX);
            phi = cache.Phi(tileX, tileY);
            phi = UpdatePhi(halfSize, phi, tileY, tileX, pi, 0, -pi/2, pi/2);
        case 'down'            
            theta = cache.Zm(tileY, tileX);
            phi = cache.Phi(tileX, TileSize - tileY + 1);
            phi = UpdatePhi(halfSize, phi, tileY, tileX, 0, pi, -pi/2, pi/2);
        case 'front'
            theta = cache.XYpm(TileSize - tileY + 1,  TileSize - tileX + 1);
            phi = cache.Phi(tileX, TileSize);
            phi = UpdatePhi(halfSize, phi, tileY, tileX, 0, 0, -pi/2, pi/2);
        case 'right'
            theta = cache.XYpm(TileSize - tileY + 1,  TileSize - tileX + 1);
            phi = cache.Phi(TileSize, TileSize - tileX + 1);
            phi = UpdatePhi(halfSize, phi, tileX, tileY, 0, pi, pi/2, pi/2);
        case 'back'
            theta = cache.XYpm(TileSize - tileY + 1,  TileSize - tileX + 1);
            phi = cache.Phi(tileX, TileSize) + pi;
        case 'left'
            theta = cache.XYpm(TileSize - tileY + 1,  TileSize - tileX + 1);
            phi = cache.Phi(TileSize, TileSize - tileX + 1);
            phi = UpdatePhi(halfSize, phi, tileX, tileY, pi, 0, -pi/2, -pi/2);
    end
    
    [spImageHeight, spImageWidth, ~] = size(SphericalImage);
    
    spX = round(Phi2Width(spImageWidth, phi));
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
        X = X - Width + 1;
    end
end
