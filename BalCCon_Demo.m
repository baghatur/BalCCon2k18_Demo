%% Hygiene
clc;clear;close all;
i = 0;

%$ Variables - edit this if you want to change display
orign = [1, 1, 1];      % Origin for displayed Reference Frame
o_len = 5;              % Axis length ( >=1 )

period = 1;             % "Time" factor if needed

arate = [5, 4, 2];      % Angurar rate - can be function of period and counter i
accel = [0, 0, 0];      % Linear acceleration 
vlcty = [0, 0, 0];      % Linear velocity 

scale   = 20;           % Scale of view ( <= 0 self ajdusting )
cycles  = 10;           % Total number of cycles to be executed ( >=1 )

%% Sanity checks and initialization 
if (o_len  < 1)  o_len = 1; endif
if (cycles < 1) cycles = 1; endif

ort_i = orign + [o_len, 0,        0       ];
ort_j = orign + [0,       o_len,  0       ];
ort_k = orign + [0,       0,        o_len ];

trans = [0, 0, 0];

figure();

%% Simulation
for i = 0 : 1 : cycles
  printf("\nSim running [%03d/%03d]", i, cycles);

  %% Rotation
  rot = arate * period;
  orign *= rot3d(rot(1),rot(2),rot(3));              ;
  ort_i *= rot3d(rot(1),rot(2),rot(3));
  ort_j *= rot3d(rot(1),rot(2),rot(3));
  ort_k *= rot3d(rot(1),rot(2),rot(3));

  %% Translation
  accel += [0, 0, 0]; 
  vlcty += accel * period;
  trans += vlcty * period;

  T = [ 1, 0, 0, trans(1);
        0, 1, 0, trans(2);
        0, 0, 1, trans(3)];

  orign = (T * [orign, 1]')';     
  ort_i = (T * [ort_i, 1]')'; 
  ort_j = (T * [ort_j, 1]')';
  ort_k = (T * [ort_k, 1]')';

  %% Arrange date into nicer format
  x = [orign(1), ort_i(1); orign(1), ort_j(1); orign(1), ort_k(1)]';
  y = [orign(2), ort_i(2); orign(2), ort_j(2); orign(2), ort_k(2)]';
  z = [orign(3), ort_i(3); orign(3), ort_j(3); orign(3), ort_k(3)]';

  %% Plot data
  plot3(x, y, z, '-o', "linewidth",6)
  grid on;

  if (scale > 0)
    xlim([-scale, scale]); 
    ylim([-scale, scale]);
    zlim([-scale, scale]);
  endif

  %% Check angles for consistency
  orthogonality = ...
  [acosd(dot (ort_i-orign, ort_j-orign) / (intensity(ort_i-orign) *  intensity(ort_j-orign))),
   acosd(dot (ort_i-orign, ort_k-orign) / (intensity(ort_i-orign) *  intensity(ort_k-orign))),
   acosd(dot (ort_k-orign, ort_j-orign) / (intensity(ort_k-orign) *  intensity(ort_j-orign)))];

  printf("\t Orthogonality: [%f %f %f]", orthogonality(1), orthogonality(2), orthogonality(3)); 

  pause(0.1);
endfor

printf("\n");
disp("Done");


%% Helper Functions
function Tx = rotX(phi)
 Tx =   [1,  0,        0;
         0,  cosd(phi), -sind(phi);
         0,  sind(phi),  cosd(phi)];
         
 return
endfunction

function Ty = rotY(theta)
 Ty =   [cosd(theta),  0, -sind(theta);
         0,            1,  0; 
         sind(theta),  0,  cosd(theta)];
 return
endfunction

function Tz = rotZ(psi)
 Tz =   [cosd(psi), -sind(psi),  0;
         sind(psi),  cosd(psi),  0;
         0,            0,            1];
 return
endfunction

function Tr = rot3d(phi, theta, psi)
 Tr = rotZ(psi) * rotY(theta) * rotX(phi);
 return
endfunction

function Projection = projectB2A(A, B)
 Projection = A * A' * B;
 return
endfunction  
function Intensity = intensity(A);  
 Intensity = sqrt(A(1)^2 + A(2)^2 + A(3)^2);
 return
endfunction