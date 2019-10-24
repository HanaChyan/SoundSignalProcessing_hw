load Num; %fdatool等波纹设计得到的fir滤波器参数,截止频率2500Hz，阶次为30
fs = 10000;
N = 20000;
t = 0: 1/fs: (N - 1)/fs; 

a = randn(N, 1); %产生高斯白噪声

tic
a_filter = oversave(a', Num, 35); %filter
toc %timing

%test = conv(Num', a');
%u = [afft; test];
figure(1)
subplot(211)
plot(t, a);
xlabel('time');
title('raw_data');
subplot(212)
plot(t, a_filter);
xlabel('time');
title('processed');

%groupdelay
[gd, w] = grpdelay(Num, 1);
figure(2)
plot(w, gd);
xlabel('freq'); ylabel('group delay');



