PRINT = 0;
PLOT = 0;

%%%%%%%%%%%%%%%%%%%%%%%%
%        ORIGINAL      %
%%%%%%%%%%%%%%%%%%%%%%%%
% lambda_hw = 0.0001;
% mu_hw = 0.0001;
% 
% lambda_link = 0.0003;
% mu_link = 0.0003;
% 
% lambda_bt = 0.02;
% mu_bt = 0.01;
% btStages = 3;
% %%%%%%%%%%%%%%%%%%%%%%%%
% nNodes = 4
% mAdj = zeros(nNodes);
% mAdj = ones(nNodes) - diag(ones(1,nNodes));
% 
% %NFC = '1';
% NFC = '1 or 3';
% %NFC = '1 and 3';
% %NFC = '1 and 3 and 2 and 1';
% %NFC = '1 or (1 and(3 and 2))';
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

lambda_hw = 1/(24*365); %1 falha por ano+
mu_hw = 1/48; % 48h para reparacao

lambda_link = 1/24; %1 falha por dia
mu_link = 1/0.5; %30min


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% New approach to bt according to theory %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
btStages = 4;
c0 = 3000; H = 25; I = 100; eta = 1.3;
cmin = 500;

interval = (c0-cmin)/btStages;

DC = 0.5; %Duty cycle - percentage of active time

syms t c;
c = c0 - I*H*(t/H)^(1/eta);

for u=1:btStages,
    if(u==1),
        tau(u) = eval(solve(c - (c0-u*interval)));
    else,
        tau(u) = eval(solve(c - (c0-u*interval)))-eval(solve(c - (c0-(u-1)*interval)));
    end
end

lambda_bt = 1./(tau/DC)
mu_bt = 1/2; % 2h para reparacao

display(['### Discharging in ' num2str(eval(solve(c - (c0-btStages*interval)))) ' hours by ' num2str(btStages) ' stages. ###'])
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%btStages = 4;
%lambda_bt = 1/(50/3); %1 falha a cada 50horas, em 3 estagios
%mu_bt = 1/20; % 20h para reparacao
%%%%%%%%%%%%%%%%%%%%%%%%

nNodes = max(size(pos));

DIRECT = 0;
FLOODING = 1;
HIERARCHICAL = 2;

%protocol = DIRECT;
%protocol = FLOODING;
%protocol = HIERARCHICAL;

%mAdj = zeros(nNodes);
mAdj = eye(nNodes);
if(protocol == DIRECT),
    for i=2:nNodes, %Index 1 is reserved for node 0 (SINK)
        mAdj(1,i) = 1;
        mAdj(i,1) = 1;
    end
elseif(protocol == FLOODING),
    
    %rRadius = 9.5;
    %rRadius = 8.5;
    rRadius = 180;
    
%     pos(1,:) = [15 16];   %GTW
%     pos(2,:) = [25.5 13]; %Fd1
%     pos(3,:) = [20 10];   %Fd2
%     pos(4,:) = [15.5 3];  %...
%     pos(5,:) = [10 8];    %...
%     pos(6,:) = [8 15];    %...
%     pos(7,:) = [4 21];    %...
%     pos(8,:) = [13 23.5]; %Fd7
%     pos(9,:) = [20.5 22]; %Fd8
    
    for i=1:nNodes,
       for j=i:nNodes,
           x=1; y=2;
           D_ij = sqrt((pos(i,x)-pos(j,x))^2 + (pos(i,y)-pos(j,y))^2);
           if( (i~=j) && (D_ij <= rRadius) ),
               mAdj(i,j) = 1;
               mAdj(j,i) = 1;
           end
       end
    end
    
elseif(protocol == HIERARCHICAL),
    ch = [5 7];
	x=1; y=2;
    
	for i=2:nNodes,
		if(any(ismember(ch,i))),
			mAdj(i,1) = 1;
            mAdj(1,i) = 1;
		else
			dist_min = Inf;
			head = -1;
			for j=1:max(size(ch)),
				D_ij = sqrt((pos( ch(j),x )-pos(i,x))^2 + (pos( ch(j),y )-pos(i,y))^2);
				if(D_ij < dist_min),
					dist_min = D_ij;
					head = ch(j);
				end
			end
			mAdj(head,i) = 1;
			mAdj(i,head) = 1;
		end
	end

	% for i=1:max(size(ch)),
		% mAdj(ch(i),1) = 1;
        % mAdj(1,ch(i)) = 1;
       % for j=2:nNodes, %Index 1 is reserved for node 0 (SINK)
           % x=1; y=2;
           % D_ij = sqrt((pos( ch(i),x )-pos(j,x))^2 + (pos( ch(i),y )-pos(j,y))^2);
           % if( (ch(i)~=j) && (D_ij <= rRadius) && mAdj(ch(i),j)==0 ),
               % mAdj(ch(i),j) = 1;
               % mAdj(j,ch(i)) = 1;
           % end
       % end
    % end
end

%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%

%NFC = '1 or 3 or 6 or 7 and 8'; %1oo3
%NFC = '5 or 6 or 7'; %1oo3
%NFC = '5 and 6 or 5 and 7 or 6 and 7'; %2oo3
%NFC = '5 and 6 and 7'; %3oo3

%NFC = '5 and 6 or 5 and 7';
%NFC = '5';