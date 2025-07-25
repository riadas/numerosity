include("../base/base_semantics.jl")
include("../task_configs/generate_tasks.jl")

languages = [
    "non_knower_language",
    "one_knower_language",
    "two_knower_language",
    "three_knower_language",
    "four_knower_language",
    "full_knower_language",
    "full_knower_reconciled_ANS_language"
]

final_probs = []
for language in languages 
    # evaluate each language on set of tasks
    println("LANGUAGE: $(language)")
    probs = []
    for task in tasks
        include("$(language).jl")
        prob = evaluate(task)
        println("----- TASK: $(task), PROB: $(prob)")   
        push!(probs, prob)      
    end
    prob = foldl(*, probs, init=1.0)
    push!(final_probs, prob)
end

println()
for i in 1:length(languages) 
    println("$(languages[i]): $(final_probs[i])")
end

label(add(meaning(word), Exact(1)))
label(add(meaning(word), meaning(word)))
# bigger blurs correspond to bigger numbers