include("plotting.jl")

current_folder = "metalanguage_enriched/didactic/"
# current_folder = ""
repeat_suffix = ""

# GENERATE LANGUAGES
include("define_languages.jl")
language_names, language_names_pretty, language_name_to_spec, tups = generate_languages(all_languages=false)

function get_language_name(language_identifier)
    if language_identifier isa Int # language index used
        language_name = language_names[language_identifier]
    elseif !occursin("_", language_identifier) # language name used
        language_name = language_identifier
    else # prettified language name used
        i = findall(x -> x == language_identifier, language_names_pretty)
        language_name = language_names[i]
    end
    language_name
end

# GENERATE TYPE SYSTEM CODE 
include("compiler.jl")
# language_name_to_type_system = generate_type_systems(define_langs=true)

function visualize_type_system(language_identifier; option="all")
    language_name = get_language_name(language_identifier)
    changing_components_str, compressed_type_system_str, compiled_type_system_str = language_name_to_type_system[language_name]

    if option == "change"
        println(changing_components_str)
    elseif option == "compressed"
        println(compressed_type_system_str)
    elseif option == "expanded"
        println(compiled_type_system_str)
    elseif option == "all"
        return language_name_to_type_system[language_name]
    end
end

function visualize_task_evaluation_code(language_identifier)
    language_name = get_language_name(language_identifier)
    spec = language_name_to_spec[language_name]

    println(generate_language(spec))
end

# DEFINE TASK DISTRIBUTION
function generate_task_distribution()
    english_dataset = Dict([
        "give_1" => 80.0, # = GiveN("one") 40 / 80
        "give_2" => 20.0, # = GiveN("two") 20 / 40
        "give_3" => 9.0, # = GiveN("three")
        "give_4" => 5.0, # = GiveN("four")
        "give_5" => 3.0, # = GiveN("five")
        "give_6" => 2.0, # = GiveN("six")
        "give_7" => 2.0, # = GiveN("seven")
        "give_8" => 1.0, # = GiveN("eight")
        "give_9" => 1.0, # = GiveN("nine")
        "give_10" => 1.0, # = GiveN("ten")

        "how_many_5_blur" => 2.0, #  = HowMany(Blur(5))
        "how_many_6_blur" => 2.0, #  = HowMany(Blur(6))
        "how_many_7_blur" => 1.0, #  = HowMany(Blur(7))
        "how_many_8_blur" => 1.0, #  = HowMany(Blur(8))
        "how_many_9_blur" => 1.0, #  = HowMany(Blur(9))
        "how_many_10_blur" => 1.0, #  = HowMany(Blur(10))

        "more_1" => 0.5, 
        "more_2" => 0.5,

        "unit_add_1" => 4.0, 
        "unit_add_2" => 4.0,
    ])

    slovenian_dataset = deepcopy(english_dataset)
    slovenian_dataset["give_1"] = slovenian_dataset["give_1"] * 1.5
    slovenian_dataset["give_2"] = slovenian_dataset["give_2"] * 1.5

    chinese_dataset = deepcopy(english_dataset)
    chinese_dataset["give_1"] = chinese_dataset["give_1"] * 0.925

    test_name_to_task_dict = Dict([
        "english" => (english_dataset, 0.25, 0.25, ["singular"]), # cultural_counting_emphasis_small_number, cultural_counting_emphasis_large_number
        "slovenian" => (slovenian_dataset, 0.20, 0.20, ["singular", "dual"]), # 0.05, 0.05
        "chinese" => (chinese_dataset, 0.25, 0.25, []),
    ])

    (english_dataset, slovenian_dataset, chinese_dataset, test_name_to_task_dict)
end

english_dataset, slovenian_dataset, chinese_dataset, test_name_to_task_dict = generate_task_distribution()

