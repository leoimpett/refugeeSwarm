

clear all;
close all;
% initialise agents


numAgents = 5;
resources = numAgents*ones(numAgents,1);

% starting positions
xpos = randi(100,numAgents,1);
ypos = randi(100,numAgents,1);
   
tmax = 10000;

waterSources = ones(1,2);
lavs = ones(1,2);

for t = 1 : tmax

    square  = zeros(100,100);
    for a = 1 : numAgents
%         square(xpos(a),ypos(a)) = 1;
    end
    for w = 1 : size(waterSources,1)
        square(waterSources(w,1),waterSources(w,2)) = 2;
    end
    for w = 1 : size(lavs,1)
        square(lavs(w,1),lavs(w,2)) = 4;
    end
%     imagesc(square);
% %     waitforbuttonpress();
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
        
        if xpos(a) > 100
            xpos(a) = 100;
        end
        if xpos(a) < 1
            xpos(a) = 1;
        end
        if ypos(a) > 100
            ypos(a) = 100;
        end
        if ypos(a) < 1
            ypos(a) = 1;
        end

        
% now, if an agent does not see that there are enough local water sources,
% the agent should build them!
        
        xdist = waterSources(:,1) - xpos(a);
        ydist = waterSources(:,2) - ypos(a);
        waterDist = sqrt(xdist.^2 + ydist.^2);
        if (min(waterDist) > 10) && (rand()>0.5)
            waterSources = [waterSources; xpos(a) ypos(a)];
        end
        
%   Now lavatories:
        xdist = lavs(:,1) - xpos(a);
        ydist = lavs(:,2) - ypos(a);
        lavDist = sqrt(xdist.^2 + ydist.^2);
        if (min(lavDist) > 20) && (rand()>0.5)
            lavs = [lavs; xpos(a) ypos(a)];
        end
        
    end


end

imagesc(square);

