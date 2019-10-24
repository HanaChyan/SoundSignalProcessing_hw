%ԭ���������������г����жϣ������ù����ʽ���ɸѡ��
%�����������ʱƽ�������������ϸ�����ʱ��ֱ���ж�Ϊ�������������Ͽ�����ʱ���������4֡���������Ͽ�ƽ���������Կ��ж�Ϊ����
clc;
close all;
clear all;

[x,fs] = audioread('sample.wav');
resample(x,fs,16e3);                    % �����������ź�
fs = 16e3;                              % �ض��������
x =  x + 0.001*randn(size(x));
x(1:0.6*fs) = [];
x(end-1.5*fs:end) = [];

frame_length = 1024;                    % �趨֡��
frame_move = 64;                         % �趨֡��
phi = 0;
i = 0;                                  % �����±�����

win = hamming(frame_length);            % ���������������ȵ���֡��
xs = zeros(frame_length, 1);            % �������ݻ���
xt = xs;

E0 = 2*sum((x(1: frame_length).*win).^2)    %�����һ֡������ƽ���������趨����ֵ�ж�����
zcr0 = 0.49;                                %����������
zcr1 = 0.14;                                %����������


x_freq = zeros(frame_length/2+1, 1);    % �趨Ƶ�׷���������棬����Լ��֡����һ��
x_freq_log = x_freq;

energy = NaN(floor(length(x)/frame_move), 1); %��¼��ʱ�������
zcr = NaN(floor(length(x)/frame_move), 1);    %��¼������
x_selected = ones(length(x), 1);              %�洢���б�Ϊ����������
ie = 1;                                       %��¼֡�ƴ�����֡��һ������һ��

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
h3 = plot([i/fs, i/fs], [-1.5,1.5], 'r', 'LineWidth', 2);  % ��ͼ������Ч��
h5 = plot((1:length(x))/fs, x_selected, 'r');
box on
hold off
axis([0, length(x)/fs, -0.9, 0.9])

set(h1, 'YDataSource', 'energy')
set(h4, 'YDataSource', 'zcr')
set(h3, 'XDataSource', '[i/fs, i/fs]')
set(h5, 'YDataSource', 'x_selected')


while (i + frame_length <= length(x))           % ѭ������ֱ���������ݿɶ�
    xs = [xs(frame_move + 1: frame_length); x(i + 1: i + frame_move)]; % �������ݻ���
    energy(ie) = sum((xs.*win).^2);
    zcr(ie) = sum(abs(sign(xs(1:end-1))-sign(xs(2:end)))/2)/length(xs);
    
    %�ж�����(�ӳ�5֡)
    temp = 0;
    if energy(ie) > E0 && ie > 4
        zcr_test = zcr(ie - 3: ie) ;
        if zcr(ie - 4) < zcr1                  % ��������ֱ���ж�Ϊ����
            temp = 1;
        elseif zcr(ie - 3) <= zcr0             % ������
            if  ((zcr_test - zcr0*ones(4, 1)) < zeros(4, 1)) == zeros(4, 1)  %����ǰ4֡,Ҫ��ÿһ֡�����ʾ�����zcr0
                temp = 1;
            end
        end
    end
    if temp == 1
        x_selected(i + 1 - 4*frame_move: i - 3*frame_move) = x(i + 1 - 4*frame_move: i - 3*frame_move);
    end
    
    i = i + frame_move;                        % ���������±꣬Ϊ��һ��ѭ����׼��
    ie = ie + 1;
    
    refreshdata(h1,'caller');
    refreshdata(h4,'caller');
    refreshdata(h3,'caller');
    refreshdata(h5,'caller');
    drawnow; pause(0.05);
end
