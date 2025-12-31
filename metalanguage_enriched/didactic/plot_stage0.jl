using Plots
using LaTeXStrings

language_names = map(x -> "L$(x)", collect(0:9))

language_names_pretty = [
    "L0_non_knower",
    "L1_1_knower",
    "L2_2_knower",
    "L3_2_knower_approx",
    "L4_3_knower",
    "L5_3_knower_approx",
    "L6_4_knower",
    "L7_CP_knower",
    "L8_CP_mapper",
    "L9_CP_unit_knower",
]

base_language_spec = Dict([
    "one" => false,
    "two" => false,
    "three" => false,
    "four" => false,
    "CP" => false,
    "CP_mapper" => false,
    "approx" => false,
    "unit" => false,
])

# non-knower
L0_spec = deepcopy(base_language_spec)

# one-knower
L1_spec = deepcopy(L0_spec)
L1_spec["one"] = true

# two-knower
L2_spec = deepcopy(L1_spec)
L2_spec["two"] = true

# two-knower, approx
L3_spec = deepcopy(L2_spec)
L3_spec["approx"] = true

# three-knower
L4_spec = deepcopy(L2_spec)
L4_spec["three"] = true

# three-knower, approx
L5_spec = deepcopy(L4_spec)
L5_spec["approx"] = true

# four-knower
L6_spec = deepcopy(L4_spec)
L6_spec["four"] = true

# CP-knower
L7_spec = deepcopy(L6_spec) # L6_spec
L7_spec["CP"] = true

# CP-mapper
L8_spec = deepcopy(L7_spec)
L8_spec["CP_mapper"] = true

# CP-unit-knower
L9_spec = deepcopy(L8_spec)
L9_spec["unit"] = true

language_name_to_spec = Dict(map(i -> language_names[i] => eval(Meta.parse("L$(i - 1)_spec")), 1:10))

function distance_between_specs(spec1, spec2)
    dist = 0
    for k in keys(spec1)
        if spec1[k] != spec2[k]
            dist += 1
        end
    end
    s = 0
    if dist != 0 
        if count(x -> x == true, collect(values(spec1))) > count(x -> x == true, collect(values(spec2)))
            s = 1 
        else
            s = -1
        end

        if !spec1["CP"] && spec2["CP"] && !spec1["three"]
            dist += 10
        end
    end

    (dist, s)
end

function plot_heatmap(t, title="")
    transition_prob_identity = transition_prob_identity_base - transition_prob_identity_rate * t
    heatmap_values = []
    for l1 in language_names 
        push!(heatmap_values, [])
        for l2 in language_names 
            l1_spec = language_name_to_spec[l1]
            l2_spec = language_name_to_spec[l2]
            dist, s = distance_between_specs(l1_spec, l2_spec)
            if dist == 0
                transition_prob = transition_prob_identity
            else
                if s == -1 
                    transition_prob = (1 - transition_prob_identity) * transition_prob_base^(-dist)
                else
                    transition_prob = 0
                end
            end
            push!(heatmap_values[end], transition_prob)
        end
        heatmap_values[end] = heatmap_values[end] ./ sum(heatmap_values[end])
    end

    heatmap_values_matrix = reshape(vcat(heatmap_values...), (10, 10))
    heatmap_values, heatmap(language_names, language_names, heatmap_values_matrix, aspect_ratio=:equal, clims=(0.0, 1.0), title=title, xrotation=270, tickfontsize=5, titlefontsize=11)
end

accuracies = [
    0.05, # L0: non-knower
    0.35, # L1: 1-knower
    0.50, # 2-knower
    0.525, # 2-knower, approx
    0.600, # 3-knower
    0.605, # 3-knower, approx 
    0.640, # 4-knower
    0.84, # CP-knower
    0.93, # CP-mapper
    1.00, # CP-unit-knower
]

