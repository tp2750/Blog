using GLMakie

mySin(x; h=1) = sin(2pi*x*h)

f = Figure()
Axis(f[1,1])

s1 = Slider(f[2,1], range = 1:10)

x = 0:.001:1
y = @lift mySin.(x, h=$(s1.value))

lines!(x,y)

