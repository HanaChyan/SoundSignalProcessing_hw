% pa�����ֵ���ʱ�
function pa = parp(loc, mag)
% loc: ѡȡ�ĺ�ѡƵ��λ��
% mag: ������
N = length(mag);
k = length(loc);
p = (sum(mag(1: N/2).^2) - sum(mag(loc).^2))/(N/2 - k);
pa = 10*log10(mag(loc).^2)/p;      % ��ʼ�����ֵ���ʱ�
end