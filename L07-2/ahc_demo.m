clear; close all; clc

[x,fs] = audioread('man.wav');
% x = x(1:fs);
g = load('path.txt');

K = 0.2;                               % 增益

g = g(:);                              % 反馈声学路径g
c = [0,0,0,0,1]';                      % 扩音系统内部传递路径c

xs1 = zeros(size(c));
xs2 = zeros(size(g));

y = zeros(size(x));                    % 先分配y1和y2空间，避免运行中临时分配空间占用大量的运算量
temp = 0;

for i = 1:length(x)                    % 卷积形成反馈回路
    xs1 = [x(i)+temp; xs1(1:end-1)];   % 等待与c卷积的信号缓存
    y(i) = K*(xs1'*c);                 % 馈给扬声器的信号
    y(i) = min(1,y(i));                % 幅度约束，啸叫则出现截止
    y(i) = max(-1,y(i));
    xs2 = [y(i); xs2(1:end-1)];        % 等待与g卷积的信号缓存
    temp = xs2'*g;                     % temp作为单样点缓存，待下一采样点处理时与输入信号混合
end

figure,plot(y)