memory_costs = [ # TODO
    0.00, # L0: non-knower
    0.15, # L1: 1-knower
    0.30, # 2-knower
    0.34, # 2-knower, approx
    0.35, # 3-knower
    0.39, # 3-knower, approx 
    0.50, # 4-knower
    0.40, # CP-knower
    0.55, # CP-mapper
    0.70, # CP-unit-knower
]
computational_costs = [ # TODO
    0.48, # L0: non-knower
    0.50, # L1: 1-knower
    0.50, # 2-knower
    0.50, # 2-knower, approx
    0.50, # 3-knower
    0.50, # 3-knower, approx 
    0.50, # 4-knower
    0.70, # CP-knower
    0.675, # CP-mapper
    0.65, # CP-unit-knower
]
computational_costs = computational_costs

time_step_unit = 0.0001
num_time_steps = 500

# three bar plots: accuracy, memory_cost, computational_cost
# one line plot: utilities over time
# heat map 1: transition probabilities
# heat map 2: max utility x transition probabilities 

# accuracy_plot = bar(map(x -> join(split(x, "_")[2:end], " "), language_names_pretty), accuracies, color = collect(palette(:tab10)), xrotation=305, size=(600, 525), legend=false, xlabel="LoT Stage", ylabel="Accuracy", title="Task Accuracy", ylims=(0.0, 1.0))

# memory_cost_plot = bar(map(x -> join(split(x, "_")[2:end], " "), language_names_pretty), memory_costs, color = collect(palette(:tab10)), xrotation=305, size=(600, 525), legend=false, xlabel="LoT Stage", ylabel="Cost", title="Memory Cost", ylims=(0.0, 1.0))

# computation_cost_plot = bar(map(x -> join(split(x, "_")[2:end], " "), language_names_pretty), computational_costs, color = collect(palette(:tab10)), xrotation=305, size=(600, 525), legend=false, xlabel="LoT Stage", ylabel="Cost", title="Computation Cost", ylims=(0.0, 1.0))

# plot(accuracy_plot, memory_cost_plot, computation_cost_plot, layout=(3, 1), size=(600, 525 * 3))

function compute_utility(language_index, t)
    gamma_c*t*accuracies[language_index] - cost_c *(memory_costs[language_index] + computational_costs[language_index] - 0.50)
end

gamma_c = 2.0
cost_c = 0.01
x_vals = collect(0:time_step_unit:num_time_steps*time_step_unit * 1/5)
line_plot = nothing 
yvals_dict = Dict()
for i in 1:length(language_names)
    y_vals = map(x -> gamma_c*x*accuracies[i] - cost_c *(memory_costs[i] + computational_costs[i] - 0.50), x_vals)
    if isnothing(line_plot)
        global line_plot = plot(x_vals, y_vals, size=(600, 450), xlims=(0.0, 0.01), ylims=(-0.0085, 0.0115), legend=:bottomright, label=join(split(language_names_pretty[i], "_")[2:end], " "), color = collect(palette(:tab10))[i], title="Utility vs. Cost Tolerance (Time)", xlabel="Cost Tolerance (Time)", ylabel="Utility")
    else
        global line_plot = plot(line_plot, x_vals, y_vals, size=(600, 450),  xlims=(0.0, 0.01), ylims=(-0.0085, 0.0115), legend=:bottomright, label=join(split(language_names_pretty[i], "_")[2:end], " "), color = collect(palette(:tab10))[i], title="Utility vs. Cost Tolerance (Time)",  xlabel="Cost Tolerance (Time)", ylabel="Utility")
    end
    yvals_dict[i] = y_vals
end

max_indexes = []
maxs = []
for i in 1:length(x_vals) 
    vals = map(arr -> arr[i], map(n -> yvals_dict[n], 1:length(language_names)))
    # println(vals)
    index = findall(v -> v == maximum(vals), vals)[1]
    push!(max_indexes, index)
    push!(maxs, join(split(language_names_pretty[index], "_")[2:end], " "))
    # println(maxs[end])
end

# line_plot

max_utility_plot = bar(ones(length(maxs)), color = map(i -> collect(palette(:tab10))[i], max_indexes), xrotation=305, size=(600, 100), legend=false, xlabel="LoT Stage", ylims=(0.0, 1.0), linecolor=:match)

