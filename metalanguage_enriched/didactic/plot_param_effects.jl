model_file_name = "plot_stage6_updated_task_dist.jl"
include(model_file_name)

function check_phase_order(phase_list, first_phase_prefixes, second_phase_prefixes, missing_index)
    indices = []
    for prefixes in [first_phase_prefixes, second_phase_prefixes]
        phase_indices = findall(x -> foldl(|, map(y -> occursin(y, x), prefixes), init=false), phase_list)
        phase_index = phase_indices == [] ? missing_index : phase_indices[1]
        push!(indices, phase_index)
    end

    @show indices
    indices[1] < indices[2] ? 1.0 : 0.0
end

results = []

distance_modifiers = collect(0:1:8)
for distance_modifier_index in 1:length(distance_modifiers)
    @show distance_modifier_index 
    distance_modifier = distance_modifiers[distance_modifier_index]
    @show distance_modifier 
    
    utility_results = []
    MAP_results = []

    modifiers = collect(-0.59:0.01:0.59) # collect(-1.18:0.02:1.18)
    for modifier_index in 1:length(modifiers)
        @show modifier_index 
        modifier = modifiers[modifier_index]

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
        two_arrival_time) = run_test("english", false, param_effects_memory_mod = modifier, param_effects_distance_mod = distance_modifier) # 8.630423783253967

        # utility order check
        utility_correct_order = check_phase_order(maxs, ["three", "four"], ["CP"], length(max_lots) + 1)
        MAP_correct_order = check_phase_order(max_lots, ["three", "four"], ["CP"], length(max_lots) + 1)

        push!(utility_results, utility_correct_order)
        push!(MAP_results, MAP_correct_order)
    end

    utility_valid_plot = bar(ones(length(modifiers)), color = map(i -> [:red, :green][Int(i) + 1], utility_results), xrotation=305, size=(600, 100), legend=false, xlabel="LoT Stage", ylims=(0.0, 1.0), linecolor=:match)
    MAP_valid_plot = bar(ones(length(modifiers)), color = map(i -> [:red, :green][Int(i) + 1], MAP_results), xrotation=305, size=(600, 100), legend=false, xlabel="LoT Stage", ylims=(0.0, 1.0), linecolor=:match)

    push!(results, (distance_modifier, utility_valid_plot, MAP_valid_plot))

    # plot(utility_valid_plot, MAP_valid_plot, layout=(2,1), size=(1000, 200))
end

utility_plot = results[1][2]
plots = [utility_plot, map(r -> r[end], results)...]

plot(plots..., layout=(length(plots), 1), size=(1000, 120 * length(plots)), xlabel="", bar_width=1)

plot(map(p -> bar(p, bar_width=1, linecolor=:match), plots)..., layout=(length(plots), 1), size=(500, 50 * length(plots)), xlabel="", xticks=false, yticks=false)