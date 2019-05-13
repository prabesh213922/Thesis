clc;
% clear all;
%% Configuration
Kundur_CIGRE_based_collapse_04 % load the data
output_data1 = output_data(:,2:end); % eliminate time column

%% Data separation

V = output_data1(:,1); % bus voltage, volts
P1 = output_data1(:,2); % active power, [-]
Q1 = output_data1(:,3); % reactive power, [-]
Sbase=1600;
Ppu =(100/Sbase)*P1;
Qpu= (100/Sbase)*Q1;
figure()
plot(Qpu(:,:),Ppu(:,:),'--bo');
time=output_data(:,1);
%%Plot
% Plot of both limits at rated MVA=1 p.u, Voltage =1 p.u. and armature current =1 p.u
psi = acos(0.72); % limiting power factor angle.. for S=1600 MVA and P=1154MW cosphi= 0.72
V1=1;  % rated terminal voltage on its own base of 13.8 KV
Ia1=1; % rated armature current
Xd=2.07; % direct axis synchronous reactance for the machine 2.07
E_1 = sqrt((V1+Xd*Ia1*sin(psi))^2+(Xd*Ia1*cos(psi))^2);  %magnitude of emf vector 
R=(E_1*V1)/Xd;
P_1= 0:.01:0.72; % range of angles
Q_1 = (-1/Xd) + sqrt(R^2-P_1.^2);

%%Armature current plot settings
theta=0:0.001:pi;
Qx=1*cos(theta);
Py=1*sin(theta);

%Practical stability limit settings
y=0:0.1:0.9;
r=y+0.1;
x=(sqrt(r.^2-y.^2))-V1^2/Xd;
t = 1:numel(x);
xy = [x;y];
pp = spline(t,xy);
tInterp = linspace(1,numel(x));
xyInterp = ppval(pp, tInterp);


%Check condition paramter settings
% P_2=app.PMWEditField_2.Value;
% Q_2=app.QMvarEditField_2.Value;
%%plot
for i=1:length(V)
plot(Qx,Py,...%Armature current limit plot
        Qpu(1:i),Ppu(1:i), Qpu(i),Ppu(i),'*r',...%Operating point
        [-1 1],[0.72 0.72],...%turbine limit
        [0 0],[0 1],'k',[-1 1],[0 0],'k',...%axes
        [0 Qpu(i)],[0 Ppu(i)],...%vector length of operating point from origin
        Q_1,P_1,...%plot of field current limit
        [-V1^2/Xd Qpu(i)],[0 Ppu(i)],...%vector length of operating point from negative axis
        -V1^2/2.07,0,'*',...
        [-V1^2/2.07 -V1^2/2.07],[0 1],'--k',...%theoretical stability limit;
        x,y,xyInterp(1,:),xyInterp(2,:));...   %practical stability limit
     
  
        app.PMWEditField.Value=Ppu(i)*Sbase;
        app.QMvarEditField.Value=Qpu(i)*Sbase;
        app.PowerFactorEditField.Value=Ppu(i);
        
       
       
%         %%Power Plot
%         z=plot(time(i),Ppu(i)*Sbase,'.',time(1:i),Ppu(1:i)*Sbase,... 
%             time(i),Qpu(i)*Sbase,'.', time(1:i),Qpu(1:i)*Sbase);
%         legend(app.UIAxes2,[z(2) z(4)],'MW','Mvar');
        
        %%Armature and field current
         X = [-V1^2/Xd,0;Qpu(i),Ppu(i)]; %vector length of operating point from negative x axis
         X1(i)= pdist(X,'euclidean');
        

         Y= [0,0;Qpu(i),Ppu(i)]; %vector length of operating point from origin
         Y1(i)= pdist(Y,'euclidean');
         
        
            
%           %%Run simulink model
%            assignin('base','I_fd',X);
%            assignin('base','I_t',Y);
%            simOut=sim('Thermal_model','TimeOut',300);
%            plot(app.UIAxes3,simOut.T_r.Time,simOut.T_r.Data,...
%                simOut.T_s.Time,simOut.T_s.Data);
               
%                
        
        
%          %if Q reactive power is positive overexcited 
%           if Qpu(i)>0   
%               app.OverexcitedLamp.Color='green';
%               app.UnderexcitedLamp.Color='black';
%           else
%               app.OverexcitedLamp.Color='black';
%               app.UnderexcitedLamp.Color='green';
%           end
%           
%           %over excitation and underexcitation check  
%           if app.QMvarEditField_2.Value>0          
%               app.OverexcitedLamp_2.Color='green';
%               app.UnderexcitedLamp_2.Color='black';
%           else
%               app.OverexcitedLamp_2.Color='black';
%               app.UnderexcitedLamp_2.Color='green';
%           end
%           
%           %limit checker for turbine limit only
%           if Ppu(i)>0.73            
%             app.LimitcheckerLamp.Color='Red';
%             app.EditField.Value='ALARM';
%         else
%             app.LimitcheckerLamp.Color='green';
%             app.EditField.Value='NORMAL';
%           end
          
         
end
         %% interactin between workspace and simulink
         I_fd=[time transpose(X1)*1065];
         I_t =[time transpose(Y1)*5406];
         simOut=sim('Thermal_model_scope','StopTime','300');
         
%          index = 1:5:length(simOut.T_r.Data);
%          
%          figure()
%          p=plot(simOut.T_r.Time(index),simOut.T_r.Data(index),...
%                simOut.T_s.Time(index),simOut.T_s.Data(index));
%           legend(p,'Tr','Ts')
            
         figure()
         p=plot(simOut.T_r.Time,simOut.T_r.Data,...
              simOut.T_s.Time,simOut.T_s.Data);
         legend(p,'Rotor','Stator','Location','Northwest');
         ylabel('Temperature [°C]');
         xlabel('Time [min]');
         grid on;
         set(groot,'defaultLineLineWidth',1.5);
         %set(gca,'linewidth',0.75); %current axes linewidth