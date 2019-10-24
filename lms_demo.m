% LMS demo by Kai Chen on April, 18, 2019 @ NJU

clear; close all; clc;

N = 2e4;                                    % ??????
x = randn(N,1);                             % 生成参考噪声

h = rand(20,1)*2-1;                         % 生成滤波器

d = filter(h,1,x)+sin(2*pi*(0:N-1)'*0.005); % 期望信号

L = 20;                                     % 规定滤波器长度
mu = 0.001;                                 % LMS步长

w = zeros(L,1);                             % 逼近滤波器系数
xs = zeros(L,1);                            % 取L阶参考信号

e =  zeros(size(d));                        % 取L阶期望信号

for i = 1:length(x)
    xs = [x(i); xs(1:end-1)];               % 更新后参考信号
    e(i) = d(i) - w'*xs;                    % 更新误差
    w = w + mu*xs*e(i);                     % 更新滤波器
end

figure                                      % ???????????
subplot(211)
hold on
plot(d)
plot(e,'r')
hold off
title('1')
legend('期望信号','误差')

subplot(212)                                % ???????????????
hold on
stem(h)
stem(w,'r')
hold off
title('2')
legend('原滤波器','更新滤波器')

