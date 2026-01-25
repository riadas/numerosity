# compute baseline CP arrival time
# model_file_name = "plot_stage3.jl"
# model_file_name = "plot_stage4_morphology.jl"
# model_file_name = "plot_stage5_extra_hypotheses.jl"
model_file_name = "plot_stage6_updated_task_dist.jl"
# global repeat_suffix = "_repeat2"

include(model_file_name)
test_name = "english"
println("INTERVENTION REPEAT 0")
baseline_CP_arrival_time = run_test(test_name, false)[end - 2]
# baseline_CP_arrival_time = 1199
# compute CP arrival time given interventions at the three-knower stage
intervention_arrival_times = []

intervention_params = [
    (true, false),
    (false, false),
    (true, true),
    (false, true),
]
labels = [
    "low number\nwords", 
    "high number\nwords", 
    "low number\ncounts", 
    "high number\ncounts"
]

counting_task_proportions = []
relate_factor_reaches_one = []
all_relate_factors = []
push!(relate_factor_reaches_one, findall(x -> x == 1.0, relate_factors) != [] ? findall(x -> x == 1.0, relate_factors)[1] : relate_factors[end])
push!(all_relate_factors, relate_factors)
for i in 1:length(intervention_params)
    println("INTERVENTION REPEAT $(i)")
    @show i
    include(model_file_name)
    ip = intervention_params[i]
    low_param, count_param = ip
    arrival_time = run_test(test_name, false, true, low_param, count_param)[end - 2]
    println("""$(replace(labels[i], "\n" => " ")): $(arrival_time)""")
    push!(intervention_arrival_times, arrival_time)
    push!(counting_task_proportions, counting_task_proportion)
    push!(relate_factor_reaches_one, findall(x -> x == 1.0, relate_factors) != [] ? findall(x -> x == 1.0, relate_factors)[1] : -1)
    push!(all_relate_factors, relate_factors)
end

println(labels)
println(intervention_arrival_times)
println(counting_task_proportions)
@show intervention_arrival_times
# intervention plot
x = (1 .- intervention_arrival_times ./ baseline_CP_arrival_time) * 100
# x = (1 .- [1053, 949, 944, 949] ./ 1106) * 100
bar(labels, x, legend=false, xtickfontsize=12, xlabel="Intervention Type", ylabel="% Reduction", ytickfontsize=12, yguidefontsize=18, xguidefontsize=18, title="Percent Reduction in CP-Knower Acquisition Time\nvs. Intervention Type", titlefontsize=21, annotationfontsize=1, ylims=(0.0, 3.0), size=(1000, 1000))
annotate!(labels, x, map(a -> "$(round(a, digits=2))%", x), :bottom)
