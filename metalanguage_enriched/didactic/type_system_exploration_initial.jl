# ----- FINAL TYPE SYSTEM ----- 
include("type_system_exploration_base.jl")
using Random 

# abstract quantity representation type
abstract type QuantityRepr end 

# core (primitive) type system 1: parallel individuation
struct PI <: QuantityRepr
    meaning::PI_val
end

add_obj(x::PI) = PI(PI_val(Int(x) + 1)) # breaks >4
compare(x1::PI, x2::PI, op::Symbol) = eval(op)(Int(x1), Int(x2))

# core (primitive) type system 2: approximate number system
struct ANS <: QuantityRepr
    meaning::ANS_val
end

add_obj(x::ANS) = ANS(ANS_val(Int(x) + sample(collect(1:3))))
compare(x1::ANS, x2::ANS, op::Symbol) = Int(x1) / Int(x2) > thresh || Int(x2) / Int(x1) > thresh ? eval(op)(Int(x1), Int(x2)) : sample([true, false])

# number symbols (wrapper around primitive quantity representations)
struct NS
    label::String 
    meaning::QuantityRepr
end

NS(l::String) = eval(Meta.parse("$(l)_"))
# NS(l, v::Union{Expr, Symbol}) = NS(l, Thunk{NS}(v))
String(x::NS) = x.label
add_obj(x::Exact, y::PI) = add_obj(x, Exact(Int(y.meaning)))
remove_obj(x::Exact, y::PI) = remove_obj(x, Exact(Int(y.meaning)))
Base.:(==)(x::Int, y::PI) = x == Int(y.meaning)
Base.:(==)(x::PI, y::Int) = y == x

# primitive values
## PI values: x, xx, xxx, xxxx
x_ = PI(pi1)
xx_ = PI(pi2)
xxx_ = PI(pi3)
xxxx_ = PI(pi4)

## ANS values: ANS1, ANS2, ..., ANS10
for i in 1:length(instances(ANS_val))
    s = "ANS$(i)_ = ANS(ans$(i))" # e.g. ANS1 = ANS(a1)
    eval(Meta.parse(s))
end

for word in number_list 
    if word == "one"
        s = "$(word)_ = NS(\"$(word)\", x_)"
    elseif word == "two"
        s = "$(word)_ = NS(\"$(word)\", xx_)"
    elseif word == "three"
        s = "$(word)_ = NS(\"$(word)\", xxx_)"
    else
        break
    end
    eval(Meta.parse(s))
end

@macro physical_expand()
    elts = []
    for num in number_list 
        s = """function $(num)(set::Exact)
        @match $(num) set
    end"""
        push!(elts, s)
    end
    join(elts, "\n\n")
end

@physical