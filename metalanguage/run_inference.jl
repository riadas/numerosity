include("metalanguage.jl")
include("../task_configs/generate_tasks.jl")
using Plots
using Combinatorics

global scale = 1 # 0.000000001

global alpha_num_defined = 0.0000000000000000000000000000000000001 * scale 
global alpha_full_knower_compression = 0.0000000000000000000000000000000000000000000000000000000000000000000000001 * scale
global alpha_ANS_reconciled = 0.0000000001 * scale

function compute_prior(spec_name)
    defined_subset_numbers, full_knower_compression, ANS_reconciled = eval(Meta.parse(spec_name))
    prob = 1.0
    
    prob = prob * alpha_num_defined^(length(defined_subset_numbers))

    if full_knower_compression 
        prob = prob * alpha_full_knower_compression
    else
        prob = prob * (1 - alpha_full_knower_compression)
    end

    if ANS_reconciled 
        prob = prob * alpha_ANS_reconciled
    else
        prob = prob * (1 - alpha_ANS_reconciled)
    end

    # TODO: not yet normalized

    return prob
end

function compute_likelihood(dataset)
    prob = 1.0
    for task in keys(dataset)
        task_prob = evaluate(task)
        prob = prob * (task_prob)^(dataset[task])
    end
    prob
end

# generate all combinations
defined_exact_subset = collect(combinations(1:10)) # collect(combinations(1:max_num))
raw_specs = collect(Iterators.product(defined_exact_subset, [true, false], [true, false]))

# default spec
default_spec = Dict([

    "one_definition" => "true",
    "two_definition" => "true",
    "three_definition" => "true",
    "four_definition" => "true",
    "five_definition" => "true",
    "six_definition" => "true",
    "seven_definition" => "true",
    "eight_definition" => "true",
    "nine_definition" => "true",
    "ten_definition" => "true",

    "five_definition_blur" => "true",
    "six_definition_blur" => "true",
    "seven_definition_blur" => "true",
    "eight_definition_blur" => "true",
    "nine_definition_blur" => "true",
    "ten_definition_blur" => "true",
    
    "list_syntax_next_two" => "two",
    "list_syntax_next_three" => "three",
    "list_syntax_next_four" => "four",
    "list_syntax_next_five" => "five",
    "list_syntax_next_six" => "six",
    "list_syntax_next_seven" => "seven",
    "list_syntax_next_eight" => "eight",
    "list_syntax_next_nine" => "nine",
    "list_syntax_next_ten" => "ten",

    "full_knower_compression" => false, 
    "ANS_reconciled" => false,
])

specs = []
spec_names = []
push!(specs, default_spec)
push!(spec_names, "Any[Any[], false, false]")
for raw_spec in raw_specs 
    spec = deepcopy(default_spec)

    defined_subset_numbers, full_knower_compression, ANS_reconciled = raw_spec

    if length(intersect([1, 2, 3], defined_subset_numbers)) != 3 && full_knower_compression || !full_knower_compression && ANS_reconciled
        continue
    end

    if full_knower_compression 
        spec["full_knower_compression"] = true
        spec["one_definition"] = "set.value == 1"
        for i in 2:max_num 
            spec["$(nums_to_number_words[i])_definition"] = compressed_exact_definition
        end
    else
        undefined_subset_numbers = filter(x -> !(x in defined_subset_numbers), 1:max_num)
        undefined_definition_list = "[$(join(map(x -> nums_to_number_words[x], defined_subset_numbers), ", "))]"
        undefined_definition = "not(map(x -> Base.invokelatest(x, set), $(undefined_definition_list)))"
        for i in undefined_subset_numbers 
            spec["$(nums_to_number_words[i])_definition"] = undefined_definition
        end

        for i in defined_subset_numbers 
            spec["$(nums_to_number_words[i])_definition"] = "set.value == $(i)"
        end
    end

    spec["ANS_reconciled"] = ANS_reconciled
    if ANS_reconciled 
        for k in filter(x -> occursin("definition_blur", x), collect(keys(spec)))
            spec[k] = ANS_blur_definition
        end
    end

    push!(specs, spec)
    push!(spec_names, string([defined_subset_numbers, full_knower_compression, ANS_reconciled]))
end

intervened_spec_names = [
    [[], false, false],
    [[1], false, false],
    [[1, 2], false, false],
    [[1, 2, 3], false, false],
    # [[1, 2, 3, 4], false, false],
    [[1, 2, 3], true, false],
    [[1, 2, 3], true, true]
]
intervened_spec_names = map(x -> string(x), intervened_spec_names)
# indices = map(x -> findall(y -> y == x, spec_names)[1], intervened_spec_names)
# specs = map(i -> specs[i], indices)
# spec_names = intervened_spec_names
intervened_spec_names_pretty = [
    "non-knower",
    "one-knower",
    "two-knower",
    "three-knower",
    # "four-knower",
    "full-knower, ANS unreconciled",
    "full-knower, ANS reconciled",
]

