clc;
close all;
clear all;

[x,fs] = audioread('sample.wav');
resample(x,fs,16e3);                    % �����������ź�
fs = 16e3;                              % �ض��������
x = x + randn(size(x))*0.001;
x(1:0.6*fs) = [];
x(end-1.5*fs:end) = [];
% h = fir2(40,[0,0.4,0.5,1],[1,1,0,0]);
% x = filter(h,1,randn(20000,1));       

frame_length = 1024;                     % �趨֡��
frame_move = 32;                        % �趨֡��
phi = 0;

i = 0;                                  % �����±�����

win = hamming(frame_length);            % ���������������ȵ���֡��
xs = zeros(frame_length, 1);            % �������ݻ���

x_freq = zeros(frame_length/2+1, 1);    % �趨Ƶ�׷���������棬����Լ��֡����һ��
x_freq_log = x_freq;

figure
subplot('Position',[0.1,0.4,0.8,0.5])
h1 = plot((0:frame_length/2)/frame_length*fs, x_freq_log);
axis([0,fs/2,-40,35])
subplot('Position',[0.1,0.1,0.8,0.2])
hold on
h2 = plot((1:length(x))/fs,x);      % ��ͼ������Ч����ע��������ȡֵ
h3 = plot([i/fs, i/fs],[-1.5,1.5],'r','LineWidth',2);
box on
hold off
axis([0,length(x)/fs,-0.9,0.9])

set(h1,'YDataSource', 'x_freq_log')
set(h3,'XDataSource', '[i/fs, i/fs]')

while (i+frame_move<=length(x))           % ѭ������ֱ���������ݿɶ�
    xs = [xs(frame_move+1:frame_length); x(i+1:i+frame_move)];  % �������ݻ��棬ע��֡������������Ľ�ɫ
    temp = fft(xs.*win);                % �Ӵ���������FFT
    temp = temp(1:frame_length/2+1);    % ����Լһ�������
    x_freq = x_freq * phi + abs(temp).^2 * (1-phi); % ���·������������ƽ���������ӶԹ�ȥ���ݽ��м�Ȩ
    x_freq_log = 10*log10(x_freq);
    i = i + frame_move;                 % ���������±꣬Ϊ��һ��ѭ����׼��

    refreshdata(h1,'caller');
%     refreshdata(h2,'caller');
    refreshdata(h3,'caller');
    drawnow; pause(0.5*frame_move/frame_length);
end

