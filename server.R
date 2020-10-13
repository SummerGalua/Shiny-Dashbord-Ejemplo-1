library(shiny)
library(openxlsx)

#Base de datos federal a nivel nacional
Data<-readxl::read_excel("Datos SSA.xlsx")

#número de estimaciones en el futuro para el arima
nhead<-18

shinyServer(function(input, output) {
 
   Tiempo<-function(){return(seq(1,input$Days,1))} 
   dato<-function(){
     S<-c(input$S)
     I<-c(input$I)
     M<-c(input$M)
     
     for (i in Tiempo()){
       
       S[i+1] <- S[i] - input$betacoef*S[i]*I[i]/(S[1]+I[1]+M[1])
       I[i+1] <- I[i] + input$betacoef*S[i]*I[i]/(S[1]+I[1]+M[1])-input$mucoef*I[i]
       M[i+1] <- M[i] + input$mucoef*I[i]
       
     }
     
     Susceptibles<-S[2:length(S)]/1000
     Infectados<-I[2:length(I)]/1000
     Recuperados<-M[2:length(M)]/1000
     Dias<-seq(input$Dia0,input$Dia0+input$Days-1,1)
     
     res<-data.frame(Dias,Susceptibles,Infectados,Recuperados)
     return(res)
   }
   
   #renderizando la Gráfica del modelo SIR 
    output$SIRGraf <- renderPlot({
      matplot(x = Tiempo(), y = dato()[,-1], type = "l",
              xlab = "Número de días", ylab = "Individuos", main = "Modelo SIR",
              lwd = 3, lty = 2, col = 1:3)
      legend("topright",lwd = 1,col=1:4,legend = c("Susceptibles","Infectados","Recuperados"),bty = "n")
    
    })
   #renderizado de la cabecera del modelo SIR
    output$Tabla<- DT::renderDataTable({
      DT::datatable(dato(),options =list(pageLength=18, dom="t")) 
    })
    
    #renderizado y descarga de la tabla de datos 
    thedata<-reactive(Data)
    output$DatosSSA<-DT::renderDataTable({
      thedata()
    })
    
    output$Mi_Modelo_SIR.xlsx<-downloadHandler(
      filename=function(){"Mi_Modelo_SIR.xlsx"},
      content = function(fname){
        write.xlsx(dato(),fname)
      }
    )
    
    output$Comparatable<-DT::renderDataTable({
      
      inicial<-length(Data$mu)-36
      final<-length(Data$mu)-18
      
      mu<-ts(Data$mu[inicial:final])/18
      beta<-ts(Data$beta[inicial:final])
      
      #simulación de 18 observaciones en el futuro (cambia al cambiar el n.ahead)
      
      mu_estimadas<-astsa::sarima.for(mu,1,1,1,n.ahead = nhead)$pred
      beta_estimadas<-astsa::sarima.for(beta,1,1,1,n.ahead = nhead)$pred
      
      #SIMULACIÓN DEL MODELO SIR con parámetros variantes 
      
      #Inicial
      
      S<-c(Data$S[final])
      I<-c(Data$Confirmados[final])
      M<-c(Data$Defunciones[final])
      
      #Iterando 
      
      for (i in seq(1,nhead,1)){
        
        S[i+1] <- S[i] - beta_estimadas[i]*(S[i]*I[i]/(S[1]+I[1]))
        I[i+1] <- I[i] + (beta_estimadas[i]*(S[i]*I[i]/(S[1]+I[1]))) 
        M[i+1] <- M[i] + (mu_estimadas[i]*I[i])
        
      }
      #POR ESTA LÍNEA ES IMPORTANTE ACTUALIZAR DATOS DIARIO
      
      Dia<-seq(Sys.Date()-18,Sys.Date()-1,1)
      Confirmados_Estimados<-as.integer(I[2:length(I)]) 
      Defunciones_Estimadas<-as.integer(M[2:length(M)])
      Confirmados_Reales<-Data$Confirmados[(length(Data$Confirmados)-17):length(Data$Confirmados)]
      Defunciones_Reales<-Data$Defunciones[(length(Data$Confirmados)-17):length(Data$Confirmados)]
      
      fireproof<-data.frame(Dia,Confirmados_Estimados,Confirmados_Reales,
                            Defunciones_Estimadas,Defunciones_Reales)
      DT::datatable(fireproof,options=list(pageLength=18,dom="t", columnDefs = list(list(className = 'dt-center', targets = 0:5))))
    })
    
    output$Estimatable<-DT::renderDataTable({
      
      inicial<-length(Data$mu)-18
      final<-length(Data$mu)
      
      mu<-ts(Data$mu[inicial:final])/18
      beta<-ts(Data$beta[inicial:final])
      
      #simulación de 18 observaciones en el futuro (cambia al cambiar el n.ahead)
      
      mu_estimadas<-astsa::sarima.for(mu,1,1,1,n.ahead = nhead)$pred
      beta_estimadas<-astsa::sarima.for(beta,1,1,1, n.ahead = nhead)$pred
      
      #SIMULACIÓN DEL MODELO SIR con parámetros variantes 
      
      #Inicial
      
      S<-c(Data$S[final])
      I<-c(Data$Confirmados[final])
      M<-c(Data$Defunciones[final])
      
      #Iterando 
      
      for (i in seq(1,nhead,1)){
        
        S[i+1] <- S[i] - beta_estimadas[i] * S[i]*I[i]/(S[1]+I[1])
        I[i+1] <- I[i] + beta_estimadas[i]*S[i]*I[i]/(S[1]+I[1]) - mu_estimadas[i]*I[i]
        M[i+1] <- M[i] + mu_estimadas[i]*I[i]
        
      }
      
      Dia<-seq(Sys.Date(),Sys.Date()+17,1)
      Confirmados_Estimados<-as.integer(I[2:length(I)]) 
      Defunciones_Estimadas<-as.integer(M[2:length(M)]) 
      DT::datatable(data.frame(Dia,Confirmados_Estimados,Defunciones_Estimadas),
                    options=list(pageLength=18,dom="t", columnDefs = list(list(className = 'dt-center', targets = 0:3)))) 
    })
    
    
})
