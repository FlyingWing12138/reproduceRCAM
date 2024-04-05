function [F0] = cost_straight_level (Z)

X = Z(1:9);
U = Z(10:14);

xdot = RCAM(X,U);
theta = X(8);
Va = sqrt (X(1)^2 + X(2)^2 + X(3)^2) ;
alpha = atan2(X(3),X(1));
gam = theta - alpha;

Q = [xdot;
     Va-85;
     gam;
     X(2);
     X(7);
     X(9)];

H = diag(ones(1,14));

F0 = Q'*H*Q;

end
