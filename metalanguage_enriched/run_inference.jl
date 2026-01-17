include("metalanguage.jl")
include("../task_configs/generate_tasks.jl")
using Plots
using Combinatorics

global scale = 100000000000000000000000000000000000000000000000 # 0.000000001

global alpha_num_defined = 0.00000000000000000000000000000000000000000000000000000000001
global alpha_full_knower_compression = 0.00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001
global alpha_count_active_compression = 0.000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001 # TODO
global alpha_count_passive_compression = 0.000000000000000000000000000000000000001 # TODO 
global alpha_ANS_reconciled = 0.00000000000000000000001
global alpha_represent_unknown_def = 0.9
global alpha_parallel_individuation_limit = 0.97

function compute_prior(spec_name)
    defined_subset_numbers, full_knower_compression, ANS_reconciled, represent_unknown_def, parallel_individuation_lim = eval(Meta.parse(spec_name))
    prob = scale * 1.0
    
    prob = prob * alpha_num_defined^(length(defined_subset_numbers))

    if full_knower_compression == "full_knower_compression"
        prob = prob * alpha_full_knower_compression
    elseif full_knower_compression == "count_active"
        prob = prob * alpha_count_active_compression
    elseif full_knower_compression == "count_passive"
        prob = prob * alpha_count_passive_compression
    else 
        # println("huh")
        # println((1 - alpha_full_knower_compression - alpha_count_active_compression - alpha_count_passive_compression))
        prob = prob * (1 - alpha_full_knower_compression - alpha_count_active_compression - alpha_count_passive_compression)
    end

    if ANS_reconciled 
        prob = prob * alpha_ANS_reconciled
    else
        prob = prob * (1 - alpha_ANS_reconciled)
    end

    if occursin("base", represent_unknown_def)
        prob = prob * alpha_represent_unknown_def
    else
        prob = prob * (1 - alpha_represent_unknown_def)
    end

    if parallel_individuation_lim == 3 
        prob = prob * alpha_parallel_individuation_limit
    else
        prob = prob * (1 - alpha_parallel_individuation_limit)
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
defined_exact_subset = [[], collect(combinations(1:4))...] # collect(combinations(1:max_num)) # 1:4
raw_specs = collect(Iterators.product(defined_exact_subset, ["none", "count_passive", "count_active", "full_knower_compression"], [true, false], ["represent_unknown_base_definition", "represent_unknown_intermediate_definition"], [3, 4]))

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

    "full_knower_compression" => "none", 
    "ANS_reconciled" => false,

    "parallel_individuation_limit" => 3,
    "represent_unknown_definition" => "represent_unknown_base_definition",

    "unit_add" => "unit_add_base",
    "give_n_definition" => "give_n_standard_definition", # give_n_passive_count_definition
    "approx" => false,
    "quantifier_structure" => Dict(),
])

