using StatsBase
abstract type Task end
abstract type NumberRep end

struct Exact <: NumberRep
    value::Int
end

struct Blur <: NumberRep
    value::Int
end

struct GiveN <: Task 
    input::String
    output::Exact
end 

struct HowMany <: Task
    input::NumberRep
    output::String
end

struct Compare <: Task 
    input::Tuple{NumberRep, NumberRep}
    output::Vector{NumberRep}
end

max_num = 10
number_words_to_nums = Dict([
    "one" => 1,
    "two" => 2,
    "three" => 3,
    "four" => 4,
    "five" => 5,
    "six" => 6,
    "seven" => 7,
    "eight" => 8,
    "nine" => 9,
    "ten" => 10
])

nums_to_number_words = Dict(map(p -> p[2] => p[1], collect(number_words_to_nums)))

GiveN(input::String) = GiveN(input, Exact(number_words_to_nums[input]))
HowMany(input::NumberRep) = HowMany(input, first(filter(x -> last(x) == input.value, collect(number_words_to_nums))[1]))
Compare(input::Tuple{NumberRep, NumberRep}) = Compare(input, input[1].value > input[2].value ? [input[1]] : input[1].value == input[2].value ? [input...] : [input[2]])

# comparisons within a core number system: Exact
Base.isless(x::Exact, y::Exact) = x.value < y.value
Base.isequal(x::Exact, y::Exact) = x.value == y.value
Base.isgreater(x::Exact, y::Exact) = x.value > y.value

# comparisons within a core number system: Blur
Base.isless(x::Blur, y::Blur) = x.value < y.value
Base.isequal(x::Blur, y::Blur) = x.value == y.value
Base.isgreater(x::Blur, y::Blur) = x.value > y.value

# comparisons across the two number systems: initially, at chance
Base.isless(x::Exact, y::Blur) = sample([false, true])
Base.isless(x::Blur, y::Exact) = sample([false, true])

Base.isequal(x::Exact, y::Blur) = sample([false, true])
Base.isequal(x::Blur, y::Exact) = sample([false, true])

Base.isgreater(x::Exact, y::Blur) = sample([false, true])
Base.isgreater(x::Blur, y::Exact) = sample([false, true])

Base.string(x::Exact) = """< $(join(map(i -> "*", 1:x.value), " ")) >"""
Base.string(x::Blur) = """? $(join(map(i -> "*", 1:x.value), " ")) ?"""

function not(x::Bool)
    !x
end

function not(x::Vector{Bool})
    !foldl(|, x, init=false)
end

function singular(set::Exact)
    set.value == 1
end

function plural(set::Exact)
    set.value != 1
end

function add(set1::Exact, set2::Exact)::Exact
    Exact(set1.value + set2.value)
end

function remove(set1::Exact, set2::Exact)::Exact
    Exact(set1.value - set2.value)
end