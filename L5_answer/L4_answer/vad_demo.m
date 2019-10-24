clear
close all
clc

[x,fs] = audioread('Ch_m3.wav');


nw = 2^nextpow2(fs/30);             % 帧长
nm = nw/16;                          % 帧移

win = hamming(nw+1);
win(end) = []; win = win(:);        % 窗函数
win = win/(0.54*nw/nm);             % 抵消窗交叠重构后的增益

i = 0;                              % 用于帧移计数的时序计数

xs = zeros(nw,1);                   % 帧数据（输入）
ys2 = xs;                           % 处理后数据叠加缓存
t = 1*ones(nw/2+1,1);        % xs的频谱幅度
p = 1*ones(nw/2+1,round(2*fs/nm));
                                    % 记录前若干秒（此处3秒）各个频率点的最小，因此该值与采样率、帧移有关
p_phi = 0.1;

fm_num = floor(length(x)/nm);       % 帧数
vad_snr = zeros(fm_num,1);
vad_state = zeros(fm_num,1);
zero_cross_rate = zeros(fm_num,1);
zero_cross_threshold = 0.01;
lpc_lowtohigh_ratio = zeros(fm_num,1);

k = 1;
freq_value_index = linspace(0,fs/2,nw/2+1);

while(i+nm<=length(x))              % 判断需要更新帧的数据是否超出输入信号(x)长度，否则跳出循环
    xs = [xs(nm+1:end);x(i+1:i+nm)];% 取x的nm个点与xs的nw-nm个点组成新的xs，实现了数据帧

    XS = fft(xs.*win);              % 求xs加窗后的傅立叶变换
    u = abs(XS(1:end/2+1).^2);      % 求xs的即时频谱
    
    t = t * p_phi + u * (1-p_phi);    % 求xs的短时平滑频谱
    
    p = [t,p(:,1:end-1)];           % 当前的短时频谱与前面若干帧的短时频谱组成了新的频谱组，为求各个频点的最小值做准备
    
    noise = min(p,[],2);          % 求各个频点短时最小频谱，作为噪声估计
    
    estimate_snr = u./noise-1;
    estimate_snr = max(estimate_snr,0);
    estimate_snr = estimate_snr(find(freq_value_index>200 & freq_value_index<2000));
    
    vad_snr(k) = 10*log10(mean(estimate_snr));
    
    
    lpc_a = lpc(xs,10);
    lpc_a_freqz = freqz(1,lpc_a,freq_value_index,fs);
    lpc_a_freqz = abs(lpc_a_freqz.^2);
    lpc_a_freqz_low_part = sum(lpc_a_freqz(find(freq_value_index>200 & freq_value_index<1200)));
    lpc_a_freqz_high_part = sum(lpc_a_freqz(find(freq_value_index>2000 & freq_value_index<4000)));
    lpc_lowtohigh_ratio(k) = lpc_a_freqz_low_part ./ lpc_a_freqz_high_part;
    
    zero_cross_rate(k) = sum(abs(sign(xs(1:end-1))-sign(xs(2:end)))/2)/(length(xs)-1);

    if(k == 1)
        vad_state(1) = 0;
    else
        switch vad_state(k-1)
            case 0              % 静默期
                con = 0;
                if(vad_snr(k)>=30)
                    con = con + 1;
                end
                if(lpc_lowtohigh_ratio(k)>=2)
                    con = con + 1;
                end
                if(zero_cross_rate(k)<0.2)
                    con = con + 1;
                end
                if(con >= 2)
                    vad_state(k) = 1;
                else
                    vad_state(k) = 0;
                end
            case 1              % 语音段
                con = 0;
                if(vad_snr(k)<=20)
                    con = con + 1;
                end
                if(lpc_lowtohigh_ratio(k)<=2)
                    con = con + 1;
                end
                if(zero_cross_rate(k)>0.2)
                    con = con + 1;
                end
                if(vad_snr(k)<=20)
                    vad_state(k) = 0;
                else
                    vad_state(k) = 1;
                end
        end
    end
    
    i = i + nm;                     % 时序计数增加帧移长度，为下一帧的数据做准备
    k = k + 1;
end

figure
subplot(311)
plot(x)
xlim([1,length(x)])
subplot(312)
plot(vad_snr)
xlim([1,length(vad_snr)])
ylim([0,45])
subplot(313)
plot(vad_state)
xlim([1,length(vad_state)])

figure
subplot(211)
plot(x)
xlim([1,length(x)])
subplot(212)
plot(zero_cross_rate)
xlim([1,fm_num])

figure,plotyy(1:length(x),x,(1:length(vad_state))*nm,vad_state)


