model_file_name = "plot_stage6_updated_task_dist.jl"
include(model_file_name)
compute_base = false
# PARAMS

transition_prob_identity_base = 0.975
transition_prob_identity_rate = 0.004 # 0.0003
transition_prob_base = 9.0 # 2
utility_base = 20.0

time_step_unit = 0.1 # 0.0005 # 0.00005 
num_time_steps = 1000

gamma_c = 1.2 # 1.0 # 1.2
cost_c = 0.5 # 0.015 # 0.008

# rate at which CP induction `@relate` discovery cost from 3+ knower stage linearly decreases with time
relate_factor_coefficient = 0.39 # below option can also be experimented with! (new)
# relate_factor_coefficient = sqrt(utility_base / transition_prob_base) * 0.26 # 0.39

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
two_arrival_time) = run_test("english", false, param_effects_memory_mod = 0.0, param_effects_distance_mod = 0)

plot(individual_dist_plot, dist_plot, max_lot_plot, layout=(3, 1), size=(1000, 1500), legend=false)