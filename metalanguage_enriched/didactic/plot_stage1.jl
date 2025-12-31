include("../run_inference.jl")

# DEFINE LANGUAGES

language_names = map(x -> "L$(x)", 0:7)

language_names_pretty = [
    "L0_non_knower",
    "L1_one_knower",
    "L2_two_knower",
    "L3_three_knower",
    "L4_four_knower",
    "L5_CP_knower",
    "L6_CP_mapper",
    "L7_CP_unit_knower",
]

# take initial specs from old run_inference.jl implementation
L0_spec = specs[3] # non-knower
L1_spec = specs[4] # one-knower
L2_spec = specs[5] # two-knower
L3_spec = specs[6] # three-knower

# four-knower
L4_spec = deepcopy(L3_spec)
L4_spec["four_definition"] = "set.value == 4"

# CP-unit-knower
L7_spec = specs[end]
L7_spec["parallel_individuation_limit"] = 4
L7_spec["ANS_reconciled"] = true
L7_spec["unit_add"] = "unit_add_final"

# CP-mapper
L6_spec = deepcopy(L7_spec)
L6_spec["ANS_reconciled"] = true
L6_spec["unit_add"] = "unit_add_base"

# CP-knower
L5_spec = deepcopy(L6_spec)
L5_spec["ANS_reconciled"] = false
L5_spec["unit_add"] = "unit_add_base"

language_name_to_spec = Dict(map(i -> language_names[i] => eval(Meta.parse("L$(i - 1)_spec")), 1:8))


# TASKS
dataset = Dict([
    "give_1" => 40, # = GiveN("one")
    "give_2" => 20, # = GiveN("two")
    "give_3" => 10, # = GiveN("three")
    "give_4" => 5, # = GiveN("four")
    "give_5" => 2, # = GiveN("five")
    "give_6" => 2, # = GiveN("six")
    "give_7" => 2, # = GiveN("seven")
    "give_8" => 2, # = GiveN("eight")
    "give_9" => 1, # = GiveN("nine")
    "give_10" => 1, # = GiveN("ten")

    "how_many_1" => 1, #  = HowMany(Exact(1))
    "how_many_2" => 1, #  = HowMany(Exact(2))
    "how_many_3" => 1, #  = HowMany(Exact(3))
    "how_many_4" => 1, #  = HowMany(Exact(4))
    "how_many_5" => 1, #  = HowMany(Exact(5))
    "how_many_6" => 1, #  = HowMany(Exact(6))
    "how_many_7" => 1, #  = HowMany(Exact(7))
    "how_many_8" => 1, #  = HowMany(Exact(8))
    "how_many_9" => 1, #  = HowMany(Exact(9))
    "how_many_10" => 1, #  = HowMany(Exact(10))

    "how_many_5_blur" => 1, #  = HowMany(Blur(5))
    "how_many_6_blur" => 1, #  = HowMany(Blur(6))
    "how_many_7_blur" => 1, #  = HowMany(Blur(7))
    "how_many_8_blur" => 1, #  = HowMany(Blur(8))
    "how_many_9_blur" => 1, #  = HowMany(Blur(9))
    "how_many_10_blur" => 2, #  = HowMany(Blur(10))

    "more_1" => 2, 
    "more_2" => 2,

    "unit_add_1" => 5, 
    "unit_add_2" => 5,
])

total_tasks = sum(map(k -> dataset[k], [keys(dataset)...]))

# ACCURACIES
# base_accuracies = Dict()
# for language_name in language_names
#     println(language_name)
#     base_accuracies[language_name] = Dict()

#     spec = language_name_to_spec[language_name]

#     # construct and load language
#     language = generate_language(spec)
#     open("metalanguage_enriched/didactic/intermediate_outputs/current_language.jl", "w+") do f 
#         write(f, replace(language, "../../" => "../../../"))
#     end
#     include("intermediate_outputs/current_language.jl")

#     for task_name in keys(dataset) 
#         println(task_name)
#         single_task_dataset = Dict([eval(Symbol(task_name)) => 1])

#         # evaluate language on tasks
#         accuracy = compute_likelihood(single_task_dataset)
#         if !spec["ANS_reconciled"] && occursin("_blur", task_name)
#             accuracy = 0.0    
#         end
#         println(accuracy)
#         base_accuracies[language_name][task_name] = accuracy
#     end
# end

accuracies = []
for language_name in language_names 
    overall_accuracy = 0.0
    for task_name in keys(dataset)
        task_count = dataset[task_name]
        base_acc = base_accuracies[language_name][task_name]
        overall_accuracy += base_acc * task_count

    end
    overall_accuracy = overall_accuracy / total_tasks
    push!(accuracies, overall_accuracy)
end

# COSTS 

memory_costs = [ # TODO
    0.00, # L0: non-knower
    0.15, # L1: 1-knower
    0.30, # 2-knower
    # 0.34, # 2-knower, approx
    0.39, # 3-knower
    # 0.39, # 3-knower, approx 
    0.50, # 4-knower
    0.41, # CP-knower
    0.55, # CP-mapper
    0.70, # CP-unit-knower
]
memory_costs = memory_costs .* 2
computational_costs = [ # TODO
    0.48, # L0: non-knower
    0.50, # L1: 1-knower
    0.50, # 2-knower
    # 0.50, # 2-knower, approx
    0.50, # 3-knower
    # 0.50, # 3-knower, approx 
    0.50, # 4-knower
    0.70, # CP-knower
    0.675, # CP-mapper
    0.65, # CP-unit-knower
]
computational_costs = computational_costs

time_step_unit = 0.0001
num_time_steps = 1000

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
x_vals = collect(0:time_step_unit:num_time_steps*time_step_unit * 1/10)
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

function distance_between_specs(spec1, spec2)
    dist = 0
    for k in keys(spec1)
        if spec1[k] != spec2[k]
            dist += 0.1
        end
    end
    s = 0
    if dist != 0 
        if count(x -> x == true, collect(values(spec1))) > count(x -> x == true, collect(values(spec2)))
            s = 1 
        else
            s = -1
        end

        if spec1["full_knower_compression"] != "full_knower_compression" && spec2["full_knower_compression"] == "full_knower_compression" && (spec1["three_definition"] in ["set.value == 3"])
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

    heatmap_values_matrix = reshape(vcat(heatmap_values...), (length(language_names), length(language_names)))
    heatmap_values, heatmap(language_names, language_names, heatmap_values_matrix, aspect_ratio=:equal, clims=(0.0, 1.0), title=title, xrotation=270, tickfontsize=5, titlefontsize=11)
end


transition_prob_identity_base = 0.975
transition_prob_identity_rate = 0.0004 # 0.0003
transition_prob_base = 100.0 # 2
utility_base = 10000000000000.0

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

# max_lot_plot

# dist_plot

plot(dist_plot, max_lot_plot, layout=(2, 1))