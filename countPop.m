
function population = countPop(populationMap, xpos, ypos, delta)
    xmax = size(populationMap,1);
    ymax = size(populationMap,2);
    
    population = sum(sum(populationMap((limitRange(xpos-delta,1,xmax):limitRange(xpos+delta,1,xmax)),limitRange(ypos-delta,1,ymax):limitRange(ypos+delta,1,ymax))));

end