include("../base/base_semantics.jl")

function one(set::Union{Exact, Blur})::Bool
    set.value == 1
end

function two(set::Union{Exact, Blur})::Bool
    set.value == 2
end

function three(set::Union{Exact, Blur})::Bool
    not(map(x -> Base.invokelatest(x, set), [one, two]))
end

function four(set::Union{Exact, Blur})::Bool
    not(map(x -> Base.invokelatest(x, set), [one, two]))
end

function five(set::Exact)::Bool
    not(map(x -> Base.invokelatest(x, set), [one, two]))
end

function six(set::Exact)::Bool
    not(map(x -> Base.invokelatest(x, set), [one, two]))
end

function seven(set::Exact)::Bool
    not(map(x -> Base.invokelatest(x, set), [one, two]))
end

function eight(set::Exact)::Bool
    not(map(x -> Base.invokelatest(x, set), [one, two]))
end

function nine(set::Exact)::Bool
    not(map(x -> Base.invokelatest(x, set), [one, two]))
end

function ten(set::Exact)::Bool
    not(map(x -> Base.invokelatest(x, set), [one, two]))
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