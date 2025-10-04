clear all; close all; clc;
% insert here the path where it is installed the EPANET-Matlab toolkit
addpath(genpath('C:\Users\Utente\OneDrive - Politecnico di Milano\Didattica\2024-25\Project\Case1 Matlab\Matlab-toolkit\EPANET-Matlab-Toolkit-master'))
start_toolkit; %to start the epanet toolkit
nameInp={'year0.inp'};% 'year1.inp' 'year2.inp' 'year3.inp' 'year4.inp' 'year5.inp'};% 'year2.inp' 'year3.inp' 'year4.inp' 'year5.inp'};
weeksInAYear=52;
%% Loading network parameters

for ii=1:length(nameInp)
d = epanet(nameInp{ii}); %importa data from .inp file
%d = epanet('Run_year1.inp');
%d=epanet('Network_simplified_pattern_leakages-80_tank.inp');
hrs = 168; %total hours of analysis
P0=0;
Pref=20;
Pf=10;


d.setTimeSimulationDuration(hrs*3600); %set of the duration time must be specified in seconds

etstep = 3600; %length in seconds of analysis step/ I will get all results only for one hour
d.setTimeReportingStep(etstep); %set time of result reporting step
d.setTimeHydraulicStep(etstep); %set time analysis step
d.setTimeRuleControlStep(etstep);

d.openHydraulicAnalysis;       %start hydraulic simulation
d.initializeHydraulicAnalysis; %inizialization of hydraulic simulation, settings, levels, etc

%%

Name = []; Name = d.getNodeNameID;
Links = []; Links = d.getLinkNameID;
lengths = []; lengths = d.getLinkLength;
nodeDemandPatternIndex=[]; nodeDemandPatternIndex= d.getNodeDemandPatternIndex;


tstep=1900;

Q =[];
tr=[];
em=[];
FR = [];
P=[];
BD=[];
pumpsEfficiency=[];

i=1;

% Calculations

while (tstep>0)                %condition to run simulations each hour until the time simulation duration is reached (tstep=1), no utilizamos un for porque no sabeos cuantas iteraciones va a tomar
    t=d.runHydraulicAnalysis;  %run the hydraulic analysis step hour 00, 01, 02....168
    
    if tstep>1800 
    FR=[FR; d.getNodeActualDemand]; %Flow rates in the nodes (Result of the simulation)
    BD=[BD; d.getNodeBaseDemands];
    Q=[Q; d.getLinkFlows];
    P = [P; d.getNodePressure]; %pressure at each node each hour
    em = [em; d.getNodeEmitterCoeff];
    pumpsEfficiency= [pumpsEfficiency; d.getLinkPumpEfficiency];

    end

    tstep=d.nextHydraulicAnalysisStep; %if next step exist d.nextHydraulicAnalysisStep==1 else 0
    tr(i)=tstep;
    %status(i,:)=d.getLinkStatus;
    i=i+1;
end



year.P=P(1:end-1,:);
year.Q=Q(1:end-1,:);
year.em=em(1:end-1,:);
year.FR=FR(1:end-1,:);
year.BD=BD(1:end-1);
year.linkNodesIndex=d.getLinkNodesIndex;
year.linkPumpIndex=d.getLinkPumpIndex;
year.nodeElevations=d.getNodeElevations;
year.linkPumpEfficiency=pumpsEfficiency(1:end-1,:);
year.linkSetting=d.getLinkSettings;
year.linkLength=d.getLinkLength;
year.pattern=d.Pattern;
year.name=Name;
year.links=Links;
year.nodeDemandPatternIndex=nodeDemandPatternIndex;



if ii==1; year0=year; end
    if ii==2; year1=year; end
        if ii==3; year2=year; end
            if ii==4; year3=year; end
                if ii==5; year4=year; end
                    if ii==6; year5=year; end


clear year


%d.closeHydraulicAnalysis; %exit the analysis
end


%% INDICATORS
years={year0}%,year1,year2,year3,year4,year5};%,year1,year2};

%I1
for i=1:length(years)
clear PP0hours  PP0hoursUser
PP0hours=zeros(size(years{i}.P));
PP0hours=1*(years{i}.P>0);
PP0hoursUser=PP0hours(:,years{i}.BD{1}>0);
PP0hoursUserTotal(i)=sum(sum(PP0hoursUser));
I1_year(i)=PP0hoursUserTotal(i)/(size(PP0hoursUser,1)*size(PP0hoursUser,2));
end
I1=sum(PP0hoursUserTotal)/((size(PP0hoursUser,1)*size(PP0hoursUser,2))*length(years));

