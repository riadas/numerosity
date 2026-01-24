include("plot_stage4_morphology.jl")

(individual_dist_plot, 
grouped_dist_plot, 
accuracy_plot, 
memory_cost_plot, 
computation_cost_plot, 
line_plot, 
max_utility_plot, 
dist_plot, 
max_lot_plot,
CP_arrival_time,
one_arrival_time,
two_arrival_time) = run_test("english", false)

english_plots = [individual_dist_plot, dist_plot, max_lot_plot]
english_arrival_times = [one_arrival_time, two_arrival_time, CP_arrival_time]

include("plot_stage4_morphology.jl")
(individual_dist_plot, 
grouped_dist_plot, 
accuracy_plot, 
memory_cost_plot, 
computation_cost_plot, 
line_plot, 
max_utility_plot, 
dist_plot, 
max_lot_plot,
CP_arrival_time,
one_arrival_time,
two_arrival_time) = run_test("slovenian", false)

slovenian_plots = [individual_dist_plot, dist_plot, max_lot_plot]
slovenian_arrival_times = [one_arrival_time, two_arrival_time, CP_arrival_time]

include("plot_stage4_morphology.jl")
(individual_dist_plot, 
grouped_dist_plot, 
accuracy_plot, 
memory_cost_plot, 
computation_cost_plot, 
line_plot, 
max_utility_plot, 
dist_plot, 
max_lot_plot,
CP_arrival_time,
one_arrival_time,
two_arrival_time) = run_test("chinese", false)

chinese_plots = [individual_dist_plot, dist_plot, max_lot_plot]
chinese_arrival_times = [one_arrival_time, two_arrival_time, CP_arrival_time]

all_plots = plot(english_plots[1], slovenian_plots[1], chinese_plots[1],
                 english_plots[2], slovenian_plots[2], chinese_plots[2],
                 english_plots[3], slovenian_plots[3], chinese_plots[3],
                layout=(3, 3), size=(2400, 1200), dpi=600, linewidth=2, xlabel=false)

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
annotate!(x_labels[3:end], cp_induction_relative_rates[3:end], map(x -> "$(round(x, digits=1))%", cp_induction_relative_rates[3:end]), :bottom)

one_knower_rate_plot = bar(x_labels, one_knower_relative_rates, color = collect(palette(:tab10))[2], size=(600, 525), legend=false, xlabel="Language Category", ylabel="% Change", title="% Arrival Time Change of\nOne Knower Stage", ylims=(-25, 75))
annotate!(x_labels[1:1], one_knower_relative_rates[1:1], map(x -> "$(round(x, digits=1))%", one_knower_relative_rates[1:1]), :bottom)
annotate!(x_labels[2:2], one_knower_relative_rates[2:2], map(x -> "$(round(x, digits=1))%", one_knower_relative_rates[2:2]), :top)
annotate!(x_labels[3:end], one_knower_relative_rates[3:end], map(x -> "$(round(x, digits=1))%", one_knower_relative_rates[3:end]), :bottom)

bar_plot = plot(one_knower_rate_plot, CP_induction_rate_plot, layout=(1,2), size=(1000, 500))

plot(all_plots, bar_plot, layout=(2,1))