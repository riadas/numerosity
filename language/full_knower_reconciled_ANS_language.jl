include("../base/base_semantics.jl")

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
    sample(noise(set)) == number_words_to_nums[string(StackTraces.stacktrace()[1].func)]
end

function six(set::Blur)::Bool
    sample(noise(set)) == number_words_to_nums[string(StackTraces.stacktrace()[1].func)]
end

function seven(set::Blur)::Bool
    sample(noise(set)) == number_words_to_nums[string(StackTraces.stacktrace()[1].func)]
end

function eight(set::Blur)::Bool
    sample(noise(set)) == number_words_to_nums[string(StackTraces.stacktrace()[1].func)]
end

function nine(set::Blur)::Bool
    sample(noise(set)) == number_words_to_nums[string(StackTraces.stacktrace()[1].func)]
end

function ten(set::Blur)::Bool
    sample(noise(set)) == number_words_to_nums[string(StackTraces.stacktrace()[1].func)]
end

function list_syntax_next(word::String)::String 
    return label(add(meaning(word), Exact(1)))
end

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