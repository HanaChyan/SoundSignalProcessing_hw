% ÏÝ²¨Æ÷º¯Êý
function [num, den] = trapper(f0, fs, N)
Q = f0/(600*fs/N);
G = 10;                                     % ÏÝ²¨Æ÷ÔöÒæ
V = 10^(G/20);
num = zeros(1, 3); den = zeros(1, 3);

k = tan(pi*f0/fs);

num(1) = (1 + k/Q +k^2)/(1 + V*k/Q +k^2);
num(2) = 2*(k^2 - 1)/(1 + V*k/Q +k^2);
num(3) = (1 - k/Q + k^2)/(1 + V*k/Q + k^2);
den = [1; num(2); (1 - V*k/Q + k^2)/(1 + V*k/Q +k^2)];
end