


function ranged = limitRange(x,a,b)

        ranged = x;

        if x > b
            ranged = b;
        end
        
        if x < a
            ranged = a;
        end
            

end

