include("../../base/base_semantics.jl")

global parallel_individuation_limit = 4

function one(set::Union{Exact, Blur})::Bool
    set.value == 1
end

function two(set::Union{Exact, Blur})::Bool
    set.value == 2
end

function three(set::Union{Exact, Blur})::Bool
    set.value == 3
end

function four(set::Union{Exact, Blur})::Bool
    set.value == 4
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
    return two
elseif word == "two"
    return three
elseif word == "three"
    return four
elseif word == "four"
    return five
elseif word == "five"
    return six
elseif word == "six"
    return seven
elseif word == "seven"
    return eight
elseif word == "eight"
    return nine
elseif word == "nine"
    return ten
end

end

function represent_unknown(set::NumberRep, label::Union{String, CountRep})::NumberRep
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

end
