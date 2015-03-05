%% Reset the window
clear all;
close all;
clc;

%% Import data and setup variables
load('ENB301TestData.mat');
a = [0.4 1 4 12 20];
KmArray = [1 5 15 35 50];
colours = ['y' 'm' 'g' 'c' 'b'];

%% Before doing any of the asked questions, find an ideal approximation for the response
BestA = 1;
BestKm = 0.1;
denominator = [ 1 BestA 0 ];

% Run first test to get a value for the error
G = tf(BestKm, denominator);
yGuess = step(G, t);

lowestError = sqrt((mean(y1 - yGuess).^2));
error = 0;

% Find the best value for Km, knowing it has the lowest error
for ii = 0.2:0.1:10
    G = tf(ii, denominator);
    yGuess = step(G, t);
    
    error = sqrt((mean(y1 - yGuess).^2));
    
    if error <= lowestError
        BestKm = ii;
        lowestError = error;
    end
    
    error = 0;
end

%% A3: Plot various values for Km and a
figure(1);
hold on;
plot(t, y1, 'r');

% Plot each of the values on a graph with the approximation
for ii = 1:5
    den = [ 1 a(ii) 0 ];
    G = tf(KmArray(ii), den);
    y = step(G, t);
    
    plot(t, y, colours(ii));
end

title('\bfStep Response of G(s) with varying values of Km and a');
legend('Location','NorthWest','Given Data', 'a = 0.2, Km = 1', 'a = 1, Km = 5', 'a = 4, Km = 15', 'a = 12, Km = 35', 'a = 20, Km = 50');
xlabel('\bfTime (sec)');
ylabel('\bfAmplitude');
hold off;

%% A4: Plot different values of a for the same value of Km
Km = 5;
figure(2);
hold on;
plot(t, y1, 'r');

% Plot each of the values on a separate graph with the approximation
for ii = 1:4
    den = [ 1 a(ii) 0 ];
    G = tf(Km, den);
    y = step(G, t);
    
    plot(t, y, colours(ii));
end

title('\bfStep Response of G(s) with varying values of alpha');
legend('Location','NorthWest','Given Data', 'a = 0.2', 'a = 1', 'a = 4', 'a = 12');
xlabel('\bfTime (sec)');
ylabel('\bfAmplitude');
hold off;
% As a increases, the motor becomes more difficult to move

%% A5: Add some uncertainty to the output y1(t)
% Will use Km = BestKm and a = BestA for y1(t) because these values were found to
% produce the most accurate reponse. The procedure for this can be seen
% before section A3. The value for noise variation is just a guess.

numerator = BestKm;
denominator = [1 BestA 0];
BestG = tf(numerator, denominator);
BestY = step(BestG, t);

NoiseVariation = 0.3;
yn = BestY + (NoiseVariation .* randn(size(BestY)));

figure(3);
hold on;
plot(t, BestY, 'b');
plot(t, yn, 'r');

title('\bfStep Response of G(s), Ideal vs. Noise')
legend('Location','NorthWest', 'Ideal', 'Noise');
xlabel('\bfTime (sec)');
ylabel('\bfAmplitude');
hold off;

%% A6: Load the experimental data
load('TestA5.mat');

% Find where the time vector goes above zero and start all the vectors at
% the same point
zeroPoint = 1;
endPoint = 1;

while Time(zeroPoint) < 0
    zeroPoint = zeroPoint + 1;
end

while Time(endPoint) < 1.55
    endPoint = endPoint + 1;
end

% Move the zero point slightly so it fits beter with the collected data
zeroPoint = zeroPoint - 20;

timeData = Time(zeroPoint:endPoint);
inputData = Input(zeroPoint:endPoint);
positionData = Position(zeroPoint:endPoint);

% Move the positionData vector down so that it begins at 0
xOffset = timeData(1);
timeData = timeData - xOffset;

yOffset = positionData(1);
positionData = positionData - yOffset;
endPoint = (endPoint - zeroPoint) + 1;

% Smooth the positionData so we can get more accurate results when
% analysing
positionData = smooth(positionData);

figure(4);
hold on;
plot(timeData, positionData, 'black');

title('\bfStep Response of G(s), Real')
legend('Location','NorthWest', 'Real');
xlabel('\bfTime (sec)');
ylabel('\bfAmplitude');
hold off;

