% H.P.Duan; hpduan2000@csu.edu.cn
clear
clc
% ..........(1) 读取地震波从peer
path = 'D:\HPduan\FD and FS pulse\FS-3\';
fileName_acc = 'RSN1148_KOCAELI_ARE090.AT2';
fileName_vel = 'RSN1148_KOCAELI_ARE090.VT2';
fileName_dis = 'RSN1148_KOCAELI_ARE090.DT2';
[acc_series, dt, ~, ~] = getAmpDtPEER(path, fileName_acc);
[vel_series, ~, ~, ~] = getAmpDtPEER(path, fileName_vel);
[dis_series, ~, ~, ~] = getAmpDtPEER(path, fileName_dis);
%%
figure
plot((1:length(acc_series))*dt, acc_series,'-','LineWidth',2,'Color','#A2142F')
ax = gca;
ax.YLim = [-0.2,0.2];
ax.YTick = (-0.2:0.1:0.2);
ax.XLim = [0,30];
ax.XTick = (0:5:30);
set(gca,'fontsize',20); 
set(gca,'Fontname','Times New Roman');
grid on
box on
xlabel('Time (s)');  % x轴名
ylabel('Acceleration (g)');  % y轴名
set(gca,'looseInset',[0 0 0 0])	%去掉白色边框
set(gcf,'unit','centimeters','position',[15 10 14 8])
%
figure
plot((1:length(vel_series))*dt, vel_series,'-','LineWidth',2,'Color','#A2142F')
ax = gca;
ax.YLim = [-60,60];
ax.YTick = (-60:30:60);
ax.XLim = [0,30];
ax.XTick = (0:5:30);
set(gca,'fontsize',20); 
set(gca,'Fontname','Times New Roman');
grid on
box on
xlabel('Time (s)');  % x轴名
ylabel('Velocity (cm/s)');  % y轴名
set(gca,'looseInset',[0 0 0 0])	%去掉白色边框
set(gcf,'unit','centimeters','position',[15 10 14 8])
%
figure
plot((1:length(dis_series))*dt, dis_series,'-','LineWidth',2,'Color','#A2142F')
ax = gca;
ax.YLim = [-40,40];
ax.YTick = (-40:20:40);
ax.XLim = [0,30];
ax.XTick = (0:5:30);
set(gca,'fontsize',20); 
set(gca,'Fontname','Times New Roman');
grid on
box on
xlabel('Time (s)');  % x轴名
ylabel('Displacement (cm)');  % y轴名
set(gca,'looseInset',[0 0 0 0])	%去掉白色边框
set(gcf,'unit','centimeters','position',[15 10 14 8])
%% ..........(2) 分解高频底波BGR和低频脉冲PTR
Tp = 7.791;
alpha_1 = 0.25;
[v_PTR, v_BGR] = FourthButterworth(vel_series, dt, Tp, alpha_1);
% figure
% plot((1:length(v_PTR))*dt, v_PTR,'-','LineWidth',2,'Color','#4DBEEE')
% hold on
% plot((1:length(v_BGR))*dt, v_BGR,'--','LineWidth',2,'Color','#4DBEEE')
% ax = gca;
% ax.YLim = [-0.2,0.2];
% ax.YTick = (-0.2:0.1:0.2);
% ax.XLim = [0,30];
% ax.XTick = (0:5:30);
% set(gca,'fontsize',20); 
% set(gca,'Fontname','Times New Roman');
% grid on
% box on
% xlabel('Time (s)');  % x轴名
% ylabel('Velocity (cm/s)');  % y轴名
% set(gca,'looseInset',[0 0 0 0])	%去掉白色边框
% set(gcf,'unit','centimeters','position',[15 10 14 8])
% legend('PTR','BGR')
%% ..........(3) 人工低频脉冲APTR
Ap = 38.5;        % 脉冲幅值
fp = 1/Tp;       % 数字脉冲频率
t0 = 15.5;       % 数字脉冲幅值出现的时间
gama = 1.5;     % 随机参数
phase = 225;    % 相位
v_APTR = SynthesisPulse(vel_series, dt, Ap, fp, t0, gama, phase);
%% ..........(4) 人工波合成
v_OR = vel_series;              % cm/s
a_OR = acc_series;              % g
v_ANR =  v_BGR + v_APTR;        % cm/s
a_ANR = (diff(v_ANR)/dt)*1e-2;  % m/s2
a_PTR = (diff(v_PTR)/dt)*1e-2;
a_APTR = (diff(v_APTR)/dt)*1e-2;
%% ..........(5) 伪反应谱
sPeriod = load('sPeriod.txt');
% [PSA_OR, PSV_OR, ~, ~, ~, ~] = SpectrumGMs(0.05, sPeriod, a_OR * 9.8, dt);     % 原波的伪加速度谱和伪速度谱
% [PSA_ANR, PSV_ANR, ~, ~, ~, ~] = SpectrumGMs(0.05, sPeriod, a_ANR, dt);        % 人工波的伪加速度谱和伪速度谱
[PSA_PTR, PSV_PTR, ~, ~, ~, ~] = SpectrumGMs(0.05, sPeriod, a_PTR, dt);
[PSA_APTR, PSV_APTR, ~, ~, ~, ~] = SpectrumGMs(0.05, sPeriod, a_APTR, dt);
%% ..........(6) 绘图
figure('Name','PTR和APTR的伪速度谱')
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
xlabel('Period (s)');  % x轴名
ylabel('PSV (cm/s)');  % y轴名
legend('$\it{v_{PTR}}\rm{(}\it{t}\rm{)}$','$\it{v_{APTR}}\rm{(}\it{t}\rm{)}$', ...
    'Interpreter','latex','FontName','Times New Roman','Location','northeast')