function compute_counting_task_proportion(task_dict, cultural_counting_emphasis_small_number, cultural_counting_emphasis_large_number, intervention=false)
    total_tasks = sum(map(k -> task_dict[k], [keys(task_dict)...]))
    # total_tasks = intervention ? sum(map(k -> test_name_to_task_dict["english"][1][k], [keys(test_name_to_task_dict["english"][1])...])) : sum(map(k -> task_dict[k], [keys(task_dict)...]))
    counting_tasks_small_number = sum(map(k -> task_dict[k], filter(x -> x in ["give_2", "give_3"], [keys(task_dict)...])))
    individual_counting_proportions = map(n -> n < 4 ? 
        cultural_counting_emphasis_small_number * task_dict["give_$(n)"] : 
        cultural_counting_emphasis_large_number * task_dict["give_$(n)"] * 2.5/n * 0.1, # 0.25
    2:10) ./ total_tasks
    sum(individual_counting_proportions)
end

# COMPUTE UTILITY COMPONENT 1/3: TASK ACCURACIES
function compute_num_tasks(dataset, task_type="")
    if task_type == ""
        sum(map(k -> dataset[k], [keys(dataset)...]))
    else
        sum(map(k -> dataset[k], filter(x -> task_type == "quantifier" ? occursin("quantifier", x) : !occursin("quantifier", x), [keys(dataset)...])))
    end
end

original_english_number_task_count = compute_num_tasks(test_name_to_task_dict["english"][1], "number")

function compute_base_accuracies(dataset, full_reset=true; dir_prefix="")
    base_accuracies = Dict()
    for language_name in language_names
        println("compute_base_accuracies!")
        @show language_name
        println(language_name)
        base_accuracies[language_name] = Dict()

        spec = language_name_to_spec[language_name]

        if occursin("LXP", language_name)
            base_accuracies[language_name] = deepcopy(base_accuracies["L0"])
            tup_index = parse(Int, replace(language_name, "LXP" => ""))
            tup = tups[tup_index]
            
            defined_subset_indices = findall(x -> x != 4, tup)
            defined_subset_numbers = map(i -> tup[i], defined_subset_indices)
            undefined_subset_indices = findall(x -> x == 4, tup)
            undefined_subset_numbers = map(i -> tup[i], undefined_subset_indices)

            for i in 1:10
                if i in defined_subset_indices
                    if i == tup[i]
                        base_accuracies[language_name]["give_$(i)"] = no_guess_prob
                        base_accuracies[language_name]["how_many_$(i)"] = no_guess_prob
                    else
                        base_accuracies[language_name]["give_$(i)"] = 1 - no_guess_prob
                        base_accuracies[language_name]["how_many_$(i)"] = 1 - no_guess_prob
                    end
                else
                    if i in defined_subset_numbers 
                        base_accuracies[language_name]["give_$(i)"] = 1 - no_guess_prob
                        base_accuracies[language_name]["how_many_$(i)"] = 1 - no_guess_prob
                    else
                        base_accuracies[language_name]["give_$(i)"] = 1/(10 - length(defined_subset_numbers))
                        base_accuracies[language_name]["how_many_$(i)"] = 1/(10 - length(defined_subset_numbers))
                    end

                end
            end

        else
            # construct and load language
            language = generate_language(spec)
            if language_name == "L00"
                println(language)
            end
            open("$(current_folder)intermediate_outputs/current_language$(repeat_suffix).jl", "w+") do f 
                write(f, replace(language, "../../" => "../../../"))
            end
            include("""$(dir_prefix != "" ? "$(dir_prefix)/" : "")intermediate_outputs/current_language.jl""")

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

        end        

        if occursin(".5", language_name)
            if !occursin("LX", language_name)
                start_num = occursin("2.5", language_name) ? 3 : 4
                for n in start_num:10
                    base_accuracies[language_name]["give_$(n)"] = (1/2)^(n - start_num + 1)
                    base_accuracies[language_name]["how_many_$(n)"] = (1/2)^(n - start_num + 1)
                end
            else
                for n in 2:10
                    base_accuracies[language_name]["give_$(n)"] = (1/2)^(n)
                    base_accuracies[language_name]["how_many_$(n)"] = (1/2)^(n)
                end
            end
        end

    end
    base_accuracies
