%原理：利用能量检测进行初步判断，再利用过零率进行筛选。
%当过零率与短时平均能量均符合严格条件时，直接判定为语音；当仅符合宽条件时，往后计算4帧，若均符合宽平稳条件则仍可判定为语音
clc;
close all;
clear all;

[x,fs] = audioread('sample.wav');
resample(x,fs,16e3);                    % 建立待分析信号
fs = 16e3;                              % 重定义采样率
x =  x + 0.001*randn(size(x));
x(1:0.6*fs) = [];
x(end-1.5*fs:end) = [];

frame_length = 1024;                    % 设定帧长
frame_move = 64;                         % 设定帧移
phi = 0;
i = 0;                                  % 数据下标索引

win = hamming(frame_length);            % 建立窗函数，长度等于帧长
xs = zeros(frame_length, 1);            % 开辟数据缓存
xt = xs;

E0 = 2*sum((x(1: frame_length).*win).^2)    %计算第一帧噪声的平均能量，设定能量值判定下限
zcr0 = 0.49;                                %过零率上限
zcr1 = 0.14;                                %过零率下限


x_freq = zeros(frame_length/2+1, 1);    % 设定频谱分析结果缓存，长度约是帧长的一半
x_freq_log = x_freq;

energy = NaN(floor(length(x)/frame_move), 1); %记录短时能量结果
zcr = NaN(floor(length(x)/frame_move), 1);    %记录过零结果
x_selected = ones(length(x), 1);              %存储被判别为语音的数据
ie = 1;                                       %记录帧移次数，帧移一次运算一次

figure
%average energy
subplot('Position', [0.1, 0.65, 0.8, 0.25])
h1 = plot((1: length(energy))/fs*frame_move, energy);
axis([0, length(energy)/fs*frame_move, 0, 30])
%zcr
hold on
subplot('Position',[0.1, 0.35, 0.8, 0.25])
h4 = plot((1: length(zcr))/fs*frame_move, zcr);
axis([0, length(zcr)/fs*frame_move, 0, 1])
%x
subplot('Position',[0.1,0.1,0.8,0.2])
hold on
h2 = plot((1:length(x))/fs, x);                
h3 = plot([i/fs, i/fs], [-1.5,1.5], 'r', 'LineWidth', 2);  % 作图，动画效果
h5 = plot((1:length(x))/fs, x_selected, 'r');
box on
hold off
axis([0, length(x)/fs, -0.9, 0.9])

set(h1, 'YDataSource', 'energy')
set(h4, 'YDataSource', 'zcr')
set(h3, 'XDataSource', '[i/fs, i/fs]')
set(h5, 'YDataSource', 'x_selected')


while (i + frame_length <= length(x))           % 循环处理，直至到无数据可读
    xs = [xs(frame_move + 1: frame_length); x(i + 1: i + frame_move)]; % 更新数据缓存
    energy(ie) = sum((xs.*win).^2);
    zcr(ie) = sum(abs(sign(xs(1:end-1))-sign(xs(2:end)))/2)/length(xs);
    
    %判定语音(延迟5帧)
    temp = 0;
    if energy(ie) > E0 && ie > 4
        zcr_test = zcr(ie - 3: ie) ;
        if zcr(ie - 4) < zcr1                  % 严条件：直接判定为语音
            temp = 1;
        elseif zcr(ie - 3) <= zcr0             % 宽条件
            if  ((zcr_test - zcr0*ones(4, 1)) < zeros(4, 1)) == zeros(4, 1)  %回溯前4帧,要求每一帧过零率均低于zcr0
                temp = 1;
            end
        end
    end
    if temp == 1
        x_selected(i + 1 - 4*frame_move: i - 3*frame_move) = x(i + 1 - 4*frame_move: i - 3*frame_move);
    end
    
    i = i + frame_move;                        % 更新数据下标，为下一次循环作准备
    ie = ie + 1;
    
    refreshdata(h1,'caller');
    refreshdata(h4,'caller');
    refreshdata(h3,'caller');
    refreshdata(h5,'caller');
    drawnow; pause(0.05);
end
