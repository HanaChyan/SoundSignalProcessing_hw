%ÖØµþ±£Áô·¨
function y = oversave(x, h, l)
lx = length(x); p = length(h);
if l > lx || l < length(h)
    error('L not fitted(l > lx)or(l < length(h))')
end
l0 = l - p + 1; T = ceil(lx/l0);
x = [zeros(1, p-1), x, zeros(1: T* l0 - lx)]; 
h_dft = fft(h, l);
for i = 0: T-1
    xi = i*l0;
    xr = x(xi + 1: xi + l);
    xr_dft = fft(xr, l);
    yr_dft = xr_dft.*h_dft;
    yr = ifft(yr_dft);
    y(xi + 1: xi + l0) = yr(p: end);
end
end
    
