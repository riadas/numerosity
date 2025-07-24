include("../base/base_semantics.jl")

function one(set::Exact)::Bool
    set == Exact(1)
end

function two(set::Exact)::Bool
    Base.invokelatest(nums_to_number_words[number_words_to_nums[string(StackTraces.stacktrace()[1].func)] - 1], remove(set, Exact(1)))
end

function three(set::Exact)::Bool
    Base.invokelatest(nums_to_number_words[number_words_to_nums[string(StackTraces.stacktrace()[1].func)] - 1], remove(set, Exact(1)))
end

function four(set::Exact)::Bool
    Base.invokelatest(nums_to_number_words[number_words_to_nums[string(StackTraces.stacktrace()[1].func)] - 1], remove(set, Exact(1)))
end

function five(set::Exact)::Bool
    Base.invokelatest(nums_to_number_words[number_words_to_nums[string(StackTraces.stacktrace()[1].func)] - 1], remove(set, Exact(1)))
end

function six(set::Exact)::Bool
    Base.invokelatest(nums_to_number_words[number_words_to_nums[string(StackTraces.stacktrace()[1].func)] - 1], remove(set, Exact(1)))
end

function seven(set::Exact)::Bool
    Base.invokelatest(nums_to_number_words[number_words_to_nums[string(StackTraces.stacktrace()[1].func)] - 1], remove(set, Exact(1)))
end

function eight(set::Exact)::Bool
    Base.invokelatest(nums_to_number_words[number_words_to_nums[string(StackTraces.stacktrace()[1].func)] - 1], remove(set, Exact(1)))
end

function nine(set::Exact)::Bool
    Base.invokelatest(nums_to_number_words[number_words_to_nums[string(StackTraces.stacktrace()[1].func)] - 1], remove(set, Exact(1)))
end

function ten(set::Exact)::Bool
    Base.invokelatest(nums_to_number_words[number_words_to_nums[string(StackTraces.stacktrace()[1].func)] - 1], remove(set, Exact(1)))
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
    return label(add(meaning(word), Exact(1)))
end

function give_n(n::String)
    f = eval(Meta.parse(n)) # definition of the number n
    matches = []
    for i in 1:max_num 
        set = Exact(i)
        if f(set) 
            push!(matches, set)
        end
    end

    if matches == []
        sample(matches)
    else
        sample(map(i -> Exact(i), 1:max_num))
    end
end

function how_many(set::NumberRep)
    matches = []
    for word in keys(number_words_to_nums)
        f = eval(Meta.parse(word))
        if Base.invokelatest(f, set)
            push!(matches, word)
        end
    end 

    if matches == []
        sample(matches)
    else
        sample(collect(keys(number_words_to_nums)))
    end
end

function compare(sets::Tuple{NumberRep, NumberRep})
    if Base.invokelatest(Base.isless, sets[1], sets[2])
        sets[2]
    elseif Base.invokelatest(Base.isequal, sets[1], sets[2])
        sample(sets[1], sets[2])
    else
        sets[1]
    end
end

function meaning(word::String)
    Exact(number_words_to_nums(word))
end

function label(set::Exact)
    nums_to_number_words(set.value)
end