x1 = 0;
y1 = h;
beta = 0*pi/180;

x2 = x1 + w*cos(beta);
y2 = y1 + w*sin(beta);

x3 = x1 + h*sin(beta);
y3 = y1 - h*cos(beta);

x4 = x1 + h*sin(beta) + w*cos(beta);
y4 = y1 - h*cos(beta) + w*sin(beta);

sizeMB = FOV*0.00087; %In INDN18 paper, 1/FOV = 0.0115, it was a good relation
wMBs = ceil(w/sizeMB);
hMBs = ceil(h/sizeMB);
ws = w/wMBs;
hs = h/hMBs;
M = w/ws; %w
N = h/hs; %h

%A_total = [];
activeNodes = [];
cnt = 1;
for i=1:n,
	C = nchoosek(1:n,i);
    for j=1:size(C,1),
        
        VMBcnt = 0;
        
        for mIndex=1:M,
            for nIndex=1:N,
                x1s = x1 + (mIndex-1)*(w/M)*cos(beta) + (nIndex-1)*(h/N)*sin(beta);
                y1s = y1 + (mIndex-1)*(w/M)*sin(beta) - (nIndex-1)*(h/N)*cos(beta);

                x2s = x1 + (mIndex)*(w/M)*cos(beta) + (nIndex-1)*(h/N)*sin(beta);
                y2s = y1 + (mIndex)*(w/M)*sin(beta) - (nIndex-1)*(h/N)*cos(beta);

                x3s = x1 + (mIndex-1)*(w/M)*cos(beta) + (nIndex)*(h/N)*sin(beta);
                y3s = y1 + (mIndex-1)*(w/M)*sin(beta) - (nIndex)*(h/N)*cos(beta);

                x4s = x1 + (mIndex)*(w/M)*cos(beta) + (nIndex)*(h/N)*sin(beta);
                y4s = y1 + (mIndex)*(w/M)*sin(beta) - (nIndex)*(h/N)*cos(beta);

                xc = x1s + (x4s-x1s)/2;
                yc = y1s + (y4s-y1s)/2;
                
                for z=1:i,
                   inside = isInsideTri( xc, yc, sensors{C(j,z)}.Ax, sensors{C(j,z)}.Ay, sensors{C(j,z)}.Bx, sensors{C(j,z)}.By, sensors{C(j,z)}.Cx, sensors{C(j,z)}.Cy, FOV, epsilon);
                   if(inside),
                       VMBcnt = VMBcnt+1;
                       break;
                   end
                end
            end
        end
        
        area = VMBcnt*ws*hs;
        
        if(area >= A*A_min),
            activeNodes{cnt} = C(j,:);
            cnt = cnt+1;
        end
    end
end