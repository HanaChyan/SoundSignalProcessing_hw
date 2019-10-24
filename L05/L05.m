clc;
close all;
clear all;

[x,fs0] = audioread('speech_with_noise.wav');
resample(x,fs0,16e3);                   % �����������ź�
fs = 16e3;                              % �ض��������

frame_length = 1024;                    % �趨֡��
frame_move = 64;                        % �趨֡��
i = 0;                                  % �����±�����

win = hamming(frame_length);            % ���������������ȵ���֡��
xi = zeros(frame_length, 1);            % �������ݻ���
xw_noise = zeros(frame_length, 1);      % �洢������
x_specsub = zeros(length(x), 1);        % �洢�׼�������

%%%%%% ��VAD��������u_noise(omega)

E0 = 2*sum((x(1: frame_length).*win).^2);    % �����һ֡������ƽ���������趨����ֵ�ж�����
zcr0 = 0.49;                                 % ����������
ie = 0;
xs = zeros(frame_length, 1);
while (i + frame_length <= length(x))           
    xs =  x(i + 1: i + frame_length);         % �������ݻ���
    energy = sum((xs.*win).^2);
    zcr = sum(abs(sign(xs(1:end-1))-sign(xs(2:end)))/2)/length(xs);
    if energy < E0 || zcr >= zcr0            % �����ж�(��ʱƽ������ + ������)  
        ie = ie + 1;
        xw_noise = xw_noise + fft(win.* xs);
    end
    i = i + frame_length;                    % �����������꣬����һ֡
end
u_noise = abs(xw_noise)/ie;



%%%%% �׼�
i = 0;                                       % �����±���������
j = sqrt(-1);
beta = 0.002;                                % ����Berouti����Ӧ�ø���SNR�ı�beta������ʵ�ʺ���beta��Ϊ0.002ʱ����Ч������

while (i + frame_length <= length(x))        % ѭ������ֱ���������ݿɶ�
    xi = [xi(frame_move + 1: frame_length); x(i + 1: i + frame_move)];
    xi = win.*xi;
    xiw = fft(xi);   
    xi_pha = angle(xiw);
    xi_amp = abs(xiw);

    SNR = 10*log10(norm(xi_amp, 2)^2/norm(u_noise, 2)^2);       % ���������
    alpha = berouti(SNR);                                       % ����Berouti�����۵õ���������alpha�������޲���beta
    
    xiw = xi_amp.^2 - alpha*(u_noise).^2;                       % �׼�
    
    test = xiw - beta*u_noise.^2;                               % �жϴ����ź��Ƿ����
    z = find(test <0);  
    if ~isempty(z)
        xiw(z) = beta*u_noise(z).^2;                            % ���ڹ���������ù��Ƴ����������źű�ʾ����ֵ
    end
    xiw = sqrt(xiw).*exp(j*xi_pha);                             % �������
    x_new = real(ifft(xiw))./win;                               % ��任
    x_specsub(i + 1: frame_move + i) = x_new(frame_length - frame_move + 1: end); 
    
    i = i + frame_move;
end

subplot(211)        
plot((1:length(x))/fs,x);                   % ��ͼ����������              
axis([0,length(x)/fs,-0.9,0.9])

subplot(212)
plot((1:length(x))/fs,x_specsub);           % ��ͼ���׼�����
axis([0,length(x)/fs,-0.9,0.9])

audiowrite('speech_denoise.wav', x_specsub,fs0);
