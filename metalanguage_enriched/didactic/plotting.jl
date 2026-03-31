function plot_individual_task_distribution(test_name_="english")
    task_dict = test_name_to_task_dict[test_name_][1]

    task_count_dict = Dict([
        "c_More" => 0.0,
        "d_Unit Addition" => 0.0,
    ])

    for k in keys(task_dict)
        if occursin("give_", k) || occursin("how_many_", k) && !occursin("blur", k)
            num = parse(Int, split(k, "_")[end])
            task_name = "$(num < 10 ? string(0, num) : string(num))_Give $(num)"
            @show task_name
            @show num
            @show task_dict[k]
            if task_name in keys(task_count_dict)
                task_count_dict[task_name] += task_dict[k]
            else
                task_count_dict[task_name] = task_dict[k]
            end
        elseif occursin("blur", k)
            num = parse(Int, split(k, "_")[end - 1])
            task_count_dict["b$(num < 10 ? string(0, num) : string(num))_Fast Dots $(num)"] = task_dict[k]
        elseif occursin("more", k)
            task_count_dict["c_More"] += task_dict[k]
        elseif occursin("unit", k)
            task_count_dict["d_Unit Addition"] += task_dict[k]
        end
    end

    colors = collect(palette(:tab10))[2:5] # 1-4
    push!(colors, reverse(collect(palette(:vik25)))[3:8]...) # 5-10
    push!(colors, collect(palette(:tab10))[7]) # fast dots 5
    push!(colors, reverse(collect(palette(:RdPu_9))[1:5])...)
    push!(colors, collect(palette(:tab20))[14]) # more 
    push!(colors, collect(palette(:tab20))[15]) # unit add

    task_group_names = sort(collect(keys(task_count_dict)))
    counts = map(group_name -> task_count_dict[group_name], task_group_names)
    proportions = counts ./ sum(counts)
    println(map(x -> split(x, "_")[end], task_group_names))
    curriculum_plot = bar(xticks=(1:length(task_group_names), map(x -> split(x, "_")[end], task_group_names)), proportions, color=colors, size=(640, 525), xrotation=305, bar_width=1, xlabel="Task Type", ylabel="Proportion", legend=false, titlefontsize=13, xtickfontsize=9, xguidefontsize=11, yguidefontsize=10, title="Task Distribution", ylims=(0.0, 0.6))
    curriculum_plot
end

function plot_grouped_task_distribution(test_name_="english")
    task_dict = test_name_to_task_dict[test_name_][1]
    task_count_dict = Dict([
        "1_Give N" => 0.0,
        "2_Fast Dots" => 0.0,
        "3_More" => 0.0,
        "4_Unit Addition" => 0.0,
    ])

    original_colors = collect(palette(:tab20))
    new_colors = [
        original_colors[3],
        original_colors[13],
        original_colors[14],
        original_colors[15],
    ]

    for k in keys(task_dict)
        if occursin("give", k)
            task_count_dict["1_Give N"] += task_dict[k]
        elseif occursin("blur", k)
            task_count_dict["2_Fast Dots"] += task_dict[k]
        elseif occursin("more", k)
            task_count_dict["3_More"] += task_dict[k]
        elseif occursin("unit", k)
            task_count_dict["4_Unit Addition"] += task_dict[k]
        end
    end

    task_group_names = sort(collect(keys(task_count_dict)))
    counts = map(group_name -> task_count_dict[group_name], task_group_names)
    proportions = counts ./ sum(counts)
    println(map(x -> split(x, "_")[end], task_group_names))
    curriculum_plot = bar(xticks=(1:length(task_group_names), map(x -> split(x, "_")[end], task_group_names)), color=new_colors, proportions, size=(640, 525), xrotation=305, bar_width=1, xlabel="Task Category", ylabel="Proportion", legend=false, titlefontsize=11, xtickfontsize=7, xguidefontsize=10, yguidefontsize=10, title="Task Category Distribution", ylims=(0.0, 1.0))
    curriculum_plot
end

function plot_accuracy(accuracies, colors, figure=false)
    language_names_pretty_bar_plot = filter(x -> !occursin("LXP", x), language_names_pretty)
    accuracies_subset = accuracies[1:length(language_names_pretty_bar_plot)]
    if figure 
        accuracies_subset = (accuracies_subset .- 0.7) ./ 0.3
    end

    accuracy_plot = bar(map(x -> join(split(x, "_")[2:end], " "), language_names_pretty_bar_plot), accuracies_subset, color = colors, xrotation=305, size=(600, 525), legend=false, xlabel="LoT Stage", ylabel="Accuracy", title="Task Accuracy", ylims=(0.0, 1.0))
    accuracy_plot
