

#include "../common/Utils.mqh"

#include <Trade\Trade.mqh>

#include "OrderRiskValidator.mqh"

int RISK_AMOUNT = 100;
double BUY_PROFIT_RATIO = 1.25;
double SELL_PROFIT_RATIO = 1;


double sell_unique_time  = -1;



//double TEMP_TAKE_PROFIT_PRICE = 0;

CTrade trade;



datetime ORDER_EXPIRES_AFTER = (36000);



bool IsExpirationTypeAllowed(int exp_type)

  {

   int expiration=(int)SymbolInfoInteger(_Symbol,SYMBOL_EXPIRATION_MODE);


   return((expiration&exp_type)==exp_type);

} 



bool placeBuyLimitOrder(double entryPrice, double takeProfit, double stopLoss){
     // takeProfitPrice = entryPrice + (entryPrice - stopLoss) * BUY_PROFIT_RATIO;

     if(!isValidEntryConditions(true, takeProfit, stopLoss)){
         return false;
     }

     if(!isValidLimitOrder(true, entryPrice)){
         return false;
     }

     bool isPlaced = placeBuyOrderAt(entryPrice, takeProfit, stopLoss);
     return isPlaced;
}


bool placeSellLimitOrder(double entryPrice, double takeProfit, double stopLoss, long uniqueTime){
     if(!isValidEntryConditions(false, takeProfit, stopLoss)){
         return false;
     }

     if(!isValidLimitOrder(false, entryPrice)){
         return false;
     }

     bool isPlaced = placeShortOrderAt(entryPrice, takeProfit, stopLoss, uniqueTime);

     return isPlaced;
}





bool placeBuyOrderAt(double entryPrice, double takeProfit , double stopLoss,  double uniqueTime = -1){

   /* if(!allow_trade()) return false;

  
    if(sell_unique_time == uniqueTime){
      return false;
   }

    sell_unique_time = uniqueTime; */

    double askPrice = askPrice();


   MqlTradeRequest request;

   ZeroMemory(request);

   request.action = TRADE_ACTION_PENDING;
   request.type = ORDER_TYPE_BUY_LIMIT;
   request.symbol = _Symbol;
   request.volume = calcLots(RISK_AMOUNT, entryPrice - stopLoss);
   request.sl = stopLoss;
   request.price = entryPrice;
   request.tp = takeProfit;
   request.expiration = TimeCurrent() + ORDER_EXPIRES_AFTER;
   request.type_time=ORDER_TIME_SPECIFIED;
   request.type_filling = ORDER_FILLING_IOC;
   MqlTradeResult result;

   MqlTradeCheckResult m_check_result;

   if(!OrderCheck(request,m_check_result)){
        return false;
    }


   return OrderSend(request, result);

}




bool placeShortOrderAt(double entryPrice, double takeProfit, double stopLossPrice, double uniqueTime){

   // if(!allow_trade()) return false;



  // if(sell_unique_time == uniqueTime){

    //  return false;

 //  }

   sell_unique_time = uniqueTime;


   MqlTradeRequest request;

   ZeroMemory(request);
   request.action = TRADE_ACTION_PENDING;
   request.type = ORDER_TYPE_SELL_LIMIT;
   request.symbol = _Symbol;
   request.volume = calcLots(RISK_AMOUNT, stopLossPrice - entryPrice);
   request.price = entryPrice;
   request.sl = stopLossPrice;
   request.tp = takeProfit;
   request.expiration = TimeCurrent() + ORDER_EXPIRES_AFTER;
   request.type_time=ORDER_TIME_SPECIFIED;
   request.deviation = 10;
   MqlTradeResult result;
   MqlTradeCheckResult m_check_result;


   if(!OrderCheck(request,m_check_result)){
        return false;
    }

   if(!OrderSend(request, result)){
        return false;
    }

    return true;

}







double calcLots (double riskMoney, double slDistance){

       double ticksize = SymbolInfoDouble (_Symbol, SYMBOL_TRADE_TICK_SIZE); 

       double tickvalue = SymbolInfoDouble (_Symbol, SYMBOL_TRADE_TICK_VALUE); 

       double lotstep = SymbolInfoDouble (_Symbol, SYMBOL_VOLUME_STEP);



       if(ticksize == 0 || tickvalue == 0 || lotstep==0){ return 0; }

       double moneyRiskPer1Lot = (slDistance / ticksize) * tickvalue;

       if (moneyRiskPer1Lot == 0) return 0; 



       double lotsRisk = riskMoney/moneyRiskPer1Lot;

       //convert lotsRisk to be multiplied by lot steps

       double lotsRiskPerStep = MathFloor(lotsRisk/lotstep) * lotstep;



      return lotsRiskPerStep;

}





//risk = 200   slDistance  = 30 ticksize = 0.01    value = 0.1

double calculateVolumne (double riskMoney, double stopLossDistance){

    

       double ticksize = SymbolInfoDouble (_Symbol, SYMBOL_TRADE_TICK_SIZE); 

       double tickvalue = SymbolInfoDouble (_Symbol, SYMBOL_TRADE_TICK_VALUE); 



       double moneyStep = (stopLossDistance / ticksize) * tickvalue;

       if (moneyStep == 0) return 0; 

       double lots = MathFloor(riskMoney/moneyStep);



      return lots;

}







double formatLotSize(double lot){

 double lotStep = SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_STEP);

 double formatted = lot/lotStep;

 formatted = ((int)formatted) * lotStep;

 return formatted;

}







double lastOrder = -1;

bool allow_trade(){

  int minAllowed = 3; // minimum number of candles before allowing another order to be placed



  //safe check to avoid infinte trades

  double max = (time(1)-time(2)) * minAllowed;

  double diff = time(0)-lastOrder;

  if(lastOrder == -1 || diff>max){

     lastOrder = time(0);

     return true;

  }



 return false;

}