

clear all;
close all;
% initialise agents

% populationMap = GeneratePopulationMatrix('Cleaned16ColorMap.bmp');
load('popmap.mat');

xmax = size(populationMap,1);
ymax = size(populationMap,2);

numAgents = 300;
resources = numAgents*ones(numAgents,1);

% starting positions
agents = randi(xmax,numAgents,2);
   
tmax = 1000;
agentSpeed = 3;

NumStructures = zeros(tmax,1);

ScaleConstant = 1/4;

waterSources = [1 1];
lavs = [1 1];
showers = [1 1];

for t = 1 : tmax


% Cycle through the agents
    for a = 1 : numAgents
%         brownian motion
        agents(a,1) = limitRange(agents(a,1) + (agentSpeed*(randi(3) - 2)),  1,  xmax);
        agents(a,2) = limitRange(agents(a,2) + (agentSpeed*(randi(3) - 2)),  1,  ymax);
    
%     now check for people in the surrounding area
        fiftyPop = countPop(populationMap, agents(a,1), agents(a,2), round(50*ScaleConstant));
        hundredPop = countPop(populationMap, agents(a,1), agents(a,2), round(100*ScaleConstant));
    
        
        
%                 and distance from the water source
                if(size(waterSources,1) ~= 0)
                    xdist = waterSources(:,1) - agents(a,1);
                    ydist = waterSources(:,2) - agents(a,2);
                    waterDist = sqrt(xdist.^2 + ydist.^2);

                    xdist = showers(:,1) - agents(a,1);
                    ydist = showers(:,2) - agents(a,2);
                    showerDist = sqrt(xdist.^2 + ydist.^2);
                    
                    xdist = lavs(:,1) - agents(a,1);
                    ydist = lavs(:,2) - agents(a,2);
                    lavDist = sqrt(xdist.^2 + ydist.^2);

                    if (min(waterDist) < 20*ScaleConstant) && ((fiftyPop - (sum(showerDist<50*ScaleConstant)*40))>0)
        %                 near water: suitable for showers. 

        %         But we also want to find out if there are other showers covering
        %         the same area...

                        showers = [showers; agents(a,:)];                
                    end



                    if (min(waterDist) > 100*ScaleConstant) &&  ((hundredPop - (sum(waterDist<100*ScaleConstant)*100))>0)
        %                 very far from water: make water source
                        waterSources = [waterSources; agents(a,:)];
                    end


                    if (min(waterDist) > 30*ScaleConstant) && ((fiftyPop - (sum(lavDist<50*ScaleConstant)*20)) > 0)
        %                 quite far from water: suitable for latrines
                        lavs = [lavs; agents(a,:)];
                    end


                end
                
        end
        
    

NumStructures(t) = size(showers,1) + size(waterSources,1) + size(lavs,1);

end



square  = zeros(xmax,ymax);
    for a = 1 : numAgents
%         square(agents(a,1),agents(a,2)) = 1;
    end
    for w = 1 : size(waterSources,1)
        square(waterSources(w,1),waterSources(w,2)) = 2;
    end
    for w = 1 : size(lavs,1)
        square(lavs(w,1),lavs(w,2)) = 3;
    end
    for w = 1 : size(showers,1)
        square(showers(w,1),showers(w,2)) = 4;
    end

    
pp(1) = subplot(2,2,1);
imagesc(populationMap);
pp(2) = subplot(2,2,2);
imagesc(square);
linkaxes(pp);

figure();
plot(NumStructures);


    