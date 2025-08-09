include("../../base/base_semantics.jl")

global parallel_individuation_limit = 3

function one(set::Union{Exact, Blur})::Bool
    set.value == 1
end

function two(set::Union{Exact, Blur})::Bool
    Base.invokelatest(eval(Meta.parse(nums_to_number_words[number_words_to_nums[string(StackTraces.stacktrace()[1].func)] - 1])), remove(set, Exact(1)))
end

function three(set::Union{Exact, Blur})::Bool
    Base.invokelatest(eval(Meta.parse(nums_to_number_words[number_words_to_nums[string(StackTraces.stacktrace()[1].func)] - 1])), remove(set, Exact(1)))
end

function four(set::Union{Exact, Blur})::Bool
    Base.invokelatest(eval(Meta.parse(nums_to_number_words[number_words_to_nums[string(StackTraces.stacktrace()[1].func)] - 1])), remove(set, Exact(1)))
end

function five(set::Exact)::Bool
    Base.invokelatest(eval(Meta.parse(nums_to_number_words[number_words_to_nums[string(StackTraces.stacktrace()[1].func)] - 1])), remove(set, Exact(1)))
end

function six(set::Exact)::Bool
    Base.invokelatest(eval(Meta.parse(nums_to_number_words[number_words_to_nums[string(StackTraces.stacktrace()[1].func)] - 1])), remove(set, Exact(1)))
end

function seven(set::Exact)::Bool
    Base.invokelatest(eval(Meta.parse(nums_to_number_words[number_words_to_nums[string(StackTraces.stacktrace()[1].func)] - 1])), remove(set, Exact(1)))
end

function eight(set::Exact)::Bool
    Base.invokelatest(eval(Meta.parse(nums_to_number_words[number_words_to_nums[string(StackTraces.stacktrace()[1].func)] - 1])), remove(set, Exact(1)))
end

function nine(set::Exact)::Bool
    Base.invokelatest(eval(Meta.parse(nums_to_number_words[number_words_to_nums[string(StackTraces.stacktrace()[1].func)] - 1])), remove(set, Exact(1)))
end

function ten(set::Exact)::Bool
    Base.invokelatest(eval(Meta.parse(nums_to_number_words[number_words_to_nums[string(StackTraces.stacktrace()[1].func)] - 1])), remove(set, Exact(1)))
end

# ANS
function five(set::Blur)::Bool
    true
end

function six(set::Blur)::Bool
    true
end

function seven(set::Blur)::Bool
    true
end

function eight(set::Blur)::Bool
    true
end

function nine(set::Blur)::Bool
    true
end

function ten(set::Blur)::Bool
    true
end

function list_syntax_next(word::String)::String 
    label(add(meaning(word), Exact(1)))
end

function represent_unknown(set::NumberRep, label::Union{String, CountRep})::NumberRep
    Exact(set.value)
end
