library(shiny)

sales <- readr::read_csv("dados/sales.csv")

ui <- fluidPage(
  selectInput("territory", "Territory", choices = unique(sales$TERRITORY)),
  selectInput("customername", "Customer", choices = NULL),
  selectInput("ordernumber", "Order number", choices = NULL),
  tableOutput("data")
)


server <- function(input, output, session) {
  
  territory <- reactive({
    filter(sales, TERRITORY == input$territory)
  })
  observeEvent(territory(), {
    choices <- unique(territory()$CUSTOMERNAME)
    updateSelectInput(session, "customername", choices = choices) 
  })
  
  customer <- reactive({
    req(input$customername)
    filter(territory(), CUSTOMERNAME == input$customername)
  })
  observeEvent(customer(), {
    choices <- unique(customer()$ORDERNUMBER)
    updateSelectInput(session, "ordernumber", choices = choices)
  })
  
  output$data <- renderTable({
    req(input$ordernumber)
    customer() %>% 
      filter(ORDERNUMBER == input$ordernumber) %>% 
      select(QUANTITYORDERED, PRICEEACH, PRODUCTCODE)
  })
}

shinyApp(ui, server)