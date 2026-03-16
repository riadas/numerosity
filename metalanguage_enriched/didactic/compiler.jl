
inverse_rules = [("add_obj", "remove_obj"), 
                 ("next_word", "prev_word")]

for r in inverse_rules[1:2] 
    push!(inverse_rules, (r[2], r[1]))
end

inverse_rules_dict = Dict(map(r -> r[1] => r[2], inverse_rules))

function compile(lang_str::String; pretty=true)
    # evaluate non-@-based code first

    lines = split(lang_str, "\n")
    macro_line_start = findall(x -> occursin("@", x), lines)[1]

    non_macro_lines = lines[1:macro_line_start - 1]
    non_macro_segment = join(non_macro_lines, "\n")

    # write to temporary file and evaluate 
    open("metalanguage_enriched/didactic/type_intermediate.jl", "w+") do f
        write(f, non_macro_segment)
    end

    include("type_intermediate.jl")

    # then evaluate nested @'s inside @macro definitions
    
    macro_lines = lines[macro_line_start:end]
    macro_definition_line_indices = findall(x -> occursin("@macro", x), macro_lines)
    
    for start_index in macro_definition_line_indices
        nesting = 0
        end_index = -1
        for i in collect(start_index:length(macro_lines))
            l = macro_lines[i]
            if occursin("if", l) || occursin("for", l) || occursin("function", l)
                nesting += 1
            elseif occursin("end", l)
                if nesting == 0 
                    end_index = i 
                    break 
                else
                    nesting -= 1
                end
            end
        end

        macro_definition_lines = map(i -> macro_lines[i], collect(start_index:end_index))
        macro_definition = join(macro_definition_lines, "\n")
        match_lines = filter(x -> occursin("@match", x), macro_definition_lines)
        if match_lines != []
            old_match_line = match_lines[1]
            new_match_line = match_expand(macro_definition, lang_str)
            macro_definition = replace(macro_definition, old_match_line => "\t$(new_match_line)")
        end

        # convert those macros into functions and evaluate them
        macro_definition = replace(macro_definition, "@macro" => "function")
        println(macro_definition)
        eval(Meta.parse(macro_definition))
    end

    # then translate remaining, top-level @'s into function calls to the above definitions
    macro_generated_strings = []
    macro_call_lines = filter(x -> occursin("@", x) && !occursin("@macro", x) && !occursin("@match", x), macro_lines)
    for line in macro_call_lines 
        @show line
        line_ = split(line[2:end], " ")[1]
        func_name = "$(line_)_expand"
        if occursin(") (", line)
            args = split(replace(line, "@relate " => ""), ") (")
            args = ["\"$(args[1]))\"", "\"($(args[2])\""]
            args = join(args, ", ")
        else
            args = """$(join(split(line, " ")[3:end], ", "))"""
        end
        func_call = "$(func_name)($(args))"
        @show func_call
        str = eval(Meta.parse(func_call))

        defn_count = length(findall(x -> occursin("set.value ==", x), split(str, "\n")))
        if pretty 
            not_nums_str = defn_count == 0 ? "true" : "not(map(x -> x(set), [$(join(number_list[1:defn_count], ", "))]))"
        else
            not_nums_str = defn_count == 0 ? "true" : "not(map(x -> Base.invokelatest(x, set), [$(join(number_list[1:defn_count], ", "))]))"
            
            for word in num_list 
                str = replace(str, "    $(word)(" => "    Base.invokelatest($(word), ")
            end
        end
        str = replace(str, "nothing" => not_nums_str)
        push!(macro_generated_strings, str)
    end

    macro_generated_string = replace(replace(join(macro_generated_strings, "\n"), "    end" => "end"), "\t" => "    ")
    final_code = join([non_macro_segment, macro_generated_string], "\n")
    # final_code = macro_generated_string

    open("metalanguage_enriched/didactic/type_intermediate.jl", "w+") do f
        write(f, join(macro_generated_strings, "\n"))
    end

    include("type_intermediate.jl")
    final_code
end

