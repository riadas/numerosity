include("../../base/base_semantics.jl")
import Base: String
abstract type QuantityRepr end 

# primitive value types
@enum PI_val pi1=1 pi2=2 pi3=3 pi4=4
@enum ANS_val ans1 ans2 ans3 ans4 ans5 ans6 ans7 ans8 ans9 ans10

struct NS end

abstract type ThunkType{Q <: QuantityRepr} <: QuantityRepr end

struct Thunk{Q} <: ThunkType{Q}
    meaning::Union{Symbol, Expr}
end

# aliases
ParallelIndividuation(v) = PI(v)
ApproximateNumberSystem(v) = ANS(v)
NumberSymbol(l, v) = NS(l, v)

# default constructors
NS(l) = NS(l, Nothing)
NS(l, v::Union{Expr, Symbol}) = NS(l, Thunk{NS}(v))
PI(x::NS) = physical_meaning(x) <= pi4 ? PI_val(physical_meaning(x)) : error("out of range")

meaning(x) = x.meaning
physical_meaning(x) = physical_eval(meaning(x))
label(x::NS) = x.label

function physical_eval(x)
    if !(x isa Thunk) || (x.meaning.head != :call)
        x
    else
        args = x.meaning.args
        eval(Meta.parse("$(args[1])(PhysicalSet($(args[2])),PhysicalSet($(args[3])))")).value
    end
end

max_num = 10
number_list = ["one", "two", "three", "four", "five", "six", "seven", "eight", "nine", "ten"]

function next_word(word::String)::String
    i = findall(x -> x == word, number_list)[1]
    number_list[i + 1]
end

function prev_word(word::String)::String
    i = findall(x -> x == word, number_list)[1]
    number_list[i - 1]
end
