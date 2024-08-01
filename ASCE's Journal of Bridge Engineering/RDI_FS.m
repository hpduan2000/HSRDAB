% Written by H.P.Duan; hpduan2000@csu.edu.cn
clear
clc
%% ..........(1) load ground motion
path = 'D:\HPduan\FD and FS pulse\FS-3\';
fileName_acc = 'RSN1148_KOCAELI_ARE090.AT2';
fileName_vel = 'RSN1148_KOCAELI_ARE090.VT2';
fileName_dis = 'RSN1148_KOCAELI_ARE090.DT2';
[acc_series, dt, ~, ~] = getAmpDtPEER(path, fileName_acc);
[vel_series, ~, ~, ~] = getAmpDtPEER(path, fileName_vel);
[dis_series, ~, ~, ~] = getAmpDtPEER(path, fileName_dis);
%% ..........(2) BGR and PTR
Tp = 7.791;
alpha_1 = 0.25;
[v_PTR, v_BGR] = FourthButterworth(vel_series, dt, Tp, alpha_1);
%% ..........(3) APTR
Ap = 38.5;
fp = 1/Tp;
t0 = 15.5;
gama = 1.5;
phase = 225;
v_APTR = SynthesisPulse(vel_series, dt, Ap, fp, t0, gama, phase);
%% ..........(4) ANR
v_OR = vel_series;              % cm/s
a_OR = acc_series;              % g
v_ANR =  v_BGR + v_APTR;        % cm/s
a_ANR = (diff(v_ANR)/dt)*1e-2;  % m/s2
a_PTR = (diff(v_PTR)/dt)*1e-2;
a_APTR = (diff(v_APTR)/dt)*1e-2;
%% ..........(5) PSA and PSV
sPeriod = load('sPeriod.txt');
[PSA_PTR, PSV_PTR, ~, ~, ~, ~] = SpectrumGMs(0.05, sPeriod, a_PTR, dt);
[PSA_APTR, PSV_APTR, ~, ~, ~, ~] = SpectrumGMs(0.05, sPeriod, a_APTR, dt);
%% ..........(6) plot
figure('Name','The PSVs of PTR and APTR')
plot(sPeriod, PSV_PTR*100,'-','LineWidth',2,'Color','#A2142F')
hold on
plot(sPeriod, PSV_APTR*100,'-','LineWidth',2,'Color','#4DBEEE')
ax = gca;
ax.XLim = [0,20];
ax.XTick = (0:4:20);
ax.YLim = [0,80];
ax.YTick = (0:20:80);
set(gca,'fontsize',20); 
set(gca,'Fontname','Times New Roman');
grid on
box on
xlabel('Period (s)');
ylabel('PSV (cm/s)');
legend('\itv_{PTR}\rm(\itt\rm)','\itv_{APTR}\rm(\itt\rm)','FontName','Times New Roman','Location','northeast')
set(gca,'looseInset',[0 0 0 0])
set(gcf,'unit','centimeters','position',[15 10 14 8])

figure('Name','The time-history of OR and ANR')
plot((1:length(v_OR)).*dt,v_OR,'-','LineWidth',2,'Color','#A2142F')
hold on
plot((1:length(v_ANR)).*dt,v_ANR,'-','LineWidth',2,'Color','#4DBEEE')
ax = gca;
ax.XLim = [0,30];
ax.XTick = (0:5:30);
ax.YLim = [-60,60];
ax.YTick = (-60:30:60);
set(gca,'fontsize',20); 
set(gca,'Fontname','Times New Roman');
grid on
box on
xlabel('Time (s)');
ylabel('Velocity (cm/s)');
legend('\itv_{OR}\rm(\itt\rm)','\itv_{ANR}\rm(\itt\rm)','FontName','Times New Roman','Location','northeast')
set(gca,'looseInset',[0 0 0 0])
set(gcf,'unit','centimeters','position',[15 10 14 8])