# plot(line_plot, max_utility_plot, layout=(2, 1), size=(600, 550))
line_plot

# _, h0 = plot_heatmap(0, "t=0")
# _, h20 = plot_heatmap(1000, "t=100")
# _, h40 = plot_heatmap(2000, "t=200")
# _, h60 = plot_heatmap(3000, "t=300")
# _, h80 = plot_heatmap(4000, "t=400")
# _, h100 = plot_heatmap(5000, "t=500")
# plot(h0, h20, h40, h60, h80, h100)

transition_prob_identity_base = 0.99
transition_prob_identity_rate = 0.0003
transition_prob_base = 100.0 # 2
utility_base = 10000.0

max_lot_indexes = [1]
max_lots = [language_names_pretty[1]]
curr_distribution = map(x -> 0.0, 1:length(language_names))
curr_distribution[1] = 1.0
all_distributions = []
push!(all_distributions, curr_distribution)
for t in 0:time_step_unit:num_time_steps*time_step_unit
    utility_sum = sum(map(x -> utility_base^(compute_utility(x, t)), 1:length(language_names)))
    transition_probabilities, _ = plot_heatmap(t, "")
    next_distribution = map(x -> 0.0, 1:length(language_names))
    for i in 1:length(language_names)
        total = 0.0
        utility = utility_base^(compute_utility(i, t)) / utility_sum
        for j in 1:length(language_names)
            transition_prob = transition_probabilities[j][i]
            # if (j in [1, 2, 3, 4]) &&  (i in [8, 9, 10])
            #     transition_prob = 0
            # end

            total += transition_prob * utility * curr_distribution[j]
        end
        next_distribution[i] = total
    end
    next_distribution = next_distribution ./ sum(next_distribution)
    index = findall(v -> v == maximum(next_distribution), next_distribution)[1]
    push!(max_lot_indexes, index)
    push!(max_lots, join(split(language_names_pretty[index], "_")[2:end], " "))
    if max_lot_indexes[end] != max_lot_indexes[end - 1]
        println(t)
    end
    global curr_distribution = next_distribution
    # if curr_distribution[6] != 0
    #     println("hello 1")
    # end
    push!(all_distributions, curr_distribution)
    println(max_lots[end])

end

max_lot_plot = bar(ones(length(max_lots)), color = map(i -> collect(palette(:tab10))[i], max_lot_indexes), xrotation=305, size=(600, 100), legend=false, xlabel="LoT Stage", ylims=(0.0, 1.0), linecolor=:match)
# max_lot_plot
# plot(line_plot, max_lot_plot, layout=(2, 1), size=(600, 550))

# for d in all_distributions
#     println(d)
# end

# for i in 295:305
#     println(all_distributions[i])
# end

# heatmap_values = []
# for l1 in language_names 
#     push!(heatmap_values, [])
#     for l2 in language_names 
#         l1_spec = language_name_to_spec[l1]
#         l2_spec = language_name_to_spec[l2]
#         dist, s = distance_between_specs(l1_spec, l2_spec)
#         push!(heatmap_values[end], dist)
#     end
# end

dist_plot = nothing
dist_xs = collect(0:time_step_unit:num_time_steps*time_step_unit)
dist_ys = []
for i in 1:length(language_names)
    println(i)
    global dist_ys = map(t -> all_distributions[t][i], 1:length(dist_xs))
    if isnothing(dist_plot)
        global dist_plot = plot(dist_xs, dist_ys, color=collect(palette(:tab10))[i], label=language_names_pretty[i], legend=:outerbottom, size=(800, 600), title="Posterior over LoTs (Background Proposal x Utility-Based Acceptor)", ylabel="Probability", xlabel="Time")
    else
        global dist_plot = plot(dist_plot, dist_xs, dist_ys, color=collect(palette(:tab10))[i], label=language_names_pretty[i], legend=:outerbottom, size=(800, 600), title="Posterior over LoTs (Background Proposal x Utility-Based Acceptor)", ylabel="Probability", xlabel="Time")
    end
end

max_lot_plot

# dist_plot

# plot(dist_plot, max_lot_plot, layout=(2, 1))