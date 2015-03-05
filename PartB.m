%% B3
clear,clc,close all;

% Vp(s)/Vm(s) 
% These values are taken from PartA.m
km = 82;
alpha = 30;

% Known Resistor Values
R2 = 33e3;
R1 = 10e3;

% Removed the -ve as it shouldnt matter as it only controls the direction of the motor. 
k = R2/R1; 

% Cascaded foward path
num = k*km;
den = [1 alpha 0];
sys = tf(num, den);

%% B4
% Closed loop transfer function
Gc = feedback(sys,1);

%% B5
% Calculate the characteristics of the response
stepinfo(Gc)
[wn, zeta] = damp(Gc);
% Clean up arrays
wn = wn(1);
zeta = zeta(1);

Ts = 4 / (zeta*wn);
OS = exp((-zeta*pi)/sqrt(1-(zeta^2)))*100;
Tp = pi/(wn*sqrt(1-(zeta^2)));

t = linspace(0,1,100);
y1 = step(0.5 * Gc,t);

% Plot the initial response
figure(1)
plot(t,y1);
title('\bf\itStep response closed loop model');
xlabel('\bf\itTime (s)');
ylabel('\bf\itVoltage (V)');

%% B6
% % Find the gain required for a 5% overshoot 
percentOS = 5 / 100;

zetaB6 = -log(percentOS) / sqrt(pi^2 + log(percentOS)^2);
wnB6 = alpha / (2 * zetaB6);

% To get 5% overshoot make the numerator and co-efficient of s^0 the same.
% Therefore km * kB6 = wnB6^2
kB6 = wnB6^2 / km;
num = kB6 * km;
den = [1 (2 * zetaB6 * wnB6) (wnB6^2)];
GB6 = tf(num,den);

% Display results to verify a 5% overshoot
stepinfo(GB6)

%% B7 
load 'test_b_day2_1.mat';

% Find where the time vector goes above zero and start all the vectors at
% the same point
te = te(197:439);
ye = ye(197:439);
ye(ye < 0) = 0; 
te = te - 0.0958;
te(te < 0) = 0; 
te = te(16:end); 
ye = ye(16:end);

% Generate the step responses
ye = smooth(ye);
y1 = step(0.5 * Gc, te);

% Plot measured data agaisnt the simulated data
figure(2)
hold on;
plot(te, ye, 'b-');
plot(te, y1, 'r-');
title('\bfClosed loop response (no overshoot)');
legend('Location','NorthWest', 'Experimental Data', 'Calculated Data');
xlabel('\bf\itTime (s)');
ylabel('\bf\itVoltage (V)');
hold off;

%% B8 
load('OvershootData.mat')

Volt1 = smooth(Volt1);

% Get the %OS value
max = max(Volt1);
min = mean(Volt1(649:end)); % mean of the steady state

OS = (max - min) / min

% Plot the input and output of the system
figure(3)
hold on;
grid on;
grid minor;
plot(second,Volt);
plot(second,Volt1,'r-');
plot_title = sprintf('Experimental Data - Closed loop Response ( %0.2f %% overshoot)', OS*100);
title(plot_title,'FontWeight','bold');
legend('Location','NorthWest', 'Input Step', 'Output Response');
xlabel('\bf\itTime (s)');
ylabel('\bf\itVoltage (V)');
hold off;

