function [ populationMap, populationMapY, populationMapC ] = GeneratePopulationMatrix ( mapImageName )

    MAP_CROP_START = 264;
    % RED = 9;        % Administrative building color code
    YELLOW = 11;    % Tent shelter color code
    CYAN = 14;      % Improvised shelter color code
    ORIGIN_METRES_PER_PIXEL = 300/126;   % Metres per pixel on original map
    TARGET_METRES_PER_PIXEL = 4;         % Metres per pixel on population density map
    PEOPLE_PER_SHELTER = 5;
    TARGET_DIMENSION_X = 600;
    TARGET_DIMENSION_Y = 600;
    
    
    inputMap = imread(mapImageName);
    [mapHeight, mapWidth] = size(inputMap);
    if (mapHeight > mapWidth)
        inputMap = inputMap(MAP_CROP_START:MAP_CROP_START+mapWidth-1,:);
    elseif (mapWidth > mapHeight)
        inputMap = inputMap(:,MAP_CROP_START:MAP_CROP_START+mapHeight-1);
    end

    C = inputMap == CYAN;
    Y = inputMap == YELLOW;

    populationMapC = ConvertToDensity(C, PEOPLE_PER_SHELTER);
    populationMapC = RescaleMap(populationMapC, ORIGIN_METRES_PER_PIXEL / TARGET_METRES_PER_PIXEL);
    populationMapC = CentreMap(populationMapC, TARGET_DIMENSION_X, TARGET_DIMENSION_Y);
    
    populationMapY = ConvertToDensity(Y, PEOPLE_PER_SHELTER);
    populationMapY = RescaleMap(populationMapY, ORIGIN_METRES_PER_PIXEL / TARGET_METRES_PER_PIXEL);
    populationMapY = CentreMap(populationMapY, TARGET_DIMENSION_X, TARGET_DIMENSION_Y);
    
    populationMap = populationMapC + populationMapY;

end

function [ populationMap ] = ConvertToDensity ( sheltersMap, peoplePerShelter )
    
    populationMap = zeros(size(sheltersMap,1),size(sheltersMap,2));
    uncountedSheltersMap = sheltersMap;
    for x = 1:size(sheltersMap,1)
        for y = 1:size(sheltersMap,2)
            if (uncountedSheltersMap(x,y) == 1)
                [area, uncountedSheltersMap] = RecursiveCountContiguous(uncountedSheltersMap, x, y);
                [populationMap, sheltersMap] = RecursiveFillContiguous(sheltersMap, x, y, populationMap, peoplePerShelter/area);
            end
        end
    end
    
end

function [ area, uncountedShelterMap ] = RecursiveCountContiguous ( uncountedShelterMap, x, y )

    if (uncountedShelterMap(x,y) == 1)
        uncountedShelterMap(x,y) = 0;
        [south, uncountedShelterMap] = RecursiveCountContiguous(uncountedShelterMap,x+1,y);
        [north, uncountedShelterMap] = RecursiveCountContiguous(uncountedShelterMap,x-1,y);
        [east, uncountedShelterMap] = RecursiveCountContiguous(uncountedShelterMap,x,y+1);
        [west, uncountedShelterMap] = RecursiveCountContiguous(uncountedShelterMap,x,y-1);
        area = 1 + south + north + east + west;
    else
        area = 0;
    end
    
end

function [ populationMap, shelterMap ] = RecursiveFillContiguous ( shelterMap, x, y, populationMap, populationDensity )

    if (shelterMap(x,y) == 1)
        populationMap(x,y) = populationMap(x,y) + populationDensity;
        shelterMap(x,y) = 0;
        [populationMap, shelterMap] = RecursiveFillContiguous (shelterMap, x+1, y, populationMap, populationDensity);
        [populationMap, shelterMap] = RecursiveFillContiguous (shelterMap, x-1, y, populationMap, populationDensity);
        [populationMap, shelterMap] = RecursiveFillContiguous (shelterMap, x, y+1, populationMap, populationDensity);
        [populationMap, shelterMap] = RecursiveFillContiguous (shelterMap, x, y-1, populationMap, populationDensity);
    end
    
end

function [ rescaledMap ] = RescaleMap( map, scaleFactor )

    rescaledMap = zeros(ceil(size(map,1)*scaleFactor), ceil(size(map,2)*scaleFactor));
    
    for x = 1:size(map,1)
        for y = 1:size(map,2)
            if (map(x,y) ~= 0)
                rescaledX = round(x*scaleFactor);
                rescaledY = round(y*scaleFactor);
                rescaledMap(rescaledX,rescaledY) = rescaledMap(rescaledX,rescaledY) + map(x,y);
            end
        end
    end

end

function [ centredMap ] = CentreMap( map, targetDimensionX, targetDimensionY )

    [mapDimensionX,mapDimensionY] = size(map);
    centredMap = zeros(targetDimensionX,targetDimensionY);
    xMargin = floor((targetDimensionX-mapDimensionX)/2);
    yMargin = floor((targetDimensionY-mapDimensionY)/2);
    centredMap(xMargin:xMargin+mapDimensionX-1,yMargin:yMargin+mapDimensionY-1) = map;

end

