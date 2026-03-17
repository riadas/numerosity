function add_objs(x::NS)
    NS(next_word(String(x)))
end
    
function remove_objs(x::NS)
    NS(prev_word(String(x)))
end

function one(set::Exact)
	set.value == ANS1_
    end

function two(set::Exact)
	one(remove_objs(set, ANS1_))
    end

function three(set::Exact)
	two(remove_objs(set, ANS1_))
    end

function four(set::Exact)
	three(remove_objs(set, ANS1_))
    end

function five(set::Exact)
	four(remove_objs(set, ANS1_))
    end

function six(set::Exact)
	five(remove_objs(set, ANS1_))
    end

function seven(set::Exact)
	six(remove_objs(set, ANS1_))
    end

function eight(set::Exact)
	seven(remove_objs(set, ANS1_))
    end

function nine(set::Exact)
	eight(remove_objs(set, ANS1_))
    end

function ten(set::Exact)
	nine(remove_objs(set, ANS1_))
    end