end

function plot_memory_costs(memory_costs, colors)
    language_names_pretty_bar_plot = filter(x -> !occursin("LXP", x), language_names_pretty)
    memory_costs_subset = memory_costs[1:length(language_names_pretty_bar_plot)]

    memory_cost_plot = bar(map(x -> join(split(x, "_")[2:end], " "), language_names_pretty_bar_plot), memory_costs_subset ./ maximum(memory_costs_subset), color = colors, xrotation=305, size=(600, 525), legend=false, xlabel="LoT Stage", ylabel="Cost", title="Memory Cost", ylims=(0.0, 1.0))
    memory_cost_plot
end

function plot_computational_costs(computational_costs, colors)
    language_names_pretty_bar_plot = filter(x -> !occursin("LXP", x), language_names_pretty)
    computation_costs_subset = computational_costs[1:length(language_names_pretty_bar_plot)]

    computation_cost_plot = bar(map(x -> join(split(x, "_")[2:end], " "), language_names_pretty_bar_plot), computation_costs_subset ./ maximum(computation_costs_subset), color = colors, xrotation=305, size=(600, 525), legend=false, xlabel="LoT Stage", ylabel="Cost", title="Computation Cost", ylims=(0.0, 1.0))
    computation_cost_plot
end

function plot_utility_components(accuracies, memory_costs, computational_costs, colors, figure=false)
    accuracy_plot = plot_accuracy(accuracies, colors, figure)

    memory_cost_plot = plot_memory_costs(memory_costs, colors)

    computation_cost_plot = plot_computational_costs(computational_costs, colors)

    (accuracy_plot, memory_cost_plot, computation_cost_plot)
    # plot(accuracy_plot, memory_cost_plot, computation_cost_plot, layout=(3, 1), size=(600, 525 * 3))
end

function plot_utility_evolution(colors)
    x_vals = collect(0:time_step_unit:num_time_steps*time_step_unit)
    line_plot = nothing 
    yvals_dict = Dict()
    max_yvals = 0.0
    min_yvals = 0.0
    for i in 1:length(language_names)
        y_vals = map(x -> compute_utility(i, x), x_vals)
        max_yvals = maximum([max_yvals, maximum(y_vals)])
        min_yvals = minimum([min_yvals, minimum(y_vals)])

        if isnothing(line_plot)
            line_plot = plot(x_vals, y_vals, size=(600, 450), xlims=(0.0, x_vals[end]), ylims=(min_yvals, max_yvals), legend=:bottomright, label=occursin("LXP", language_names_pretty[i]) ? "" : join(split(language_names_pretty[i], "_")[2:end], " "), color = colors[i], title="Utility vs. Cost Tolerance (Time)", xlabel="Cost Tolerance (Time)", ylabel="Utility")
        else
            line_plot = plot(line_plot, x_vals, y_vals, size=(600, 450),  xlims=(0.0, x_vals[end]), ylims=(min_yvals, max_yvals), legend=:bottomright, label=occursin("LXP", language_names_pretty[i]) ? "" : join(split(language_names_pretty[i], "_")[2:end], " "), color = colors[i], title="Utility vs. Cost Tolerance (Time)",  xlabel="Cost Tolerance (Time)", ylabel="Utility")
        end
        yvals_dict[i] = y_vals
    end

    max_indexes = []
    maxs = []
    for i in 1:length(x_vals) 
        vals = map(arr -> arr[i], map(n -> yvals_dict[n], 1:length(language_names)))
        # @show vals
        index = findall(v -> v == maximum(vals), vals)[1]
        push!(max_indexes, index)
        push!(maxs, join(split(language_names_pretty[index], "_")[2:end], " "))
        # println(maxs[end])
    end

    max_utility_plot = bar(ones(length(maxs)), color = map(i -> colors[i], max_indexes), xrotation=305, size=(600, 100), legend=false, xlabel="LoT Stage", ylims=(0.0, 1.0), linecolor=:match)

    (maxs, line_plot, max_utility_plot)
    # plot(line_plot, max_utility_plot, layout=(2, 1), size=(600, 550))
