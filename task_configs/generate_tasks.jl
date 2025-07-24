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
    compare_across
]