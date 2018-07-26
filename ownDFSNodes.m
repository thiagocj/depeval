function [ paths ] = ownDFSNodes(paths,mAdj,dev,cPath)
%ownDFS Depth First Search according to Silva, 2012.
%   For more informantion: "Reliability and Availability Evaluation of Wireless Sensor
%   Networks for Industrial Appl

%cPath: Current Path

nodes = size((mAdj),1);

for i=1:nodes,

	if(dev==1), %dev0 = Gateway
		%paths(nPaths+1) = cPath;
        nPaths = max(size(paths));
        paths{nPaths+1} = cPath;
		break;
	end
	
	if(mAdj(dev,i) == 1),
		%Eliminar ciclos
        auxDev = ['Dev' num2str(i-1)];
        %auxLink = ['L' num2str(min(i,dev)-1) '.' num2str(max(i,dev)-1)];
		if(~pathContains(cPath, auxDev)),
            %Current_Path.addLink()
            %cPath(max(size(cPath))+1) = cell({auxLink});
            
            %Current_Path.addNode()
            cPath(max(size(cPath))+1) = cell({auxDev});
			paths = ownDFSNodes(paths,mAdj,i,cPath);
            %Current_Path.removePathAndLink()
			%cPath = cPath(1,1:max(size(cPath)-2));
            cPath = cPath(1,1:max(size(cPath)-1));
		end		
	end
end

end