//+------------------------------------------------------------------+
//|                                              WeakZoneRemover.mqh |
//|                                  Copyright 2023, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2023, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"

#include "../Zone.mqh";
#include "ATR.mqh";
#include "../ZoneUtils.mqh";

class WeakZoneRule{


 

  /**
      filter out zones with main touch point having a weak movement reaction
  **/
  public: static void filterOut(CArrayObj* zoneList){
     double atr = ATR::average();
   

     for(int i= zoneList.Total() -1; i>=0; i--){
         Zone* obj = zoneList.At(i);
         
         double moveReaction = MoveStrength::findFullZone(obj);
        

         if(moveReaction < minReactionZone()){
            //filter out weak
            zoneList.Delete(i);
         }
     }
  }
};
//#include "./Zone.mqh";