specs = []
spec_names = []
# push!(specs, default_spec)
# push!(spec_names, """Any[Any[], false, false, "represent_unknown_base_definition", 3]""")
for raw_spec in raw_specs 
    spec = deepcopy(default_spec)

    defined_subset_numbers, full_knower_compression, ANS_reconciled, represent_unknown, parallel_individuation_lim = raw_spec

    if length(intersect([1, 2, 3], defined_subset_numbers)) != 3 && full_knower_compression != "none" || full_knower_compression == "none" && ANS_reconciled
        continue
    end

    spec["parallel_individuation_limit"] = parallel_individuation_lim
    spec["full_knower_compression"] = full_knower_compression

    if full_knower_compression == "full_knower_compression"
        spec["one_definition"] = "set.value == 1"
        for i in 2:max_num 
            spec["$(nums_to_number_words[i])_definition"] = compressed_exact_definition
        end
        spec["represent_unknown_definition"] = "represent_unknown_final_definition"
        spec["unit_add"] = "unit_add_final"
    elseif full_knower_compression == "count_active"
        for i in 1:max_num 
            spec["$(nums_to_number_words[i])_definition"] = "set.value == number_words_to_nums[count_active(Exact(($i)))[end]]"
        end
        spec["represent_unknown_definition"] = represent_unknown
    elseif full_knower_compression == "count_passive"
        for i in 1:max_num 
            spec["$(nums_to_number_words[i])_definition"] = "set.value == number_words_to_nums[count_passive(Exact(($i)))[end]]"
        end
        spec["give_n_definition"] = "give_n_passive_count_definition"
        spec["represent_unknown_definition"] = represent_unknown
    else # full_knower_compression == "none"
        undefined_subset_numbers = filter(x -> !(x in defined_subset_numbers), 1:max_num)
        undefined_definition_list = "[$(join(map(x -> nums_to_number_words[x], defined_subset_numbers), ", "))]"
        undefined_definition = "not(map(x -> Base.invokelatest(x, set), $(undefined_definition_list)))"
        for i in undefined_subset_numbers 
            spec["$(nums_to_number_words[i])_definition"] = undefined_definition
        end

        for i in defined_subset_numbers 
            spec["$(nums_to_number_words[i])_definition"] = "set.value == $(i)"
        end
        spec["represent_unknown_definition"] = represent_unknown
    end

    spec["ANS_reconciled"] = ANS_reconciled
    if ANS_reconciled 
        for k in filter(x -> occursin("definition_blur", x), collect(keys(spec)))
            spec[k] = ANS_blur_definition
        end
        if full_knower_compression == "count_active" && spec["represent_unknown_definition"] == "represent_unknown_intermediate_definition"
            spec["represent_unknown_definition"] = "represent_unknown_final_definition"
        end
    end

    push!(specs, spec)
    push!(spec_names, string([defined_subset_numbers, full_knower_compression, ANS_reconciled, represent_unknown, parallel_individuation_lim]))
end

intervened_spec_names = [
    [[], "none", false, "represent_unknown_base_definition", 3],
    [[], "none", false, "represent_unknown_intermediate_definition", 3],
    [[], "none", false, "represent_unknown_intermediate_definition", 4],
    [[1], "none", false, "represent_unknown_intermediate_definition", 4],
    [[1, 2], "none", false, "represent_unknown_intermediate_definition", 4],
    [[1, 2, 3], "none", false, "represent_unknown_intermediate_definition", 4],
    [[1, 2, 3], "count_passive", false, "represent_unknown_intermediate_definition", 4],
    [[1, 2, 3], "count_active", false, "represent_unknown_intermediate_definition", 4],
    [[1, 2, 3], "count_active", true, "represent_unknown_intermediate_definition", 3],
    # [[1, 2, 3, 4], false, false],
    [[1, 2, 3], "full_knower_compression", false, "represent_unknown_base_definition", 3],
    [[1, 2, 3], "full_knower_compression", true, "represent_unknown_base_definition", 3]
]
intervened_spec_names = map(x -> replace(string(x), "Any[[" => "Any[Any["), intervened_spec_names)
specs = map(name -> specs[findall(x -> x == name, spec_names)[1]], intervened_spec_names)
spec_names = intervened_spec_names

@show length(specs)
@show length(spec_names)

# indices = map(x -> findall(y -> y == x, spec_names)[1], intervened_spec_names)
# specs = map(i -> specs[i], indices)
# spec_names = intervened_spec_names
intervened_spec_names_pretty = [
    "non-knower, parallel indiv. limit=3",
    "non-knower, parallel indiv. limit=3, count seq. ~ quantity",
    "non-knower, parallel indiv. limit=4, count seq. ~ quantity",
    "one-knower, parallel indiv. limit=4",
    "two-knower, parallel indiv. limit=4",
    "three-knower, parallel indiv. limit=4",
    "passive CP induction, ANS unreconciled",
    "active CP induction, ANS unreconciled",
    "active CP induction, ANS reconciled",
    # "four-knower",
    "full-knower, ANS unreconciled",
    "full-knower, ANS reconciled (exact unit difference learned)",
]
spec_names_pretty = Dict(map(x -> x => "", spec_names))
for i in 1:length(intervened_spec_names)
    spec_names_pretty[string(intervened_spec_names[i])] = intervened_spec_names_pretty[i]
end

