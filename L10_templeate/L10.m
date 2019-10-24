clear all; clc;
[x, fs] = audioread('ref.wav');       % input reference source signal
[u, ~] = audioread('noise.wav');        % input noise signal
c = load('sec.txt');        % input dummy secondary path filter coefficient

z = filter(c, 1, x);
N = length(x);
mu = 0.01;       % step length
M = 128;        % buffer size 
h_hat = zeros(M, 1);     % initialize h filter coefficients
es = zeros(N, 1);
e = es;


for n = M: N
    % LMS for h (using secondary path & z)
    xs = x(n - M + 1: n);       
    zs = z(n - M + 1: n);
    es(n) = u(n) + h_hat'*zs(end: -1: 1);
    h_hat = h_hat - 2*mu*zs(end: -1: 1)*es(n);
    
    % active noise cancellation 
    h = h_hat;
    y = filter(h, 1, xs); % passing primary path
    y = conv(c, y); % passing primary path
    e(n) = u(n) + y(M);     % real out put
end
 
plot(1: length(x), x)
hold on
plot(1: length(x), e, 'r')
legend('raw noise', 'ANC output')