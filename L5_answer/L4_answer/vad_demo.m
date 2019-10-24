clear
close all
clc

[x,fs] = audioread('Ch_m3.wav');


nw = 2^nextpow2(fs/30);             % ֡��
nm = nw/16;                          % ֡��

win = hamming(nw+1);
win(end) = []; win = win(:);        % ������
win = win/(0.54*nw/nm);             % �����������ع��������

i = 0;                              % ����֡�Ƽ�����ʱ�����

xs = zeros(nw,1);                   % ֡���ݣ����룩
ys2 = xs;                           % ��������ݵ��ӻ���
t = 1*ones(nw/2+1,1);        % xs��Ƶ�׷���
p = 1*ones(nw/2+1,round(2*fs/nm));
                                    % ��¼ǰ�����루�˴�3�룩����Ƶ�ʵ����С����˸�ֵ������ʡ�֡���й�
p_phi = 0.1;

fm_num = floor(length(x)/nm);       % ֡��
vad_snr = zeros(fm_num,1);
vad_state = zeros(fm_num,1);
zero_cross_rate = zeros(fm_num,1);
zero_cross_threshold = 0.01;
lpc_lowtohigh_ratio = zeros(fm_num,1);

k = 1;
freq_value_index = linspace(0,fs/2,nw/2+1);

while(i+nm<=length(x))              % �ж���Ҫ����֡�������Ƿ񳬳������ź�(x)���ȣ���������ѭ��
    xs = [xs(nm+1:end);x(i+1:i+nm)];% ȡx��nm������xs��nw-nm��������µ�xs��ʵ��������֡

    XS = fft(xs.*win);              % ��xs�Ӵ���ĸ���Ҷ�任
    u = abs(XS(1:end/2+1).^2);      % ��xs�ļ�ʱƵ��
    
    t = t * p_phi + u * (1-p_phi);    % ��xs�Ķ�ʱƽ��Ƶ��
    
    p = [t,p(:,1:end-1)];           % ��ǰ�Ķ�ʱƵ����ǰ������֡�Ķ�ʱƵ��������µ�Ƶ���飬Ϊ�����Ƶ�����Сֵ��׼��
    
    noise = min(p,[],2);          % �����Ƶ���ʱ��СƵ�ף���Ϊ��������
    
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
            case 0              % ��Ĭ��
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
            case 1              % ������
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
    
    i = i + nm;                     % ʱ���������֡�Ƴ��ȣ�Ϊ��һ֡��������׼��
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


