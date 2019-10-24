%根据Berouti的理论得到过减因子alpha
function alpha = berouti(SNR)
if SNR >= -5.0 && SNR <= 20
	alpha = 4 - SNR*3/20;
else
    if SNR < -5.0
        alpha = 5;
    end
    if SNR > 20
        alpha = 1;
    end
end