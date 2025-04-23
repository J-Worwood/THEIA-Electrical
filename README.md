# THEIA-Electrical

This repository pertains to the Electrical work package for the THEIA Group Design Project completed as part of the MSc Astronautics and Space Engineering Course at Cranfield University (2024-25). The following scripts were used for preliminary design, and intended for internal use.

# THEIA Mission Requirements

Requirements.xlsx - Excel sheet containing the top level and system requirements for the entire THEIA mission

# Electrical Power System Scaling

COTS Solar Panels.xlsx - A data set of commercial off the shelf solar panels taken from publically available data sheets, predominantly CubeSat size

SA_Mass_Power_Fits.m - This script takes data from the COTS Solar Panels excel and forms mass estimation relations for each variation of the number of deployable panels

EPS.m - This script requires the SA_Mass_Power_Fits.m script to be ran first to generate the mass estimation function. There are inputs at the beginning of the script to specify the orbit, required power load during each phase of orbit, the mission lifetime, solar array and battery specifications. The script can then be ran, and will output estimated solar array area and mass as well as battery specifications required to support the power draw requirements. If selecting from COTS solutions for the solar array, ensure that the power generation requirement (Psa in the workspace) does not exceed the EOL peak power generation of your array.

B_Optim.m - Battery Stacking Optimisation Script for use with 18650 Li-Po cell standard. Input the number of cells in series and parallel as specified from EPS.m to get a battery layout and estimated volume

# Electrical Power System Simulink Model

THEIA_EPS.slx - This is a simulink model used for analysing the selected EPS components. The model has several simplifications and limitations. The output is limited to the 12 V regulated bus and likely does not accurately reflect the performance of the 2ndSpace PCDM selected for the THEIA mission. The inductance and resistance values have been estimated since specific values were not publically available from the vendor. 

There is an issue when a low power draw is placed on the 12 V regulated output whilst the irradiance is set to the expected 1367 W/m2. This appears to overwhelm the voltage regulation and results in an output voltage in excess of 12 V. It is unclear if this reflects real world performance or is a simulation limitation.

Inputs:

The Irradiance is varied using a step function in the PV Array Block

The Day Load is activated using a step function in the Satellite Load Control Block and the load can be varied using the Day Load resistor (this requires an iterative process to match the expected draw). It is recommended to switch the day load at the same time as the irradiance step.

The Eclipse Load is activated using a step function in the Satellite Load Control Block and load can be varied using the Eclipse Load resistor. 

The simulation time which is set in the simulation tab of Simulink. This should be set to 60s by default.

Outputs:

There are two main output scopes, these should open upon simulation start. If not the EPS scope is located to the right of the Battery Control Block and the Regulated Bus scope is located within the Satellite Bus Block.




