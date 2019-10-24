% function mysubspectrum_test

[x,fs] = wavread('Ch_m3.wav');

y = 0.01*filter([1,0.9], 1, randn(size(x))) + x;

z = mysubspectrum(y,fs);

figure
subplot(211)
plot(y)
subplot(212)
plot(z)

