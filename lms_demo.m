% LMS demo by Kai Chen on April, 18, 2019 @ NJU

clear; close all; clc;

N = 2e4;                                    % ??????
x = randn(N,1);                             % ���ɲο�����

h = rand(20,1)*2-1;                         % �����˲���

d = filter(h,1,x)+sin(2*pi*(0:N-1)'*0.005); % �����ź�

L = 20;                                     % �涨�˲�������
mu = 0.001;                                 % LMS����

w = zeros(L,1);                             % �ƽ��˲���ϵ��
xs = zeros(L,1);                            % ȡL�ײο��ź�

e =  zeros(size(d));                        % ȡL�������ź�

for i = 1:length(x)
    xs = [x(i); xs(1:end-1)];               % ���º�ο��ź�
    e(i) = d(i) - w'*xs;                    % �������
    w = w + mu*xs*e(i);                     % �����˲���
end

figure                                      % ???????????
subplot(211)
hold on
plot(d)
plot(e,'r')
hold off
title('1')
legend('�����ź�','���')

subplot(212)                                % ???????????????
hold on
stem(h)
stem(w,'r')
hold off
title('2')
legend('ԭ�˲���','�����˲���')