end

function compute_accuracies_efficient(dataset, normalized=true, recompute_base=false, intervention=false, quantifier_structure_weight=0.7; dir_prefix="")
    if recompute_base 
        global base_accuracies = compute_base_accuracies(dataset, false, dir_prefix=dir_prefix)
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
        else
            if !intervention
                overall_number_accuracy = overall_number_accuracy * compute_num_tasks(test_name_to_task_dict["english"][1], "number") / total_number_tasks
            end
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
        if normalized 
            accuracy = quantifier_structure_weight * quantifier_accuracy + (1 - quantifier_structure_weight) * number_accuracy
        else
            if total_quantifier_tasks == 0
                accuracy = 0.5 * (quantifier_structure_weight * quantifier_accuracy * (total_number_tasks) + (1 - quantifier_structure_weight) * number_accuracy)
            else
                accuracy = 0.5 * (quantifier_structure_weight * quantifier_accuracy * (total_number_tasks / total_quantifier_tasks) + (1 - quantifier_structure_weight) * number_accuracy)
            end
        end
        push!(accuracies, accuracy)
    end

    @show accuracies
    if normalized 
        accuracies = accuracies .- minimum(accuracies)
        accuracies = accuracies / maximum(accuracies)
    else
        accuracies = accuracies .+ 250 # maximum(accuracies)
        accuracies = (accuracies / 240)
    end

    accuracies
end

compute_base = (@isdefined compute_base) ? compute_base : true
if compute_base 
    base_accuracies = compute_base_accuracies(english_dataset)
end

# COMPUTE UTILITY COMPONENT 2/3: COMPUTATIONAL COSTS
function compute_base_computation_costs(dataset, dir_prefix="")
    base_computation_costs = Dict()
    reordered_language_names = [filter(x -> !occursin(".5", x), language_names)..., filter(x -> occursin(".5", x), language_names)...]
    for language_name in reordered_language_names
        base_computation_costs[language_name] = Dict()
        if occursin("LXP", language_name)
            # count number of number word defs
            number_defn_count = 0
            spec = language_name_to_spec[language_name]
            for k in keys(spec)
                if occursin("definition", k) && !occursin("blur", k) && !occursin("unknown", k) && !occursin("give_n", k)
                    if !occursin("not", spec[k])
                        println(spec[k])
                        println(default_spec[k])
                        number_defn_count += 1
                    end
                end
            end

            for task_name in keys(dataset)
                base_computation_costs[language_name][task_name] = base_computation_costs["L$(number_defn_count)"][task_name]
            end

        elseif occursin(".5", language_name)
            for task_name in keys(dataset)
                if occursin("2.5", language_name) && task_name in ["give_1", "give_2", "how_many_1", "how_many_2"]
                    base_computation_costs[language_name][task_name] = base_computation_costs["L2"][task_name]
                elseif occursin("3.5", language_name) && task_name in ["give_1", "give_2", "give_3", "how_many_1", "how_many_2", "how_many_3"]
                    base_computation_costs[language_name][task_name] = base_computation_costs["L3"][task_name]
                else
                    base_computation_costs[language_name][task_name] = base_computation_costs["L5"][task_name]
                end
            end
        else 
            # construct and load language
            spec = language_name_to_spec[language_name]
            language = generate_language(spec)
            if language_name == "L00"
                println(language)
            end
            open("$(current_folder)intermediate_outputs/current_language$(repeat_suffix).jl", "w+") do f 
                write(f, replace(language, "../../" => "../../../"))
            end
            include("""$(dir_prefix != "" ? "$(dir_prefix)/" : "")intermediate_outputs/current_language.jl""")

            for task_name in keys(dataset)
                println(task_name)
                single_task_dataset = Dict([eval(Symbol(task_name)) => 1])

                # evaluate language on tasks
                cost = compute_computation_cost(single_task_dataset)
                println(cost)
                base_computation_costs[language_name][task_name] = cost
            end

        end
    end
    base_computation_costs
end

