clc;
clear all;
[raw, fs] = audioread('input.wav');
x1 = raw(1: end, 1);
x2 = raw(1: end, 2);                         % ��ȡ����ͨ��

L = 30;                                      % �涨�˲�������
mu = 0.01;                                   % LMS����

w1 = zeros(L,1); w2 = w1;                    % �ƽ��˲���ϵ��
xs1 = zeros(L,1); xs2 = xs1;                 % ȡL�ײο��ź�

e1 =  zeros(size(x1)); e2 = e1;              % ȡL�������ź�
delta = 0.01;
for i = 1: length(x2)
    xs1 = [x1(i); xs1(1: end-1)];            % ���²ο��ź�
    e1(i) = x2(i) - w1'*xs1;                 % �������
    w1 = w1 + mu*xs1*e1(i)./(norm(xs1, 2)^2 + delta);                   % �����˲���
    
    xs2 = [x2(i); xs2(1: end-1)];
    e2(i) = x1(i) - w2'*xs2;
    w2 = w2 + mu*xs2*e2(i)./(norm(xs2, 2)^2 + delta);
end

s1 = x1 - filter(w1, 1, x2); s1 = s1/max(abs(s1));
s2 = x2 - filter(w2, 1, x1); s2 = s2/max(abs(s2));

figure
subplot(211)
plot(1: length(x1), x1)
hold on
plot(1: length(s1), s1,'r')

subplot(212)
plot(1: length(x2), x2)
hold on
plot(1: length(s2), s2,'r')

audiowrite('s1.wav', s1, fs);
audiowrite('s2.wav', s2, fs);