# type casts
NS(l::String) = eval(Meta.parse("$(l)_"))
if supertype(NS) == QuantityRepr
    NS(l, v::Union{Expr, Symbol}) = NS(l, Thunk{NS}(v))
end
String(x::NS) = x.label
add_obj(x::Exact, y::PI) = add_obj(x, Exact(Int(y.meaning)))
remove_obj(x::Exact, y::PI) = remove_obj(x, Exact(Int(y.meaning)))
add_objs(x::Exact, y::ANS) = add_obj(x, Exact(sample(Int(y.meaning) .+ (Int(y.meaning) .* collect(0:1)))))
remove_objs(x::Exact, y::ANS) = remove_obj(x, Exact(sample(Int(y.meaning) .+ (Int(y.meaning) .* collect(0:1)))))
Base.:(==)(x::Int, y::PI) = x == Int(y.meaning)
Base.:(==)(x::PI, y::Int) = y == x
Base.:(==)(x::Int, y::ANS) = x == sample(Int(y.meaning) .+ (Int(y.meaning) .* collect(0:1)))
Base.:(==)(x::ANS, y::Int) = y == x

function indexof(e::NS, l=number_list)
    e == one_ ? 0 : indexof(string(e.meaning.meaning.args[end - 1]))
end

function indexof(e, l=number_list)
    x = findall(a -> a == e, l)
    x == [] ? -1 : x[1]
end