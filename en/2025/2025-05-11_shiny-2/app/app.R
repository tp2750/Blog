library(shiny)
library(bslib)

sin1 = function(t, h) sin(t*h*2*pi)
t = seq(0,1,by=0.001)

## ui = fluidPage(h1("Hello Shiny"),
##                plotOutput("plot1"),
##                sliderInput("s1", min=1, max = 10, step = 1, value = 1, label="Frequency")
##                )

ui = page_sidebar(title="Hello Shiny",
                  sidebar = sidebar(
                      sliderInput("s1", min=1, max = 10, step = 1, value = 1, label="Frequency")
                  ),
                  plotOutput("plot1")
                  )


server = function(input, output, session){
    output$plot1 = renderPlot(plot(t,sin1(t,input$s1), type = 'l', ylab = "Amplitude", main = sprintf("Frequency: %s Hz", input$s1)))
}

app = shinyApp(ui, server)

runApp(app)
