# compute baseline CP arrival time
include("plot_stage3.jl")
test_name = "english"
baseline_CP_arrival_time = run_test(test_name, false)[end]

# compute CP arrival time given interventions at the three-knower stage
intervention_arrival_times = []

intervention_params = [
    (true, false),
    (false, false),
    (true, true),
    (false, true),
]
labels = ["low number\nwords", "high number\nwords", "low number\ncounts", "high number\ncounts"]

for i in 1:length(intervention_params)
    include("plot_stage3.jl")
    ip = intervention_params[i]
    low_param, count_param = ip
    arrival_time = run_test(test_name, false, true, low_param, count_param)[end]
    println("""$(replace(labels[i], "\n" => " ")): $(arrival_time)""")
    push!(intervention_arrival_times, arrival_time)
end

# intervention plot
x = (1 .- intervention_arrival_times ./ baseline_CP_arrival_time) * 100
# x = (1 .- [1053, 949, 944, 949] ./ 1106) * 100
bar(labels, x, legend=false, xtickfontsize=12, xlabel="Intervention Type", ylabel="% Reduction", ytickfontsize=12, yguidefontsize=18, xguidefontsize=18, title="Percent Reduction in CP-Knower Acquisition Time\nvs. Intervention Type", titlefontsize=21, annotationfontsize=1, ylims=(0.0, 20.0), size=(1000, 1000))
annotate!(labels, x, map(a -> "$(round(a, digits=2))%", x), :bottom)