end

function plot_cross_linguistic_diversity_results(english_plots, english_arrival_times, chinese_plots, chinese_arrival_times, slovenian_plots, slovenian_arrival_times)
    all_plots = plot(plot(english_plots[1], ylims=(0.0, 0.65)), plot(slovenian_plots[1], ylims=(0.0, 0.65)), plot(chinese_plots[1], ylims=(0.0, 0.65)),
                    english_plots[2], slovenian_plots[2], chinese_plots[2],
                    english_plots[3], slovenian_plots[3], chinese_plots[3],
                    layout=(3, 3), size=(2400, 1200), dpi=600, linewidth=3, xlabel="", ylabel="")

    println("english, slovenian, chinese")
    println("one, two, CP")
    println("$(english_arrival_times[1]), $(english_arrival_times[2]), $(english_arrival_times[3])")
    println("$(slovenian_arrival_times[1]), $(slovenian_arrival_times[2]), $(slovenian_arrival_times[3])")
    println("$(chinese_arrival_times[1]), $(chinese_arrival_times[2]), $(chinese_arrival_times[3])")

    one_knower_arrivals = Dict("slovenian" => slovenian_arrival_times[1], "english" => english_arrival_times[1], "chinese" => chinese_arrival_times[1])
    cp_induction_arrivals = Dict("slovenian" => slovenian_arrival_times[end], "english" => english_arrival_times[end], "chinese" => chinese_arrival_times[end])

    x_labels = ["English\nRussian\nSpanish\n(singular-plural)", "Chinese\nJapanese\nBasque\n(no singular-plural)", "Slovenian\nArabic\n(singular-dual-plural)"]
    cp_induction_relative_rates = [0, (cp_induction_arrivals["chinese"] / cp_induction_arrivals["english"]) - 1, cp_induction_arrivals["slovenian"] / cp_induction_arrivals["english"] - 1] * 100
    one_knower_relative_rates = [0, (one_knower_arrivals["chinese"] / one_knower_arrivals["english"]) - 1, one_knower_arrivals["slovenian"] / one_knower_arrivals["english"] - 1] * 100

    x_labels = [x_labels[1], x_labels[3], x_labels[2]]
    cp_induction_relative_rates = [cp_induction_relative_rates[1], cp_induction_relative_rates[3], cp_induction_relative_rates[2]]
    one_knower_relative_rates = [one_knower_relative_rates[1], one_knower_relative_rates[3], one_knower_relative_rates[2]]

    CP_induction_rate_plot = bar(x_labels, cp_induction_relative_rates, color = collect(palette(:tab10))[6], size=(600, 525), legend=false, xlabel="Language Category", ylabel="% Change", title="% Arrival Time Change of\nCP Induction", ylims=(-25, 75))
    annotate!(x_labels[1:1], cp_induction_relative_rates[1:1], map(x -> "$(round(x, digits=1))%", cp_induction_relative_rates[1:1]), :bottom, fontsize=6)
    annotate!(x_labels[2:2], cp_induction_relative_rates[2:2], map(x -> "$(round(x, digits=1))%", cp_induction_relative_rates[2:2]), :bottom)
    annotate!(x_labels[3:end], cp_induction_relative_rates[3:end], map(x -> "$(round(x, digits=1))%", cp_induction_relative_rates[3:end]), :top)

    one_knower_rate_plot = bar(x_labels, one_knower_relative_rates, color = collect(palette(:tab10))[2], size=(600, 525), legend=false, xlabel="Language Category", ylabel="% Change", title="% Arrival Time Change of\nOne Knower Stage", ylims=(-25, 75))
    annotate!(x_labels[1:1], one_knower_relative_rates[1:1], map(x -> "$(round(x, digits=1))%", one_knower_relative_rates[1:1]), :bottom)
    annotate!(x_labels[2:2], one_knower_relative_rates[2:2], map(x -> "$(round(x, digits=1))%", one_knower_relative_rates[2:2]), :top)
    annotate!(x_labels[3:end], one_knower_relative_rates[3:end], map(x -> "$(round(x, digits=1))%", one_knower_relative_rates[3:end]), :bottom)

    bar_plot = plot(one_knower_rate_plot, CP_induction_rate_plot, layout=(1,2), size=(1000, 500))

    (all_plots, bar_plot)
end
