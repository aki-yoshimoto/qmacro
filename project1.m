clc
clear all
close all

% load the data
startdate = '01/01/1994';
enddate = '01/01/2021';
f = fred
%CHOSE Canada to compare with Japan, because of two countries greatly impacted by US 
%Japan vs Canada 
JPY = fetch(f,'JPNRGDPEXP',startdate,enddate)
CNY = fetch(f,'NGDPRSAXDCCAQ',startdate,enddate)
jpy = log(JPY.Data(:,2));
cny = log(CNY.Data(:,2));
q = CNY.Data(:,1);

T = size(cny,1);

% Hodrick-Prescott filter
lam = 1600;
A = zeros(T,T);

% unusual rows
A(1,1)= lam+1; A(1,2)= -2*lam; A(1,3)= lam;
A(2,1)= -2*lam; A(2,2)= 5*lam+1; A(2,3)= -4*lam; A(2,4)= lam;

A(T-1,T)= -2*lam; A(T-1,T-1)= 5*lam+1; A(T-1,T-2)= -4*lam; A(T-1,T-3)= lam;
A(T,T)= lam+1; A(T,T-1)= -2*lam; A(T,T-2)= lam;

% generic rows
for i=3:T-2
    A(i,i-2) = lam; A(i,i-1) = -4*lam; A(i,i) = 6*lam+1;
    A(i,i+1) = -4*lam; A(i,i+2) = lam;
end

tauJPGDP = A\jpy;
tauCNGDP = A\cny;

% detrended GDP
jpytilde = jpy-tauJPGDP;
cnytilde = cny-tauCNGDP;

% plot detrended GDP
dates = 1994:1/4:2021.1/1; 
figure
title('Detrended log(real GDP) 1994Q1-2021Q1'); hold on
plot(q, cnytilde,'b', q, jpytilde,'r')
datetick('x', 'yyyy-qq')

% compute sd(y), sd(c), rho(y), rho(c), corr(y,c) (from detrended series)
jpysd = std(jpytilde)*100;
cnysd = std(cnytilde)*100;
corr_jc = corrcoef(jpytilde(1:T),cnytilde(1:T)); corr_jc = corr_jc(1,2);

disp(['Percent standard deviation of detrended log real GDP for Japan: ', num2str(jpysd),'.']); disp(' ')
disp(['Percent standard deviation of detrended log real GDP for Canada: ', num2str(cnysd),'.']); disp(' ')
disp(['Contemporaneous correlation between detrended log real GDP and PCE: ', num2str(corr_jc),'.']);



