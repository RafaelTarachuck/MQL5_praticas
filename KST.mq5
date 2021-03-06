//+------------------------------------------------------------------+
//|                                                         KST .mq5 |
//|                                                  RafaelTarachuck |
//|                               https://github.com/RafaelTarachuck |
//+------------------------------------------------------------------+
#include <MovingAverages.mqh>
#property copyright "RafaelTarachuck"
#property link      "https://github.com/RafaelTarachuck"
#property version   "1.00"
#property indicator_separate_window
#property indicator_buffers 14
#property indicator_plots   2
//--- plot Linha_KST
#property indicator_label1  "Linha_KST"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrRed
#property indicator_style1  STYLE_SOLID
#property indicator_width1  2
//--- plot Linha_Sinal
#property indicator_label2  "Linha_Sinal"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrWhite
#property indicator_style2  STYLE_SOLID
#property indicator_width2  2

#property indicator_level1 0


//--- indicator buffers
double         kst_buffer[];
double         sinal_kst[];

//--- PARÊMETROS DE ENTRADA
input int RocLen1=10; //RocLen1
input int RocLen2=15; //RocLen2
input int RocLen3=20; //RocLen3
input int RocLen4=30; //RocLen4
input int SMALen1=10; //SMALen1
input int SMALen2=10; //SMALen2
input int SMALen3=10; //SMALen3
input int SMALen4=15; //SMALen4
input int SigLen =9;  //SigLen

//---BUFFER VARIÁVEIS OCULTAS
int handle_roc1;
int handle_roc2;
int handle_roc3;
int handle_roc4;

double roc1[];
double roc2[];
double roc3[];
double roc4[];

double med_roc1[];
double med_roc2[];
double med_roc3[];
double med_roc4[];

double medData1[];
double medData2[];
double medData3[];
double medData4[];


//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
    SetIndexBuffer(0,kst_buffer,INDICATOR_DATA);
    SetIndexBuffer(1,sinal_kst,INDICATOR_DATA);
    SetIndexBuffer(2,roc1,INDICATOR_CALCULATIONS);
    SetIndexBuffer(3,roc2,INDICATOR_CALCULATIONS);
    SetIndexBuffer(4,roc3,INDICATOR_CALCULATIONS);
    SetIndexBuffer(5,roc4,INDICATOR_CALCULATIONS);
    SetIndexBuffer(6,med_roc1,INDICATOR_CALCULATIONS);
    SetIndexBuffer(7,med_roc2,INDICATOR_CALCULATIONS);
    SetIndexBuffer(8,med_roc3,INDICATOR_CALCULATIONS);
    SetIndexBuffer(9,med_roc4,INDICATOR_CALCULATIONS);
    SetIndexBuffer(10,medData1,INDICATOR_CALCULATIONS);
    SetIndexBuffer(11,medData2,INDICATOR_CALCULATIONS);
    SetIndexBuffer(12,medData3,INDICATOR_CALCULATIONS);
    SetIndexBuffer(13,medData4,INDICATOR_CALCULATIONS);

    handle_roc1 = iCustom(Symbol(), Period(),"Examples\\ROC",RocLen1);
    handle_roc2 = iCustom(Symbol(), Period(),"Examples\\ROC",RocLen2);
    handle_roc3 = iCustom(Symbol(), Period(),"Examples\\ROC",RocLen3);
    handle_roc4 = iCustom(Symbol(), Period(),"Examples\\ROC",RocLen4);

//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {

int inicio;
int qntCopiada;
   
   if(prev_calculated == 0)
   {
      inicio = 0;
      qntCopiada = rates_total;
   }else{
      inicio = prev_calculated;
      qntCopiada = 1;
   }
   
   
   CopyBuffer(handle_roc1,0,0,qntCopiada,roc1);
   CopyBuffer(handle_roc2,0,0,qntCopiada,roc2);
   CopyBuffer(handle_roc3,0,0,qntCopiada,roc3);
   CopyBuffer(handle_roc4,0,0,qntCopiada,roc4);
     
    for(int i=inicio;i<rates_total;i++)
    {
      if(i < (RocLen4))
      {
         medData1[i] = 0;
         medData2[i] = 0;
         medData3[i] = 0;
         medData4[i] = 0;

      }else{
         medData1[i] = roc1[i];
         medData2[i] = roc2[i];
         medData3[i] = roc3[i];
         medData4[i] = roc4[i];
      }
    }
    
    
    SimpleMAOnBuffer(rates_total,prev_calculated, 0, SMALen1, medData1, med_roc1);
    SimpleMAOnBuffer(rates_total,prev_calculated, 0, SMALen2, medData2, med_roc2);
    SimpleMAOnBuffer(rates_total,prev_calculated, 0, SMALen3, medData3, med_roc3);
    SimpleMAOnBuffer(rates_total,prev_calculated, 0, SMALen4, medData4, med_roc4);
    

   for(int i=inicio;i<rates_total;i++)
     {
      kst_buffer[i] = (med_roc1[i]*1)+(med_roc2[i]*2)+(med_roc3[i]*3)+(med_roc4[i]*4);
     } 
   
    SimpleMAOnBuffer(rates_total,prev_calculated, 0, SigLen,kst_buffer, sinal_kst);
     

//--- return value of prev_calculated for next call
    return(rates_total);
  }
           //+------------------------------------------------------------------+

           //+------------------------------------------------------------------+