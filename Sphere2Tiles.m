function [ Up, Down, Left, Front, Right, Back ] = Sphere2Tiles( SphericalImage, TileSize )

    AngleLimits = [...
        struct('name', 'front', 'ThetaMin',   pi/4, 'ThetaMax',  pi*3/4, 'PhiMin',  -pi/4, 'PhiMax',   pi/4) ...
        struct('name', 'right', 'ThetaMin',   pi/4, 'ThetaMax',  pi*3/4, 'PhiMin',   pi/4, 'PhiMax', pi*3/4) ...
        struct('name',  'back', 'ThetaMin',   pi/4, 'ThetaMax',  pi*3/4, 'PhiMin', pi*3/4, 'PhiMax', pi*5/4) ...
        struct('name',  'left', 'ThetaMin',   pi/4, 'ThetaMax',  pi*3/4, 'PhiMin', pi*5/4, 'PhiMax', pi*7/4) ...
        struct('name',   'top', 'ThetaMin',      0, 'ThetaMax',    pi/4, 'PhiMin',  -pi/4, 'PhiMax', pi*7/4) ...
        struct('name','bottom', 'ThetaMin', pi*3/4, 'ThetaMax',      pi, 'PhiMin',  -pi/4, 'PhiMax', pi*7/4) ...
        ];

    imageTileSize = size(SphericalImage, 1) / 2;
    if (TileSize > imageTileSize)
        SphericalImage = imresize(SphericalImage, TileSize / imageTileSize);
    end

%     Front  = ProcessImage(SphericalImage, tileSizeForImage, AngleLimits(1));
%     Right  = ProcessImage(SphericalImage, tileSizeForImage, AngleLimits(2));
%     Back   = ProcessImage(SphericalImage, tileSizeForImage, AngleLimits(3));
%     Left   = ProcessImage(SphericalImage, tileSizeForImage, AngleLimits(4));
%     Top    = ProcessImage(SphericalImage, tileSizeForImage, AngleLimits(5));
    Down = ProcessImage(SphericalImage, TileSize, AngleLimits(6));

%     if (tileSizeForImage ~= TileSize)
%         Front  = imresize(FrontTile, TileSize / tileSizeForImage);
%         Right  = imresize(RightTile, TileSize / tileSizeForImage);
%         Back   = imresize(BackTile, TileSize / tileSizeForImage);
%         Left   = imresize(LeftTile, TileSize / tileSizeForImage);
%         Top    = imresize(TopTile, TileSize / tileSizeForImage);
%         Down = imresize(BottomTile, TileSize / tileSizeForImage);
%     end
end

function Image = ProcessImage(SphericalImage, TileSize, Limits)
    colors = size(SphericalImage, 3);
    
    Image = zeros(TileSize, TileSize, colors);
    for color = 1 : colors
        colorImage = SphericalImage(:,:,color);
        Image(:,:,color) = CutImage(colorImage, TileSize, Limits);
    end
    Image = uint8(Image);
 
    imshow(Image);
end

function Image = CutImage(SphericalImage, TileSize, Limits)
    [spImageHeight, spImageWidth] = size(SphericalImage);

    limXmin2 = 1;
    limXmax2 = 0;

    limYMin = median([1,Theta2Height(spImageHeight, Limits.ThetaMin), spImageHeight]);
    limYMax = max(Theta2Height(spImageHeight, Limits.ThetaMax), 1);

    if (strcmp(Limits.name, 'top') || strcmp(Limits.name, 'bottom'))
        limXmin1 = 1;
        limXmax1 = spImageWidth;
        if (strcmp(Limits.name, 'top'))
            limYMax = ceil(limYMax * sqrt(3));
        elseif (strcmp(Limits.name, 'bottom'))
            limYMin = floor(limYMin / 2);
        end
    else
        limXmin1 = max(Phi2Width(spImageWidth, Limits.PhiMin), 1);
        limXmax1 = Phi2Width(spImageWidth, Limits.PhiMax);

        if (limXmax1 > spImageWidth)
            limXmax2 = limXmax1 - spImageWidth;
            limXmax1 = spImageWidth;
        end
    end

    Image = zeros(TileSize, TileSize, size(SphericalImage, 3));
    count = zeros(TileSize);
    for y = limYMin : limYMax
        theta = Height2Theta(spImageHeight, y);
        [limYMin y limYMax]
        for x = limXmin1 : limXmax1
            [Image, count] = ProcessAngles(SphericalImage, TileSize, Limits.name, x, y, theta, Image, count);
        end
        for x = limXmin2 : limXmax2
            [Image, count] = ProcessAngles(SphericalImage, TileSize, Limits.name, x, y, theta, Image, count);
        end
    end
    Image = Image ./ count;
end

function [Image, Count] = ProcessAngles(SphericalImage, TileSize, TileName, X, Y, Theta, Image, Count)
    spImageWidth = size(SphericalImage, 2);
    phi = Width2Phi(spImageWidth, X);
    tileCoords = Angles2TileCoords(TileSize, TileName, phi, Theta);
    if (max(tileCoords) <= TileSize)
        pixel = SphericalImage(Y, X, :);
        [Image, Count] = SetPixels(Image, Count, tileCoords, pixel);
    end
end

function [Image, Count] = SetPixels(Image, Count, TileCoords, Pixel)    
    yMin = max(floor(TileCoords(1)), 1);
    yMax = max(ceil(TileCoords(1)), 1);

    xMin = max(floor(TileCoords(2)), 1);
    xMax = max(ceil(TileCoords(2)), 1);
    
    Image(yMin:yMax, xMin:xMax, :) = Image(yMin:yMax, xMin:xMax, :) + double(Pixel);
    Count(yMin:yMax, xMin:xMax, :) = Count(yMin:yMax, xMin:xMax, :) + 1;
end

function Coords = Angles2TileCoords(TileSize, TileName, Phi, Theta)
    halfSize = TileSize / 2;
    if (strcmp(TileName, 'top'))
        rectCoords = [cos(Phi), sin(Phi)] * tan(Theta);
    elseif (strcmp(TileName, 'bottom'))
        rectCoords = [cos(Phi), -sin(Phi)] * tan(Theta);
    else
        if (strcmp(TileName, 'front'))
            rectCoords = [ -cot(Theta),  sin(Phi)] / cos(Phi);
        elseif (strcmp(TileName, 'right'))
            rectCoords = [ -cot(Theta), -cos(Phi)] / sin(Phi);
        elseif (strcmp(TileName, 'back'))
            rectCoords = [  cot(Theta),  sin(Phi)] / cos(Phi);
        elseif (strcmp(TileName, 'left'))
            rectCoords = [  cot(Theta), -cos(Phi)] / sin(Phi);
        end
    end
    Coords = (rectCoords + 1) * halfSize;
end

function Theta = Height2Theta(Height, Y)
    Theta = (Y/Height)*pi;
end

function Y = Theta2Height(Height, Theta)
    Y = Height*Theta/pi;
end

function Phi = Width2Phi(Width, X)
    Phi = (X/Width)*2*pi - pi;
end

function X = Phi2Width(Width, Phi)
    X = 0.5*Width*(Phi/pi + 1);
end
