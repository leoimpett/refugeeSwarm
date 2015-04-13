

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
xpos = randi(xmax,numAgents,1);
ypos = randi(ymax,numAgents,1);
   
tmax = 1000;

ScaleConstant = 4;

waterSources = ones(1,2);
lavs = ones(1,2);

for t = 1 : tmax

%     square  = zeros(xmax,ymax);
%     for a = 1 : numAgents
%         square(xpos(a),ypos(a)) = 1;
%     end
%     for w = 1 : size(waterSources,1)
%         square(waterSources(w,1),waterSources(w,2)) = 2;
%     end
%     for w = 1 : size(lavs,1)
%         square(lavs(w,1),lavs(w,2)) = 4;
%     end
%     imagesc(square);
%     waitforbuttonpress();
%     pause(0.1);


    for a = 1 : numAgents 
        distances = sqrt((xpos-xpos(a)).^2 + (ypos-ypos(a)).^2);
    %     distances = (distances < 10).*distances;
    distances(distances==0) = [];
        [xx ii] = sort(distances,'ascend');

    %     stygmergic communication: only through action on the environment!

    % Firstly: if there are any other agents very nearby, move away from the
    % nearest one.
    xmove = 0;
    ymove = 0;
    
        if(xx(1) < 10)
            xmove = -sign(xpos(ii(1)) - xpos(a));
            ymove = -sign(ypos(ii(1)) - ypos(a));
        end

        xpos(a) = xpos(a) + randi(3) - 2 + randi(3)*xmove;
        ypos(a) = ypos(a) + randi(3) - 2 + randi(3)*ymove;
        
        xpos(a) = limitRange(xpos(a),1,xmax);        
        ypos(a) = limitRange(ypos(a),1,ymax);

        
        
%         Tally the local population in the next 100 metres:

        delta = 100*ScaleConstant;
        subPop = populationMap((limitRange(xpos(a)-delta,1,xmax):limitRange(xpos(a)+delta,1,xmax)),limitRange(ypos(a),1,ymax):limitRange(ypos(a),1,ymax));
        localPop = sum(sum(subPop));
        
        
%         Now see if there are enough services for the population 
        
%         water sources: one per 100 people in  <100m radius

        if localPop > 100
            
            while localPop > 100
                        delta = delta - 1;
                        localPop = sum(sum(populationMap((limitRange(xpos(a)-delta,1,xmax):limitRange(xpos(a)+delta,1,xmax)),limitRange(ypos(a),1,ymax):limitRange(ypos(a),1,ymax))));
            end
        
        end
        
        
        
        
% % now, if an agent does not see that there are enough local water sources,
% % the agent should build them!
%         
        xdist = waterSources(:,1) - xpos(a);
        ydist = waterSources(:,2) - ypos(a);
        waterDist = sqrt(xdist.^2 + ydist.^2);
        
        if (min(waterDist) > delta) && (rand()>0.5)
            waterSources = [waterSources; xpos(a) ypos(a)];
        end
% %         
% % %   Now lavatories: per 20 people, <50m from people, >30m from water
% sources
        delta = 50*ScaleConstant;
        
        if localPop > 20
            if (min(waterDist) > 30*ScaleConstant)
            
                while localPop > 20
                            delta = delta - 1;
                            localPop = sum(sum(populationMap((limitRange(xpos(a)-delta,1,xmax):limitRange(xpos(a)+delta,1,xmax)),limitRange(ypos(a),1,ymax):limitRange(ypos(a),1,ymax))));
                end
            end
        
        end

        xdist = lavs(:,1) - xpos(a);
        ydist = lavs(:,2) - ypos(a);
        
        
        lavDist = sqrt(xdist.^2 + ydist.^2);
        if (min(lavDist) > delta) && (rand()>0.5)
            lavs = [lavs; xpos(a) ypos(a)];
        end
%         



        
        
        
        
        
        
    end


end

    square  = zeros(xmax,ymax);
    for a = 1 : numAgents
        square(xpos(a),ypos(a)) = 1;
    end
    for w = 1 : size(waterSources,1)
        square(waterSources(w,1),waterSources(w,2)) = 2;
    end
    for w = 1 : size(lavs,1)
        square(lavs(w,1),lavs(w,2)) = 4;
    end

    
pp(1) = subplot(2,1,1)
imagesc(populationMap)
pp(2) = subplot(2,1,2)
imagesc(square)
linkaxes(pp);

