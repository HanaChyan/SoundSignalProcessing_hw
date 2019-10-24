clc;
clear all;

fr = 3000;                  
M = 49;                     % 阵列单元数
c = 344;                    % 声速
d0 = 0.03;

if d0 >= c/(2*fr)
    error('传声器阵列间距过大')
end

fs = 7000;
theta = [50, 40];
t0 = 45;
win = hamming(M);


theta_to_freq = fr*fs*d0*cos(theta/180*pi)/c;
h1 = fir1(M-1, theta_to_freq/(fs/2), 'stop');
h1 = hilbert(h1)/2;
h2 = fir2(M-1, [0, 1], [1, 1]);
h2 = fliplr(hilbert(h2)/2);

h = win.*(h1' + h2');
%h = fir1(M - 1, theta_to_freq/(fs/2), 'stop')';        % 设计滤波器                           
                                     % 希尔伯特变换

phi = 0: 1: 180;
response = zeros(size(phi));
for i = 1: length(phi)       % 计算空间响应
    d = exp(1i*2*pi*fr*(0:M-1)'*d0*cos(phi(i)/180*pi)/c);
    response(i) = h.'*d;
end

figure
plot(phi,10*log10(abs(response).^2))