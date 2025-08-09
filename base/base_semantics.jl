using StatsBase
abstract type Task end
abstract type NumberRep end
abstract type CountRep end

global parallel_individuation_limit = 4
global ANS_ratio = 3/2

struct Exact <: NumberRep
    value::Int
end

struct Blur <: NumberRep
    value::Int
end

struct Unknown <: NumberRep
    value::Int
end

struct VerbalCount <: CountRep 
    value::Int
    foreign::Bool
    reordered::Bool
    one_to_one::Bool
end

struct VerbalCountWithCP <: CountRep 
    value::Int
    foreign::Bool
    reordered::Bool
    one_to_one::Bool
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

struct LabeledCompare <: Task 
    input::Tuple{Tuple{NumberRep, NumberRep}, Tuple{Union{String, CountRep}, Union{String, CountRep}}}
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

number_words_to_nums = Dict( filter(p -> last(p) <= max_num, collect(number_words_to_nums)))

nums_to_number_words = Dict(map(p -> p[2] => p[1], collect(number_words_to_nums)))

VerbalCount(value::Int) = VerbalCount(value, false, false, true)
VerbalCountWithCP(value::Int) = VerbalCountWithCP(value, false, false, true)

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
Base.string(x::Unknown) = """??? ($(x.value)) ???"""

function not(x::Bool)
    !x
end

function not(x)
    !foldl(|, x, init=false)
end

function singular(set::Exact)
    set.value == 1
end

function plural(set::Exact)
    set.value != 1
end

function add(set1::NumberRep, set2::NumberRep)::NumberRep
    typeof(set1)(set1.value + set2.value)
end

function remove(set1::NumberRep, set2::NumberRep)::NumberRep
    typeof(set1)(set1.value - set2.value)
end

function meaning(word::String)
    Exact(number_words_to_nums(word))
end

function label(set::Exact)
    nums_to_number_words(set.value)
end

function noise(set::Blur, std_diff=5)
    std = set.value - std_diff 
    collect(set.value - std : set.value + std)
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

function how_many(set::NumberRep, prob=false) 
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
end

function compare(sets::Tuple{NumberRep, NumberRep}, prob=false)
    if !prob 
        if Base.invokelatest(Base.isless, sets[1], sets[2])
            sets[2]
        elseif Base.invokelatest(Base.isequal, sets[1], sets[2])
            sample(sets[1], sets[2])
        else
            sets[1]
        end
    else
        if typeof(sets[1]) == typeof(sets[2])
            1.0
        else
            xs = []
            for _ in 1:100 # TODO: refactor
                push!(xs, Base.invokelatest(Base.isless, sets[1], sets[2]))
            end
            if length(unique(xs)) == 1
                1.0
            else
                0.5
            end
        end
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

function labeled_compare(labeled_sets::Tuple{Tuple{NumberRep, NumberRep}, Tuple{Union{String, CountRep}, Union{String, CountRep}}}, prob=false)
    sets = labeled_sets[1]
    labels = labeled_sets[2]

    set1 = Base.invokelatest(represent_unknown, sets[1], labels[1])
    set2 = Base.invokelatest(represent_unknown, sets[2], labels[2])

    if !prob 

        if set1 isa Unknown || set2 isa Unknown 
            sample([sets...])
        elseif set1 isa Blur || set2 isa Blur 
            max_value = max(set1.value, set2.value)
            min_value = min(set1.value, set2.value)
            if max_value/min_value > ANS_ratio 
                max_sets = filter(x -> x.value == max_value, sets)
                sample([max_sets...])
            else
                sample([sets...])
            end
        else
            if set1.value < set2.value 
                sets[2]
            elseif set1.value > set2.value 
                sets[1]
            else
                sample([sets...])
            end
        end
    else

        if set1 isa Unknown || set2 isa Unknown 
            0.5
        elseif set1 isa Blur || set2 isa Blur 
            max_value = max(set1.value, set2.value)
            min_value = min(set1.value, set2.value)
            if max_value/min_value >= ANS_ratio || max_value == min_value
                1.0
            else
                0.5
            end
        else
            1.0
        end        

    end
end

function evaluate(task)
    task_type = string(typeof(task))
    task_eval_function_characters = []
    for i in 1:length(task_type)
        c = task_type[i]
        if isuppercase(c)
            if i == 1 
                push!(task_eval_function_characters, "$(string(lowercase(c)))")
            else
                push!(task_eval_function_characters, "_$(string(lowercase(c)))")
            end
        else
            push!(task_eval_function_characters, string(c))
        end
    end
    task_eval_function = eval(Meta.parse(join(task_eval_function_characters)))
    prob = Base.invokelatest(task_eval_function, task.input, true)
    prob
end