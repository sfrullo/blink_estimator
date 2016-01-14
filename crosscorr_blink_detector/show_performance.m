function show_performance(sub_id)

data = load(['results/crosscorr_s' num2str(sub_id) '.mat']);

plot(data.l.accuracy,'DisplayName','accuracy');
title('Left eye');
hold on;
plot(data.l.precision,'DisplayName','precision');
plot(data.l.recall,'DisplayName','recall');
legend('show');
hold off;

figure;
plot(data.r.accuracy,'DisplayName','accuracy');
title('Right eye');
hold on;
plot(data.r.precision,'DisplayName','precision');
plot(data.r.recall,'DisplayName','recall');
legend('show');
hold off;


end