%%
%I2
for i=1:length(years)
clear PP0hours  PP0hoursUser userService PP0hoursUserCompleteYear 
PP0hours=zeros(size(years{i}.P));
PP0hours=1*(years{i}.P>0);
PP0hoursUser=PP0hours(:,years{i}.BD{1}>0);
PP0hoursUserCompleteYear=sum(PP0hoursUser);
for ii=1:length(PP0hoursUserCompleteYear)
if PP0hoursUserCompleteYear(ii)==hrs;
    userService(ii)=1;
else
    userService(ii)=0;
end
end
userServiceYear(i)=sum(userService);

end

I2=sum(userServiceYear)/(sum(year0.BD{1}>0)*length(years));

%%
%I3
ID_sources={'R1' 'W2_SA' 'W3_AB' 'W4_SM' 'W5_PL' 'W6_NORTH'};
ID_sourcesMaxLim=[-200-10 -10-2 -25-2 -48-2 -27-2 50-2];
%ID_sources={'1'};
clear sources
for i=1:length(years)
    for ii=1:length(ID_sources);
    try sources(i,ii)=sum(years{i}.FR(:,find(strcmp((years{i}.name), ID_sources{ii}))));
        sourcesMaxYear(i,ii)=min(years{i}.FR(:,find(strcmp((years{i}.name), ID_sources{ii}))));
    sourcesMaxYearCount(i,ii)=sum(years{i}.FR(:,find(strcmp((years{i}.name), ID_sources{ii})))<ID_sourcesMaxLim(ii));
    end
    end
end
volumeInlet=-sum(sum(sources));


for i=1:length(years)
    clear sortLeak sortLeakInd volumeEmitterYearNodes volumeEmitterYearNodes1 volumeEmitterYearNodes2 volumeEmitterYearNodes3
        volumeEmitterYearNodes1=(years{i}.P.*years{i}.em);
        [sortLeak,sortLeakInd]=sort(sum(volumeEmitterYearNodes1),'descend');
        volumeEmitterYearNodes2=volumeEmitterYearNodes1(volumeEmitterYearNodes1>0);
        volumeEmitterYearNodes3=sum(volumeEmitterYearNodes2);
    volumeEmitterYear(i)=sum(volumeEmitterYearNodes3);
end
volumeEmitter=sum(volumeEmitterYear);

I3=volumeEmitter/volumeInlet;

sourceMax=min(sourcesMaxYear)';
sourceMaxHoursOverLimit=sum((sourcesMaxYearCount))';


%%
%I4


for i=1:length(years)
    clear demandYearUserHours demandYearUser
    demandYearUserHours=zeros(hrs,length(years{i}.name));
    for ii=1:hrs;
        for us=1:length(years{i}.name)
            if years{i}.nodeDemandPatternIndex{1}(us)>0;
                demandYearUserHours(ii,us)=(years{i}.BD{ii}(us).*years{i}.pattern(years{i}.nodeDemandPatternIndex{1}(us),ii));
        
            end
        end
    end
    demandYearUser=sum(demandYearUserHours);
    demandYear(i)=sum(demandYearUser);
end

volumeDemanded=sum(demandYear);


for i=1:length(years)
    clear demandActualYearUserHours demandYearUser demandDeliveredToUsers
    demandActualYearUserHours=zeros(hrs,length(years{i}.name));
    emitterActualYearUserHours=zeros(hrs,length(years{i}.name));
    for ii=1:hrs
        for us=1:length(years{i}.name)
            if years{i}.BD{ii}(us)>0 && years{i}.P(ii,us)>0
               demandActualYearUserHours(ii,us)=years{i}.FR(ii,us);
               emitterActualYearUserHours(ii,us)=years{i}.P(ii,us).*years{i}.em(ii,us);
            end
        end
    end 
    demandDeliveredToUsers=demandActualYearUserHours-emitterActualYearUserHours;
    demandActualYear(i)=sum(sum(demandDeliveredToUsers));
end

volumeSupplied=sum(demandActualYear);

I4=volumeSupplied/volumeDemanded;

%%
%I5

for i=1:length(years)
    clear P5 P5UserYear
    P5=zeros(hrs,length(years{i}.name));
    P5UserYear=zeros(hrs,length(years{i}.name));
    for ii=1:hrs
        for us=1:length(years{i}.name)
            if  years{i}.BD{ii}(us)>0 && years{i}.P(ii,us)>0
                P5UserYear(ii,us)=years{i}.P(ii,us);
                if years{i}.P(ii,us)>20
                    P5UserYear(ii,us)=20;
                end
            end
        end
    end 
    P5Year(i)=sum(sum(P5UserYear));
end

P5=sum(P5Year);

I5=P5/(hrs*nnz(years{1}.BD{1})*length(years)*Pref)


%%
%I6

