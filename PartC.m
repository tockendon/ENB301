%% C4
clear,clc,close all;

% Create simulated data
%----------------------------------------
km = 82;
alpha = 30;

% Find the gain required for a 5% overshoot 
percentOS = 5 / 100;

zetaB6 = -log(percentOS) / sqrt(pi^2 + log(percentOS)^2);
wnB6 = alpha / (2 * zetaB6);

% To get 5% overshoot make the numerator and co-efficient of s^0 the same.
% Therefore km * kB6 = wnB6^2
kB6 = wnB6^2 / km;

% Tf motor
num = km;
den = [1 alpha 0];
G_Motor = tf(num, den);   

% Tf gain
G_Gain = tf(kB6,1); 

% Cascade the forward path
G = G_Motor*G_Gain;

% Closed loop
GC4 = feedback(G,1); 

% Load the data from experiment
%----------------------------------------
load 'OvershootData.mat';

% Manipulate vectors 
te5 = second(587:801);
ye5 = Volt1(587:801);
te5 = te5 - te5(1);
ye5(ye5<0) = 0; 

% Plot both the measured and simulated signal
%----------------------------------------
yc = step(0.5 * GC4, te5);
ye5 = smooth(ye5);

figure(1)
plot(te5,ye5,'b-');
hold on;
plot(te5,yc,'r-');
axis([0 1 0 0.6]);
title('\bfClosed loop response 5% overshoot');
xlabel('\bf\itTime (s)');
ylabel('\bf\itVoltage (V)');
legend('Measured Signal','Simulated Signal');
hold off;

%% C5 
% Build a PD compensator that has a settling time twice as fast.
%----------------------------------------
GPD = tf((30/82)*[1 63.0783],1);

% Cascade the forward path.
G2 = GPD*G_Motor;

% Compute the closed loop transfer function.
GC5 = feedback(G2,1);

% Get Info about the model.
%----------------------------------------
pole(GC5)
[wn, zeta] = damp(GC5);

% Root locus of open loop
figure(2)
rlocus(G2)
title('\bf\itOpen loop');
% Root locus of closed loop
figure(3)
rlocus(GC5)
title('\bf\itClosed loop');
stepinfo(GC5)
% Root locus of uncompensated system
figure(4)
rlocus(GC4)
axis([-60 10 -60 60]);
title('\bf\itUncompensated closed loop');

% Plot the compensated and uncompensated reponse.
%----------------------------------------
yc2 = step(0.5 * GC5, te5);

figure(5)
plot(te5,yc2,'b-');
hold on;
plot(te5,yc,'r-');
plot(te5,ye5,'k-');
axis([0 1 0 0.6]);
title('\bfClosed loop response 5% overshoot');
xlabel('\bf\itTime (s)');
ylabel('\bf\itVoltage (V)');
legend('Compensated Response','Uncompensated Response','Measured Signal','Location','SouthEast');
hold off;

