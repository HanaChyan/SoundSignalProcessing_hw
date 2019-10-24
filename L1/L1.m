load Num; %fdatool�Ȳ�����Ƶõ���fir�˲�������,��ֹƵ��2500Hz���״�Ϊ30
fs = 10000;
N = 20000;
t = 0: 1/fs: (N - 1)/fs; 

a = randn(N, 1); %������˹������

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



