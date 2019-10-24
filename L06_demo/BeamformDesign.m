
fr = 5000;
M = 30;                    % 阵列单元数
c = 344;                    % 声速
d0 = 0.03;

fs = 8000;
theta = [70,60,50];

theta_to_freq = fr*fs*d0*cos(theta/180*pi)/c;

h = fir2(M-1,[0,theta_to_freq,(fs/2)]/(fs/2),[0,0,1,0,0])';
                            % 设计滤波器
h1 = hilbert(h)/2;          % 希尔伯特变换

phi = 0:1:180;
response = zeros(size(phi));
for i = 1:length(phi)       % 计算空间响应
    d = exp(1i*2*pi*fr*(0:M-1)'*d0*cos(phi(i)/180*pi)/c);
    response(i) = h1.'*d;
end

figure
plot(phi,10*log10(abs(response).^2))
