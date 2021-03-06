//+------------------------------------------------------------------+
//|                                                     KST_Robô.mq5 |
//|                                                  RafaelTarachuck |
//|                               https://github.com/RafaelTarachuck |
//+------------------------------------------------------------------+
#property copyright "RafaelTarachuck"
#property link      "https://github.com/RafaelTarachuck"
#property version   "1.00"

#include <Trade/Trade.mqh>
#resource "\\Indicators\\Meus Indicadores\\KST.ex5"

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+

enum ESTRATEGIA_ENTRADA
  {
   APENAS_KST_CRUZAMENTO,
   KST_ZONAS,
   KST_ZONAS_MM,
   KST_MM
  };

// Variáveis Input
sinput string s0; //-----------Estratégia de Entrada-------------
input ESTRATEGIA_ENTRADA   estrategia      = APENAS_KST_CRUZAMENTO;     // Estratégia de Entrada Trade

sinput string s1; //-----------PARÂMETROS KST-------------
input int ROCLen1                          =10;             // ROCLen1
input int ROCLen2                          =15;             // ROCLen2
input int ROCLen3                          =20;             // ROCLen3
input int ROCLen4                          =30;             // ROCLen4
input int SMALen1                          =10;             // SMALen1
input int SMALen2                          =10;             // SMALen1
input int SMALen3                          =10;             // SMALen1
input int SMALen4                          =15;             // SMALen1
input int SigLen                           =9;              // SigLen

sinput string s2; //-----------MÉDIA MÓVEL EXPONENCIAL-------------
input int MEDIA_MOVEL                      =50;             // Média Móvel da Estratégia

sinput string s3; //----------INFORMAÇÕES ORDENS----------
input double num_lots                      = 1;           // Lotes


//+------------------------------------------------------------------+
//|  Variáveis para as funções                                   |
//+------------------------------------------------------------------+

int magic_number = 123456;   // Nº mágico do robô

MqlRates velas[];            // Variável para armazenar velas
MqlTick tick;                // variável para armazenar ticks

CTrade trade;

//+------------------------------------------------------------------+
//|    Variáveis para indicadores                                       |
//+------------------------------------------------------------------+

//--- KST
int kst_handle;
double kst_Buffer[];
double kstMM_Buffer[];

