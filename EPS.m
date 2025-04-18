close all; clear; clc

% Electrical Power System sizing and mass estimation script. Inputs and
% assumptions are listed at the top. Should be valid for spacecraft from
% 10 kg to 500 kg.

% Author: Josh Worwood


%% Inputs

% Power Requirements
PowerEclipse = 52; % W
PowerDay = 70; % W

% Orbit Altitude
AltOrbit = 585; % km

% Maximum Eclipse Time
TimeEclipse = 2040; % s

% Mission Lifetime
Lifetime = 5;

% Maximum Incidence Angle (Beta)
IncidenceAngle = 0; % deg

% Maximum Depth of Discharge
DoD = 0.3; % Selected based on the number of cycles during lifetime

% Target Bus Voltage
BusVolt = 12;

% Solar Flux
SolFlux = 1368; % W/m2


%% Solar Cell - Spectrolab XTJ-Prime 

% Efficiency
BOL_eff = 0.307; 
EOL_eff = 0.2763; % After 10yrs

% Cell Degradation
cell_deg = (BOL_eff - EOL_eff)/10; % per year

% Estimated Power Output per Cell
P0 = BOL_eff*SolFlux;


%% Battery Cell - Samsung 35E (18650)

% Cell Voltage
CellVolt = 3.6; % V

% Cell Capacity
CellCap = 3500; % mAh

% Cell Mass
CellMass = 0.048; % kg

% Specific Energy Density
SpecificEnergyDensity = 276; % Wh/kg


%% Assumptions

% EPS Efficiencies using MPPT (Taken from SME:The New SMAD)
%Xe = 0.6; % Path from SA through the battery to the individual loads
%Xd = 0.8; % Path directly from the arrays to the loads
%Id = 0.77; % Inherent degradation of the solar array junctions

% EPS Efficiencies estimated from Pumpkin Space Data Sheets
Xe = 0.8;
Xd = 0.9;
Id = 0.77;

% EPS Efficiencies using DET (Taken from SME:The New SMAD)
%Xe = 0.65; % Path from SA through the battery to the individual loads
%Xd = 0.85; % Path directly from the arrays to the loads

% Excess Mass factor
BattExcessMass = 1.2;

%% Solar Array Calculations

% Orbit Period
SemiMajor = (AltOrbit + 6378);
Torb = 2*pi*sqrt(SemiMajor^3/3.986e5);
TimeDay = (Torb - TimeEclipse)/60;

% Solar Array Power
Psa = ((PowerEclipse*(TimeEclipse/60)/Xe) + ((PowerDay*TimeDay)/Xd))/TimeDay;

% Power at Beginning of Life
PBOL = P0*Id*cosd(IncidenceAngle);

% Lifetime Degradation
Ld = (1 - cell_deg)^Lifetime;

% Power at End of Life
PEOL = PBOL*Ld;

% Solar Array Area Required
Asa = Psa/PEOL;
Asa_cm2 = Asa * 10000;

load('SolarPanelMassFits.mat')

if (Asa_cm2 > 0) && (Asa_cm2 < 800)
    
    zero_mass = (Zero_Func(Asa_cm2)/1000);

else

    zero_mass = (Zero_Func(Asa_cm2)/1000);
    warning('Input is beyond data range of the Non-Deployable mass relation')

end

if (Asa_cm2 > 300) && (Asa_cm2 < 13530)

    one_mass = (One_Func(Asa_cm2)/1000);

else

    one_mass = (One_Func(Asa_cm2)/1000);
    warning('Input is beyond data range of the Single Deployable mass relation')

end

if (Asa_cm2 > 500) && (Asa_cm2 < 27060)

    two_mass = (Two_Func(Asa_cm2)/1000);

else

    two_mass = (Two_Func(Asa_cm2)/1000);
    warning('Input is beyond data range of the Double Deployable mass relation')

end

if (Asa_cm2 > 700) && (Asa_cm2 < 40590)

    three_mass = (Three_Func(Asa_cm2)/1000);

else

    three_mass = (Three_Func(Asa_cm2)/1000);
    warning('Input is beyond data range of the Triple Deployable mass relation')

end

fprintf('Estimated Solar Array Mass For Required Surface Area (%g m2)\n\n', Asa)
fprintf('Assuming 2 identical arrays, following shows required size per side: \n')
fprintf('Non-Deployable = %g kg     Panel Size: %g m2\n', zero_mass, Asa)
fprintf('Single Deployable = %g kg  Panel Size: %g m2\n', one_mass,Asa/2)
fprintf('Double Deployable = %g kg     Panel Size: %g m2\n', two_mass,Asa/4)
fprintf('Triple Deployable = %g kg  Panel Size: %g m2\n', three_mass, Asa/6)

%% Battery Calculations

% Number of Cycles
OrbNoDay = 86164/Torb; % Orbits per Sidereal Day
OrbNoYr = OrbNoDay * 365; % Orbits per Year
OrbNoLife = OrbNoYr * Lifetime; % Orbits per mission lifetime

% Required Capacity
Capacity = PowerEclipse*(TimeEclipse/3600)/DoD; % Wh

% Number of Series Cells
SeriesCell = round(BusVolt/CellVolt);

% Peak Battery output voltage
PeakVol = SeriesCell * CellVolt;

% Convert mAh to Wh
CellCapConv = (CellCap * PeakVol)/1000; % Wh

% Number of Parallel Cells
ParallelCell = ceil(Capacity/CellCapConv);

% Number of Cells required to satisfy Capacity
CellNo = ParallelCell * SeriesCell;

% Mass of Battery
BattMassCell = CellNo * CellMass * BattExcessMass; % kg

% Volume of Battery
BattVol = ((pi*9^2*65) * CellNo)/1e9;

fprintf(['\nEstimated Battery Configuration \nTotal Capacity: %g Wh    ' ...
    'Peak Output Voltage: %g V\nEstimated Mass: %g kg    Estimated Volume: ' ...
    '%g m3\n\nTotal Number of Cells: %g\nCells in Series: %g   Cells in ' ...
    'Parallel: %g\n'],Capacity,PeakVol,BattMassCell,BattVol,CellNo, ...
    SeriesCell,ParallelCell)