function match_expand(macro_str::String, str::String)
    all_lines = split(str, "\n")
    lines = split(replace(macro_str, "\t" => ""), "\n")
    match_line = filter(x -> occursin("@match", x), lines)[1]
    func_env = Dict()
    func_type_sig_lines = filter(x -> occursin("function ", x), lines)
    if func_type_sig_lines != []
        type_sig_line = replace(split(func_type_sig_lines[1], "(")[end], ")" => "")
        if occursin(", ", type_sig_line)
            typed_args = split(type_sig_line, ", ")
        else
            typed_args = [type_sig_line]
        end

        for typed_arg in typed_args 
            arg_name, arg_type = split(typed_arg, "::")
            func_env[arg_name] = eval(Meta.parse(arg_type))
        end
    end

    types = []
    match_elements = filter(x -> x != "", split(replace(match_line, "@match " => ""), " "))
    for elt in match_elements 
        if elt in keys(func_env)
            elt_type = func_env[elt]
        else
            elt_type = eval(:NS)
        end
        push!(types, elt_type)
    end

    @show types

    new_match_line = ""
    if types[1] == eval(:NS) 
        field1 = string(fieldnames(types[1])[end])
        field2 = string(fieldnames(types[2])[end])
        # determine correct expansion using relate rules
        NS_defn_line_indices = findall(x -> occursin("_ = NS(", x), all_lines)
        if NS_defn_line_indices != []
            start_index = NS_defn_line_indices[1]
            end_index = NS_defn_line_indices[end]
            all_indices = collect(max(1, (start_index - 1)) : min(length(all_lines), (end_index + 1)))

            NS_defn_segment = join( map(i -> all_lines[i], all_indices), "\n")

            var_name1 = ""
            for i in 2:2:length(all_indices) 
                index = all_indices[i]
                line = all_lines[index]
                var_name2 = replace(replace(replace(match_elements[1], "\$" => ""), "(" => ""), ")" => "")

                if occursin("x_", line)
                    var_name1 = filter(x -> x != "", split(all_lines[index - 1], " "))[2]
                    num_word = filter(x -> x != "", split(all_lines[index - 1], " "))[end][2:end-1]
                    val = eval(Meta.parse("$(num_word)_.$(field1)"))
                    val = occursin(":(x", line) ? val.meaning : """$(join(map(x -> "x", 1:parse(Int, repr(val.meaning)[end]))))_"""
                    # val = val isa PI_val ? PI(val) : val
                    s = "\t\"$(match_elements[2]).$(field2) == $(val)\""
                    NS_defn_segment = replace(NS_defn_segment, line => s)
                    NS_defn_segment = replace(NS_defn_segment, all_lines[index - 1] => replace(all_lines[index - 1], var_name1 => var_name2))
                else
                    # relate rules 
                    func_name = split(split(line, ":(")[end], "(")[1]
                    if func_name in keys(inverse_rules_dict)
                        inverse_func_name = inverse_rules_dict[func_name]

                        new_func_name = split(split(line, "$(func_name)(")[end], ", ")[1]
                        extra_args = split(split(split(line, "$(func_name)(")[end], ", ")[end], ")")
                        extra_args = map(y -> eval(Meta.parse("$(y)_")), filter(x -> x != "" && x != "\"", extra_args))
                        extra_args = map(x -> replace(split(repr(x), ":")[end], ")" => ""), extra_args)

                        s = """\t\"$(new_func_name)($(inverse_func_name)($(match_elements[2]), $(join(extra_args, ", "))))\""""
                        s = replace(s, "($(var_name1))" => "($(var_name2))")
                        NS_defn_segment = replace(NS_defn_segment, line => s)
                    else
                        error("incorrect relate syntax")
                    end
                end
            end

            new_match_line = "\$($(NS_defn_segment))"
            println(new_match_line)
            if occursin("else)", new_match_line)
                new_match_line = replace(new_match_line, "else)" => "end)")
            end
        else
            new_match_line = "nothing"
        end
    else
        error("incorrect @match syntax")
    end

    new_match_line
end


function relate_expand(arg1::String, arg2::String)
    @show arg1 
    @show arg2
    func1, rettype1 = split(arg1[2:end - 1], ", ")
    func2, rettype2 = split(arg2[2:end - 1], ", ")

    function_strs = []

    func_str = """function $(func1)(x::$(rettype1))
    $(rettype1)($(func2)($(rettype2)(x)))
end
    """
    push!(function_strs, func_str)
    if func1 in keys(inverse_rules_dict) && func2 in keys(inverse_rules_dict)
        inverse_func1 = inverse_rules_dict[func1]
        inverse_func2 = inverse_rules_dict[func2]

        func_str = """function $(inverse_func1)(x::$(rettype1))
        $(rettype1)($(inverse_func2)($(rettype2)(x)))
    end
    """
        push!(function_strs, func_str)
    end
    join(function_strs, "\n")
end

# TEST
lang_str = ""
open("metalanguage_enriched/didactic/type_system_exploration_final.jl", "r") do f 
    global lang_str = read(f, String)
end

final_code = compile(lang_str, pretty=true)
println(final_code)

# TODO
# - implement relate_expand: DONE
# - get generated code to run, by adding appropriate Exact/PI translation function: DONE
# - add type annotation to the top of each LoT file in the actual implementation
# --- first: make sure generated code works for the pre-relate setting: DONE
# --- second: figure out how to handle compare + unit add, here (i.e. choose the right/final abstractions) 
# --- use a cache structure, to avoid compiling all the time; i.e. compile the different type systems/LoTs all at the start
# - make a visualization of the changing type systems / LoTs
# --- could switch to the RN setting first before doing this, but could also possibly make a small/simple visualization for completion purposes

# (1) later-greater princinple (compare), 
# (2) unit add, 
# (3) ANS-based definitions