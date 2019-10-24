clc;
close all;
clear all;

[x,fs] = audioread('sample.wav');
resample(x,fs,16e3);                    % 建立待分析信号
fs = 16e3;                              % 重定义采样率
% x = x + randn(size(x))*0.001;
x(1:0.6*fs) = [];
x(end-1.5*fs:end) = [];
% h = fir2(40,[0,0.4,0.5,1],[1,1,0,0]);
% x = filter(h,1,randn(20000,1));       

frame_length = 4096;                    % 设定帧长
frame_move = 64;                        % 设定帧移
phi = 0;

i = 0;                                  % 数据下标索引

win = hamming(frame_length);            % 建立窗函数，长度等于帧长
xs = zeros(frame_length, 1);            % 开辟数据缓存
xt = xs;

h = fir2(999,[0,0.125,0.130,1],[1,1,0,0]); h = h(:);
h1 = 2*real(h.*exp(1i*2*pi*(1/16)*(0:length(h)-1)'));
h2 = 2*real(h.*exp(1i*2*pi*(3/16)*(0:length(h)-1)'));
h3 = 2*real(h.*exp(1i*2*pi*(5/16)*(0:length(h)-1)'));
h4 = 2*real(h.*exp(1i*2*pi*(7/16)*(0:length(h)-1)'));

x_freq = zeros(frame_length/2+1, 1);    % 设定频谱分析结果缓存，长度约是帧长的一半
x_freq_log1 = x_freq;
x_freq_log2 = x_freq;
x_freq_log3 = x_freq;
x_freq_log4 = x_freq;

xb1 = filter(h1,1,x);
xb2 = filter(h2,1,x);
xb3 = filter(h3,1,x);
xb4 = filter(h4,1,x);

xbs1 = zeros(frame_length,1);
xbs2 = zeros(frame_length,1);
xbs3 = zeros(frame_length,1);
xbs4 = zeros(frame_length,1);

gcff=figure;
subplot('Position',[0.05,0.8,0.55,0.15])
h11 = plot(1:frame_length, xbs1);
axis([1,frame_length,-max(abs(xb1)),max(abs(xb1))])
set(gca,'xtick',[])
subplot('Position',[0.63,0.8,0.32,0.15])
h12 = plot((0:frame_length/2)/frame_length*fs, x_freq_log1);
axis([0,fs/2,-100,40])
set(gca,'xtick',[])

subplot('Position',[0.05,0.6,0.55,0.15])
h21 = plot(1:frame_length, xbs2);
axis([1,frame_length,-max(abs(xb2)),max(abs(xb2))])
set(gca,'xtick',[])
subplot('Position',[0.63,0.6,0.32,0.15])
h22 = plot((0:frame_length/2)/frame_length*fs, x_freq_log2);
axis([0,fs/2,-100,10])
set(gca,'xtick',[])

subplot('Position',[0.05,0.4,0.55,0.15])
h31 = plot(1:frame_length, xbs3);
axis([1,frame_length,-max(abs(xb3)),max(abs(xb3))])
set(gca,'xtick',[])
subplot('Position',[0.63,0.4,0.32,0.15])
h32 = plot((0:frame_length/2)/frame_length*fs, x_freq_log3);
axis([0,fs/2,-100,10])
set(gca,'xtick',[])

subplot('Position',[0.05,0.2,0.55,0.15])
h41 = plot(1:frame_length, xbs4);
axis([1,frame_length,-max(abs(xb4)),max(abs(xb4))])

subplot('Position',[0.63,0.2,0.32,0.15])
h42 = plot((0:frame_length/2)/frame_length*fs, x_freq_log4);
axis([0,fs/2,-100,10])


subplot('Position',[0.05,0.05,0.9,0.1])
hold on
h2 = plot((1:length(x))/fs,x);      % 作图，动画效果，注意横坐标的取值
h3 = plot([i/fs, i/fs],[-1.5,1.5],'r','LineWidth',2);
box on
hold off
axis([0,length(x)/fs,-0.9,0.9])

set(h11,'YDataSource', 'xbs1')
set(h12,'YDataSource', 'x_freq_log1')

set(h21,'YDataSource', 'xbs2')
set(h22,'YDataSource', 'x_freq_log2')

set(h31,'YDataSource', 'xbs3')
set(h32,'YDataSource', 'x_freq_log3')

set(h41,'YDataSource', 'xbs4')
set(h42,'YDataSource', 'x_freq_log4')

set(h3,'XDataSource', '[i/fs, i/fs]')

while (i+frame_move<=length(x))           % 循环处理，直至到无数据可读
    
    xbs1 = [xbs1(frame_move+1:frame_length); xb1(i+1:i+frame_move)];  % 更新数据缓存，注意帧长和争议所起的角色
    xbs2 = [xbs2(frame_move+1:frame_length); xb2(i+1:i+frame_move)];
    xbs3 = [xbs3(frame_move+1:frame_length); xb3(i+1:i+frame_move)];
    xbs4 = [xbs4(frame_move+1:frame_length); xb4(i+1:i+frame_move)];
    
    x_freq_log1 = fft(xbs1.*win);
    x_freq_log1 = 20*log10(abs(x_freq_log1(1:end/2+1)));
    x_freq_log2 = fft(xbs2.*win);
    x_freq_log2 = 20*log10(abs(x_freq_log2(1:end/2+1)));
    x_freq_log3 = fft(xbs3.*win);
    x_freq_log3 = 20*log10(abs(x_freq_log3(1:end/2+1)));
    x_freq_log4 = fft(xbs4.*win);
    x_freq_log4 = 20*log10(abs(x_freq_log4(1:end/2+1)));
    
    figure(1)
    if(strcmp(get(gcff,'CurrentCharacter'),' '))
        pause
    end
    
    i = i + frame_move;                 % 更新数据下标，为下一次循环作准备

    refreshdata(h11,'caller'); refreshdata(h12,'caller');
    refreshdata(h21,'caller'); refreshdata(h22,'caller');
    refreshdata(h31,'caller'); refreshdata(h32,'caller');
    refreshdata(h41,'caller'); refreshdata(h42,'caller');
    
    refreshdata(h3,'caller');
    drawnow; pause(1*frame_move/frame_length);
end

