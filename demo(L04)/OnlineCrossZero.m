clc;
close all;
clear all;

[x,fs] = audioread('sample.wav');
resample(x,fs,16e3);                    % 建立待分析信号
fs = 16e3;                              % 重定义采样率
x =  x + 0.001*randn(size(x));

x(1:0.6*fs) = [];
x(end-1.5*fs:end) = [];

% x = x + sin(2*pi*5000/fs*(1:length(x))')*0.05;

frame_length = 1024;                    % 设定帧长
frame_move = 64;                        % 设定帧移
phi = 0;

i = 0;                                  % 数据下标索引

win = hamming(frame_length);            % 建立窗函数，长度等于帧长
xs = zeros(frame_length, 1);            % 开辟数据缓存
xt = xs;

x_freq = zeros(frame_length/2+1, 1);    % 设定频谱分析结果缓存，长度约是帧长的一半
x_freq_log = x_freq;

c = NaN(floor(length(x)/frame_move),1); %记录过零结果
ic = 1;                                 %记录帧移次数，帧移一次运算一次

figure
%zero cross rate
subplot('Position',[0.1,0.6,0.8,0.3])
h1 = plot((1:length(c))/fs*frame_move,c);
axis([0,length(c)/fs*frame_move,0,1])
%xs
subplot('Position',[0.1,0.35,0.8,0.2])
h4 = plot(1:frame_length, xs);
% axis([1,frame_length,-0.9,0.9])
%x
xlim([1,frame_length])
subplot('Position',[0.1,0.1,0.8,0.2])
hold on
h2 = plot((1:length(x))/fs,x);      % 作图，动画效果，注意横坐标的取值
h3 = plot([i/fs, i/fs],[-1.5,1.5],'r','LineWidth',2);
box on
hold off
axis([0,length(x)/fs,-0.9,0.9])

set(h1,'YDataSource', 'c')
set(h4,'YDataSource', 'xs')
set(h3,'XDataSource', '[i/fs, i/fs]')


while (i+frame_length<=length(x))           % 循环处理，直至到无数据可读
    xs = [xs(frame_move+1:frame_length); x(i+1:i+frame_move)];  % 更新数据缓存，注意帧长和争议所起的角色
    
    c(ic) = sum(abs(sign(xs(1:end-1))-sign(xs(2:end)))/2)/length(xs);
    
    i = i + frame_move;                 % 更新数据下标，为下一次循环作准备
    ic = ic + 1;

    refreshdata(h1,'caller');
    refreshdata(h4,'caller');
    refreshdata(h3,'caller');
    drawnow; pause(0.05);
end

