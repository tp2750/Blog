## Live-coding a shiny app

library(shiny)

mySin <- function(x, h=1) sin(2*pi*x*h)
t <- seq(0,1,0.001)

ui <- fluidPage(h1("Hello Shiny"),
                plotOutput("plot1"),
                sliderInput("h", label="Frequency", min = 1, max = 10, value= 1)
                )

server <- function(input, output, session){
    output$plot1 <- renderPlot(
        plot(t,mySin(t, h=input$h),
             type="l", ylab="Amplitude")
    )
}

app <- shinyApp(ui, server)
runApp(app)
