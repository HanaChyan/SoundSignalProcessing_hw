clc;
close all;
clear all;

[x,fs0] = audioread('speech_with_noise.wav');
resample(x,fs0,16e3);                   % 建立待分析信号
fs = 16e3;                              % 重定义采样率

frame_length = 1024;                    % 设定帧长
frame_move = 64;                        % 设定帧移
i = 0;                                  % 数据下标索引

win = hamming(frame_length);            % 建立窗函数，长度等于帧长
xi = zeros(frame_length, 1);            % 开辟数据缓存
xw_noise = zeros(frame_length, 1);      % 存储噪声谱
x_specsub = zeros(length(x), 1);        % 存储谱减后纯语音

%%%%%% 用VAD方法计算u_noise(omega)

E0 = 2*sum((x(1: frame_length).*win).^2);    % 计算第一帧噪声的平均能量，设定能量值判定下限
zcr0 = 0.49;                                 % 过零率上限
ie = 0;
xs = zeros(frame_length, 1);
while (i + frame_length <= length(x))           
    xs =  x(i + 1: i + frame_length);         % 更新数据缓存
    energy = sum((xs.*win).^2);
    zcr = sum(abs(sign(xs(1:end-1))-sign(xs(2:end)))/2)/length(xs);
    if energy < E0 || zcr >= zcr0            % 噪声判定(短时平均能量 + 过零率)  
        ie = ie + 1;
        xw_noise = xw_noise + fft(win.* xs);
    end
    i = i + frame_length;                    % 更新数据坐标，后移一帧
end
u_noise = abs(xw_noise)/ie;



%%%%% 谱减
i = 0;                                       % 数据下标索引归零
j = sqrt(-1);
beta = 0.002;                                % 按照Berouti理论应该根据SNR改变beta，但是实际好像beta恒为0.002时降噪效果更好

while (i + frame_length <= length(x))        % 循环处理，直至到无数据可读
    xi = [xi(frame_move + 1: frame_length); x(i + 1: i + frame_move)];
    xi = win.*xi;
    xiw = fft(xi);   
    xi_pha = angle(xiw);
    xi_amp = abs(xiw);

    SNR = 10*log10(norm(xi_amp, 2)^2/norm(u_noise, 2)^2);       % 计算信噪比
    alpha = berouti(SNR);                                       % 根据Berouti的理论得到过减因子alpha和谱下限参数beta
    
    xiw = xi_amp.^2 - alpha*(u_noise).^2;                       % 谱减
    
    test = xiw - beta*u_noise.^2;                               % 判断纯净信号是否过减
    z = find(test <0);  
    if ~isempty(z)
        xiw(z) = beta*u_noise(z).^2;                            % 对于过减情况，用估计出来的噪声信号表示下限值
    end
    xiw = sqrt(xiw).*exp(j*xi_pha);                             % 补回相角
    x_new = real(ifft(xiw))./win;                               % 逆变换
    x_specsub(i + 1: frame_move + i) = x_new(frame_length - frame_move + 1: end); 
    
    i = i + frame_move;
end

subplot(211)        
plot((1:length(x))/fs,x);                   % 绘图：含噪语音              
axis([0,length(x)/fs,-0.9,0.9])

subplot(212)
plot((1:length(x))/fs,x_specsub);           % 绘图：谱减语音
axis([0,length(x)/fs,-0.9,0.9])

audiowrite('speech_denoise.wav', x_specsub,fs0);
