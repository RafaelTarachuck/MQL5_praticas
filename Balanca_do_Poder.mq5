//+------------------------------------------------------------------+
//|                                             Balança do Poder.mq5 |
//|                               https://github.com/RafaelTarachuck |
//+------------------------------------------------------------------+
#include <MovingAverages.mqh>
#property copyright "Copyright 2020, MetaQuotes Software Corp."
#property link      "https://github.com/RafaelTarachuck"
#property version   "1.00"
#property indicator_separate_window
#property indicator_buffers 5
#property indicator_plots   3

#property indicator_label1  "Balança do Poder"
#property indicator_type1   DRAW_HISTOGRAM
#property indicator_color1  clrSilver
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1

#property indicator_label2  "Média Rápida"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrRed
#property indicator_style2  STYLE_SOLID
#property indicator_width2  2

#property indicator_label3  "Média Lenta"
#property indicator_type3   DRAW_LINE
#property indicator_color3  clrWhite
#property indicator_style3  STYLE_SOLID
#property indicator_width3  2

//--- input parameters
sinput string s0; //----------VALORES----------
input int         medbp    =     72; // Média exp BP
input int         med1     =     17; // Média Rápida
input int         med2     =     72; // Média lenta


//--- indicator buffers
double   bpunitBuffer[];
double   medbpbuffer[];
double   med1buffer[];
double   med2buffer[];  
double   medbpdatabuffer[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,medbpbuffer,INDICATOR_DATA);
   SetIndexBuffer(1,med1buffer,INDICATOR_DATA);
   SetIndexBuffer(2,med2buffer,INDICATOR_DATA);
   SetIndexBuffer(3,bpunitBuffer,INDICATOR_CALCULATIONS);
   SetIndexBuffer(4,medbpdatabuffer,INDICATOR_CALCULATIONS);
   
   ArrayInitialize(bpunitBuffer,EMPTY_VALUE);
   IndicatorSetInteger(INDICATOR_DIGITS,2);
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
//---
 int inicio;
   
   if(prev_calculated == 0)
   {
      inicio = 0;
   }else{
      inicio = prev_calculated - 1;
        }  
   
      for(int i=0;i<rates_total;i++)
        {
         double divd = high[i] - low[i]; 
         
         if(divd == 0)
           {
            bpunitBuffer[i] = 0;
           }else
              {
               bpunitBuffer[i] = (close[i] - open[i]) / divd;
              }
        }
    
  ExponentialMAOnBuffer(rates_total, prev_calculated,0,medbp,bpunitBuffer,medbpbuffer);
  ExponentialMAOnBuffer(rates_total,prev_calculated, 0,med1, medbpbuffer, med1buffer);
  ExponentialMAOnBuffer(rates_total,prev_calculated, 0,med2, medbpbuffer, med2buffer);  
  
    
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
