% H.P.Duan; hpduan2000@csu.edu.cn
clear
clc
sPeriod = load('sPeriod.txt');
[PSA_ANR_100, PSV_ANR_100, a_ANR_100] = FD_alterPar_Ap(100);
[PSA_ANR_150, PSV_ANR_150, a_ANR_150] = FD_alterPar_Ap(150);
[PSA_ANR_200, PSV_ANR_200, a_ANR_200] = FD_alterPar_Ap(200);
[PSA_ANR_250, PSV_ANR_250, a_ANR_250] = FD_alterPar_Ap(250);
%%
figure('Name','Ap变参的伪加速度谱')
T1 = 2.11;
plot(sPeriod, PSA_ANR_100/9.8,'-','LineWidth',2,'Color','#A2142F')
hold on
plot(sPeriod, PSA_ANR_150/9.8,'-','LineWidth',2,'Color','#4DBEEE')
plot(sPeriod, PSA_ANR_200/9.8,'-','LineWidth',2,'Color','#77AC30')
plot(sPeriod, PSA_ANR_250/9.8,'-','LineWidth',2,'Color','#7E2F8E')
loglog([T1 T1],[0.01 100],'k--','LineWidth',2)
ax = gca;
ax.XLim = [0,20];
ax.XTick = (0:4:20);
ax.YLim = [0,1];
ax.YTick = (0:0.2:1);
set(gca,'fontsize',20); 
set(gca,'Fontname','Times New Roman');
grid on
box on
xlabel('Period (s)');  % x轴名
ylabel('PSA (g)');  % y轴名
legend('$\it{A_{p}}\rm{ = 100 cm/s}$','$\it{A_{p}}\rm{ = 150 cm/s}$','$\it{A_{p}}\rm{ = 200 cm/s}$','$\it{A_{p}}\rm{ = 250 cm/s}$',...
    'Interpreter','latex','FontName','Times New Roman','Location','northeast','FontSize',15)
set(gca,'looseInset',[0 0 0 0])	%去掉白色边框
set(gcf,'unit','centimeters','position',[15 10 14 8])
%%
% cai bo
path = 'D:\desktop\pulseparameter\fd\ap250\';
needcut_wave = a_ANR_250/9.8;
dt = 0.005;
[PGA, Ds5, Ds75, Ds95] = intensityCalculate(needcut_wave, dt, 'g', 0.05, 2.11, 0.05);

acc_5_95 = needcut_wave(Ds5/dt : Ds95/dt);

for i = 1:length(acc_5_95)
    time(i,:) = dt*i;
end
writematrix(num2str(time,'%16.6E'), [path,'TIME.txt'])
writematrix(num2str(acc_5_95,'%16.6E'), [path,'GM_Y.txt'])
% writematrix(num2str(acc_5_95*0.8,'%16.6E'), [path,'GM_X.txt'])
% writematrix(num2str(acc_5_95*0.65,'%16.6E'), [path,'GM_Z.txt'])

%%
function [PSA_ANR, PSV_ANR, a_ANR] = FD_alterPar_Ap(Ap)
    % ..........(1) 读取地震波从peer
    path = 'D:\HPduan\FD and FS pulse\FD-5\';
    fileName_acc = 'RSN1529_CHICHI_TCU102-E.AT2';
    fileName_vel = 'RSN1529_CHICHI_TCU102-E.VT2';
    [acc_series, dt, ~, ~] = getAmpDtPEER(path, fileName_acc);
    [vel_series, ~, ~, ~] = getAmpDtPEER(path, fileName_vel);
    
    % ..........(2) 分解高频底波BGR和低频脉冲PTR
    Tp = 9.632;
    alpha_1 = 0.65;
    [v_PTR, v_BGR] = FourthButterworth(vel_series, dt, Tp, alpha_1);
    
    % ..........(3) 人工低频脉冲APTR
    % Ap = -66;        % 脉冲幅值
    fp = 1/Tp;       % 数字脉冲频率
    t0 = 38.9;       % 数字脉冲幅值出现的时间
    gama = 1.5;     % 随机参数
    phase = 290;    % 相位
    v_APTR = SynthesisPulse(vel_series, dt, Ap, fp, t0, gama, phase);
    
    % ..........(4) 人工波合成
    v_OR = vel_series;              % cm/s
    a_OR = acc_series;              % g
    v_ANR =  v_BGR + v_APTR;        % cm/s
    a_ANR = (diff(v_ANR)/dt)*1e-2;  % m/s2
    
    % ..........(5) 伪反应谱
    sPeriod = load('sPeriod.txt');
    [PSA_ANR, PSV_ANR, ~, ~, ~, ~] = SpectrumGMs(0.05, sPeriod, a_ANR, dt);        % 人工波的伪加速度谱和伪速度谱
end
