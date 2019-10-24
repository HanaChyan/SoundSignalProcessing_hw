% pa：峰均值功率比
function pa = parp(loc, mag)
% loc: 选取的候选频点位置
% mag: 幅度谱
N = length(mag);
k = length(loc);
p = (sum(mag(1: N/2).^2) - sum(mag(loc).^2))/(N/2 - k);
pa = 10*log10(mag(loc).^2)/p;      % 初始化峰均值功率比
end