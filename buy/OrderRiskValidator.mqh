

#include "../common/Utils.mqh"

#include <Trade\Trade.mqh>



bool isValidLimitOrder(bool isLong, double entryPrice){
   double askPrice = askPrice();
   double bidPrice = bidPrice();
  if(isLong){
       if(entryPrice>= askPrice){ 
          return false;
       }
  }else{
       if(entryPrice <= bidPrice){
          return false;
       }
  }

  return true;
}

bool isValidEntryConditions(bool isLong, double takeProfitPrice, double stopLossPrice){
    double askPrice = askPrice();
    double bidPrice = bidPrice();

    /***** verify distance between take profit and buy price not below minimum required ****/

    double stopLevelDistance = SymbolInfoInteger (_Symbol, SYMBOL_TRADE_STOPS_LEVEL);  

    double minimumDistanceBetweenStopAndTakeProfit = (stopLevelDistance * _Point) + _Point*3;

     if(isLong)
   {

      
      /***** LONG TRADE *****/
      // Verify TP is far enough from entry (above Ask)
      if(takeProfitPrice - askPrice < minimumDistanceBetweenStopAndTakeProfit)
         return false;

      // Verify SL is far enough from entry (below Bid)
      if(bidPrice - stopLossPrice < minimumDistanceBetweenStopAndTakeProfit)
         return false;
   }
   else
   {
      /***** SHORT TRADE *****/
      // Verify TP is far enough from entry (below Bid)
      if(bidPrice - takeProfitPrice < minimumDistanceBetweenStopAndTakeProfit)
         return false;

      // Verify SL is far enough from entry (above Ask)
      if(stopLossPrice - askPrice < minimumDistanceBetweenStopAndTakeProfit)
         return false;
   }

    return true;

}