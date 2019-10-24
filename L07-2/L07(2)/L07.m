clear; close all; clc
% 啸叫检测方法参考了论文《基于DSP的啸叫抑制系统的研究与实现》：
% 求取每帧候选啸叫频点的峰均值功率比（PARP），分析其是否有上升趋势且是否超出阈值，作为是否啸叫的判据，
% 根据啸叫频点更新陷波器组。
% 但是可能是阈值选取的经验不足和判断上升取的帧数不够，所以滤得有点过了......
% （也看过GitHub上别人的做法，是直接用了两个固定啸叫频点的陷波器，有点不太懂为什么是固定的......）
% 经验不足只能给老师交上一份有缺陷的答卷，非常抱歉orz

[x,fs] = audioread('man.wav');
% x = x(1:fs);
g = load('path.txt');

K = 0.2;                                    % 增益

g = g(:);                                   % 反馈声学路径g
c = [0, 0, 0, 0, 1]';                       % 扩音系统内部传递路径c：简单纯时延代替

xs1 = zeros(size(c));
xs2 = zeros(size(g));

y = zeros(size(x));                         % 先分配y空间，避免运行中临时分配空间占用大量的运算量
temp = 0;

N = 1024;                                   % 帧长
M = N/2;                                    % 帧移
xs = zeros(1, N);                           % 啸叫检测缓存区
win = blackman(length(xs));              	% 加窗
num = [1,0,0]';den=[1,0,0]';                % 陷波器初始化

% 啸叫检测参数初始化
k = 5;                                      % 候选频率点个数k
loc = ones(k, 1);                           % 初始候选频率点位置     
pa = zeros(k, 1);                           % 初始化峰均值功率比


for i = 1: length(x)                        
    % 卷积形成反馈回路
    xs1 = [x(i) + temp; xs1(1: end - 1)];   % 等待与c卷积的信号缓存

    y(i) = xs1'*c;                        % 馈给扬声器的信号
    
    y(i) = min(1, y(i));                   % 幅度约束，啸叫则出现截止
    y(i) = max(-1, y(i));
    
    % 啸叫检测
    if i/M == fix(i/M)                     
        xs = [xs1(1: end); xs2(1: N - size(xs1))];   % 存储待啸叫检测数据
        xs_mag = abs(fft(win.*xs));         % fft变换的幅度谱
        pa0 = parp(loc, xs_mag);            % 新的一帧频谱中，原候选频率点的parp值
        p = find((pa0 > pa).*(pa > -1e13) == 1);  % 找出候选频点中功率连续上升的频点 
        % 陷波处理
        if isempty(p) == 0
            num = [1,0,0]'; den=[1,0,0]';   % 陷波器初始化后更新
            f0 = p*fs/N;
            for j = 1: length(p)
                [num1, den1] = trapper(f0(j), fs, N);
                num = conv(num, num1);
                den = conv(den, den1);
            end
        end
        % 更新数据
        [~, loc] = sort(xs_mag(1: ceil(length(xs)/2)), 'descend'); % 找出该帧功率谱最大k个频点f0(f0 = loc1(1: k)*fs/length(xs);) 
        loc = loc(1: k);
        pa = pa0;
    end
    
    y(i) = K*filter(num, den, y(i));
    % 反馈声
    
    xs2 = [y(i); xs2(1: end-1)];            % 等待与g卷积的信号缓存
    temp = xs2'*g;                          % temp作为单样点缓存，待下一采样点处理时与输入信号混合  

end
plot(y)


