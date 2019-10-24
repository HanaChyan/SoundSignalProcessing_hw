clear all
close all
clc

[x,fs] = wavread('man.wav');
% x = x(1:fs);
g = load('path.txt');

K = 0.2;                                % ����

g = g(:);                               % ������ѧ·��g
c = [0,0,0,0,1]';                       % ����ϵͳ�ڲ�����·��c

xs1 = zeros(size(c));
xs2 = zeros(size(g));

y1 = zeros(size(x));                    % �ȷ���y1��y2�ռ䣬������������ʱ����ռ�ռ�ô�����������
y2 = zeros(size(x));
temp = 0;

for i = 1:length(x)                     % ����γɷ�����·
    xs1 = [x(i)+temp; xs1(1:end-1)];    % �ȴ���c������źŻ���
    y1(i) = K*(xs1'*c);                 % �������������ź�
    y1(i) = min(1,y1(i));               % ����Լ����Х������ֽ�ֹ
    y1(i) = max(-1,y1(i));
    xs2 = [y1(i); xs2(1:end-1)];        % �ȴ���g������źŻ���
    temp = xs2'*g;                      % temp��Ϊ�����㻺�棬����һ�����㴦��ʱ�������źŻ��
end

d  = fdesign.notch('N,F0,Q,Ap',2,922/(fs/2),1,1);   % ����ݲ���������Ƶ��Ϊ922Hz
Hd = design(d);
iir_coef1 = Hd.sosMatrix;

d  = fdesign.notch('N,F0,Q,Ap',2,4534/(fs/2),1,1);  % ����ݲ���������Ƶ��Ϊ4534Hz
Hd = design(d);
iir_coef2 = Hd.sosMatrix;

iir_coef = [iir_coef1; iir_coef2];  % �����ݲ����������ݲ�����


iir_buffer = zeros(size(iir_coef,1),5);

xs1 = zeros(size(c));
xs2 = zeros(size(g));
temp = 0;

for i = 1:length(x)
    xs1 = [x(i)+temp; xs1(1:end-1)];
    y2(i) = K*(xs1'*c);
    y2(i) = min(1,y2(i));
    y2(i) = max(-1,y2(i));
    d = y2(i);                      % iir�˲�����
    for k = 1:size(iir_coef,1)      % iir�˲�����
        iir_buffer(k,1:3) = [d, iir_buffer(k,1:2)];
        d = iir_buffer(k,1:3) * iir_coef(k,1:3)' - iir_buffer(k,4:5) * iir_coef(k,5:6)';
        iir_buffer(k,4:5) = [d, iir_buffer(k,4)];
    end
    y2(i) = d;
    xs2 = [y2(i); xs2(1:end-1)];
    temp = xs2'*g;
end

[b,a] = sos2tf(iir_coef,ones(size(iir_coef,1)+1,1));
figure,freqz(b,a,1:fs/2,fs)     % �۲��ݲ������Ƶ��

figure
subplot(211),plot(y1)           % δ�����ź�
subplot(212),plot(y2)           % Х�������ź�
