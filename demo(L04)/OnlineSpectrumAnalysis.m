clc;
close all;
clear all;

[x,fs] = audioread('sample.wav');
resample(x,fs,16e3);                    % 建立待分析信号
fs = 16e3;                              % 重定义采样率
x = x + randn(size(x))*0.001;
x(1:0.6*fs) = [];
x(end-1.5*fs:end) = [];
% h = fir2(40,[0,0.4,0.5,1],[1,1,0,0]);
% x = filter(h,1,randn(20000,1));       

frame_length = 1024;                     % 设定帧长
frame_move = 32;                        % 设定帧移
phi = 0;

i = 0;                                  % 数据下标索引

win = hamming(frame_length);            % 建立窗函数，长度等于帧长
xs = zeros(frame_length, 1);            % 开辟数据缓存

x_freq = zeros(frame_length/2+1, 1);    % 设定频谱分析结果缓存，长度约是帧长的一半
x_freq_log = x_freq;

figure
subplot('Position',[0.1,0.4,0.8,0.5])
h1 = plot((0:frame_length/2)/frame_length*fs, x_freq_log);
axis([0,fs/2,-40,35])
subplot('Position',[0.1,0.1,0.8,0.2])
hold on
h2 = plot((1:length(x))/fs,x);      % 作图，动画效果，注意横坐标的取值
h3 = plot([i/fs, i/fs],[-1.5,1.5],'r','LineWidth',2);
box on
hold off
axis([0,length(x)/fs,-0.9,0.9])

set(h1,'YDataSource', 'x_freq_log')
set(h3,'XDataSource', '[i/fs, i/fs]')

while (i+frame_move<=length(x))           % 循环处理，直至到无数据可读
    xs = [xs(frame_move+1:frame_length); x(i+1:i+frame_move)];  % 更新数据缓存，注意帧长和争议所起的角色
    temp = fft(xs.*win);                % 加窗函数并做FFT
    temp = temp(1:frame_length/2+1);    % 保留约一半的数据
    x_freq = x_freq * phi + abs(temp).^2 * (1-phi); % 更新分析结果，采用平滑遗忘因子对过去数据进行加权
    x_freq_log = 10*log10(x_freq);
    i = i + frame_move;                 % 更新数据下标，为下一次循环作准备

    refreshdata(h1,'caller');
%     refreshdata(h2,'caller');
    refreshdata(h3,'caller');
    drawnow; pause(0.5*frame_move/frame_length);
end

