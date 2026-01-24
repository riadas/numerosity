include("../../../base/base_semantics.jl")

global parallel_individuation_limit = 4

function singular(set::Exact)::Bool
    set.value == 1
end




function one(set::Union{Exact, Blur})::Bool
    set.value in [1, 2]
end

function two(set::Union{Exact, Blur})::Bool
    not(map(x -> Base.invokelatest(x, set), [one]))
end

function three(set::Union{Exact, Blur})::Bool
    not(map(x -> Base.invokelatest(x, set), [one]))
end

function four(set::Union{Exact, Blur})::Bool
    not(map(x -> Base.invokelatest(x, set), [one]))
end

function five(set::Exact)::Bool
    not(map(x -> Base.invokelatest(x, set), [one]))
end

function six(set::Exact)::Bool
    not(map(x -> Base.invokelatest(x, set), [one]))
end

function seven(set::Exact)::Bool
    not(map(x -> Base.invokelatest(x, set), [one]))
end

function eight(set::Exact)::Bool
    not(map(x -> Base.invokelatest(x, set), [one]))
end

function nine(set::Exact)::Bool
    not(map(x -> Base.invokelatest(x, set), [one]))
end

function ten(set::Exact)::Bool
    not(map(x -> Base.invokelatest(x, set), [one]))
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

function unit_add(set::NumberRep, prob=false)
    if !prob 
        sample([nums_to_number_words[set.value + 1], nums_to_number_words[set.value + 2]])
    else
        0.5
    end
end


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


