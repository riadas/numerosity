function add_obj(x::NS)
    NS(next_word(String(x)))
end
    
function remove_obj(x::NS)
    NS(prev_word(String(x)))
end

function one(set::Exact)
	set.value == x_
    end

function two(set::Exact)
	one(remove_obj(set, x_))
    end

function three(set::Exact)
	two(remove_obj(set, x_))
    end

function four(set::Exact)
	three(remove_obj(set, x_))
    end

function five(set::Exact)
	four(remove_obj(set, x_))
    end

function six(set::Exact)
	five(remove_obj(set, x_))
    end

function seven(set::Exact)
	six(remove_obj(set, x_))
    end

function eight(set::Exact)
	seven(remove_obj(set, x_))
    end

function nine(set::Exact)
	eight(remove_obj(set, x_))
    end

function ten(set::Exact)
	nine(remove_obj(set, x_))
    end