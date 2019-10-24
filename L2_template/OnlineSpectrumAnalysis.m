clc;
close all;
clear all;

[x,fs] = audioread('sample_test_32k_16bit.wav');
resample(x,16e3,fs);                    % �����������ź�
fs = 16e3;                              % �ض��������
x = x + randn(size(x))*0.001;           % ���������ı�������
x(1:0.6*fs) = [];                       % ȥ����Ƶǰ�����Ч����clc
x(end-1.5*fs:end) = [];


frame_length = 0.03*fs;                   % ���ڴ˴��趨֡��������֪����ʦ�����֪֡��ѡ��һ����10ms~30ms��
frame_move = 0.008*fs;                     % ���ڴ˴��趨֡��
phi = 0;

i = 0;                                  % �����±�����

win = hamming(frame_length);            % ���������������ȵ���֡��
xs = zeros(frame_length, 1);            % �������ݻ���

x_freq = zeros(frame_length/2 + 1, 1);    % �趨Ƶ�׷���������棬����Լ��֡����һ��
x_freq_log = x_freq;

figure
subplot('Position',[0.1,0.4,0.8,0.5])
h1 = plot((0: frame_length/2)/frame_length*fs, x_freq_log);
axis([0, fs/2, -40, 35])

subplot('Position',[0.1,0.1,0.8,0.2])
hold on
h2 = plot((1: length(x))/fs,x);      % ��ͼ������Ч����ע��������ȡֵ
h3 = plot([i/fs, i/fs],[-1.5, 1.5], 'r', 'LineWidth', 2); %bar
box on
hold off
axis([0, length(x)/fs, -0.9, 0.9])

set(h1,'YDataSource', 'x_freq_log')
set(h3,'XDataSource', '[i/fs, i/fs]')

while (i + frame_length<=length(x))           % ѭ������ֱ���������ݿɶ�
% ���ڴ˴���д����
    xs = x(i + 1: i + frame_length);
    x_temp = xs.* win;
    x_temp = real(fft(x_temp));
    x_freq_log = x_temp(1: 1 + frame_length/2);
    
    i = i + frame_move;                 % ���������±꣬Ϊ��һ��ѭ����׼��

    refreshdata(h1,'caller');
    refreshdata(h3,'caller');
    drawnow; pause(0.5*frame_move/frame_length);
end

