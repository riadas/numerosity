include("../run_inference.jl")

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

# fully ANS-based specs
LX1_spec = deepcopy(L1_spec)
LX1_spec["one_definition"] = "set.value in [1, 2]"
# LX1_spec["two_definition"] = "set.value != 1"

LX2_spec = deepcopy(L2_spec)
LX2_spec["one_definition"] = "set.value in [1, 2]"
LX2_spec["two_definition"] = "set.value in [2, 3]"
# LX2_spec["three_definition"] = "!(set.value in [1, 2])"


LX3_spec = deepcopy(L3_spec)
LX3_spec["one_definition"] = "set.value in [1, 2]"
LX3_spec["two_definition"] = "set.value in [2, 3]"
LX3_spec["three_definition"] = "set.value in [2, 3, 4]"
# LX3_spec["four_definition"] = "!(set.value in [1, 2, 3])"

LX4_spec = deepcopy(L1_spec)
LX4_spec["one_definition"] = "set.value in [1, 2]"
LX4_spec["approx"] = true

language_name_to_spec["LX1"] = LX1_spec
language_name_to_spec["LX2"] = LX2_spec
language_name_to_spec["LX3"] = LX3_spec
language_name_to_spec["LX1.5"] = LX4_spec

language_names = [language_names..., "LX1", "LX2", "LX3", "LX1.5"]
language_names_pretty = [language_names_pretty..., "LX1_ans_1", "LX2_ans_2", "LX3_ans_3", "LX1.5_ans_relate"]

# # alternative PI-based specs
# alt_pi_language_names = []
# alt_pi_language_names_pretty = []
# alt_pi_language_specs = []
# # tups = collect(Iterators.product(map(x -> collect(1:5), 1:4)...))
# # tups = collect(Iterators.product([1, 5], [2, 5], [3, 5], [4, 5]))
# # tups = filter(t -> !(t in [
# #                             (5, 5, 5, 5),
# #                             (1, 5, 5, 5),
# #                             (1, 2, 5, 5),
# #                             (1, 2, 3, 5),
# #                             (1, 2, 3, 4),
# #                             ]),
# #                     tups)

# tups = collect(Iterators.product(map(x -> collect(1:4), 1:3)...))
# tups = filter(t -> !(t in [
#                             (4, 4, 4),
#                             (1, 4, 4),
#                             (1, 2, 4),
#                             (1, 2, 3),
#                             ]),
#                     tups)

# for i in 1:length(tups)
#     tup = tups[i]
#     spec = deepcopy(L0_spec) 
#     undefined_subset_numbers = findall(x -> x == 4, tup)
#     defined_subset_numbers = findall(x -> x != 4, tup)
#     undefined_definition_list = "[$(join(map(x -> nums_to_number_words[x], defined_subset_numbers), ", "))]"
#     undefined_definition = "not(map(x -> Base.invokelatest(x, set), $(undefined_definition_list)))"

#     for n in defined_subset_numbers 
#         spec["$(nums_to_number_words[n])_definition"] = "set.value == $(tup[n])"
#     end

#     for n in [undefined_subset_numbers..., collect(4:10)...]
#         spec["$(nums_to_number_words[n])_definition"] = undefined_definition
#     end
#     base_name = "LXP$(i)"
#     push!(alt_pi_language_names, base_name)
#     push!(alt_pi_language_names_pretty, "$(base_name)_$(join(tup))")
#     language_name_to_spec[base_name] = spec
# end

# push!(language_names, alt_pi_language_names...)
# push!(language_names_pretty, alt_pi_language_names_pretty...)