dataset = Dict([
    give_1 => 15, # = GiveN("one")
    give_2 => 12, # = GiveN("two")
    give_3 => 9, # = GiveN("three")
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
    how_many_10_blur => 2, #  = HowMany(Blur(10))

    compare_exact => 1,
    compare_blur => 1,
    compare_across => 1,

    labeled_compare_2_4_no_count => 1,
    labeled_compare_2_4_correct_count => 1,

    labeled_compare_4_6_no_count => 1,
    labeled_compare_4_6_correct_count => 1,

    # labeled_compare_3_4_no_count => 1,
    labeled_compare_3_4_correct_count => 1,

    more_1 => 1, 
    more_2 => 1,

    unit_add_1 => 1, 
    unit_add_2 => 2,
])

# println("length(specs): $(length(specs))")
# max_repeats = 20
# single_repeat_results = Dict()
# results = Dict()
# for repeats in 1:max_repeats 
#     results[repeats] = Dict()
#     for i in 1:length(specs)
#         println("repeats = $(repeats), spec index = $(i)")
#         spec = specs[i]
#         spec_name = spec_names[i]

#         # construct and load language
#         language = generate_language(spec)
#         open("metalanguage_enriched/intermediate_outputs/current_language.jl", "w+") do f 
#             write(f, language)
#         end
#         include("intermediate_outputs/current_language.jl")

#         if repeats == 1 
#             # compute prior
#             prior = compute_prior(spec_name)

#             # evaluate language on tasks
#             likelihood = (compute_likelihood(dataset))^repeats

#             single_repeat_results[spec_name] = (prior, likelihood)
#         end

#         prior, likelihood_single_repeat = single_repeat_results[spec_name]
#         results[repeats][spec_name] = prior * (likelihood_single_repeat)^repeats
#         println("prior: $(prior)")
#         println("likelihood: $((likelihood_single_repeat))")
#         println("posterior: $(prior * (likelihood_single_repeat)^repeats)")
#     end
# end

# # TODO: plot results
# for repeats in 1:max_repeats
#     println("REPEATS: $(repeats)")
#     i = findall(name -> results[repeats][name] == maximum(map(n -> results[repeats][n], spec_names)),  spec_names)[1]
#     map_spec_name = spec_names[i]
#     println(map_spec_name)
# end

# sums = map(r -> sum(collect(values(results[r]))), 1:max_repeats)

# # # pretty_spec_names = ["chance language, no impos", "chance language, with impos", "minimal language, i.e. propositional logic", "modal language, i.e. first-order logic"]

# p = plot(1:max_repeats, collect(1:max_repeats) * 1/max_repeats, color="white", label=false)
# for i in 1:length(spec_names)
#     spec_name = spec_names[i]
#     # println(spec_name)
#     # println("\tprior: $(priors[i])")
#     # println("\tlikelihood: $(likelihoods[i])")
    
#     p = plot!(collect(1:max_repeats), map(r -> results[r][spec_name], 1:max_repeats) ./ sums, legend=false, label="") # legend=:outerbottom 
    
# end

# sort!(spec_names, by=x -> x in intervened_spec_names ? findall(y -> y == x, intervened_spec_names)[1] : 10)

# for i in 1:length(spec_names)
#     spec_name = spec_names[i]
#     # println("\tprior: $(priors[i])")
#     # println("\tlikelihood: $(likelihoods[i])")
#     if spec_name in intervened_spec_names
#         println(spec_name)
#         p = plot!(collect(1:max_repeats), map(r -> results[r][spec_name], 1:max_repeats) ./ sums, label = "$(spec_names_pretty[spec_name])", legend=:outerbottom, xticks=0:1:max_repeats) # legend=:outerbottom 
#     end
# end

# # for spec_name in intervened_spec_names
# #     p = plot!(collect(1:max_repeats), map(r -> results[r][spec_name], 1:max_repeats) ./ sums, label = "$(spec_names_pretty[spec_name])", legend=:outerbottom) # legend=:outerbottom 
# # end

# xlabel!("Training Data Volume", xguidefontsize=9)
# ylabel!("Proportion", yguidefontsize=9)
# title!("Relative Proportions of Number LoTs", titlefontsize=10)

# p