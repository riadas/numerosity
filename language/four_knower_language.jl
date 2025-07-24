include("../base/base_semantics.jl")

function one(set::Exact)::Bool
    set == Exact(1)
end

function two(set::Exact)::Bool
    set == Exact(2)
end

function three(set::Exact)::Bool
    set == Exact(3)
end

function four(set::Exact)::Bool
    set == Exact(4)
end

function five(set::Exact)::Bool
    not(map(x -> Base.invokelatest(x, set), [one, two, three, four]))
end

function six(set::Exact)::Bool
    not(map(x -> Base.invokelatest(x, set), [one, two, three, four]))
end

function seven(set::Exact)::Bool
    not(map(x -> Base.invokelatest(x, set), [one, two, three, four]))
end

function eight(set::Exact)::Bool
    not(map(x -> Base.invokelatest(x, set), [one, two, three, four]))
end

function nine(set::Exact)::Bool
    not(map(x -> Base.invokelatest(x, set), [one, two, three, four]))
end

function ten(set::Exact)::Bool
    not(map(x -> Base.invokelatest(x, set), [one, two, three, four]))
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
    if word == "one"
        return "two"
    elseif word == "two"
        return "three"
    elseif word == "three"
        return "four"
    elseif word == "four"
        return "five"
    elseif word == "five"
        return "six"
    elseif word == "six"
        return "seven"
    elseif word == "seven"
        return "eight"
    elseif word == "eight"
        return "nine"
    elseif word == "nine"
        return "ten"
    end
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