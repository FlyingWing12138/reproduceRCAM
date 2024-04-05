function [Xdot] = RCAM(X,U)

% ----------------------- State and Control Vectors -----------------------

x1 = X(1);      % u
x2 = X(2);      % v
x3 = X(3);      % w
x4 = X(4);      % p
x5 = X(5);      % q
x6 = X(6);      % r
x7 = X(7);      % phi
x8 = X(8);      % theta
x9 = X(9);      % psi

u1 = U(1);      % d_A (aileron)
u2 = U(2);      % d_T (stabilizer)
u3 = U(3);      % d_R (rudder)
u4 = U(4);      % d_th1 (throttle 1)
u5 = U(5);      % d_th2 (throttle 2)

% ------------------------------- Constants -------------------------------

% nominal vehicle constants
% inertia matrix defined later

m = 120000;         % aircraft total mass (kg)

cbar = 6.6;         % mean aerodynamic chord (m)
lt = 24.8;          % distance by aerodynamic center of tail and body (m)
S = 260;            % wing planform aera (m^2)
St = 64;            % tail planform area (m^2)

Xcg = 0.23*cbar;    % x position of center of gravity in Fm frame (m)
Ycg = 0;            % y position of center of gravity in Fm frame (m)
Zcg = 0.10*cbar;    % z position of center of gravity in Fm frame (m)

Xac = 0.12*cbar;    % x position of aerodynamic center in Fm frame (m)
Yac = 0;            % y position of aerodynamic center in Fm frame (m)
Zac = 0;            % z position of aerodynamic center in Fm frame (m)

% engine constants

Xapt1 = 0;          % x position of engine 1 force in Fm frame (m)
Yapt1 = -7.94;      % y position of engine 1 force in Fm frame (m)
Zapt1 = -1.9;       % z position of engine 1 force in Fm frame (m)

Xapt2 = 0;          % x position of engine 2 force in Fm frame (m)
Yapt2 = 7.94;       % y position of engine 2 force in Fm frame (m)
Zapt2 = -1.9;       % z position of engine 2 force in Fm frame (m)

% other constants

rho = 1.225;                % air density (kg/m^3)
g = 9.80665;                % gravitational acceleration (m/s^2)
depsda = 0.25;              % change in downwash w.r.t. alpha (rad/rad)
alpha_L0 = -11.5*pi/180;    % zero lift angle of attack (rad)
n = 5.5;                    % slope of linear region of lift slope
a3 = -768.5;                % coefficient of alpha^3
a2 = 609.2;                 % coefficient of alpha^2
a1 = -155.2;                % coefficient of alpha^1
a0 = 15.212;                % coefficient of alpha^0
alpha_switch = 14.5*pi/180; % alpha where lift slope switch to nonlinear

% -------------------- step 1. control limits / saturation ----------------

% these can alternately be enforced in Simulink

% u1min = -25*pi/180;
% u1max = 25*pi/180;      % aileron
% 
% u2min = -25*pi/180;
% u2max = 10*pi/180;      % stabilizer
% 
% u3min = -30*pi/180;
% u3max = 30*pi/180;      % rudder
% 
% u4min = 0.5*pi/180;
% u4max = 10*pi/180;      % throttle 1
% 
% u5min = 0.5*pi/180;
% u5max = 10*pi/180;      % throttle 2
% 
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

% -------------------- step 2. intermediate variables ---------------------

% calculate airspeed
Va = sqrt(x1^2+x2^3+x3^2);

% calculate alpha and beta
alpha = atan2(x3,x1);
beta = asin(x2/Va);

% calculate dynamic pressure
Q = 0.5*rho*Va^2;

% define the vectors wbe_b and V_b
wbe_b = [x4;x5;x6];
V_b = [x1;x2;x3];

% ----------------- step 3. aerodynamic force coefficients ----------------

% calculate CL_wb (wing body)
if alpha<=alpha_switch
    CL_wb = n*(alpha - alpha_L0);
else
    CL_wb = a3*alpha^3 + a2*alpha^2 + a1*alpha + a0;
end

% calculate CL_t (tail)
epsilon = depsda*(alpha - alpha_L0);
alpha_t = alpha - epsilon + u2 + 1.3*x5*lt/Va;
CL_t = 3.1*(St/S)*alpha_t;

