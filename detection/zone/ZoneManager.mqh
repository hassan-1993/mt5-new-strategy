//+------------------------------------------------------------------+
//|                                                  ZoneManager.mqh |
//|                                  Copyright 2023, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2023, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"


#include "../../SwingPoints/HighLow.mqh";
#include "ZoneStore.mqh";
#include "../../common/Utils.mqh";
#include "../../common/log/LogManager.mqh";
#include "ZoneBuilder.mqh";
#include <Arrays\ArrayObj.mqh>

/**
 
     for creating zone stores 
     communicating with ZoneBuilder to get all filtered zones available
**/
class ZoneManager
  {

   private: ZoneStore* store;

   public: void ZoneManager(){
      int all_lows[];
      int all_highs[];
      int all_lows_close[];
      int all_highs_closes[];
   
     
      int count = 10;
      int distance = 20;
      getLows(all_lows,count,distance,-1,0,false);

      getLows(all_lows_close,count,distance,-1,0,false,MODE_CLOSE);
      getHighs(all_highs_closes,count,distance,-1,0,MODE_CLOSE);
      getHighs(all_highs,count,distance,-1,0);
      
      drawPoints("close", all_highs_closes , MODE_HIGH, clrYellow, MODE_CLOSE);
      drawPoints("", all_highs, MODE_HIGH, clrRed);
      drawPoints("", all_lows, MODE_LOW, clrYellow);
      drawPoints("close", all_lows_close, MODE_LOW, clrWhite, MODE_CLOSE);


      addLog("MODE_LOW " + MODE_LOW + " MODE_HIGH" + MODE_HIGH + " MODE_CLOSE" + MODE_CLOSE  );
      this.store = new ZoneStore(all_lows_close, all_highs_closes, all_lows, all_highs);

      
   }


   public: CArrayObj* findZones(){
      ZoneBuilder builder = new ZoneBuilder();
      return builder.build(store);
      
   }
 };
