% initialize constants for the RCAM 
clear
clc
close all

%% Define constants
x0 = [85;       % approx. 165 knots
      0;
      0;
      0;
      0;
      0;
      0;
      0.1;      % approx. 5.73 deg
      0];

u = [0;
     -0.1;      % approx. -5.73 deg
     0;
     0;      % minimum value for throttles are 0.5*pi/180 = 0.0087
     0.08];

TF = 180;

% control limits / saturations

u1min = -25*pi/180;
u1max = 25*pi/180;      % aileron

u2min = -25*pi/180;
u2max = 10*pi/180;      % stabilizer

u3min = -30*pi/180;
u3max = 30*pi/180;      % rudder

% u4min = 0.5*pi/180;
u4min = 0;
u4max = 10*pi/180;      % throttle 1

u5min = 0.5*pi/180;
u5max = 10*pi/180;      % throttle 2

% if u1>u1max
%     u1 = u1max;
% elseif u1<u1min
%     u1 = u1min;
% end
% 
% if u2>u2max
%     u2 = u2max;
% elseif u2<u2min
%     u2 = u2min;
% end
% 
% if u3>u3max
%     u3 = u3max;
% elseif u3<u3min
%     u3 = u3min;
% end
% 
% if u4>u4max
%     u4 = u4max;
% elseif u4<u4min
%     u4 = u4min;
% end
% 
% if u5>u5max
%     u5 = u5max;
% elseif u5<u5min
%     u5 = u5min;
% end

%% Run the model
RCAM=sim('RCAM_Simulink.slx');

%% Plot the results

t = RCAM.simX.Time;

u1 = RCAM.simU.Data(:,1);
u2 = RCAM.simU.Data(:,2);
u3 = RCAM.simU.Data(:,3);
u4 = RCAM.simU.Data(:,4);
u5 = RCAM.simU.Data(:,5);

x1 = RCAM.simX.Data(:,1);
x2 = RCAM.simX.Data(:,2);
x3 = RCAM.simX.Data(:,3);
x4 = RCAM.simX.Data(:,4);
x5 = RCAM.simX.Data(:,5);
x6 = RCAM.simX.Data(:,6);
x7 = RCAM.simX.Data(:,7);
x8 = RCAM.simX.Data(:,8);
x9 = RCAM.simX.Data(:,9);

figure
% control deflects
subplot(5,1,1)
plot(t,u1)
legend('u_1')
grid on
subplot(5,1,2)
plot(t,u2)
legend('u_2')
grid on
subplot(5,1,3)
plot(t, u3)
legend('u_3')
grid on
subplot(5,1,4)
plot(t, u4)
legend('u_4')
grid on
subplot(5,1,5)
plot(t, u5)
legend('u_5')
grid on

% plot the states
figure
% u, v, w
subplot(3,3,1)
plot(t, x1)
legend('x_1')
grid on
subplot(3,3,4)
plot(t, x2)
legend('x_2')
grid on
subplot(3,3,7)
plot (t, x3)
legend('x_3')
grid on

% p, q, r
subplot(3,3,2)
plot(t, x4)
legend('x_4')
grid on
subplot(3,3,5)
plot (t, x5)
legend('x_5')
grid on
subplot(3,3,8)
plot(t, x6)
legend('x_6')
grid on
% phi, theta, psi
subplot(3,3,3)
plot(t, x7)
legend('x_7')
grid on
subplot(3,3,6)
plot (t, x8)
legend('x_8')
grid on
subplot(3,3,9)
plot(t, x9)
legend('x_9')
grid on