function compute_computation_costs_efficient(dataset)
    costs = []
    for language_name in language_names 
        total_cost = 0.0
        for task_name in keys(dataset)
            cost = base_computation_costs[language_name][task_name]
            if (occursin("give_", task_name) || occursin("how_many", task_name)) && !occursin("blur", task_name) 
                num_word = nums_to_number_words[parse(Int, split(task_name, "_")[end])]
                spec = language_name_to_spec[language_name]
                if occursin("not", spec["$(num_word)_definition"]) && !spec["approx"] 
                    cost = 0
                end
            end
            total_cost += cost * dataset[task_name]
        end
        spec = language_name_to_spec[language_name]
        if !(spec["full_knower_compression"] == default_spec["full_knower_compression"])
            early_costs = base_computation_costs["L1"]["give_1"]
            total_cost = (total_cost - early_costs) * 0.05 + early_costs
        elseif spec["approx"]
            if occursin("3.5", language_name)
                early_costs = base_computation_costs["L3.5"]["give_1"] + base_computation_costs["L3.5"]["give_2"] + base_computation_costs["L3.5"]["give_3"] 
            elseif occursin("2.5", language_name)
                early_costs = base_computation_costs["L2.5"]["give_1"] + base_computation_costs["L2.5"]["give_2"]
            elseif occursin("1.5", language_name)
                early_costs = base_computation_costs["L1"]["give_1"]
            end
            total_cost = (total_cost - early_costs) * 0.05 + early_costs
        end

        push!(costs, total_cost)
    end
    costs
end

function compute_individual_computation_cost(spec)
    cost = 0.0
    addend = 0.02
    recurse_addend = 0.065
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

    if number_defn_count > 0
        cost += addend 
    end

    if !(spec["full_knower_compression"] == default_spec["full_knower_compression"]) || spec["approx"]
        cost += recurse_addend
    end

    if spec["ANS_reconciled"] != default_spec["ANS_reconciled"]
        cost -= 0.025
    end

    if spec["unit_add"] != default_spec["unit_add"]
        cost -= 0.025
    end

    cost
end

function compute_all_computation_costs()
    costs = []
    for language_name in language_names
        println(language_name)
        spec = language_name_to_spec[language_name]
        cost = compute_individual_computation_cost(spec)
        push!(costs, cost)
    end
    costs
end

# x .* (0.565 - 0.48) .- 0.02 .+ 0.5^C

# base_computation_costs = compute_base_computation_costs(english_dataset)
# costs = compute_computation_costs_efficient(english_dataset)

# COMPUTE UTILITY COMPONENT 3/3: MEMORY COSTS
function compute_memory_cost(spec, param_effects_memory_mod=0.0)
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
            cost += addend
        end

        if spec["approx"]
            cost += addend * 2/3
        end
    else
        # CP-knower stage reached
        base_cost = addend # knowing meaning of just "one"
        rule_knower_cost = addend * 4/3 # knowing meaning of recursive rule following "one"
        cost = base_cost + rule_knower_cost + param_effects_memory_mod

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
            cost += addend * 1.25
        end
    end

    cost
end

function compute_all_memory_costs(param_effects_memory_mod=0.0) 
    costs = []
    for language_name in language_names
        println(language_name)
        spec = language_name_to_spec[language_name]
        cost = compute_memory_cost(spec, param_effects_memory_mod)
        push!(costs, cost)
    end
    costs
end

# PLOT UTILITY COMPONENTS
accuracies = compute_accuracies_efficient(english_dataset, true)
memory_costs = compute_all_memory_costs()
computational_costs = compute_all_computation_costs()

# edit color palette
old_colors = collect(palette(:tab10))
modified_colors = [old_colors[1:3]..., old_colors[9], old_colors[4], old_colors[10], old_colors[5:8]...]

accuracy_plot, memory_cost_plot, computation_cost_plot = plot_utility_components(accuracies, memory_costs, computational_costs, modified_colors)

plot(accuracy_plot, memory_cost_plot, computation_cost_plot, layout=(3, 1), size=(600, 525 * 3))

