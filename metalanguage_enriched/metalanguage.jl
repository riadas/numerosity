include("../base/base_semantics.jl")

function generate_language(spec)    
    language = language_template

    language = replace(language, "[parallel_individuation_limit]" => spec["parallel_individuation_limit"])

    for k in keys(number_words_to_nums)
        language = replace(language, "[$(k)_definition]" => spec["$(k)_definition"])
    end

    for k in filter(x -> occursin("definition_blur", x), collect(keys(spec)))
        language = replace(language, "[$(k)]" => spec[k])
    end

    if spec["full_knower_compression"] == "full_knower_compression"
        list_syntax_definition = list_syntax_compressed
        language = replace(language, "[represent_unknown_definition]" => represent_unknown_final_definition)
    else
        list_syntax_definition = list_syntax_next_definition_template
        for k in filter(x -> occursin("list_syntax_next", x), collect(keys(spec)))
            list_syntax_definition = replace(list_syntax_definition, "[$(k)]" => spec[k])
        end
        language = replace(language, "[represent_unknown_definition]" => eval(Meta.parse(spec["represent_unknown_definition"])))
    end

    language = replace(language, "[list_syntax_next_definition_template]" => list_syntax_definition)
    
    language = replace(language, "[unit_add]" => eval(Meta.parse(spec["unit_add"])))

    language = replace(language, "[give_n_definition]" => eval(Meta.parse(spec["give_n_definition"])))

    if spec["ANS_reconciled"]
        language = "$(language)\n$(ANS_eval_components)"
    end

    return language
end

language_template = """
include("../../base/base_semantics.jl")

global parallel_individuation_limit = [parallel_individuation_limit]

function one(set::Union{Exact, Blur})::Bool
    [one_definition]
end

function two(set::Union{Exact, Blur})::Bool
    [two_definition]
end

function three(set::Union{Exact, Blur})::Bool
    [three_definition]
end

function four(set::Union{Exact, Blur})::Bool
    [four_definition]
end

function five(set::Exact)::Bool
    [five_definition]
end

function six(set::Exact)::Bool
    [six_definition]
end

function seven(set::Exact)::Bool
    [seven_definition]
end

function eight(set::Exact)::Bool
    [eight_definition]
end

function nine(set::Exact)::Bool
    [nine_definition]
end

function ten(set::Exact)::Bool
    [ten_definition]
end

# ANS
function five(set::Blur)::Bool
    [five_definition_blur]
end

function six(set::Blur)::Bool
    [six_definition_blur]
end

function seven(set::Blur)::Bool
    [seven_definition_blur]
end

function eight(set::Blur)::Bool
    [eight_definition_blur]
end

function nine(set::Blur)::Bool
    [nine_definition_blur]
end

function ten(set::Blur)::Bool
    [ten_definition_blur]
end

function list_syntax_next(word::String)::String 
    [list_syntax_next_definition_template]
end

function represent_unknown(set::NumberRep, label::Union{String, CountRep})::NumberRep
    [represent_unknown_definition]
end

[unit_add]

[give_n_definition]

"""

# function represent_unknown(set::NumberRep, label::Union{String, CountRep})::NumberRep
#     if !(set isa Unknown)
#         set
#     elseif set.value <= parallel_individuation_limit 
#         Exact(set.value)
#     elseif label isa String 
#         set
#     else # if label isa CountRep 
#         if (label isa VerbalCount && !label.foreign && !label.reordered && label.one_to_one) || (label isa VerbalCountWithCP && label.one_to_one)
#             Blur(set.value)
#         else
#             set
#         end
#     end
# end

# function represent_unknown(set::NumberRep, label::Union{String, CountRep})::NumberRep
#     set
# end

# function represent_unknown(set::NumberRep, label::Union{String, CountRep})::NumberRep
#     Exact(set.value)
# end

represent_unknown_base_definition = "set"
represent_unknown_final_definition = "Exact(set.value)"
represent_unknown_intermediate_definition = """
if !(set isa Unknown)
    set
elseif set.value <= parallel_individuation_limit 
    Exact(set.value)
elseif label isa String 
    set
else # if label isa CountRep 
    if (label isa VerbalCount && !label.foreign && !label.reordered && label.one_to_one) || (label isa VerbalCountWithCP && label.one_to_one)
        Blur(set.value)
    else
        set
    end
end
"""

unit_add_base = """
function unit_add(set::NumberRep, prob=false)
    if !prob 
        sample([nums_to_number_words[set.value + 1], nums_to_number_words[set.value + 2]])
    else
        0.5
    end
end
"""

unit_add_final = """
function unit_add(set::NumberRep, prob=false)
    if !prob 
        nums_to_number_words(set.value + 1)
    else
        1.0
    end
end
"""

list_syntax_next_definition_template = """
if word == "one"
    return [list_syntax_next_two]
elseif word == "two"
    return [list_syntax_next_three]
elseif word == "three"
    return [list_syntax_next_four]
elseif word == "four"
    return [list_syntax_next_five]
elseif word == "five"
    return [list_syntax_next_six]
elseif word == "six"
    return [list_syntax_next_seven]
elseif word == "seven"
    return [list_syntax_next_eight]
elseif word == "eight"
    return [list_syntax_next_nine]
elseif word == "nine"
    return [list_syntax_next_ten]
end
"""

list_syntax_compressed = "label(add(meaning(word), Exact(1)))"
ANS_eval_components = """
function how_many(set::NumberRep, prob=false)
    if set isa Exact 
        matches = []
        for word in keys(number_words_to_nums)
            f = eval(Meta.parse(word))
            if Base.invokelatest(f, set)
                push!(matches, word)
            end
        end 

        if matches != []
            prob ? 1/length(matches) : sample(matches)
        else
            prob ? 1/max_num : sample(collect(keys(number_words_to_nums)))
        end
    else
        # TODO: refactor below
        probs = Dict([
            5 => (1)
            6 => (1/3)
            7 => (1/5)
            8 => (1/6)
            9 => (1/6)
            10 => (1/6)
        ])

        prob ? probs[set.value] : noise(set)
    end
end

Base.isless(x::Exact, y::Blur) = x.value < y.value
Base.isless(x::Blur, y::Exact) = x.value < y.value

Base.isequal(x::Exact, y::Blur) = x.value == y.value
Base.isequal(x::Blur, y::Exact) = x.value == y.value

Base.isgreater(x::Exact, y::Blur) = x.value > y.value
Base.isgreater(x::Blur, y::Exact) = x.value > y.value

Base.isless(x::NumberWord, y::NumberWord) = x.value < y.value
Base.isgreater(x::NumberWord, y::NumberWord) = x.value > y.value
"""

ANS_blur_definition = "sample(noise(set)) == number_words_to_nums[string(StackTraces.stacktrace()[1].func)]"
compressed_exact_definition = "Base.invokelatest(eval(Meta.parse(nums_to_number_words[number_words_to_nums[string(StackTraces.stacktrace()[1].func)] - 1])), remove(set, Exact(1)))"

give_n_standard_definition = """
function give_n(n::String, prob=false)
    f = eval(Meta.parse(n)) # definition of the number n
    matches = []
    for i in 1:max_num 
        set = Exact(i)
        if Base.invokelatest(f, set) 
            push!(matches, set)
        end
    end

    if matches != []
        prob ? 1/length(matches) : sample(matches)
    else
        prob ? 1/max_num : sample(map(i -> Exact(i), 1:max_num))
    end
end
"""

give_n_passive_count_definition = """
function give_n(n::String, prob=false)
    if number_words_to_nums[n] <= 3 
        1.0
    else
        1/length(4:max_num)
    end
end
"""