
clear;
close all;

% populationMap = GeneratePopulationMatrix('Cleaned16ColorMap.bmp');
load('PopulationDensityMap.mat');

xmax = size(populationMap,1);
ymax = size(populationMap,2);

% initialise agents
numAgents = 300;
resources = numAgents*ones(numAgents,1);

% starting positions
agents = randi(xmax,numAgents,2);
   
tmax = 3000;
agentSpeed = 5;

showeredData = zeros(tmax,1);
wateredData = zeros(tmax,1);
latrinedData = zeros(tmax,1);
fullySatisfiedData = zeros(tmax,1);
numStructuresData = zeros(tmax,1);

ScaleConstant = 1/4;

waterSources = [1 1];
lavs = [1 1];
showers = [1 1];

currentMap = populationMap0;

for t = 1 : tmax
    
    if (t == floor(tmax/4))
        currentMap = populationMap1;
    elseif (t == floor(2*tmax/3))
        currentMap = populationMap;
    end
    
    sumShowered = 0;
    sumWatered = 0;
    sumLatrined = 0;
    sumFullySatisfied = 0;
    sumFiftyPop = 0;
    sumHundredPop = 0;
    
    % Cycle through the agents
    for a = 1 : numAgents
        % brownian motion
        agents(a,1) = limitRange(agents(a,1) + (randi(agentSpeed)*(randi(3) - 2)),  1,  xmax);
        agents(a,2) = limitRange(agents(a,2) + (randi(agentSpeed)*(randi(3) - 2)),  1,  ymax);
        
        % now check for people in the surrounding area
        fiftyPop = countPop(currentMap, agents(a,1), agents(a,2), round(50*ScaleConstant));
        hundredPop = countPop(currentMap, agents(a,1), agents(a,2), round(100*ScaleConstant));
        
        % and distance from the water source
        xdist = waterSources(:,1) - agents(a,1);
        ydist = waterSources(:,2) - agents(a,2);
        waterDist = sqrt(xdist.^2 + ydist.^2);
        
        xdist = showers(:,1) - agents(a,1);
        ydist = showers(:,2) - agents(a,2);
        showerDist = sqrt(xdist.^2 + ydist.^2);
        
        xdist = lavs(:,1) - agents(a,1);
        ydist = lavs(:,2) - agents(a,2);
        lavDist = sqrt(xdist.^2 + ydist.^2);
        
        localPopShowered = 40*sum(showerDist < 50*ScaleConstant);
        sumShowered = sumShowered + min([fiftyPop localPopShowered]);
        if (min(waterDist) < 20*ScaleConstant) && (fiftyPop - localPopShowered > 0)
            % near water: suitable for showers.
            % But we also want to find out if there are other showers covering
            % the same area...
            showers = [showers; agents(a,:)];
        end
        
        localPopWatered = 100*sum(waterDist < 100*ScaleConstant);
        sumWatered = sumWatered + min([hundredPop localPopWatered]);
        if (hundredPop - localPopWatered > 0)
            % very far from water: make water source
            waterSources = [waterSources; agents(a,:)];
        end
        
        localPopLatrined = 20*sum(lavDist < 50*ScaleConstant);
        sumLatrined = sumLatrined + min([fiftyPop localPopLatrined]);
        if (min(waterDist) > 30*ScaleConstant) && (fiftyPop - localPopLatrined > 0)
            % quite far from water: suitable for latrines
            lavs = [lavs; agents(a,:)];
        end
        
        if fiftyPop > 0
            sumFullySatisfied = sumFullySatisfied + fiftyPop * min([1 localPopShowered/fiftyPop]) ...
                * min([1 localPopWatered/hundredPop]) * min([1 localPopLatrined/fiftyPop]);
        end
        
        sumFiftyPop = sumFiftyPop + fiftyPop;
        sumHundredPop = sumHundredPop + hundredPop;
        
    end
    
    showeredData(t) = sumShowered/sumFiftyPop;
    wateredData(t) = sumWatered/sumHundredPop;
    latrinedData(t) = sumLatrined/sumFiftyPop;
    fullySatisfiedData(t) = sumFullySatisfied/sumFiftyPop;
    numStructuresData(t) = size(showers,1) + size(waterSources,1) + size(lavs,1);
    
end


square  = zeros(xmax,ymax);
% for a = 1 : numAgents
%     square(agents(a,1),agents(a,2)) = 1;
% end
for w = 1 : size(lavs,1)
    square(lavs(w,1),lavs(w,2)) = 3;
end
for w = 1 : size(showers,1)
    square(showers(w,1),showers(w,2)) = 4;
end
for w = 1 : size(waterSources,1)
    square(waterSources(w,1),waterSources(w,2)) = 2;
end


figure();
imagesc(currentMap);
colormap parula;
axis equal tight;
title('Population map');
figure();
image(square*14);
colormap jet;
axis equal tight;
title('Facility map after simulation');

figure();
plot(numStructuresData);
title('Number of structures (water sources, bathing, and latrines) over time');
xlabel('Time steps, t');
ylabel('Number of structures');

figure();
plot(showeredData);
title('Approximate probability of access to bathing facilities over time');
xlabel('Time steps, t');
ylabel('Probability');

figure();
plot(wateredData);
title('Approximate probability of access to water over time');
xlabel('Time steps, t');
ylabel('Probability');

figure();
plot(latrinedData);
title('Approximate probability of access to latrine over time');
xlabel('Time steps, t');
ylabel('Probability');

figure();
plot(fullySatisfiedData);
title('Approximate probability of full access to facilities over time');
xlabel('Time steps, t');
ylabel('Probability');


    