# COMPUTE UTILITY FUNCTION
function compute_utility(language_index, t)
    unscaled_utility = gamma_c*t*accuracies[language_index] - cost_c *(memory_costs[language_index] + computational_costs[language_index] - 0.50)
    # @show unscaled_utility
    0.3 * (unscaled_utility - 0.7) - 20
end

# COMPUTE DISCOVERY COSTS
function distance_between_specs(spec1, spec2, relate_factor=0.0; param_effects_distance_mod = 0.0)
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
    dist = dist * 3
    s = 0
    if dist != 0 
        # TODO: add "not" check here
        num_non_default_spec1 = count(k -> !occursin("quantifier", k) && (spec1[k] != default_spec[k]) || occursin("quantifier", k) && filter(x -> spec1[k][x], collect(keys(spec1[k]))) != [], collect(keys(spec1))) 
        num_non_default_spec2 = count(k -> !occursin("quantifier", k) && (spec2[k] != default_spec[k]) || occursin("quantifier", k) && filter(x -> spec2[k][x], collect(keys(spec2[k]))) != [], collect(keys(spec2))) 
        if num_non_default_spec1 > num_non_default_spec2
            s = 1 
        else
            s = -1
        end

        if spec1["full_knower_compression"] != "full_knower_compression" && spec2["full_knower_compression"] == "full_knower_compression" 
            # println("hey")
            # @show dist
            if !((spec1["three_definition"] in ["set.value == 3"]) && (spec1["two_definition"] in ["set.value == 2"]) && (spec1["one_definition"] in ["set.value == 1"]))
                if spec1["two_definition"] in ["set.value == 2"]
                    c = 10 - param_effects_distance_mod # (30.5 + log(2)/log(9)) / 22.5
                    dist = (dist - (dist - 0.1 * c) * minimum([relate_factor * 2, 1.0])) * c
                else
                    dist = dist * 10
                end
                # dist = dist * 10
            else
                dist = 30.5 - 30.4 * relate_factor # 200 - 199.5 * relate_factor
                if !spec1["ANS_reconciled"] && spec2["ANS_reconciled"]
                    dist += 1.5
                end
            end
        end

        # if spec1["full_knower_compression"] != "full_knower_compression" && spec2["ANS_reconciled"]
        #     dist += 10
        # end

        if !spec1["ANS_reconciled"] && spec2["unit_add"] == "unit_add_final"
            dist += 10
        end

        # TODO: if spec1 does not have singular defined or one defined, if spec2 has one defined, that is very low probability
        if ("singular" in keys(spec1["quantifier_structure"])) && !spec1["quantifier_structure"]["singular"] && spec1["one_definition"] != "set.value == 1" && spec2["one_definition"] == "set.value == 1" 
            dist = dist * 100
        elseif ("singular" in keys(spec1["quantifier_structure"])) && spec1["quantifier_structure"]["singular"] && spec1["one_definition"] != "set.value == 1" && spec2["one_definition"] == "set.value == 1" 
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

function compute_transition_probabilities(relate_factor, t, title=""; param_effects_distance_mod = 0.0)
    transition_prob_identity = transition_prob_identity_base - transition_prob_identity_rate * t
    heatmap_values = []
    for l1 in language_names 
        push!(heatmap_values, [])
        for l2 in language_names 
            l1_spec = language_name_to_spec[l1]
            l2_spec = language_name_to_spec[l2]
            dist, s = distance_between_specs(l1_spec, l2_spec, relate_factor, param_effects_distance_mod = param_effects_distance_mod)
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

function get_transition_distribution(transition_probabilities, start_index) # from language with index start_index
    transition_probabilities[i]
end

function get_transition_probability(transition_probabilities, start_index, proposed_index) # from language (start_index) to language (proposed_index)
    get_transition_distribution(transition_probabilities, start_index)[proposed_index]
end

# PARAMS

transition_prob_identity_base = 0.975
transition_prob_identity_rate = 0.004 # 0.0003
transition_prob_base = 9.0 # 2
utility_base = 1.0e13