set(gca,'looseInset',[0 0 0 0])	%去掉白色边框
set(gcf,'unit','centimeters','position',[15 10 14 8])
%
figure('Name','OR和ANR时程曲线')
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
xlabel('Time (s)');  % x轴名
ylabel('Velocity (cm/s)');  % y轴名
legend('$\it{v_{OR}}\rm{(}\it{t}\rm{)}$','$\it{v_{ANR}}\rm{(}\it{t}\rm{)}$', ...
    'Interpreter','latex','FontName','Times New Roman','Location','northeast')
set(gca,'looseInset',[0 0 0 0])	%去掉白色边框
set(gcf,'unit','centimeters','position',[15 10 14 8])
%
% figure('Name','PTR和APTR时程曲线')
% plot((1:length(v_PTR)).*dt,v_PTR,'-','LineWidth',2,'Color','#A2142F')
% hold on
% plot((1:length(v_APTR)).*dt,v_APTR,'-','LineWidth',2,'Color','#4DBEEE')
% ax = gca;
% ax.YLim = [-40,40];
% set(gca,'fontsize',20); 
% set(gca,'Fontname','Times New Roman');
% grid on
% box on
% xlabel('Time (s)');  % x轴名
% ylabel('Velocity (cm/s)');  % y轴名
% legend('PTR','APTR','FontName','Times New Roman','Location','southeast')
% set(gca,'looseInset',[0 0 0 0])	%去掉白色边框
%% ..........(7) 裁波
% T1 = 2.1;  % 结构基本周期
% [PGA_OR, Ds5_OR, Ds75_OR, Ds95_OR] = intensityCalculate(a_OR, dt, 'g', 0.05, T1, 0.05);
% [PGA_ANR, Ds5_ANR, Ds75_ANR, Ds95_ANR] = intensityCalculate(a_ANR * 1e2, dt, 'cm/s^2', 0.05, T1, 0.05);
% a_OR_5_75 = a_OR(Ds5_OR/dt : Ds75_OR/dt);
% a_ANR_5_75 = a_ANR(Ds5_ANR/dt : Ds75_ANR/dt);
%% ..........(8) 输出三向地震动1:0.8:0.65
% writematrix(a_ANR_5_75, [path,'ANR_AY.txt'])
% writematrix(a_ANR_5_75*0.8, [path,'ANR_AX.txt'])
% writematrix(a_ANR_5_75*0.65, [path,'ANR_AZ.txt'])
