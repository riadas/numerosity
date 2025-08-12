include("../base/base_semantics.jl")

# give n tasks
give_1 = GiveN("one")
give_2 = GiveN("two")
give_3 = GiveN("three")
give_4 = GiveN("four")
give_5 = GiveN("five")
give_6 = GiveN("six")
give_7 = GiveN("seven")
give_8 = GiveN("eight")
give_9 = GiveN("nine")
give_10 = GiveN("ten")

# how many tasks 
how_many_1 = HowMany(Exact(1))
how_many_2 = HowMany(Exact(2))
how_many_3 = HowMany(Exact(3))
how_many_4 = HowMany(Exact(4))
how_many_5 = HowMany(Exact(5))
how_many_6 = HowMany(Exact(6))
how_many_7 = HowMany(Exact(7))
how_many_8 = HowMany(Exact(8))
how_many_9 = HowMany(Exact(9))
how_many_10 = HowMany(Exact(10))

how_many_5_blur = HowMany(Blur(5))
how_many_6_blur = HowMany(Blur(6))
how_many_7_blur = HowMany(Blur(7))
how_many_8_blur = HowMany(Blur(8))
how_many_9_blur = HowMany(Blur(9))
how_many_10_blur = HowMany(Blur(10))

# compare tasks
compare_exact = Compare((Exact(1), Exact(3)))
compare_blur = Compare((Blur(6), Blur(10)))
compare_across = Compare((Exact(1), Blur(5)))

# labeled compare tasks 
labeled_compare_2_4_no_count = LabeledCompare(((Unknown(2), Unknown(4)), ("two", "four")), NumberRep[Unknown(4)])
labeled_compare_2_4_correct_count = LabeledCompare(((Unknown(2), Unknown(4)), (VerbalCount(2), VerbalCount(4))), NumberRep[Unknown(4)])

labeled_compare_4_6_no_count = LabeledCompare(((Unknown(4), Unknown(6)), ("four", "six")), NumberRep[Unknown(6)])
labeled_compare_4_6_correct_count = LabeledCompare(((Unknown(4), Unknown(6)), (VerbalCount(4), VerbalCount(6))), NumberRep[Unknown(6)])

labeled_compare_3_4_no_count = LabeledCompare(((Unknown(3), Unknown(4)), ("three", "four")), NumberRep[Unknown(4)])
labeled_compare_3_4_correct_count = LabeledCompare(((Unknown(3), Unknown(4)), (VerbalCount(3), VerbalCount(4))), NumberRep[Unknown(4)])

# more tasks 
more_1 = More((NumberWord(5), NumberWord(7)))
more_2 = More((NumberWord(6), NumberWord(9)))

# unit add tasks
unit_add_1 = UnitAdd(Exact(5))
unit_add_2 = UnitAdd(Exact(8))

tasks = [
    give_1, # = GiveN("one")
    give_2, # = GiveN("two")
    give_3, # = GiveN("three")
    give_4, # = GiveN("four")
    give_5, # = GiveN("five")
    give_6, # = GiveN("six")
    give_7, # = GiveN("seven")
    give_8, # = GiveN("eight")
    give_9, # = GiveN("nine")
    give_10, # = GiveN("ten")

    how_many_1, #  = HowMany(Exact(1))
    how_many_2, #  = HowMany(Exact(2))
    how_many_3, #  = HowMany(Exact(3))
    how_many_4, #  = HowMany(Exact(4))
    how_many_5, #  = HowMany(Exact(5))
    how_many_6, #  = HowMany(Exact(6))
    how_many_7, #  = HowMany(Exact(7))
    how_many_8, #  = HowMany(Exact(8))
    how_many_9, #  = HowMany(Exact(9))
    how_many_10, #  = HowMany(Exact(10))

    how_many_5_blur, #  = HowMany(Blur(5))
    how_many_6_blur, #  = HowMany(Blur(6))
    how_many_7_blur, #  = HowMany(Blur(7))
    how_many_8_blur, #  = HowMany(Blur(8))
    how_many_9_blur, #  = HowMany(Blur(9))
    how_many_10_blur, #  = HowMany(Blur(10))

    compare_exact,
    compare_blur,
    compare_across,

    labeled_compare_2_4_no_count,
    labeled_compare_2_4_correct_count,

    labeled_compare_4_6_no_count,
    labeled_compare_4_6_correct_count,

    labeled_compare_3_4_no_count,
    labeled_compare_3_4_correct_count,

    more_1, 
    more_2,

    unit_add_1,
    unit_add_2
]