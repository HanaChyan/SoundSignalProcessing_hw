clc;
close all;
clear all;

[x,fs] = audioread('sample_test_32k_16bit.wav');
resample(x,16e3,fs);                    % 建立待分析信号
fs = 16e3;                              % 重定义采样率
x = x + randn(size(x))*0.001;           % 加入适量的本底噪声
x(1:0.6*fs) = [];                       % 去除音频前后的无效数据clc
x(end-1.5*fs:end) = [];


frame_length = 0.03*fs;                   % 请在此处设定帧长（由宋知用老师的书得知帧长选择一般在10ms~30ms）
frame_move = 0.008*fs;                     % 请在此处设定帧移
phi = 0;

i = 0;                                  % 数据下标索引

win = hamming(frame_length);            % 建立窗函数，长度等于帧长
xs = zeros(frame_length, 1);            % 开辟数据缓存

x_freq = zeros(frame_length/2 + 1, 1);    % 设定频谱分析结果缓存，长度约是帧长的一半
x_freq_log = x_freq;

figure
subplot('Position',[0.1,0.4,0.8,0.5])
h1 = plot((0: frame_length/2)/frame_length*fs, x_freq_log);
axis([0, fs/2, -40, 35])

subplot('Position',[0.1,0.1,0.8,0.2])
hold on
h2 = plot((1: length(x))/fs,x);      % 作图，动画效果，注意横坐标的取值
h3 = plot([i/fs, i/fs],[-1.5, 1.5], 'r', 'LineWidth', 2); %bar
box on
hold off
axis([0, length(x)/fs, -0.9, 0.9])

set(h1,'YDataSource', 'x_freq_log')
set(h3,'XDataSource', '[i/fs, i/fs]')

while (i + frame_length<=length(x))           % 循环处理，直至到无数据可读
% 请在此处填写代码
    xs = x(i + 1: i + frame_length);
    x_temp = xs.* win;
    x_temp = real(fft(x_temp));
    x_freq_log = x_temp(1: 1 + frame_length/2);
    
    i = i + frame_move;                 % 更新数据下标，为下一次循环作准备

    refreshdata(h1,'caller');
    refreshdata(h3,'caller');
    drawnow; pause(0.5*frame_move/frame_length);
end

