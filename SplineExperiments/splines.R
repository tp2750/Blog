data(cars)

d1 <- with(cars, data.frame(x=speed, y=dist))

f1 <- smooth.spline(d1, lambda = 250)

predict(f1, c(20)) ## : 61.06888

f2 <- smooth.spline(d1) # lambda =  0.1112206
predict(f2, 20) ## 60.67389

str(f2)