spec_names_pretty = Dict(map(x -> x => "", spec_names))
for i in 1:length(intervened_spec_names)
    spec_names_pretty[string(intervened_spec_names[i])] = intervened_spec_names_pretty[i]
end

dataset = Dict([
    give_1 => 20, # = GiveN("one")
    give_2 => 15, # = GiveN("two")
    give_3 => 10, # = GiveN("three")
    give_4 => 5, # = GiveN("four")
    give_5 => 1, # = GiveN("five")
    give_6 => 1, # = GiveN("six")
    give_7 => 1, # = GiveN("seven")
    give_8 => 1, # = GiveN("eight")
    give_9 => 1, # = GiveN("nine")
    give_10 => 1, # = GiveN("ten")

    how_many_1 => 1, #  = HowMany(Exact(1))
    how_many_2 => 1, #  = HowMany(Exact(2))
    how_many_3 => 1, #  = HowMany(Exact(3))
    how_many_4 => 1, #  = HowMany(Exact(4))
    how_many_5 => 1, #  = HowMany(Exact(5))
    how_many_6 => 1, #  = HowMany(Exact(6))
    how_many_7 => 1, #  = HowMany(Exact(7))
    how_many_8 => 1, #  = HowMany(Exact(8))
    how_many_9 => 1, #  = HowMany(Exact(9))
    how_many_10 => 1, #  = HowMany(Exact(10))

    how_many_5_blur => 1, #  = HowMany(Blur(5))
    how_many_6_blur => 1, #  = HowMany(Blur(6))
    how_many_7_blur => 1, #  = HowMany(Blur(7))
    how_many_8_blur => 1, #  = HowMany(Blur(8))
    how_many_9_blur => 1, #  = HowMany(Blur(9))
    how_many_10_blur => 1, #  = HowMany(Blur(10))

    compare_exact => 1,
    compare_blur => 1,
    compare_across => 1,
])

println("length(specs): $(length(specs))")
max_repeats = 10
single_repeat_results = Dict()
results = Dict()
for repeats in 1:max_repeats 
    results[repeats] = Dict()
    for i in 1:length(specs)
        println("repeats = $(repeats), spec index = $(i)")
        spec = specs[i]
        spec_name = spec_names[i]

        # construct and load language
        language = generate_language(spec)
        open("metalanguage/intermediate_outputs/current_language.jl", "w+") do f 
            write(f, language)
        end
        include("intermediate_outputs/current_language.jl")

        if repeats == 1 
            # compute prior
            prior = compute_prior(spec_name)

            # evaluate language on tasks
            likelihood = (compute_likelihood(dataset))^repeats

            single_repeat_results[spec_name] = (prior, likelihood)
        end

        prior, likelihood_single_repeat = single_repeat_results[spec_name]
        results[repeats][spec_name] = prior * (likelihood_single_repeat)^repeats
    end
end

# TODO: plot results
for repeats in 1:max_repeats
    println("REPEATS: $(repeats)")
    i = findall(name -> results[repeats][name] == maximum(map(n -> results[repeats][n], spec_names)),  spec_names)[1]
    map_spec_name = spec_names[i]
    println(map_spec_name)
end

sums = map(r -> sum(collect(values(results[r]))), 1:max_repeats)

# # pretty_spec_names = ["chance language, no impos", "chance language, with impos", "minimal language, i.e. propositional logic", "modal language, i.e. first-order logic"]

p = plot(1:max_repeats, collect(1:max_repeats) * 1/max_repeats, color="white", label=false)
for i in 1:length(spec_names)
    spec_name = spec_names[i]
    # println(spec_name)
    # println("\tprior: $(priors[i])")
    # println("\tlikelihood: $(likelihoods[i])")
    
    p = plot!(collect(1:max_repeats), map(r -> results[r][spec_name], 1:max_repeats) ./ sums, legend=false, label="") # legend=:outerbottom 
    
end

sort!(spec_names, by=x -> x in intervened_spec_names ? findall(y -> y == x, intervened_spec_names)[1] : 10)

for i in 1:length(spec_names)
    spec_name = spec_names[i]
    # println("\tprior: $(priors[i])")
    # println("\tlikelihood: $(likelihoods[i])")
    if spec_name in intervened_spec_names
        println(spec_name)
        p = plot!(collect(1:max_repeats), map(r -> results[r][spec_name], 1:max_repeats) ./ sums, label = "$(spec_names_pretty[spec_name])", legend=:outerbottom) # legend=:outerbottom 
    end
end

# for spec_name in intervened_spec_names
#     p = plot!(collect(1:max_repeats), map(r -> results[r][spec_name], 1:max_repeats) ./ sums, label = "$(spec_names_pretty[spec_name])", legend=:outerbottom) # legend=:outerbottom 
# end

xlabel!("Training Data Volume", xguidefontsize=9)
ylabel!("Proportion", yguidefontsize=9)
title!("Relative Proportions of Number LoTs", titlefontsize=10)

p