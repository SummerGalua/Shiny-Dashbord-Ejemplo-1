library(shiny)
library(shinythemes)
library(shinydashboard)


# Interfaz del Usuario
shinyUI(dashboardPage(skin = "red", 
                      dashboardHeader(title = "Simulador Epidémico"),
                      dashboardSidebar(h1("CONTÁCTANOS"),
                                       p(" brandoncortes05@ciencias.unam.mx"),
                                       downloadButton("Mi_Modelo_SIR.xlsx","Descarga tu Modelo SIR")
                                       ),
                      dashboardBody(    
                        tags$head( 
                          tags$style(HTML("
                                          @import url('//fonts.googleapis.com/css2?family=Anton&display=swap');
                                          
                                          h1{
                                          text-align:center;
                                          font-family:'Anton', sans-serif;
                                          }
                                          
                                          h2{
                                          font-family:'Anton', sans-serif;
                                          text-size:15px;
                                          margin-left:9%;
                                          }
                                          p{
                                          text-align:justify;
                                          }
                                          
                                          
                                          "))
                          ),
                        
                        tabsetPanel(type="tabs", 
                                    tabPanel("Genera tu modelo SIR", 
                                             # Sidebar elementos por modificar (Input) 
                                             sidebarLayout(
                                               sidebarPanel(
                                                 dateInput("Dia0","SELECCIONA EL DÍA CERO DE TU MODELO", value = as.Date("2020-01-01"), min = NULL, max = NULL,
                                                           format = "yyyy-mm-dd", startview = "month", weekstart = 0,
                                                           language = "en", width = NULL),
                                                 sliderInput("Days",
                                                             "CANTIDAD DE DÍAS DEL ANÁLISIS:",
                                                             min=100,
                                                             max=500,
                                                             value=200),
                                                 numericInput("S",
                                                              "POBLACIÓN SUSCEPTIBLE INICIAL:",
                                                              min=0,
                                                              max=500000000,
                                                              value=128991228,
                                                              step=1),
                                                 numericInput("I",
                                                              "POBLACIÓN INFECTADA INICIAL:",
                                                              min=0,
                                                              max=500000000,
                                                              value=8000,
                                                              step=1),
                                                 numericInput("M",
                                                              "DEFUNCIONES INICIALES:",
                                                              min=0,
                                                              max=500000000,
                                                              value=772,
                                                              step=1),
                                                 numericInput("mucoef",
                                                              "TASA DE RECUPERACIÓN DIARIA:",
                                                              min = 0,
                                                              max = 1,
                                                              value =.048,
                                                              step = .001),
                                                 
                                                 numericInput("betacoef",
                                                              "TASA DE CONTAGIO DIARIA:",
                                                              min=0,
                                                              max=1,
                                                              value=.168,
                                                              step=.001)
                                                 
                                               ), 
                                               
                                               #Muestra al usuario lo siguiente
                                               mainPanel(
                                                 
                                                 h1("Simulación"),
                                                 plotOutput("SIRGraf"),
                                                 p("Nota: Los datos en la Gráfica como en la tabla 
                                                   estan expresados en miles de unidades."),
                                                 DT::dataTableOutput("Tabla", width="100%"),
                                                 h1("Contexto"),
                                                 p("Debido a la creciente ola de Covid-19, el estudio
                                                   epidemiológico se ha convertido en una prioridad para 
                                                   la correcta implementación de políticas sanitarias, sin embargo,
                                                   en México se han reportado situaciones que van desde 
                                                   la opacidad de los datos, hasta el desconcocimiento total del manejo
                                                   de información en materia de análisis epidemiológicos, y en respuesta
                                                   a dicha situación se diseñó esta herramienta, cuyo propósito es, por un 
                                                   lado, generar predicciones con nuevas propuestas que refuercen las
                                                   metodoloías ya estipuladas y por el otro invitar a autoridades de distintos
                                                   niveles de gobierno a que se pongan en contacto para que nos faciliten sus 
                                                   reportes y así consolidar un repositorio que permita hacer comparativos con
                                                   lo datos federales y que tambipen nos permita dar estimaciones específicas
                                                   y fidedignas para cada estado o región.")
    
      )
     )
    ),br(),
    tabPanel("Nuetras Predicciones",fluidPage(
              h1("Metodología Propuesta"),
              p("El modelo SIR, como en sus respectivas variantes, está definido
                  principalmente mediante sus parámetros y coeficientes, por lo cual, se
                  propone analizar la variabilidad de estos parámetros como series
                  temporales. En nuestro caso se ajustó un modelo ARIMA a cada parámetro beta
                  y la tasa de mortalidad del modelo SIM (Susceptibles, Infectados y Muertos),
                  para así realizar predicciones más acertadas respecto
                  a la evolución del Covid-19 que nos acecha hoy en día."),
              h1("Prueba de fuego"),
              p("Para poner a prueba nuestra metodología, tomamos los datos reportados en
                los últimos 18 días por fuentes federales en México sobre 
                Confirmados y Defunciones por Covid-19 a nivel nacional, y los comparados 
                con los 18 días estimados por nuestro programa."),br(),
              DT::dataTableOutput("Comparatable"),br(),
              h1("Nuestras predicciones para los próximos 18 días"),
              DT::dataTableOutput("Estimatable")
              
  )
             
)
  )
)
                        
                      ))
