close all
clear
clc

%% Import Excel

opts = detectImportOptions('COTS Solar Panels.xlsx','VariableNamingRule','preserve');
%preview('COTS Solar Panels.xlsx', opts)
DATA = readtable('COTS Solar Panels.xlsx',opts);

%% Number of Panels

zero = find(DATA.("Number of Deployable Panels") == 0);
one = find(DATA.("Number of Deployable Panels") == 1);
two = find(DATA.("Number of Deployable Panels") == 2);
three = find(DATA.("Number of Deployable Panels") == 3);

%% Non Deployable

[xzero, idx] = sort([0; DATA(zero,:).("Mass (g)")]);
yzero = [0; DATA(zero,:).("Power (W)")];
yzero = yzero(idx);

Zero_Fit = fit(xzero, yzero, 'a*x', 'StartPoint', 1);
Zero_95 = predint(Zero_Fit,xzero, 0.95, 'Observation','on');

figure
plot(Zero_Fit, xzero, yzero, 'ro');
hold on
plot(xzero,Zero_95,'k--')
xlabel('Mass (g)')
ylabel('Power (W)')

Zero_Func = @(x) feval(Zero_Fit,x);
Zero_Coeff = coeffvalues(Zero_Fit);

%% Single Deployable

[xone, idx] = sort([0; DATA(one,:).("Mass (g)")]);
yone = [0; DATA(one,:).("Power (W)")];
yone = yone(idx);

One_Fit = fit(xone, yone, 'a*x', 'StartPoint', 1);
One_95 = predint(One_Fit,xone, 0.95, 'Observation','on');

figure
plot(One_Fit, xone, yone, 'ro');
hold on
plot(xone,One_95,'k--')
xlabel('Mass(g)')
ylabel('Power (W)')

One_Func = @(x) feval(One_Fit,x);
One_Coeff = coeffvalues(One_Fit);

%% Double Deployable

[xtwo, idx] = sort([0; DATA(two,:).("Mass (g)")]);
ytwo = [0; DATA(two,:).("Power (W)")];
ytwo = ytwo(idx);

Two_Fit = fit(xtwo, ytwo, 'a*x', 'StartPoint', 1);
Two_95 = predint(Two_Fit,xtwo, 0.95, 'Observation','on');

figure
plot(Two_Fit, xtwo, ytwo, 'ro');
hold on
plot(xtwo,Two_95,'k--')
xlabel('Mass (g)')
ylabel('Power (W)')

Two_Func = @(x) feval(Two_Fit,x);
Two_Coeff = coeffvalues(Two_Fit);

%% Triple Deployable

[xthree, idx] = sort([0; DATA(three,:).("Mass (g)")]);
ythree = [0; DATA(three,:).("Power (W)")];
ythree = ythree(idx);

Three_Fit = fit(xthree, ythree, 'a*x', 'StartPoint', 1);
Three_95 = predint(Three_Fit,xthree, 0.95, 'Observation','on');

figure
plot(Three_Fit, xthree, ythree, 'ro');
hold on
plot(xthree,Three_95,'k--')
xlabel('Mass (g)')
ylabel('Power (W)')

Three_Func = @(x) feval(Three_Fit,x);
Three_Coeff = coeffvalues(Three_Fit);

%% Combined Plot
figure
plot(Zero_Fit, xzero, yzero, 'ro');
hold on
plot(xzero,Zero_95,'k--')

plot(One_Fit, xone, yone, 'ro');
plot(xone,One_95,'k--')

plot(Two_Fit, xtwo, ytwo, 'ro');
plot(xtwo,Two_95,'k--')

plot(Three_Fit, xthree, ythree, 'ro');
plot(xthree,Three_95,'k--')

xlabel('Mass (g)')
ylabel('Power (W)')
legend("off")

save('SolarPanelPowerFits.mat', 'Zero_Func', "One_Func", "Two_Func", "Three_Func")


%% Specific Power Plot

Lim_M = linspace(10,max(DATA.("Mass (g)")),200);
Lower_lim_P = (Lim_M*1)/1000;
Upper_lim_P = (Lim_M*200)/1000;
Mid_lim_P = (Lim_M*30)/1000;


figure
loglog(xthree/1000,ythree,'o','Color','#EDB120','LineWidth',1)
hold on 
loglog(xtwo/1000,ytwo,'o','Color','#7E2F8E','LineWidth',1)
loglog(xone/1000,yone,'o','Color','#77AC30','LineWidth',1)
loglog(xzero/1000,yzero,'o','Color','#4DBEEE','LineWidth',1)
plot(4.4,135,'ro','LineWidth',1)
plot(Lim_M/1000,Lower_lim_P,'k--','LineWidth',1)
plot(Lim_M/1000,Upper_lim_P,'k--','LineWidth',1)
plot(Lim_M/1000,Mid_lim_P,'k--','LineWidth',1)

xlabel('Mass (kg)')
ylabel('Power (W)')
grid on
title('Specific Power of COTS Solar Arrays')

legend('Triple-Deployable','Double-Deployable','Single-Deployable','Non-Deployable','Pumpkin Space 135W Array','Location','southeast')
t = text(Lim_M(:,2)/1000,Lower_lim_P(:,2),'1 W/kg','HorizontalAlignment','center',BackgroundColor='w');
t1 = text(Lim_M(:,2)/1000,Mid_lim_P(:,2),'30 W/kg','HorizontalAlignment','left',BackgroundColor='w',VerticalAlignment='top');
t2 = text(Lim_M(:,120)/1000,Upper_lim_P(:,120),'200 W/kg','HorizontalAlignment','right',BackgroundColor='w');

%% Surface Area vs Power Plot

Lim_SA = linspace(0.1,max(DATA.("Surface Area (cm^2)")/10000));

SA_Fit = fit(DATA.("Surface Area (cm^2)")/10000, DATA.("Power (W)"), 'a*x', 'StartPoint', 1);
SA_95 = predint(SA_Fit,DATA.("Surface Area (cm^2)")/10000, 0.95, 'Observation','on');

figure
hold on
plot(SA_Fit,DATA.("Surface Area (cm^2)")/10000, DATA.("Power (W)"),'o')
plot(0.36,135,'o','LineWidth',1)

legend('COTS Solar Arrays', 'Line of Best Fit (~285 W/m2)', 'Pumpkin Space 135W Array', Location='southeast')
xlabel('Surface Area (m^2)')
ylabel('Power (W)')
xlim([0 2])
grid on
title('Power vs Surface Area for COTS Solar Arrays')