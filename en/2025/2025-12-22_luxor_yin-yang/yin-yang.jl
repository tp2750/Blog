# Drawing yin-yang in Luxor

using Luxor

R = 250

@svg begin
    move(Point(0,-R)) # start at top
    arc(Point(0,0), R, -pi/2, pi/2, :path) # right side arc to bottom
    arc(Point(0,R/2), R/2, pi/2, 3pi/2, :path) # small arc up
    carc(Point(0,-R/2), R/2,  pi/2, 3pi/2,:path) # small arc couterclockwise
    fillpath()
    circle(Point(0,0), R, action=:stroke)
    circle(Point(0,-R/2), R/8, action=:fill)
    sethue("white")
    circle(Point(0,R/2), R/8, action=:fill)
end 2R+10 2R+10 "ying-yang.svg"

@png begin
    move(Point(0,-R)) # start at top
    arc(Point(0,0), R, 3pi/2, pi/2, :path) # right side arc to bottom
    arc(Point(0,R/2), R/2, pi/2, 3pi/2, :path) # small arc up
    carc(Point(0,-R/2), R/2,  pi/2, 3pi/2,:path) # small arc couterclockwise
    fillpath()
    circle(Point(0,0), R, action=:stroke)
    circle(Point(0,-R/2), R/8, action=:fill)
    sethue("white")
    circle(Point(0,R/2), R/8, action=:fill)
end 600 600 "ying-yang.png"


@svg begin
    move(Point(0,-128)) # start at top
    arc(Point(0,0), 128, 3pi/2, pi/2, :path) # right side arc to bottom
    arc(Point(0,64), 64, pi/2, 3pi/2, :path) # small arc up
    carc(Point(0,-64), 64,  pi/2, 3pi/2,:path) # small arc couterclockwise
    fillpath()
    circle(Point(0,0), 128, action=:stroke)
    circle(Point(0,-64), 16, action=:fill)
    sethue("white")
    circle(Point(0,64), 16, action=:fill)
    sethue("black")
end



# Not working
@svg begin
    circle(Point(0,0), 128, :path)
    move(Point(0,128)) # move(Point(0,64) + polar(64,0))
    arc(Point(0,64), 64, pi/2, 3pi/2, :path)
    move(Point(0,64) + polar(16,0))
    ngon(Point(0,64), 16, 128, 0, reversepath=true, :path) # circle(Point(0,64), 16, :path)
    fillpath()
    # strokepath()
end


# Refined  Outline 
@svg begin
circle(Point(0,0), 128, action=:stroke)
arc(Point(0,64), 64, pi/2, 3pi/2, action=:stroke)
circle(Point(0,64), 16, action=:stroke)
arc(Point(0,-64), 64,  3pi/2, pi/2,action=:stroke)
circle(Point(0,-64), 16, action=:fill)
end



# This is the basic outline
@svg begin
circle(Point(0,0), 128, action=:stroke)
circle(Point(0,64), 64, action=:stroke)
circle(Point(0,64), 16, action=:stroke)
circle(Point(0,-64), 64, action=:stroke)
circle(Point(0,-64), 16, action=:fill)

end




Drawing(500,500, :png)
origin()
# background("white")
sethue("black")

circle(Point(0,0), 128, action=:stroke)
circle(Point(0,64), 64, action=:stroke)


finish()
preview()

