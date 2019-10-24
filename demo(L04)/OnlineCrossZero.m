clc;
close all;
clear all;

[x,fs] = audioread('sample.wav');
resample(x,fs,16e3);                    % �����������ź�
fs = 16e3;                              % �ض��������
x =  x + 0.001*randn(size(x));

x(1:0.6*fs) = [];
x(end-1.5*fs:end) = [];

% x = x + sin(2*pi*5000/fs*(1:length(x))')*0.05;

frame_length = 1024;                    % �趨֡��
frame_move = 64;                        % �趨֡��
phi = 0;

i = 0;                                  % �����±�����

win = hamming(frame_length);            % ���������������ȵ���֡��
xs = zeros(frame_length, 1);            % �������ݻ���
xt = xs;

x_freq = zeros(frame_length/2+1, 1);    % �趨Ƶ�׷���������棬����Լ��֡����һ��
x_freq_log = x_freq;

c = NaN(floor(length(x)/frame_move),1); %��¼������
ic = 1;                                 %��¼֡�ƴ�����֡��һ������һ��

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
h2 = plot((1:length(x))/fs,x);      % ��ͼ������Ч����ע��������ȡֵ
h3 = plot([i/fs, i/fs],[-1.5,1.5],'r','LineWidth',2);
box on
hold off
axis([0,length(x)/fs,-0.9,0.9])

set(h1,'YDataSource', 'c')
set(h4,'YDataSource', 'xs')
set(h3,'XDataSource', '[i/fs, i/fs]')


while (i+frame_length<=length(x))           % ѭ������ֱ���������ݿɶ�
    xs = [xs(frame_move+1:frame_length); x(i+1:i+frame_move)];  % �������ݻ��棬ע��֡������������Ľ�ɫ
    
    c(ic) = sum(abs(sign(xs(1:end-1))-sign(xs(2:end)))/2)/length(xs);
    
    i = i + frame_move;                 % ���������±꣬Ϊ��һ��ѭ����׼��
    ic = ic + 1;

    refreshdata(h1,'caller');
    refreshdata(h4,'caller');
    refreshdata(h3,'caller');
    drawnow; pause(0.05);
end

