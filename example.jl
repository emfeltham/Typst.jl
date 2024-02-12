# example.jl

data = DataFrame(X=[1,2,3], Y=[2,4,7], Z = [4,5,6])

ols1 = lm(@formula(Y ~ X), data)
ols2 = lm(@formula(Y ~ Z), data)
ols3 = lm(@formula(Y ~ X + Z), data)

ms = [ols1, ols2, ols3];

regtable_typ(
    ms, "exampletable";
    caption = "Models of Y."
)