% total lift force coefficient
CL = CL_wb + CL_t;

% total drag force (neglecting tail)
CD = 0.13 + 0.07*(5.5*alpha + 0.654)^2;

% calculate sideforce
CY = -1.6*beta + 0.24*u3;

% ----------------- step 4. dimensional aerodynamic forces ----------------

% calculate the actual dimensional forces in Fs (stability axis)
FA_s = [-CD*Q*S;
         CY*Q*S;
        -CL*Q*S];

% rotate these forces to Fb (body axis)
C_bs = [cos(alpha) 0 -sin(alpha);
        0 1 0;
        sin(alpha) 0 cos(alpha)];

FA_b = C_bs*FA_s;

% ---- step 5. aerodynamic moment coefficient about aerodynamic center ----

% calculate the moment in Fb (body axis), define eta, dCMdx and dCMdu

eta11 = -1.4*beta;
eta21 = -0.59 - (3.1*(St*lt)/(S*cbar))*(alpha - epsilon);
eta31 = (1 - alpha*(180/(15*pi)))*beta;

eta = [eta11;
       eta21;
       eta31];

dCMdx = (cbar/Va)*[-11 0 5;
                    0 (-4.03*(St*lt^2)/(S*cbar^2)) 0;
                    1.7 0 -11.5];

dCMdu = [-0.6 0 0.22;
          0 (-3.1*(St*lt)/(S*cbar)) 0;
          0 0 -0.63];

% calculate CM = [Cl;Cm;Cn] about aerodynamic center in Fb
CMac_b = eta + dCMdx*wbe_b + dCMdu*[u1;u2;u3];

% ---------- step 6. aerodynamic moment about aerodynamic center ----------

% normalize to an aerodynamic moment
MAac_b = CMac_b*Q*S*cbar;

% ----------- step 7. aerodynamic moment about center of gravity ----------

% transfer moment to center of gravity
rcg_b = [Xcg;Ycg;Zcg];
rac_b = [Xac;Yac;Zac];
MAcg_b = MAac_b + cross(FA_b,rcg_b - rac_b);

% -------------------- step 8. engine force and moment --------------------

% calculate the thrust of each engine
F1 = u4*m*g;
F2 = u5*m*g;

% assuming that engine thrust is aligned with Fb,
FE1_b = [F1;0;0];
FE2_b = [F2;0;0];
FE_b = FE1_b + FE2_b;

% engine moment due to offset of engine thrust from center of gravity
mew1 = [Xcg - Xapt1;
        Yapt1 - Ycg;
        Zcg - Zapt1];
mew2 = [Xcg - Xapt2;
        Yapt2 - Ycg;
        Zcg - Zapt2];
MEcg1_b = cross(mew1,FE1_b);
MEcg2_b = cross(mew2,FE2_b);
MEcg_b = MEcg1_b + MEcg2_b;

% ------------------------ step 9. gravity effects-- ----------------------

% calculate gravitational forces in the body frame, no moment about center
% of gravity

g_b = [-g*sin(x8); 
        g*cos(x8)*sin(x7);
        g*cos(x8)*cos(x7)];
Fg_b = m*g_b;

% ----------------------- step 10. state derivatives ----------------------

% inertia matrix
Ib = m*[40.07 0 -2.0923;
        0 64 0;
        -2.0923 0 99.92];

% inverse of inertia matrix
% invIb = inv(Ib);
invIb = (1/m)*[0.0249836 0 0.000523151;
               0 0.015625 0;
               0.000523151 0 0.010019];

% form all the forces in Fb and calculate udot, vdot, wdot
F_b = Fg_b + FE_b + FA_b;
x1to3dot = (1/m)*F_b - cross(wbe_b, V_b);

% form all moments about center of gravity in Fb and calculate pdot, qdot,
% rdot
Mcg_b = MAcg_b + MEcg_b;
x4to6dot = invIb*(Mcg_b - cross(wbe_b,Ib*wbe_b));

% calculate phidot, thetadot, and psidot
H_phi = [1 sin(x7)*tan(x8) cos(x7)*tan(x8);
         0 cos(x7) -sin(x7);
         0 sin(x7)/cos(x8) cos(x7)/cos(x8)];
x7to9dot = H_phi*wbe_b;

% place in first order form
Xdot = [x1to3dot
        x4to6dot
        x7to9dot];


end