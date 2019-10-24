clear all
close all
clc

[x,fs] = wavread('man.wav');
x = x(1:fs*2);
g = load('path.txt');

h = fir2(200,[0,0.48,0.5,1],[1,1,0,0]); h = h(:); h = h.*exp(2*pi*1i*(1:length(h))'/4);
                                        % ϣ�����ر任�����˲������������ȵõ���ͨ��Ȼ����Ƶ
h_dummy = zeros(size(h)); h_dummy((end+1)/2) = 1;

K = 0.2;                                % ����

g = g(:);                               % ������ѧ·��g
c = [0,0,0,0,1]';                       % ����ϵͳ�ڲ�����·��c

xs1 = zeros(size(c));
xs2 = zeros(size(g));
xs3 = zeros(size(h_dummy));

y1 = zeros(size(x));                    % �ȷ���y1��y2�ռ䣬������������ʱ����ռ�ռ�ô�����������
y2 = zeros(size(x));
temp = 0;

for i = 1:length(x)                     % ����γɷ�����·
    xs1 = [x(i)+temp; xs1(1:end-1)];    % �ȴ���c������źŻ���
    y1(i) = K*(xs1'*c);                 % �������������ź�
    
    xs3 = [y1(i); xs3(1:end-1)];        % ͨ��һ��ֻ��ʱ�ӵ��˲�����Ϊ�˽�y1��y2��Ⱥʱ��������ͬ
    y1(i) = xs3' * h_dummy;
    
    y1(i) = min(1,y1(i));               % ����Լ����Х������ֽ�ֹ
    y1(i) = max(-1,y1(i));
    xs2 = [y1(i); xs2(1:end-1)];        % �ȴ���g������źŻ���
    temp = xs2'*g;                      % temp��Ϊ�����㻺�棬����һ�����㴦��ʱ�������źŻ��
end


xs1 = zeros(size(c));
xs2 = zeros(size(g));
xs3 = zeros(size(h));
temp = 0;
f_shift = 3;                            % ��ƵƵ��Ϊ3Hz

for i = 1:length(x)
    xs1 = [x(i)+temp; xs1(1:end-1)];
    y2(i) = K*(xs1'*c);
    
    xs3 = [y2(i); xs3(1:end-1)];
    y2(i) = xs3' * h;                   % ͨ���˲����õ��ź�Ƶ�׵������Ჿ��
    y2(i) = y2(i)*exp(2*pi*1i*i/fs*f_shift);    % Ƶ��f_shift
    y2(i) = real(y2(i));                % ȡʵ�����ָ���Ƶ���ڸ����Ჿ�ֵ��ź�

    y2(i) = min(1,y2(i));
    y2(i) = max(-1,y2(i));
    xs2 = [y2(i); xs2(1:end-1)];
    temp = xs2'*g;
end

figure
subplot(211),plot(y1)           % δ�����ź�
subplot(212),plot(y2)           % Х�������ź