time_step_unit = 0.1 # 0.0005 # 0.00005 
num_time_steps = 1000

gamma_c = 1.2 # 1.0 # 1.2
cost_c = 0.5 # 0.015 # 0.008

accuracies = []
memory_costs = []
computation_costs = []
relate_task_proportion = 0.0
global relate_factors = [0.0]
all_distributions = []
counting_task_proportion = -1.0

function run_test(test_name_, normalized=true, intervention=false, intervention_small=false, intervention_count=false, save_fig_title=""; param_effects_memory_mod = 0.0, param_effects_distance_mod = 0.0, override_recompute=false, dir_prefix="")
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

            # add singular, one-knower, no dual language
            new_intermediate_language2 = "L02_one_knower_singular_no_dual"
            new_intermediate_spec2 = deepcopy(L1_spec)
            new_intermediate_spec2["quantifier_structure"] = deepcopy(quantifier_structure_spec)

            push!(new_language_names, new_intermediate_language2)
            push!(new_language_specs, new_intermediate_spec2)

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
            global modified_colors = [:lightskyblue1, :deepskyblue1, :darkorange3, modified_colors...]
        end

        # recompute accuracies 
        quantifier_task_proportion = 0.7
        global accuracies = compute_accuracies_efficient(task_dict, normalized, override_recompute ? false : true, false, quantifier_task_proportion, dir_prefix=dir_prefix) # TEMP -- original, stable value is: true, false
    else
        global accuracies = compute_accuracies_efficient(task_dict, normalized, dir_prefix=dir_prefix)
    end

    # accuracies[1] = 0.0

    # COSTS 

    # global memory_costs = [ # TODO
    #     0.00, # L0: non-knower
    #     0.15, # L1: 1-knower
    #     0.30, # 2-knower
    #     0.34, # 2-knower, approx
    #     0.45, # 3-knower
    #     0.49, # 3-knower, approx 
    #     0.6, # 4-knower
    #     0.35, # CP-knower # 0.41
    #     0.5, # CP-mapper
    #     0.65, # CP-unit-knower # normalized setting: 0.7
    # ]
    global memory_costs = compute_all_memory_costs(param_effects_memory_mod)
    global memory_costs = memory_costs .* 2
    # global computational_costs = compute_all_computation_costs() .+ 0.48

    global computational_costs = [ # TODO
    0.48, # L0: non-knower
    0.50, # L1: 1-knower
    0.50, # 2-knower
    0.565, # 2-knower, approx # previously: 0.50
    0.50, # 3-knower
    0.565, # 3-knower, approx # previously: 0.50
    0.50, # 4-knower
    0.565, # CP-knower
    0.54, # CP-mapper
    0.515, # CP-unit-knower
    0.50, # LX1
    0.50, # LX2
    0.50, # LX3
    0.565, # LX1.5
]


    modified_colors = [modified_colors..., :darkgray, :gray76, :gray86, :gray95]
    modified_colors = [modified_colors..., map(x -> :burlywood2, tups)...]
    computational_costs = [computational_costs..., map(x -> 0.50, tups)...]

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

    accuracy_plot, memory_cost_plot, computation_cost_plot = plot_utility_components(accuracies, memory_costs, computational_costs, modified_colors)
    # plot(accuracy_plot, memory_cost_plot, computation_cost_plot, layout=(3, 1), size=(600, 525 * 3))

    maxs, line_plot, max_utility_plot = plot_utility_evolution(modified_colors)
    # plot(line_plot, max_utility_plot, layout=(2, 1), size=(600, 550))

    # _, h0 = compute_transition_probabilities(0, "t=0")
    # _, h20 = compute_transition_probabilities(1000, "t=100")
    # _, h40 = compute_transition_probabilities(2000, "t=200")
    # _, h60 = compute_transition_probabilities(3000, "t=300")
    # _, h80 = compute_transition_probabilities(4000, "t=400")
    # _, h100 = compute_transition_probabilities(5000, "t=500")
    # plot(h0, h20, h40, h60, h80, h100)

    three_knower_stage_reached = false
    three_knower_stage_intervention_made = false
    global relate_factors = [0.0]
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
                    cultural_counting_emphasis_small_number = 0.3
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
                    cultural_counting_emphasis_large_number = 0.3
                end

            end
            
            # counting context vs. no counting context
            # cultural_counting_emphasis_small_number = 0.5
            # cultural_counting_emphasis_large_number = 0.5

            # recompute accuracies and counting_task_proportion
            global accuracies = compute_accuracies_efficient(task_dict, normalized, false, intervention, dir_prefix=dir_prefix)

            global counting_task_proportion = compute_counting_task_proportion(task_dict, cultural_counting_emphasis_small_number, cultural_counting_emphasis_large_number)
        end

        # utility_sum = sum(map(x -> utility_base^(compute_utility(x, t)), 1:length(language_names)))
        
        relate_factor = relate_factors[end]
        relate_factor = relate_factor + time_step_unit * counting_task_proportion * 0.39 # 0.45
        relate_factor = relate_factor > 1 ? 1 : relate_factor
        push!(relate_factors, relate_factor)

        transition_probabilities, _ = compute_transition_probabilities(relate_factor, t, "", param_effects_distance_mod = param_effects_distance_mod)
        next_distribution = map(x -> 0.0, 1:length(language_names))

        normalizer_jk_dict = Dict()
        for j in 1:length(language_names)
            normalizer = 0.0
            for k in 1:length(language_names)
                transition_prob_k = transition_probabilities[j][k]
                utility_k = utility_base^(compute_utility(k, t))
                normalizer += transition_prob_k * utility_k
            end
            normalizer_jk_dict[j] = normalizer
        end

        for i in 1:length(language_names)
            total = 0.0
            utility = utility_base^(compute_utility(i, t))
            for j in 1:length(language_names)
                transition_prob = transition_probabilities[j][i]
                # if (j in [1, 2, 3, 4]) &&  (i in [8, 9, 10])
                #     transition_prob = 0
                # end
                normalizer = normalizer_jk_dict[j]
                total += curr_distribution[j] * (transition_prob * utility / normalizer)
                # total += transition_prob * utility * curr_distribution[j]
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
            dist_plot = plot(dist_xs, dist_ys, color=modified_colors[i], label=occursin("LXP", language_names_pretty[i]) ? "" : language_names_pretty[i], legend=:right, size=(800, 600), title="Posterior over LoTs (Background Proposal x Utility-Based Acceptor)", ylabel="Probability", xlabel="Time")
        else
            dist_plot = plot(dist_plot, dist_xs, dist_ys, color=modified_colors[i], label=occursin("LXP", language_names_pretty[i]) ? "" : language_names_pretty[i], legend=:right, size=(800, 600), title="Posterior over LoTs (Background Proposal x Utility-Based Acceptor)", ylabel="Probability", xlabel="Time")
        end
    end

    # max_lot_plot

    # dist_plot

    # plot(individual_dist_plot, dist_plot, max_lot_plot, layout=(3, 1), size=(1000, 1500))

    println("1 knower becomes MAP: $((intersect(["one knower", "one knower singular no dual"], max_lots) != []) ? findall(x -> x == "one knower" || x == "one knower singular no dual", max_lots)[1] : -1)")
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
    maxs, # utility evolution max LoTs
    max_utility_plot, # maximum utility evolution plot
    dist_plot, # posterior evolution plot
    max_lot_plot, # MAP evolution plot
    max_lots, # MAP evolution max LoTs
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
# maxs,
# max_utility_plot, 
# dist_plot, 
# max_lot_plot,
# max_lots,
# CP_arrival_time,
# one_arrival_time,
# two_arrival_time) = run_test("english", false, param_effects_memory_mod = 0.0, param_effects_distance_mod = 0)

# plot(individual_dist_plot, dist_plot, max_lot_plot, layout=(3, 1), size=(1000, 1500), legend=false)