for i=1:length(years)
clear PPfhours  PPfhoursUser PfuserService PPfhoursUserCompleteYear 
PPfhours=zeros(size(years{i}.P));
PPfhours=1*(years{i}.P>Pf);
PPfhoursUser=PPfhours(:,years{i}.BD{1}>0);
PPfhoursUserCompleteYear=sum(PPfhoursUser);
for ii=1:length(PPfhoursUserCompleteYear)
if PPfhoursUserCompleteYear(ii)==hrs;
    PfuserService(ii)=1;
else
    PfuserService(ii)=0;
end
end
PfuserServiceYear(i)=sum(PfuserService);

end

I6=sum(PfuserServiceYear)/(sum(year0.BD{1}>0)*length(years));

%%
%I7
for i=1:length(years)
    clear volumeEmitterYearNodes volumeEmitterYearNodes1 volumeEmitterYearNodes2 volumeEmitterYearNodes3
        volumeEmitterYearNodes1=(years{i}.P.*years{i}.em).*3600;
        volumeEmitterYearNodes2=volumeEmitterYearNodes1(volumeEmitterYearNodes1>0);
        volumeEmitterYearNodes3=sum(volumeEmitterYearNodes2);
    volumeEmitterYear(i)=sum(volumeEmitterYearNodes3);
    linkLengthYear(i)=sum(years{i}.linkLength);
end
I7=sum((volumeEmitterYear./1000.*weeksInAYear./365)./(linkLengthYear./1000))./length(years);




%%
%I8

for i=1:length(years)
    clear Qpumps p1pumps p2pumps DPpumps EpumpsYearPumps etaPumps
etaPumps=years{i}.linkPumpEfficiency;
% speedPumps=years{i}.linkSettings(years{i}.linkPumpIndex);
% if speedPumps==0
%     speedPumps=1;
% end
Qpumps=years{i}.Q(:,years{i}.linkPumpIndex);
p1pumps= years{i}.P(:,years{i}.linkNodesIndex(years{i}.linkPumpIndex,1))+years{i}.nodeElevations(:,years{i}.linkNodesIndex(years{i}.linkPumpIndex,1));
p2pumps= years{i}.P(:,years{i}.linkNodesIndex(years{i}.linkPumpIndex,2))+years{i}.nodeElevations(:,years{i}.linkNodesIndex(years{i}.linkPumpIndex,2));
DPpumps=abs(p1pumps-p2pumps);
EpumpsYearPumps=(Qpumps/1000).*DPpumps.*9.806.*999./etaPumps;
EpumpsYearPumps(isnan(EpumpsYearPumps))=0;
EpumpsYear(i)=sum(sum(EpumpsYearPumps));
end

I8=sum(EpumpsYear)./sum(demandActualYear);


%%
%I9

for i=1:length(years)
    clear demandYearUserHours demandYearUser
    demandYearUserHours=zeros(hrs,length(years{i}.name));
    for ii=1:hrs;
        for us=1:length(years{i}.name)
            if nodeDemandPatternIndex{1}(us)>0;
                demandYearUserHours(ii,us)=(years{i}.BD{ii}(us).*years{i}.pattern(nodeDemandPatternIndex{1}(us),ii));
        
            end
        end
    end
    demandYearUser=sum(demandYearUserHours);
    demandYear(i)=sum(demandYearUser);



    clear demandActualYearUserHours  demandDeliveredToUsers emitterActualYearUserHours
    demandActualYearUserHours=zeros(hrs,length(years{i}.name));
    emitterActualYearUserHours=zeros(hrs,length(years{i}.name));
    for ii=1:hrs
        for us=1:length(years{i}.name)
            if years{i}.BD{ii}(us)>0 && years{i}.P(ii,us)>0
               demandActualYearUserHours(ii,us)=years{i}.FR(ii,us);
               emitterActualYearUserHours(ii,us)=years{i}.P(ii,us).*years{i}.em(ii,us);
            end
        end
    end 
    demandDeliveredToUsers=demandActualYearUserHours-emitterActualYearUserHours;
    demandActualYear(i)=sum(sum(demandDeliveredToUsers));

    clear SRnodes clear
    SRnodes=sum(demandDeliveredToUsers)./sum(demandYearUserHours);
    SR(i,:)=SRnodes(years{i}.BD{1}>0);
    SR(isnan(SR))=0;
    
end

SRA=sum(sum(SR))./(length(years)*sum(years{1}.BD{1}>0));
SRDEV=sum(sum(abs(SR-SRA)))./(length(years)*sum(years{1}.BD{1}>0));

I9=1-(SRDEV/SRA)
indicators=[I1;I2;I3;I4;I5;I6;I7;I8;I9];

save(strcat(cd,'\Output4'));




