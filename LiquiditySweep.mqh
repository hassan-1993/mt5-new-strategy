//+------------------------------------------------------------------+
//|                                               LiquiditySweep.mqh |
//|                                  Copyright 2025, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"

#include "../zone/ZoneStore.mqh";


//verify if it is a liquidty sweep 


//find max number of bar wait candles below zone floor price -> verify a candle after touch point rebroken the zone below max allowed
//verify a strong candle with strong spike above ATR -> enter (stop loss next strong zone???)


/*
  i need to know how bars after broken zone before reclaim or not reaching max bars or not reaching reclaim price
  find the movement spike after sweep point
  find the depth requires the sweep point
*/



class LiquiditySweep
{
  
   private: int firstBrokenBar;   //first bar broken either the high or low
   private: int firstBarReclaim;   //first bar reclaimed the zone - so between first broken bar and first bar reclaim we can measure movement spike
   private: TouchPoint* sweepPoint;  //the lowest bar or highest bar after broken
   private: int maxWaitBars;
   

   public: LiquiditySweep(Zone* zone){
       this.maxWaitBars = findMaxWaitBarsForSweep(zone);   
   }


// find if maxWait bars are not reached -> possible entry
//find the average atr for candles from the sweepPoint until firstBarReclaim must be above ATR average by at least 50%

public: bool isFound(){
   return this.sweepPoint!=NULL;
}

public: int mode(){
   return this.sweepPoint.mode;
}

private: int findMaxWaitBarsForSweep(Zone* zone){
   

    int baseBar = 2; // minimum number of bars 
    int depthWeight = 5;   // How much deeper sweeps increase waiting time
    double atr50 = store.ATR_50;
    double atr14 = store.ATR_14;
    
    findSweepPoint(zone);
    findFirstBrokenBar(zone);

    if(this.sweepPoint = NULL){
        return -1;
    }

    double sweepDepth = findSweepDepth(zone); 

    double depth_ratio = sweepDepth / atr50;
    double depthEffect = depthWeight * depth_ratio;

    double volatilityWeight = 1;
    double volatilityEffect = volatilityWeight * (atr50 / atr14);

    return MathMax(baseBar + depthEffect + volatilityEffect , 8);

}


//find the low after price was broken below zone
private: TouchPoint* findSweepPoint(Zone* zone){

    ZoneTouchInfo* touchInfo = last(zone.touchInfos);

    TouchPoint* sweepPoint = NULL;

    int sweepType = -1;
 

    for(int i=0 ;i< store.sortedPoints.Total(); i++){
         TouchPoint* barPoint = store.sortedPoints.At(i);

        if(barPoint.candleIndex() >= touchInfo.candleIndex()){
             continue;
        }


        if(sweepType == -1){
              if(low(barPoint.candleIndex())  < zone.min_price ){
                   sweepPoint = barPoint;
                   sweepType = MODE_LOW;
              }else if(high(barPoint.candleIndex()) > zone.max_price){ 
                   sweepPoint = barPoint;
                   sweepType = MODE_HIGH;
              }
        }else if(sweepType == MODE_LOW){ 
             if(close(barPoint.candleIndex()) >= zone.min_price ){
                //price reclaimed
                break;
             }else if(low(barPoint.candleIndex()) < low(sweepPoint.candleIndex() ) ){
                  //another low detected
                  sweepPoint = barPoint;
             }
              
        }else if(sweepType == MODE_HIGH){ 
              if(close(barPoint.candleIndex()) <= zone.max_price ){
                //price reclaimed
                break;
             }else if(high(barPoint.candleIndex()) > high(sweepPoint.candleIndex() ) ){
                  //another high detected
                  sweepPoint = barPoint;
             }
        }

    }

  return sweepPoint;
}


private: double findSweepDepth(Zone* zone){

    if(this.sweepPoint = NULL){
        return -1;
    }


    int mode = this.sweepPoint.mode;

    if(mode == MODE_LOW){
          double movement = zone.min_price  - low(this.sweepPoint.candleIndex());
          return movement;
    }else{
         double movement = high(this.sweepPoint.candleIndex()) - zone.max_price;
          return movement;
    }

    
}


private: void findFirstBrokenBar(Zone* zone){
   if(this.sweepPoint = NULL){
        return;
    }

    
    int currentBar = this.sweepPoint.candleIndex() + 1;


    if(this.sweepPoint.mode == MODE_LOW){
         //find first broken bar
         do{
            currentBar++;
          }while(low(currentBar) < zone.min_price);

         this.firstBrokenBar = currentBar;
         
         currentBar = this.sweepPoint.candleIndex();   
         

          if(currentBar<=1){
             //we are still going down - no price reclaim
             return;
          }
         
         //find last broken bar
          do{
            currentBar--;
          }while(currentBar>=1 && close(currentBar) >= zone.min_price);
 
          this.firstBarReclaim = currentBar;

    }else{
          do{
            currentBar++;
          }while(high(currentBar) > zone.min_price);
 
          this.firstBrokenBar = currentBar;
          currentBar = this.sweepPoint.candleIndex();  

          if(currentBar<=1){
             //we are still going above zone - no price reclaim
             return;
          }

          do{
            currentBar--;
          }while(currentBar>=1 && close(currentBar) <= zone.max_price);
    
          this.firstBarReclaim = currentBar;
    }

  
}

};

