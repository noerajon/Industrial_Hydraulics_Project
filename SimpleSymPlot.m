% Clear
clear all; close all; clc;
% insert here the path where it is installed the EPANET-Matlab toolkit
start_toolkit; %to start the epanet toolkit
%%
% Load a network hello world
d = epanet(['Network_modified.inp']); %importa data from .inp file

%%

type="PDA";   %type of analysis pressure driven or demand driven this is the modification :)
pmin = 0;     %lower limit for Pressure driven analysis
preq = 20;    %upper limit for Pressure driven analysis
pexp = 0.5;   %exponent to calculate actual node demand in case Pis between Pmin and Preq
d.setDemandModel(type, pmin, preq, pexp); %set conditions for PDA 

hrs = 168; %total hours of analysis
d.setTimeSimulationDuration(hrs*3600); %set of the duration time must be specified in seconds

etstep = 3600; %length in seconds of analysis step
d.setTimeReportingStep(etstep); %set time of result reporting step
d.setTimeHydraulicStep(etstep); %set time analysis step

d.openHydraulicAnalysis;       %start hydraulic simulation
d.initializeHydraulicAnalysis; %inizialization of hydraulic simulation

tstep=1;P=[];T_H=[];D=[];H=[];F=[];   %inizialization of result vectors
while (tstep>0)                       %condition to run simulations each hour until the time simulation duration is reached (tstep=1)
    t=d.runHydraulicAnalysis;         %run the hydraulic analysis step hour 00, 01, 02....48
    P=[P; d.getNodePressure];         % get the pressure calculated in the nodes for the step
    D=[D; d.getNodeActualDemand];     % get the actual demand calculated in the nodes for the step
    H=[H; d.getNodeHydraulicHead];     % get the node hydraulic head calculated in the nodes for the step
    F=[F; d.getLinkFlows];            % get the link flow rate for the step
    T_H=[T_H; t];                     %get simulation time in seconds
    tstep=d.nextHydraulicAnalysisStep; %if next step exist d.nextHydraulicAnalysisStep==1 else 0
end

%%Plot the network
d.plot('links','yes','nodes', 'yes', 'fontsize', 10,'legend', 'show', 'highlightnode', {'10', '11'})  %plot the layout of the network



%% plot of the pressure in some node along simulation time
node_indices = [1, 3, 5];                   %select some of the nodes
node_names = d.getNodeNameID(node_indices); %select node name from node indices

figure(2)
for i=1:length(node_indices) 
    plot([1:hrs+1], P(:,node_indices(i))); %splot of pressure in selected nodes
    hold on
    leg{i}=(strcat('Pressure for the node id "', d.getNodeNameID{node_indices(i)},'"'));  %legend definition
end

legend(leg) %create legend
xlabel('Time (hrs)'); %create x axis label
ylabel(['Pressure (', d.NodePressureUnits,')']) %create the y axis label using a property of the simulation

%d.closeHydraulicAnalysis; %exit the analysis


%% Plot of pressure at the nodes
figure(10)
%d.plot('links','yes','nodes', 'yes', 'fontsize', 10,'legend', 'show', 'highlightnode', {'10', '11'})  %plot the layout of the network
hold on
coord = d.getNodeCoordinates;
x=d.getNodeCoordinates{1};
y=d.getNodeCoordinates{2};
cmap = parula(512);
c = P(1,:);
scatter(x,y,[],c, 'filled');
colormap(cmap)
a=colorbar
a.Location="southoutside";
ylabel(a,'Pressure (m)','FontSize',10,'Rotation',0);

%% Plot of flow in the links
figure(11)
links=d.getLinkNodesIndex;
clmap = parula(512);
cl = F(1,:);
colorValue=(ceil((abs(cl)-min(abs(cl)))./(max(abs(cl))-min(abs(cl))).*511+1));
for i=1:length(cl)
plot([x(links(i,1));x(links(i,2))], [y(links(i,1));y(links(i,2))],'Color',clmap(colorValue(i),:));
hold on
end
colormap(clmap)
a=colorbar
caxis([min(abs(cl)) max(abs(cl))]);
a.Location="northoutside";
ylabel(a,'Flow rate (l/s)','FontSize',10,'Rotation',0);


d.saveInputFile('Network_modified.inp');