%% A7: Plot both experimental data and calculated response on the same graph
% Get the ideal response again
numerator = BestKm;
denominator = [1 BestA 0];
BestG = tf(numerator, denominator);
BestY = step(BestG, timeData);

figure(5);
hold on;
plot(timeData, positionData, 'black');
plot(timeData, BestY, 'r');

title('\bfStep Response of G(s), Real vs. Calculated')
legend('Location','NorthWest', 'Real', 'Calculated');
xlabel('\bfTime (sec)');
ylabel('\bfAmplitude');
hold off;

%% A8: Get a value for the error between the suggested guess and actual response
totalError = sqrt(mean((positionData - BestY).^2));
fprintf('The calculated value for error is %f\n', totalError);

%% A9: Try to lower the error
aA9 = 1;
KmA9 = 1;
%reTryKm = (positionData(endPoint) - positionData(1)) / (timeData(endPoint) - timeData(1)); % let Km = the gradient of the collected data
denA9 = [ 1 aA9 0 ];

% Run first test to get a value for the error
GA9 = tf(KmA9, denA9);
yGuess = step(GA9, timeData);

lowestError = sqrt((mean(positionData - yGuess).^2));

% Find the best value for Km, knowing it has the lowest error
for aAdd = 1:1:30
    for KmAdd = (2 * aAdd):0.4:(5 * aAdd)

        denA9 = [ 1 aAdd 0 ];
        GA9 = tf(KmAdd, denA9);
        yGuess = step(GA9, timeData);

        error = sqrt(mean((positionData - yGuess).^2));

        if error <= lowestError
            aA9 = aAdd;
            KmA9 = KmAdd;
            lowestError = error;
        end
    end
end

fprintf('The re-calculated value for error is %f\n', lowestError);

numA9 = KmA9;
denA9 = [1 aA9 0];
GA9 = tf(numA9, denA9);
YA9 = step(GA9, timeData);

figure(6);
hold on;
plot(timeData, positionData, 'black');
plot(timeData, YA9, 'r');

title('\bfStep Response of G(s), Real vs. Calculated (ReTry)')
legend('Location','NorthWest', 'Real', 'Calculated');
xlabel('\bfTime (sec)');
ylabel('\bfAmplitude');
hold off;

%% A10: Use second order response and vary Km and B until 

% Keep alpha the same as from previous approximation
aA10 = aA9;

% Knowing that Beta has to be at least 10 times greater then alpha, start
% it at that area
bA10 = 3 * (10 * aA10) / 4;

% Cycle Km through a + or - 10 region from what it was previously
% calculated at in the for loop, cycle beta through a +50 region seeing as
% it is not known what it will be
KmA10 = 12000;

% Run first test to get a value for the error
denA10 = conv([1 aA10 0], [1 bA10]);
GA10 = tf(KmA10, denA10);
yGuess = step(GA10, timeData);

lowestError = sqrt((mean(YA9 - yGuess).^2));

bLow = bA10;
bHigh = bA10 + 500;
KmLow = KmA10;
KmHigh = KmA10 + 15000;

% Find the best value for Km, knowing it has the lowest error
for bAdd = bLow:5:bHigh
    for KmAdd = KmLow:300:KmHigh

        denA10 = conv([1 aA10 0], [1 bAdd]);
        GA10 = tf(KmAdd, denA10);
        yGuess = step(GA10, timeData);

        error = sqrt(mean((YA9 - yGuess).^2));

        if error <= lowestError
            bA10 = bAdd;
            KmA10 = KmAdd;
            lowestError = error;
        end
    end
end

fprintf('The re-calculated value for error is %f\n', lowestError);

numA10 = KmA10;
denA10 = conv([1 aA10 0], [1 bA10]);
GA10 = tf(numA10, denA10);
YA10 = step(GA10, timeData);

figure(7);
hold on;
plot(timeData, YA9, 'black');
plot(timeData, YA10, '--r');

title('\bfStep Response of G(s), Approximation using only alpha vs using both alpha and beta')
legend('Location','NorthWest', 'alpha', 'alpha and beta');
xlabel('\bfTime (sec)');
ylabel('\bfAmplitude');
hold off;
