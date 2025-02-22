using WGLMakie

mySin(x; h=1) = sin(2pi*x*h)

f = Figure()
a1 = Axis(f[1,1], title="Hello Makie")
s1 = Slider(f[2,1], range = 1:10, )

x = 0:.001:1
y = @lift mySin.(x, h=$(s1.value))

lines!(a1, x, y)

WGLMakie.activate!()

f

