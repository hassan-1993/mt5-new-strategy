//+------------------------------------------------------------------+
//|                                                    ZoneRules.mqh |
//|                                  Copyright 2023, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2023, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"

#include "WeakZoneRule.mqh";
#include "ATR.mqh";
#include "../ZoneStore.mqh";

class ZoneRules
  {

      

     // ATR::generate(last(store.lows));

      public: static void apply(CArrayObj* zoneList){

         /***** for debugging purpose only  ******/
             string detected_zones[];
             ArrayResize(detected_zones, 5000);
            for(int i=0; i<zoneList.Total(); i++){
               Zone *zone = zoneList.At(i);
               detected_zones[i] = zone.fullInfo();
            }
        /************************/

          WeakZoneRule::filterOut(zoneList);
      

        /***** for debugging purpose only  ******/
             string after_detected_zones[];
             ArrayResize(after_detected_zones, 5000);
            for(int i=0; i<zoneList.Total(); i++){
               Zone *zone = zoneList.At(i);
               after_detected_zones[i] = zone.fullInfo();
            }
        /************************/
     }

  };


/*

"mainIndex = 161.0
 
  candle 210 mode:MODE_HIGH modeTypeClose
  candle 260 mode:MODE_HIGH modeTypeClose" (length: 103)


*/