include("../run_inference.jl")

# DEFINE LANGUAGES

language_names = map(x -> "L$(x)", 0:7)
language_names = [language_names[1:3]..., "L2.5", "L3", "L3.5", language_names[5:end]...]

language_names_pretty = [
    "L0_non_knower",
    "L1_one_knower",
    "L2_two_knower",
    "L2.5_two_knower_approx",
    "L3_three_knower",
    "L3.5_three_knower_approx",
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

# two-knower approx
L25_spec = deepcopy(L2_spec)
L25_spec["approx"] = true

# three-knower approx
L35_spec = deepcopy(L3_spec)
L35_spec["approx"] = true

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

language_name_to_spec = Dict(map(i -> "L$(i)" => eval(Meta.parse("L$(i)_spec")), 0:7))
language_name_to_spec["L2.5"] = L25_spec
language_name_to_spec["L3.5"] = L35_spec

# TASKS
english_dataset = Dict([
    "give_1" => 40, # = GiveN("one") 40 / 80
    "give_2" => 20, # = GiveN("two") 20 / 40
    "give_3" => 9, # = GiveN("three")
    "give_4" => 5, # = GiveN("four")
    "give_5" => 3, # = GiveN("five")
    "give_6" => 2, # = GiveN("six")
    "give_7" => 2, # = GiveN("seven")
    "give_8" => 1, # = GiveN("eight")
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

    "how_many_5_blur" => 2, #  = HowMany(Blur(5))
    "how_many_6_blur" => 2, #  = HowMany(Blur(6))
    "how_many_7_blur" => 2, #  = HowMany(Blur(7))
    "how_many_8_blur" => 1, #  = HowMany(Blur(8))
    "how_many_9_blur" => 1, #  = HowMany(Blur(9))
    "how_many_10_blur" => 1, #  = HowMany(Blur(10))

    "more_1" => 2, 
    "more_2" => 2,

    "unit_add_1" => 5, 
    "unit_add_2" => 5,
])

slovenian_dataset = deepcopy(english_dataset)
slovenian_dataset["give_1"] = slovenian_dataset["give_1"] * 2
slovenian_dataset["give_2"] = slovenian_dataset["give_2"] * 2 

chinese_dataset = deepcopy(english_dataset)
chinese_dataset["give_1"] = chinese_dataset["give_1"] * 0.8

japanese_dataset = deepcopy(chinese_dataset)

russian_dataset = deepcopy(english_dataset)

test_name_to_task_dict = Dict([
    "english" => (english_dataset, 0.25, 0.25, ["singular"]), # cultural_counting_emphasis_small_number, cultural_counting_emphasis_large_number
    "slovenian" => (slovenian_dataset, 0.05, 0.05, ["singular", "dual"]),
    "chinese" => (chinese_dataset, 0.25, 0.25, []),
    "japanese" => (japanese_dataset, 0.25, 0.25, []),
    "russian" => (russian_dataset, 0.25, 0.25, ["singular"])
])

function plot_individual_task_distribution(test_name_="english")
    task_dict = test_name_to_task_dict[test_name_][1]

    task_count_dict = Dict([
        "c_More" => 0,
        "d_Unit Addition" => 0,
    ])

    for k in keys(task_dict)
        if occursin("give_", k) || occursin("how_many_", k) && !occursin("blur", k)
            num = parse(Int, split(k, "_")[end])
            task_name = "$(num < 10 ? string(0, num) : string(num))_Give $(num)"
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
    # push!(colors, collect(palette(:tab20b))[end]) # fast dots 6
    push!(colors, reverse(collect(palette(:RdPu_9))[1:5])...)
    # push!(colors, collect(palette([pink, lightpink], 7))[2:end-1]...) # fast dots 6-10
    # push!(colors, collect(palette(:valentine))[2:end]...) # fast dots 6-10
    # push!(colors, collect(palette(:darkterrain))[end-4:end]...) # fast dots 6-10
    push!(colors, collect(palette(:tab20))[14]) # more 
    push!(colors, collect(palette(:tab20))[15]) # unit add

    task_group_names = sort(collect(keys(task_count_dict)))
    counts = map(group_name -> task_count_dict[group_name], task_group_names)
    proportions = counts ./ sum(counts)
    println(map(x -> split(x, "_")[end], task_group_names))
    curriculum_plot = bar(xticks=(1:length(task_group_names), map(x -> split(x, "_")[end], task_group_names)), proportions, color=colors, size=(640, 525), xrotation=305, bar_width=1, xlabel="Task Type", ylabel="Proportion", legend=false, titlefontsize=13, xtickfontsize=9, xguidefontsize=11, yguidefontsize=10, title="Task Distribution", ylims=(0.0, 0.5))
    curriculum_plot
end

function plot_grouped_task_distribution(test_name_="english")
    task_dict = test_name_to_task_dict[test_name_][1]
    task_count_dict = Dict([
        "1_Give N" => 0,
        "2_Fast Dots" => 0,
        "3_More" => 0,
        "4_Unit Addition" => 0,
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

# total_tasks = sum(map(k -> dataset[k], [keys(dataset)...]))
# cultural_counting_emphasis_small_number = 0.25 # 0.25 / 0.025
# cultural_counting_emphasis_large_number = 0.25 # 0.25 / 0.025

function compute_counting_task_proportion(task_dict, cultural_counting_emphasis_small_number, cultural_counting_emphasis_large_number)
    total_tasks = sum(map(k -> task_dict[k], [keys(task_dict)...]))
    counting_tasks_small_number = sum(map(k -> task_dict[k], filter(x -> x in ["give_2", "give_3"], [keys(task_dict)...])))
    individual_counting_proportions = map(n -> n < 4 ? 
        cultural_counting_emphasis_small_number * task_dict["give_$(n)"] : 
        cultural_counting_emphasis_large_number * task_dict["give_$(n)"] * 2.5/n * 0.25,
    2:10) ./ total_tasks
    sum(individual_counting_proportions)
end

# # counting_tasks_small_number = sum(map(y -> dataset[y], filter(k -> k in ["give_1", "give_2", "give_3"], [keys(dataset)...])))
# # counting_task_proportion = counting_tasks_small_number / total_tasks
# counting_task_proportion = compute_counting_task_proportion(dataset, cultural_counting_emphasis_small_number, cultural_counting_emphasis_large_number)

# ACCURACIES
function compute_num_tasks(dataset, task_type="")
    if task_type == ""
        sum(map(k -> dataset[k], [keys(dataset)...]))
    else
        sum(map(k -> dataset[k], filter(x -> task_type == "quantifier" ? occursin("quantifier", x) : !occursin("quantifier", x), [keys(dataset)...])))
    end
end

function compute_base_accuracies(dataset, full_reset=true)
    base_accuracies = Dict()
    for language_name in language_names
        println(language_name)
        base_accuracies[language_name] = Dict()

        spec = language_name_to_spec[language_name]

        # construct and load language
        language = generate_language(spec)
        if language_name == "L00"
            println(language)
        end
        open("metalanguage_enriched/didactic/intermediate_outputs/current_language.jl", "w+") do f 
            write(f, replace(language, "../../" => "../../../"))
        end
        include("intermediate_outputs/current_language.jl")

        for task_name in keys(dataset)
            if full_reset || !(task_name in keys(base_accuracies[language_name]))
                println(task_name)
                single_task_dataset = Dict([eval(Symbol(task_name)) => 1])

                # evaluate language on tasks
                accuracy = compute_likelihood(single_task_dataset)
                if !spec["ANS_reconciled"] && occursin("_blur", task_name)
                    accuracy = 0.1 # 0.0    
                end
                println(accuracy)
                base_accuracies[language_name][task_name] = accuracy
            end
        end

        if occursin(".5", language_name)
            start_num = occursin("2.5", language_name) ? 3 : 4
            for n in start_num:10
                base_accuracies[language_name]["give_$(n)"] = (1/2)^(n - start_num + 1)
                base_accuracies[language_name]["how_many_$(n)"] = (1/2)^(n - start_num + 1)
            end
        end

    end
    base_accuracies
end

# base_accuracies = compute_base_accuracies(english_dataset)

function compute_accuracies_efficient(dataset, normalized=true, recompute_base=false, intervention=false, quantifier_structure_weight=0.7)
    if recompute_base 
        global base_accuracies = compute_base_accuracies(dataset, false)
    end

    total_number_tasks = compute_num_tasks(dataset, "number")
    total_quantifier_tasks = compute_num_tasks(dataset, "quantifier")

    @show total_number_tasks 
    @show total_quantifier_tasks

    number_accuracies = []
    quantifier_accuracies = []
    for language_name in language_names
        println("HMMMM")
        @show language_name
        overall_number_accuracy = 0.0
        overall_quantifier_accuracy = 0.0
        for task_name in keys(dataset)
            task_count = dataset[task_name]
            base_acc = base_accuracies[language_name][task_name]

            if occursin("quantifier", task_name)
                @show task_name 
                @show base_acc
                @show task_count
                if normalized 
                    overall_quantifier_accuracy += base_acc * task_count
                else
                    overall_quantifier_accuracy += log(base_acc) * task_count
                end
                @show overall_quantifier_accuracy
            else
                if normalized 
                    overall_number_accuracy += base_acc * task_count
                else
                    overall_number_accuracy += log(base_acc) * task_count
                end
            end
        end

        if normalized
            overall_number_accuracy = overall_number_accuracy / total_number_tasks # / total tasks
            if total_quantifier_tasks == 0 
                overall_quantifier_accuracy = 1.0
            else
                overall_quantifier_accuracy = overall_quantifier_accuracy / total_quantifier_tasks # / total tasks
            end
        elseif !intervention
            overall_number_accuracy = overall_number_accuracy * compute_num_tasks(test_name_to_task_dict["english"][1], "number") / total_number_tasks
            if total_quantifier_tasks != 0
                overall_quantifier_accuracy = overall_quantifier_accuracy * 2 / total_quantifier_tasks
            end
        end       

        push!(number_accuracies, overall_number_accuracy)
        push!(quantifier_accuracies, overall_quantifier_accuracy)

    end

    accuracies = []
    for i in 1:length(language_names)
        number_accuracy = number_accuracies[i]
        quantifier_accuracy = quantifier_accuracies[i]
        if occursin("L0", language_names[i])
            @show language_names[i]
            @show number_accuracy 
            @show quantifier_accuracy
        end
        if total_quantifier_tasks == 0
            accuracy = 0.5 * (quantifier_structure_weight * quantifier_accuracy * (total_number_tasks) + (1 - quantifier_structure_weight) * number_accuracy)
        else
            accuracy = 0.5 * (quantifier_structure_weight * quantifier_accuracy * (total_number_tasks / total_quantifier_tasks) + (1 - quantifier_structure_weight) * number_accuracy)
        end
        push!(accuracies, accuracy)
    end

    # @show accuracies
    if normalized 
        accuracies = accuracies .- minimum(accuracies)
        accuracies = accuracies / maximum(accuracies)
    else
        accuracies = accuracies .+ 250 # maximum(accuracies)
        accuracies = (accuracies / 240)
    end

    accuracies
end

function compute_memory_cost(spec)
    cost = 0.0
    addend = 0.15
    
    quantifier_addend = 0.05

    if "singular" in keys(spec["quantifier_structure"]) && spec["quantifier_structure"]["singular"]
        cost += quantifier_addend
    end

    if "dual" in keys(spec["quantifier_structure"]) && spec["quantifier_structure"]["dual"]
        cost += quantifier_addend
    end

    if spec["full_knower_compression"] == default_spec["full_knower_compression"]
        # pre-CP-knower: count numbers learned
        number_defn_count = 0
        for k in keys(spec)
            if occursin("definition", k) && !occursin("blur", k) && !occursin("unknown", k) && !occursin("give_n", k)
                if !occursin("not", spec[k])
                    println(spec[k])
                    println(default_spec[k])
                    number_defn_count += 1
                end
            end
        end
        println(number_defn_count)

        for n in 1:number_defn_count 
            if n % 3 == 0 
                addend = addend * 6/7
            end
            cost += addend
        end

        if spec["approx"]
            cost += addend * 2/3
        end
    else
        # CP-knower stage reached
        base_cost = addend # knowing meaning of just "one"
        rule_knower_cost = addend * 4/3 # knowing meaning of recursive rule following "one"
        cost = base_cost + rule_knower_cost 

        num_extra_memorizations = 0
        if spec["ANS_reconciled"] != default_spec["ANS_reconciled"]
            num_extra_memorizations += 1
        end

        if spec["unit_add"] != default_spec["unit_add"]
            num_extra_memorizations += 1
        end

        for n in 1:num_extra_memorizations 
            if n % 2 == 0
                addend = addend * 3/5
            end
            cost += addend
        end
    end

    cost
end

function compute_all_memory_costs() 
    costs = []
    for language_name in language_names
        println(language_name)
        spec = language_name_to_spec[language_name]
        cost = compute_memory_cost(spec)
        push!(costs, cost)
    end
    costs
end


function distance_between_specs(spec1, spec2, relate_factor=0.0)
    dist = 0
    for k in keys(spec1)
        if !occursin("quantifier", k)
            
            if spec1[k] != spec2[k] && !((spec1[k] isa AbstractString) && (spec2[k] isa AbstractString) && occursin("not", spec1[k]) && occursin("not", spec2[k])) && !occursin("blur", k) && !occursin("list_syntax", k) && !occursin("unknown", k) && !occursin("give_n", k) && !occursin("quantifier", k)
                dist += 0.75
            end

        else
            for k in keys(spec1["quantifier_structure"])
                
                if spec1["quantifier_structure"][k] != spec2["quantifier_structure"][k]
                    dist += 0.75
                end

            end
        end
    end
    s = 0
    if dist != 0 
        num_non_default_spec1 = count(k -> !occursin("quantifier", k) && (spec1[k] != default_spec[k]) || occursin("quantifier", k) && filter(x -> spec1[k][x], collect(keys(spec1[k]))) != [], collect(keys(spec1))) 
        num_non_default_spec2 = count(k -> !occursin("quantifier", k) && (spec2[k] != default_spec[k]) || occursin("quantifier", k) && filter(x -> spec2[k][x], collect(keys(spec2[k]))) != [], collect(keys(spec2))) 
        if num_non_default_spec1 > num_non_default_spec2
            s = 1 
        else
            s = -1
        end

        if spec1["full_knower_compression"] != "full_knower_compression" && spec2["full_knower_compression"] == "full_knower_compression" 
            if !(spec1["three_definition"] in ["set.value == 3"])
                dist = dist * 10
            else
                dist += 12.5 - 12.4 * relate_factor # 200 - 199.5 * relate_factor
            end
        end

        # if spec1["full_knower_compression"] != "full_knower_compression" && spec2["ANS_reconciled"]
        #     dist += 10
        # end

        if !spec1["ANS_reconciled"] && spec2["unit_add"] == "unit_add_final"
            dist += 10
        end

        # TODO: if spec1 does not have singular defined or one defined, if spec2 has one defined, that is very low probability
        if ("singular" in keys(spec1["quantifier_structure"])) && !spec1["quantifier_structure"]["singular"] && spec1["one_definition"] == "true" && spec2["one_definition"] != "true" 
            dist = dist * 100
        elseif ("singular" in keys(spec1["quantifier_structure"])) && spec1["quantifier_structure"]["singular"] && spec1["one_definition"] == "true" && spec2["one_definition"] != "true" 
            dist = dist / 1.5
        end        
        
        # TODO: if spec1 does not have dual defined or two defined, if spec2 has two defined, that is very low probability (if dual is a key in the quantifier dict)
        if ("dual" in keys(spec1["quantifier_structure"])) && !spec1["quantifier_structure"]["dual"] && spec1["two_definition"] != "set.value == 2" && spec2["two_definition"] == "set.value == 2"
            dist = dist * 100
        elseif ("dual" in keys(spec1["quantifier_structure"])) && spec1["quantifier_structure"]["dual"] && spec1["two_definition"] != "set.value == 2" && spec2["two_definition"] == "set.value == 2"
            dist = dist / 1.5 
        end

    end

    (dist, s)
end

function plot_heatmap(relate_factor, t, title="")
    transition_prob_identity = transition_prob_identity_base - transition_prob_identity_rate * t
    heatmap_values = []
    for l1 in language_names 
        push!(heatmap_values, [])
        for l2 in language_names 
            l1_spec = language_name_to_spec[l1]
            l2_spec = language_name_to_spec[l2]
            dist, s = distance_between_specs(l1_spec, l2_spec, relate_factor)
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

function compute_utility(language_index, t)
    unscaled_utility = gamma_c*t*accuracies[language_index] - cost_c *(memory_costs[language_index] + computational_costs[language_index] - 0.50)
    0.3 * (unscaled_utility - 0.7)
end

# PARAMS

transition_prob_identity_base = 0.975
transition_prob_identity_rate = 0.004 # 0.0003
transition_prob_base = 100.0 # 2
utility_base = 10000000000000.0

time_step_unit = 0.0005 # 0.00005 
num_time_steps = 3000

gamma_c = 1.0 # 1.2
cost_c = 0.015 # 0.008

params_dict = Dict([

])

accuracies = []
memory_costs = []
computation_costs = []
relate_task_proportion = 0.0
global relate_factors = []
all_distributions = []
counting_task_proportion = -1.0

# modified color palette
old_colors = collect(palette(:tab10))
modified_colors = [old_colors[1:3]..., old_colors[9], old_colors[4], old_colors[10], old_colors[5:8]...]

function run_test(test_name_, normalized=true, intervention=false, intervention_small=false, intervention_count=false, save_fig_title="")
    global test_name = test_name_
    # params_dict["test_name"] = test_name

    individual_dist_plot = plot_individual_task_distribution(test_name)
    grouped_dist_plot = plot_grouped_task_distribution(test_name)
    # plot(individual_dist_plot, grouped_dist_plot, layout=(1, 2))

    task_dict, cultural_counting_emphasis_small_number, cultural_counting_emphasis_large_number, quantifier_structure = test_name_to_task_dict[test_name]
    # params_dict["curriculum"] = Dict(map(k -> k => task_dict[k][2], collect(keys(task_dict))))

    global counting_task_proportion = compute_counting_task_proportion(task_dict, cultural_counting_emphasis_small_number, cultural_counting_emphasis_large_number)

    # handle diverse quantifier structure
    new_language_names = []
    new_language_specs = []

    @show language_names
    global language_names = filter(l -> !(occursin("L00", l) || occursin("L01", l) || occursin("L02", l)), language_names)
    global language_names_pretty = filter(l -> !(occursin("L00", l) || occursin("L01", l) || occursin("L02", l)), language_names_pretty)

    if quantifier_structure != []
        println("hello")
        quantifier_structure_spec = Dict(map(k -> k => false, quantifier_structure))
        
        # add new base language (L00)
        new_base_language = """L00_non_knower_no_$(join(quantifier_structure, "_"))"""
        new_base_spec = deepcopy(L0_spec)
        new_base_spec["quantifier_structure"] = deepcopy(quantifier_structure_spec)

        push!(new_language_names, new_base_language)
        push!(new_language_specs, new_base_spec)

        if "singular" in quantifier_structure
            quantifier_structure_spec["singular"] = true
            # add singular task 
            task_dict["quantifier_singular_task_total_$(length(quantifier_structure))"] = 2
        end

        if "dual" in quantifier_structure 
            # add singular no dual language
            new_intermediate_language = "L01_non_knower_singular_no_dual"
            new_intermediate_spec = deepcopy(new_base_spec)
            new_intermediate_spec["quantifier_structure"] = deepcopy(quantifier_structure_spec)

            push!(new_language_names, new_intermediate_language)
            push!(new_language_specs, new_intermediate_spec)

            # # add singular, one-knower, no dual language
            # new_intermediate_language2 = "L02_one_knower_singular_no_dual"
            # new_intermediate_spec2 = deepcopy(L1_spec)
            # new_intermediate_spec2["quantifier_structure"] = deepcopy(quantifier_structure_spec)

            # push!(new_language_names, new_intermediate_language2)
            # push!(new_language_specs, new_intermediate_spec2)

            quantifier_structure_spec["dual"] = true

            # add dual task
            task_dict["quantifier_dual_task_total_$(length(quantifier_structure))"] = 1
        end

        for language_name in language_names 
            spec = language_name_to_spec[language_name]
            spec["quantifier_structure"] = quantifier_structure_spec
        end

        for i in 1:length(new_language_names)
            name = split(new_language_names[i], "_")[1]
            spec = new_language_specs[i]
            language_name_to_spec[name] = spec
        end
        @show language_names 
        @show new_language_names
        global language_names = [map(x -> split(x, "_")[1], new_language_names)..., language_names...]
        global language_names_pretty = [new_language_names..., language_names_pretty...]
        @show language_names

        # handle colors 
        if length(new_language_names) == 1
            global modified_colors = [:lightskyblue1, modified_colors...]
        elseif length(new_language_names) == 2
            global modified_colors = [:lightskyblue1, :deepskyblue1, modified_colors...]
        elseif length(new_language_names) == 3
            global modified_colors = [:lightskyblue1, :deepskyblue1, :dodgerblue1, modified_colors...]
        end

        # recompute accuracies 
        quantifier_task_proportion = cultural_counting_emphasis_small_number == test_name_to_task_dict["english"][2] ? 0.7 : 0.75
        global accuracies = compute_accuracies_efficient(task_dict, normalized, true, false, quantifier_task_proportion) # TEMP: true, false
    else
        global accuracies = compute_accuracies_efficient(task_dict, normalized)
    end

    # accuracies[1] = 0.0

    # COSTS 

    # global memory_costs = [ # TODO
    #     0.00, # L0: non-knower
    #     0.15, # L1: 1-knower
    #     0.30, # 2-knower
    #     # 0.34, # 2-knower, approx
    #     0.39, # 3-knower
    #     # 0.39, # 3-knower, approx 
    #     0.48, # 4-knower
    #     0.35, # CP-knower # 0.41
    #     0.5, # CP-mapper
    #     0.59, # CP-unit-knower # normalized setting: 0.7
    # ]
    global memory_costs = compute_all_memory_costs()
    global memory_costs = memory_costs .* 2
    global computational_costs = [ # TODO
        0.48, # L0: non-knower
        0.50, # L1: 1-knower
        0.50, # 2-knower
        0.60, # 2-knower, approx # previously: 0.50
        0.50, # 3-knower
        0.60, # 3-knower, approx # previously: 0.50
        0.50, # 4-knower
        0.565, # CP-knower
        0.54, # CP-mapper
        0.515, # CP-unit-knower
    ]
    @show new_language_names
    if new_language_names != []
        computational_costs = [map(x -> computational_costs[1], new_language_names)..., computational_costs...]
        if length(new_language_names) == 3 
            computational_costs[3] = computational_costs[4] # one-knower, but no dual
        end
    end
    @show computational_costs

    # three bar plots: accuracy, memory_cost, computational_cost
    # one line plot: utilities over time
    # heat map 1: transition probabilities
    # heat map 2: max utility x transition probabilities 

    accuracy_plot = bar(map(x -> join(split(x, "_")[2:end], " "), language_names_pretty), accuracies, color = modified_colors, xrotation=305, size=(600, 525), legend=false, xlabel="LoT Stage", ylabel="Accuracy", title="Task Accuracy", ylims=(0.0, 1.0))

    memory_cost_plot = bar(map(x -> join(split(x, "_")[2:end], " "), language_names_pretty), memory_costs ./ maximum(memory_costs), color = modified_colors, xrotation=305, size=(600, 525), legend=false, xlabel="LoT Stage", ylabel="Cost", title="Memory Cost", ylims=(0.0, 1.0))

    computation_cost_plot = bar(map(x -> join(split(x, "_")[2:end], " "), language_names_pretty), computational_costs ./ maximum(computational_costs), color = modified_colors, xrotation=305, size=(600, 525), legend=false, xlabel="LoT Stage", ylabel="Cost", title="Computation Cost", ylims=(0.0, 1.0))

    # plot(accuracy_plot, memory_cost_plot, computation_cost_plot, layout=(3, 1), size=(600, 525 * 3))

    x_vals = collect(0:time_step_unit:num_time_steps*time_step_unit)
    line_plot = nothing 
    yvals_dict = Dict()
    max_yvals = 0.0
    min_yvals = 0.0
    for i in 1:length(language_names)
        y_vals = map(x -> gamma_c*x*accuracies[i] - cost_c *(memory_costs[i] + computational_costs[i] - 0.50), x_vals)
        max_yvals = maximum([max_yvals, maximum(y_vals)])
        min_yvals = minimum([min_yvals, minimum(y_vals)])

        if isnothing(line_plot)
            line_plot = plot(x_vals, y_vals, size=(600, 450), xlims=(0.0, x_vals[end]), ylims=(min_yvals, max_yvals), legend=:bottomright, label=join(split(language_names_pretty[i], "_")[2:end], " "), color = modified_colors[i], title="Utility vs. Cost Tolerance (Time)", xlabel="Cost Tolerance (Time)", ylabel="Utility")
        else
            line_plot = plot(line_plot, x_vals, y_vals, size=(600, 450),  xlims=(0.0, x_vals[end]), ylims=(min_yvals, max_yvals), legend=:bottomright, label=join(split(language_names_pretty[i], "_")[2:end], " "), color = modified_colors[i], title="Utility vs. Cost Tolerance (Time)",  xlabel="Cost Tolerance (Time)", ylabel="Utility")
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

    max_utility_plot = bar(ones(length(maxs)), color = map(i -> modified_colors[i], max_indexes), xrotation=305, size=(600, 100), legend=false, xlabel="LoT Stage", ylims=(0.0, 1.0), linecolor=:match)

    # plot(line_plot, max_utility_plot, layout=(2, 1), size=(600, 550))
    line_plot

    # _, h0 = plot_heatmap(0, "t=0")
    # _, h20 = plot_heatmap(1000, "t=100")
    # _, h40 = plot_heatmap(2000, "t=200")
    # _, h60 = plot_heatmap(3000, "t=300")
    # _, h80 = plot_heatmap(4000, "t=400")
    # _, h100 = plot_heatmap(5000, "t=500")
    # plot(h0, h20, h40, h60, h80, h100)

    three_knower_stage_reached = false
    three_knower_stage_intervention_made = false
    global relate_factors = []
    max_lot_indexes = [1]
    max_lots = [language_names_pretty[1]]
    curr_distribution = map(x -> 0.0, 1:length(language_names))
    curr_distribution[1] = 1.0
    global all_distributions = []
    push!(all_distributions, curr_distribution)
    for t in 0:time_step_unit:num_time_steps*time_step_unit

        if intervention && three_knower_stage_reached && !three_knower_stage_intervention_made
            # add intervention 
            three_knower_stage_intervention_made = true

            if intervention_small 
                # low number 
                task_dict["give_1"] += 0
                task_dict["give_2"] += 0
                task_dict["give_3"] += 1
    
                if intervention_count 
                    cultural_counting_emphasis_small_number = 0.5
                else
                    cultural_counting_emphasis_small_number *= 1.35
                end

            else
                # high number 
                task_dict["give_4"] += 0
                task_dict["give_5"] += 0 
                task_dict["give_6"] += 0 
                task_dict["give_7"] += 0
                task_dict["give_8"] += 0
                task_dict["give_9"] += 0 
                task_dict["give_10"] += 1

                if intervention_count 
                    cultural_counting_emphasis_large_number = 0.5
                end

            end
            
            # counting context vs. no counting context
            # cultural_counting_emphasis_small_number = 0.5
            # cultural_counting_emphasis_large_number = 0.5

            # recompute accuracies and counting_task_proportion
            global accuracies = compute_accuracies_efficient(task_dict, normalized, intervention)

            global counting_task_proportion = compute_counting_task_proportion(task_dict, cultural_counting_emphasis_small_number, cultural_counting_emphasis_large_number)
        end

        utility_sum = sum(map(x -> utility_base^(compute_utility(x, t)), 1:length(language_names)))
        
        relate_factor = t * counting_task_proportion * 30
        relate_factor = relate_factor > 1 ? 1 : relate_factor
        push!(relate_factors, relate_factor)

        transition_probabilities, _ = plot_heatmap(relate_factor, t, "")
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
        curr_distribution = next_distribution
        # if curr_distribution[6] != 0
        #     println("hello 1")
        # end
        push!(all_distributions, curr_distribution)
        println(max_lots[end])

        if max_lots[end] == "three knower" && !three_knower_stage_reached
            three_knower_stage_reached = true
        end

    end

    max_lot_plot = bar(ones(length(max_lots)), color = map(i -> modified_colors[i], max_lot_indexes), xrotation=305, size=(600, 100), legend=false, xlabel="LoT Stage", ylims=(0.0, 1.0), linecolor=:match)
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
        dist_ys = map(t -> all_distributions[t][i], 1:length(dist_xs))
        if isnothing(dist_plot)
            dist_plot = plot(dist_xs, dist_ys, color=modified_colors[i], label=language_names_pretty[i], legend=:right, size=(800, 600), title="Posterior over LoTs (Background Proposal x Utility-Based Acceptor)", ylabel="Probability", xlabel="Time")
        else
            dist_plot = plot(dist_plot, dist_xs, dist_ys, color=modified_colors[i], label=language_names_pretty[i], legend=:right, size=(800, 600), title="Posterior over LoTs (Background Proposal x Utility-Based Acceptor)", ylabel="Probability", xlabel="Time")
        end
    end

    # max_lot_plot

    # dist_plot

    # plot(individual_dist_plot, dist_plot, max_lot_plot, layout=(3, 1), size=(1000, 1500))

    println("1 knower becomes MAP: $("one knower" in max_lots ? findall(x -> x == "one knower" || x == "one knower singular no dual", max_lots)[1] : -1)")
    println("2 knower becomes MAP: $("two knower" in max_lots ? findall(x -> x == "two knower", max_lots)[1] : -1)")
    println("3 knower becomes MAP: $("three knower" in max_lots ? findall(x -> x == "three knower", max_lots)[1] : -1)")
    println("CP knower becomes MAP: $("CP knower" in max_lots ? findall(x -> x == "CP knower", max_lots)[1] : -1)")
    # println("CP knower becomes MAP: $("CP knower" in max_lots ? findall(x -> x == "CP knower", max_lots)[1] : -1)")

    if save_fig_title != ""
        # save figures and params

    end

    CP_arrival_time = "CP knower" in max_lots ? findall(x -> x == "CP knower", max_lots)[1] : -1
    one_arrival_time = (intersect(["one knower", "one knower singular no dual"], max_lots) != []) ? findall(x -> x == "one knower" || x == "one knower singular no dual", max_lots)[1] : -1
    two_arrival_time = "two knower" in max_lots ? findall(x -> x == "two knower", max_lots)[1] : -1

    (individual_dist_plot, # individual task distribution 
    grouped_dist_plot, # grouped/categorized task distribution
    accuracy_plot, # accuracy bar plot
    memory_cost_plot, # memory cost bar plot
    computation_cost_plot, # computation cost plot
    line_plot, # utility evolution plot
    max_utility_plot, # maximum utility evolution plot
    dist_plot, # posterior evolution plot
    max_lot_plot, # MAP evolution plot
    CP_arrival_time, 
    one_arrival_time, 
    two_arrival_time)
end

# (individual_dist_plot, 
# grouped_dist_plot, 
# accuracy_plot, 
# memory_cost_plot, 
# computation_cost_plot, 
# line_plot, 
# max_utility_plot, 
# dist_plot, 
# max_lot_plot,
# CP_arrival_time,
# one_arrival_time,
# two_arrival_time) = run_test("english", false)

# plot(individual_dist_plot, dist_plot, max_lot_plot, layout=(3, 1), size=(1000, 1500))

# relate_factor = 0.0
# distances = []
# for l1 in language_names 
#     push!(distances, [])
#     for l2 in language_names 
#         l1_spec = language_name_to_spec[l1]
#         l2_spec = language_name_to_spec[l2]
#         dist, s = distance_between_specs(l1_spec, l2_spec, relate_factor)
#         push!(distances[end], dist)
#     end
# end

# heatmap_values = distances 
# heatmap_values_matrix = reshape(vcat(heatmap_values...), (length(language_names), length(language_names)))
# heatmap(language_names, language_names, heatmap_values_matrix, aspect_ratio=:equal)

# one_knower_arrivals = Dict("slovenian" => 366, "english" => 435, "japanese" => 482)
# cp_induction_arrivals = Dict("slovenian" => 1543, "english" => 1025, "japanese" => 971)

# x_labels = ["English\nRussian\nSpanish\n(singular-plural)", "Japanese\nChinese\nBasque\n(no singular-plural)", "Slovenian\nArabic\n(singular-dual-plural)"]
# cp_induction_relative_rates = [0, (cp_induction_arrivals["japanese"] / cp_induction_arrivals["english"]) - 1, cp_induction_arrivals["slovenian"] / cp_induction_arrivals["english"] - 1] * 100
# CP_induction_rate_plot = bar(x_labels, cp_induction_relative_rates, color = collect(palette(:tab10))[6], size=(600, 525), legend=false, xlabel="Language Category", ylabel="% Change", title="% Arrival Time Change of\nCP Induction", ylims=(-25, 75))
# annotate!(x_labels[1:1], cp_induction_relative_rates[1:1], map(x -> "$(round(x, digits=1))%", cp_induction_relative_rates[1:1]), :bottom, fontsize=6)
# annotate!(x_labels[2:2], cp_induction_relative_rates[2:2], map(x -> "$(round(x, digits=1))%", cp_induction_relative_rates[2:2]), :top)
# annotate!(x_labels[3:end], cp_induction_relative_rates[3:end], map(x -> "$(round(x, digits=1))%", cp_induction_relative_rates[3:end]), :bottom)

# one_knower_relative_rates = [0, (one_knower_arrivals["japanese"] / one_knower_arrivals["english"]) - 1, one_knower_arrivals["slovenian"] / one_knower_arrivals["english"] - 1] * 100
# one_knower_rate_plot = bar(x_labels, one_knower_relative_rates, color = collect(palette(:tab10))[2], size=(600, 525), legend=false, xlabel="Language Category", ylabel="% Change", title="% Arrival Time Change of\nOne Knower Stage", ylims=(-25, 75))
# annotate!(x_labels[1:1], one_knower_relative_rates[1:1], map(x -> "$(round(x, digits=1))%", one_knower_relative_rates[1:1]), :bottom)
# annotate!(x_labels[2:2], one_knower_relative_rates[2:2], map(x -> "$(round(x, digits=1))%", one_knower_relative_rates[2:2]), :bottom)
# annotate!(x_labels[3:end], one_knower_relative_rates[3:end], map(x -> "$(round(x, digits=1))%", one_knower_relative_rates[3:end]), :top)

# plot(one_knower_rate_plot, CP_induction_rate_plot, layout=(1,2), size=(1000, 500))

# xlabels = ["Baseline", "Low Counting Emphasis", "High Counting Emphasis"]
# ylabels = [0.25, 0.125, 0.5]
# count_emphasis_intervention_plot = bar(xlabels, ylabels, ylims=(0.0, 1.0), legend=false, xlabel="Intervention", ylabel="Parameter Value", title="Count Seqence Emphasis Comparison: Parameter Values", titlefontsize=11, xguidefontsize=10, yguidefontsize=10)
# annotate!(xlabels, ylabels, ylabels, :bottom, annotationfontsize=6)

# # intervention plot
# x = (1 .- [1053, 949, 944, 949] ./ 1106) * 100
# bar(labels, x, legend=false, xtickfontsize=12, xlabel="Intervention Type", ylabel="% Reduction", ytickfontsize=12, yguidefontsize=18, xguidefontsize=18, title="Percent Reduction in CP-Knower Acquisition Time\nvs. Intervention Type", titlefontsize=21, annotationfontsize=1, ylims=(0.0, 20.0), size=(1000, 1000))
# annotate!(labels, x, map(a -> "$(round(a, digits=2))%", x), :bottom)