model_file_name = "plot_stage6_updated_task_dist.jl"
include(model_file_name)

(individual_dist_plot, 
grouped_dist_plot, 
accuracy_plot, 
memory_cost_plot, 
computation_cost_plot, 
line_plot, 
maxs,
max_utility_plot, 
dist_plot, 
max_lot_plot,
max_lots,
CP_arrival_time,
one_arrival_time,
two_arrival_time) = run_test("english", false)

english_plots = [individual_dist_plot, dist_plot, max_lot_plot]
english_arrival_times = [one_arrival_time, two_arrival_time, CP_arrival_time]

include(model_file_name)
(individual_dist_plot, 
grouped_dist_plot, 
accuracy_plot, 
memory_cost_plot, 
computation_cost_plot, 
line_plot, 
maxs,
max_utility_plot, 
dist_plot, 
max_lot_plot,
max_lots,
CP_arrival_time,
one_arrival_time,
two_arrival_time) = run_test("slovenian", false)

slovenian_plots = [individual_dist_plot, dist_plot, max_lot_plot]
slovenian_arrival_times = [one_arrival_time, two_arrival_time, CP_arrival_time]

include(model_file_name)
(individual_dist_plot, 
grouped_dist_plot, 
accuracy_plot, 
memory_cost_plot, 
computation_cost_plot, 
line_plot, 
maxs,
max_utility_plot, 
dist_plot, 
max_lot_plot,
max_lots,
CP_arrival_time,
one_arrival_time,
two_arrival_time) = run_test("chinese", false)

chinese_plots = [individual_dist_plot, dist_plot, max_lot_plot]
chinese_arrival_times = [one_arrival_time, two_arrival_time, CP_arrival_time]

cross_linguistic_plot = plot_cross_linguistic_diversity_results(english_plots, english_arrival_times, chinese_plots, chinese_arrival_times, slovenian_plots, slovenian_arrival_times)

cross_linguistic_plot