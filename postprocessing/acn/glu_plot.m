%% Import Data
import_txt();
data = accm;
clear accm;

%% Figure out blocks (?)
glu_mean = mean(data(:,1));
positive = data(:,1) > glu_mean;
plot(positive)

%From the mean, no blocks are identifiable over time. Though There could be
%by other methods.


%%%%%%%%% Plot %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Plot fMRS glutamate signal over samples
figure
plot((data(:,1)));
xlabel('samples');
ylabel('Glu levels');
title('fMRS Dataset Glu Signal');

%% Plot variability (boxplot)
figure
boxplot(data(:,1));
title('Glu Variance');
ylabel('Glu levels');
xlabel('All samples');

%% Divide between even and odd
figure

x = 1:2:size(data,1);
set_1 = data(x,1);

plot(data(x,1));
xlabel('samples');
ylabel('Glu levels');
title('fMRS Dataset Glu Signal');

%% Blocks (?) get mean of x consecutive samples and plot them over time
indx = 0;
spacing = 4;
new_data = zeros(size(data,1)/spacing,1);
for i = 0:spacing:size(data,1)-1
    indx= indx + 1;
    disp(indx);
    new_data(indx) = mean(data([i+1:(i+spacing)],1),1);
end
plot(new_data - glu_mean);