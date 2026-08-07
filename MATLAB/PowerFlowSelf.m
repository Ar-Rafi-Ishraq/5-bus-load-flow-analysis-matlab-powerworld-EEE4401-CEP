%% Power Flow code for a 5 Bus Power System by Ar- Rafi Ishraq,ID: 210021330
clear all;
clc;
%% Admitances
% Line Admittances
z12 = 0.02 + j*0.06; y12 = 1/z12;
z13 = 0.08 + j*0.24; y13 = 1/z13;
z23 = 0.06 + j*0.18; y23 = 1/z23;
z24 = 0.06 + j*0.18; y24 = 1/z24;
z25 = 0.04 + j*0.12; y25 = 1/z25;
z34 = 0.01 + j*0.03; y34 = 1/z34;
z45 = 0.08 + j*0.24; y45 = 1/z45;
% Self Admittances
y22 = y12+y23+y24+y25;
y33 = y13+y23+y34;
%% format long
iter = 0;
S4 = -0.5 - j*0.3; % Load demand at Bus-4
S5 = -0.8 - j*0.4; % Load demand at Bus-5
P2 = 0.4-0.4;% Real power demand at Bus-2
P3 = 0.3-0.4;% Real power demand at Bus-3
% Initial Bus Voltage Values
V1 = 1.06 + j*0;  % Constant Voltage 
V2 = 1.045 + j*0; % Real part is constant
V3 = 1.03 + j*0;  % Real part is constant
V4 = 1 + j*0;
V5 = 1 + j*0;
Vm2 = 1.045;
Vm3 = 1.03;
%% Iteration Loop for Gauss-Seidel Method
for I = 1:10       % Loop will do 10 Iterations
    iter = iter+1; % No. of iteration
    E2=V2;
    E3=V3;
    E4=V4;
    E5=V5;
    % Determining Voltage at Bus-5
    V5 = ((conj(S5)/conj(V5))+y25*V2+y45*V4)/(y25+y45);
    DV5=V5-E5;
    % Determining Voltage at Bus-2 
    Q2 = -imag(conj(V2)*(y22*V2-y12*V1-y23*V3-y24*V4-y25*V5));
    S2 = P2 + j*(Q2-0.1);
    Vc2 =((conj(S2)/conj(V2))+y12*V1+y23*V3+y24*V4+y25*V5)/(y22);
    Vi2 = imag(Vc2);
    Vr2 = sqrt(Vm2^2 - Vi2^2);
    V2 = Vr2 + j*Vi2;
    DV2 = V2-E2;
    % Determining Voltage at Bus-4
    V4 = ((conj(S4)/conj(V4))+y24*V2+y34*V3+y45*V5)/(y24+y34+y45);
    DV4 = V4 - E4;
    % Determining Voltage at Bus-3
    Q3 = -imag(conj(V3)*(y33*V3-y13*V1-y23*V2-y34*V4));
    S3 = P3 + j*(Q3-0.15);
    Vc3 =((conj(S3)/conj(V3))+y13*V1+y23*V2+y34*V4)/(y33);
    Vi3 = imag(Vc3);
    Vr3 = sqrt(Vm3^2 - Vi3^2);
    V3 = Vr3 + j*Vi3;
    DV3 = V3-E3;
end
%% Calculation of Currents
I12 = y12*(V1-V2); I21 = -I12;
I13 = y13*(V1-V3); I31 = -I13;
I23 = y23*(V2-V3); I32 = -I23;
I24 = y24*(V2-V4); I42 = -I24;
I25 = y25*(V2-V5); I52 = -I25;
I34 = y34*(V3-V4); I43 = -I34;
I45 = y45*(V4-V5); I54 = -I45;
%% Calculation of Complex Powers
S12=(V1*conj(I12))*100; S21=(V2*conj(I21))*100;
S13=(V1*conj(I13))*100; S31=(V3*conj(I31))*100;
S23=(V2*conj(I23))*100; S32=(V3*conj(I32))*100;
S24=(V2*conj(I24))*100; S42=(V4*conj(I42))*100;
S25=(V2*conj(I25))*100; S52=(V5*conj(I52))*100;
S34=(V3*conj(I34))*100; S43=(V4*conj(I43))*100;
S45=(V4*conj(I45))*100; S54=(V5*conj(I54))*100;
%% Calculation of Power Loss
SL12=S12+S21;
SL13=S13+S31;
SL23=S23+S32;
SL24=S24+S42;
SL25=S25+S52;
SL34=S34+S43;
SL45=S45+S54;
%% Diplay Output
disp('Bus Voltages in p.u. : ')
V1 = abs(V1),V2 = abs(V2),V3 = abs(V3),V4 = abs(V4),V5 = abs(V5)
disp('Power Losses: (units: MW & MVar) ')
SL12,SL13,SL23,SL24,SL25,SL34,SL45
disp('Total Real Power Loss: (MW)')
Ptotal = real(SL12+SL13+SL23+SL24+SL25+SL34+SL45)
disp('Total Reactive Power Loss: (MVar)')
Qtotal = imag(SL12+SL13+SL23+SL24+SL25+SL34+SL45)