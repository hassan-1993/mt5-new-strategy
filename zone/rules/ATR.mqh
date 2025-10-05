//+------------------------------------------------------------------+
//|                                                          ATR.mqh |
//|                                  Copyright 2023, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2023, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"


#include "../../../common/Utils.mqh";
#include <Arrays\ArrayInt.mqh>;
#include <Arrays\ArrayDouble.mqh>;
#include "../ZoneStore.mqh";



class ATR{
  

 public: static double averageVal;


 public: static double average(){
   if(averageVal == 0){
      averageVal = ATR::generate(last(store.lows));
   }

   return averageVal;
 }
 
 public: static double generate(int until){

   double total = 0;
   for(int i= 1; i<=until; i++){
       double one = high(i) - low(i);
       double two = MathAbs(high(i) - close(i+1));
       double three = MathAbs(close(i+1) - low(i));
       double max = MathMax(one, MathMax(two, three));
       total+=max;
      
       
       
   }

   return total/(until);

}

};



double ATR::averageVal = 0.0;