//--- Média móvel
double MM_Handle;
double MM_Buffer[];

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit()
  {

   kst_handle = iCustom(_Symbol,_Period,"Meus indicadores\\KST");

   MM_Handle = iMA(_Symbol,_Period,MEDIA_MOVEL,0,MODE_EMA,PRICE_CLOSE);

   CopyRates(_Symbol,_Period,0,4,velas);
   ArraySetAsSeries(velas,true);

   ChartIndicatorAdd(0,1,kst_handle);
   ChartIndicatorAdd(0,0,MM_Handle);

   

   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   IndicatorRelease(kst_handle);
   IndicatorRelease(MM_Handle);
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
bool be_ativado = false;

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnTick()
  {
// Copiar um vetor de dados tamanho três para o vetor mm_Buffer
   CopyBuffer(kst_handle,0,0,4,kst_Buffer);
   CopyBuffer(kst_handle,1,0,4,kstMM_Buffer);
   CopyBuffer(MM_Handle,0,0,4,MM_Buffer);

//--- Alimentar Buffers das Velas com dados:
   CopyRates(_Symbol,_Period,0,4,velas);
   ArraySetAsSeries(velas,true);

// Ordenar o vetor de dados:
   ArraySetAsSeries(kst_Buffer,true);
   ArraySetAsSeries(kstMM_Buffer,true);
   ArraySetAsSeries(MM_Buffer,true);

// Alimentar com dados variável de tick
   SymbolInfoTick(_Symbol,tick);

// LOGICA PARA ATIVAR COMPRA
   bool compra_kst = kst_Buffer[0] > kstMM_Buffer[0] &&
                     kst_Buffer[1] < kstMM_Buffer[1];

   bool compra_kst_zona = kst_Buffer[0] > kstMM_Buffer[0] &&
                          kst_Buffer[1] < kstMM_Buffer[1] &&
                          kst_Buffer[0] < 0 ;

   bool compra_kst_zonaMM = kst_Buffer[0] > kstMM_Buffer[0] &&
                            kst_Buffer[1] < kstMM_Buffer[1] &&
                            kst_Buffer[0] < 0 && MM_Buffer[0] > MM_Buffer[3];

   bool compra_kst_MM = kst_Buffer[0] > kstMM_Buffer[0] &&
                        kst_Buffer[1] < kstMM_Buffer[1] &&
                        MM_Buffer[0] > MM_Buffer[2];

// LOGICA PARA ATIVAR VENDA
   bool venda_kst = kst_Buffer[0] < kstMM_Buffer[0] &&
                    kst_Buffer[1] > kstMM_Buffer[1];

   bool venda_kst_zona = kst_Buffer[0] < kstMM_Buffer[0] &&
                         kst_Buffer[1] > kstMM_Buffer[1] &&
                         kst_Buffer[0] > 0 ;

   bool venda_kst_zonaMM = kst_Buffer[0] < kstMM_Buffer[0] &&
                           kst_Buffer[1] > kstMM_Buffer[1] &&
                           kst_Buffer[0] > 0 && MM_Buffer[0] < MM_Buffer[3];

   bool venda_kst_MM = kst_Buffer[0] < kstMM_Buffer[0] &&
                       kst_Buffer[1] > kstMM_Buffer[1] &&
                       MM_Buffer[0] < MM_Buffer[3];
                       
// LOGICA FECHAR POSIÇÃO SE DIFERENTE DE "APENAS KST"
   bool fecha_compra = kst_Buffer[0] < kstMM_Buffer[0] &&
                         kst_Buffer[1] > kstMM_Buffer[1];
                                 
   bool fecha_venda  = kst_Buffer[0] > kstMM_Buffer[0] &&
                         kst_Buffer[1] < kstMM_Buffer[1];
  //---
   bool Comprar = false; // Pode comprar?
   bool Vender  = false; // Pode vender?

   if(estrategia == APENAS_KST_CRUZAMENTO)
     {
      Comprar = compra_kst;
      Vender = venda_kst;
     }
   else if(estrategia == KST_ZONAS)
        {
         Comprar = compra_kst_zona;
         Vender = venda_kst_zona;
        }
      else if(estrategia == KST_ZONAS_MM)
           {
            Comprar = compra_kst_MM;
            Vender = venda_kst_zonaMM;
           }
      else
           {
            Comprar = compra_kst_MM;
            Vender = venda_kst_MM;
           }
 
 // retorna true se tivermos uma nova vela
    bool temosNovaVela = TemosNovaVela(); 
    
    // Toda vez que existir uma nova vela entrar nesse 'if'
    if(temosNovaVela)
      {
       
       // Condição de Compra:
       if(Comprar && PositionSelect(_Symbol)==false)
         {
          CompraAMercado();
          be_ativado = false;
         }
       
       // Condição de Venda:
       if(Vender && PositionSelect(_Symbol)==false)
         {
          VendaAMercado();
          be_ativado = false;
         }
       //Se Posicionado^
             
       
        if(Comprar && PositionSelect(_Symbol) == true && estrategia == APENAS_KST_CRUZAMENTO 
        && PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_SELL)
          {
           FecharPosicao();
           CompraAMercado();
           be_ativado = false;
          }
         if(Vender && PositionSelect(_Symbol) == true && estrategia == APENAS_KST_CRUZAMENTO 
        && PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY)
           {
            FecharPosicao();
            VendaAMercado();
            be_ativado =false;
           }
         if( fecha_compra && PositionSelect(_Symbol) == true && estrategia != APENAS_KST_CRUZAMENTO &&
          PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY)
           {
            FecharPosicao();
            be_ativado = false;
           }
         if( fecha_venda && PositionSelect(_Symbol) == true && estrategia != APENAS_KST_CRUZAMENTO &&
          PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_SELL)
           {
            FecharPosicao();
            be_ativado = false;
           }
       
  
            }
  }

//+------------------------------------------------------------------+
//|              FUNÇÕES                              |
//+------------------------------------------------------------------+
//--- Para Mudança de Candle
bool TemosNovaVela()
  {
//--- memoriza o tempo de abertura da ultima barra (vela) numa variável
   static datetime last_time=0;
//--- tempo atual
   datetime lastbar_time= (datetime) SeriesInfoInteger(Symbol(),Period(),SERIES_LASTBAR_DATE);

//--- se for a primeira chamada da função:
   if(last_time==0)
     {
      //--- atribuir valor temporal e sair
      last_time=lastbar_time;
      return(false);
     }

//--- se o tempo estiver diferente:
   if(last_time!=lastbar_time)
     {
      //--- memorizar esse tempo e retornar true
      last_time=lastbar_time;
      return(true);
     }
//--- se passarmos desta linha, então a barra não é nova; retornar false
   return(false);
  }

//+------------------------------------------------------------------+
//| FUNÇÕES PARA ENVIO DE ORDENS                                     |
//+------------------------------------------------------------------+
void CompraAMercado()
   {
    
      trade.Buy(num_lots,_Symbol,NormalizeDouble(tick.ask,_Digits));
      
      if(trade.ResultRetcode() == 10008 || trade.ResultRetcode() == 10009)
        {
            Print("Ordem de compra Executada com Sucesso!!");
        }else
           {
            Print("Erro de execução... ", GetLastError());
            ResetLastError();
           }          
    }
//---
void VendaAMercado()
   {  
     trade.Sell(num_lots,_Symbol,NormalizeDouble(tick.bid,_Digits));
      
      if(trade.ResultRetcode() == 10008 || trade.ResultRetcode() == 10009)
        {
            Print("Ordem de venda Executada com Sucesso!!");
        }else
           {
            Print("Erro de execução... ", GetLastError());
            ResetLastError();
           }              
   }
   
void FecharPosicao()
   {
   
      ulong ticket = PositionGetTicket(0);
      
      trade.PositionClose(ticket);
      
      if(trade.ResultRetcode() == 10009)
        {
            Print("Fechamento Executado com Sucesso!!");
        }else
           {
            Print("Erro de execução... ", GetLastError());
            ResetLastError();
           }  
   
   }




//+------------------------------------------------------------------+
