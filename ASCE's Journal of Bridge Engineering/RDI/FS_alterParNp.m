% H.P.Duan; hpduan2000@csu.edu.cn
clear
clc
sPeriod = load('sPeriod.txt');
T1 = 2.11;
[PSA_ANR_2, PSV_ANR_2, a_ANR_2, v_APTR_2, v_ANR_2] = FS_alterPar_Np(1,40);
[PSA_ANR_3, PSV_ANR_3, a_ANR_3, v_APTR_3, v_ANR_3] = FS_alterPar_Np(2,10);
[PSA_ANR_4, PSV_ANR_4, a_ANR_4, v_APTR_4, v_ANR_4] = FS_alterPar_Np(2.5,100); %2.5 90
[PSA_ANR_5, PSV_ANR_5, a_ANR_5, v_APTR_5, v_ANR_5] = FS_alterPar_Np(3.5,0);
% subplot(4,1,1)
% plot((1:length(v_APTR_2))*0.005,v_APTR_2)
% subplot(4,1,2)
% plot((1:length(v_APTR_2))*0.005,v_APTR_3)
% subplot(4,1,3)
% plot((1:length(v_APTR_2))*0.005,v_APTR_4)
% subplot(4,1,4)
% plot((1:length(v_APTR_2))*0.005,v_APTR_5)
%%
figure('Name','Np变参的伪加速度谱')
plot(sPeriod, PSA_ANR_2/9.8,'-','LineWidth',2,'Color','#A2142F')
hold on
plot(sPeriod, PSA_ANR_3/9.8,'-','LineWidth',2,'Color','#4DBEEE')
plot(sPeriod, PSA_ANR_4/9.8,'-','LineWidth',2,'Color','#77AC30')
plot(sPeriod, PSA_ANR_5/9.8,'-','LineWidth',2,'Color','#7E2F8E')
loglog([T1 T1],[0.01 100],'k--','LineWidth',2)
ax = gca;
ax.XLim = [0,20];
ax.XTick = (0:4:20);
ax.YLim = [0,0.5];
ax.YTick = (0:0.1:0.5);
set(gca,'fontsize',20); 
set(gca,'Fontname','Times New Roman');
grid on
box on
xlabel('Period (s)');  % x轴名
ylabel('PSA (g)');  % y轴名
legend('$\it{N}\rm{ = 2}, \it{\gamma}\rm{ = 1.0}, \it{\phi}\rm{ = 40}$', ...
    '$\it{N}\rm{ = 3}, \it{\gamma}\rm{ = 2.0}, \it{\phi}\rm{ = 10}$', ...
    '$\it{N}\rm{ = 4}, \it{\gamma}\rm{ = 2.5}, \it{\phi}\rm{ = 100}$', ...
    '$\it{N}\rm{ = 5}, \it{\gamma}\rm{ = 3.5}, \it{\phi}\rm{ = 0}$', ...
    'Interpreter','latex','FontName','Times New Roman','Location','northeast','NumColumns',1,'FontSize',15)
set(gca,'looseInset',[0 0 0 0])	%去掉白色边框
set(gcf,'unit','centimeters','position',[15 10 14 8])
%%
% cai bo
path = 'D:\desktop\pulseparameter\fs\n5\';
needcut_wave = a_ANR_5/9.8;
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
function [PSA_ANR, PSV_ANR, a_ANR, v_APTR, v_ANR] = FS_alterPar_Np(gama, phase)
    % ..........(1) 读取地震波从peer
    path = 'D:\HPduan\FD and FS pulse\FS-3\';
    fileName_acc = 'RSN1148_KOCAELI_ARE090.AT2';
    fileName_vel = 'RSN1148_KOCAELI_ARE090.VT2';
    [acc_series, dt, ~, ~] = getAmpDtPEER(path, fileName_acc);
    [vel_series, ~, ~, ~] = getAmpDtPEER(path, fileName_vel);
    
    % ..........(2) 分解高频底波BGR和低频脉冲PTR
    Tp = 7.791;
    alpha_1 = 0.25;
    [v_PTR, v_BGR] = FourthButterworth(vel_series, dt, Tp, alpha_1);
    
    %..........(3) 人工低频脉冲APTR
    Ap = 38.5;        % 脉冲幅值
    fp = 1/Tp;       % 数字脉冲频率
    t0 = 15.5;       % 数字脉冲幅值出现的时间
    % gama = 1;     % 随机参数
    % phase = 257;    % 相位487
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
