clear; close all; clc

[x,fs] = audioread('man.wav');
% x = x(1:fs);
g = load('path.txt');

K = 0.2;                               % ����

g = g(:);                              % ������ѧ·��g
c = [0,0,0,0,1]';                      % ����ϵͳ�ڲ�����·��c

xs1 = zeros(size(c));
xs2 = zeros(size(g));

y = zeros(size(x));                    % �ȷ���y1��y2�ռ䣬������������ʱ����ռ�ռ�ô�����������
temp = 0;

for i = 1:length(x)                    % ����γɷ�����·
    xs1 = [x(i)+temp; xs1(1:end-1)];   % �ȴ���c������źŻ���
    y(i) = K*(xs1'*c);                 % �������������ź�
    y(i) = min(1,y(i));                % ����Լ����Х������ֽ�ֹ
    y(i) = max(-1,y(i));
    xs2 = [y(i); xs2(1:end-1)];        % �ȴ���g������źŻ���
    temp = xs2'*g;                     % temp��Ϊ�����㻺�棬����һ�����㴦��ʱ�������źŻ��
end

figure,plot(y)
