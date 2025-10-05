//+------------------------------------------------------------------+
//|                                                    ZoneStore.mqh |
//|                                  Copyright 2023, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2023, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"

#include <Arrays\ArrayInt.mqh>;
#include "../../common/Utils.mqh";
#include "../../common/log/logManager.mqh";
#include "./rules/ATR.mqh";
#include "./Zone.mqh";




class TouchPoint: public CObject{

   public: int mode;
   public: int modeType;
   public: int candle_index;

   public: TouchPoint(int mode, int modeType, int candleIndex){
      this.mode = mode;
      this.modeType = modeType;
      this.candle_index = candleIndex;
   }
  

   public: double price(){
      if(mode == MODE_LOW){
            if(modeType == MODE_CLOSE){
               return close(candle_index);
            }else{
                return low(candle_index);
            }
      }else if(mode == MODE_HIGH){
             if(modeType == MODE_CLOSE){
                return close(candle_index);
            }else{
                return high(candle_index);
            }
      }
      
      addLog("TouchPoint incorrect parameters passed to price() method");
      ExpertRemove();
      return -1;
   }


   public: int candleIndex(){
      return candle_index;
   }
};


class ZoneStore
  {

    public: CArrayInt lowCloses;
    public: CArrayInt highCloses;
    public: CArrayInt lows;
    public: CArrayInt highs;
    public: CArrayObj *sortedPoints;
    public:  double THRESHOLD_BROKEN_LEVEL;  // threshold for a candle to be considered broken a specific level
    public:  double THRESHOLD_ZONE_SAME_LEVEL; //if two zones are apart by less then threshold -> we merge them
    public:  double THRESHOLD_BROKEN_IGNORE_RECENT_CANDLES; // ignore the last recent candles when checking if a zone is broken
    public:  double ATR_14;
    public:  double ATR_21;
    public:  double ATR_50;

    public: ZoneStore(int &lowCloses[], int &highCloses[], int &lows[], int &highs[]){
         copyArrayToCArrayInt(lowCloses, this.lowCloses);
         copyArrayToCArrayInt(highCloses, this.highCloses);
         copyArrayToCArrayInt(lows, this.lows);
         copyArrayToCArrayInt(highs, this.highs);

         this.sortedPoints = sortAllPoints();
         this.ATR_14 = ATR::generate(14);
         this.ATR_21 = ATR::generate(100);
         this.ATR_50 = ATR::generate(50);
         this.THRESHOLD_BROKEN_LEVEL = ATR_14 * 0.4;
         this.THRESHOLD_ZONE_SAME_LEVEL = ATR_50;
         this.THRESHOLD_BROKEN_IGNORE_RECENT_CANDLES = 30;
         Print("ATR14 is " + ATR_14 + " ATR_21: " + ATR_21);
    }



   public: CArrayObj* sortAllPoints(){
       CArrayObj *touchPoints = new CArrayObj();

       int pointerLow = 0;
       int pointerHigh = 0;   
       int pointerLowClose = 0;
       int pointerHighClose = 0;

       while(pointerLow < this.lows.Total() || pointerHigh < this.highs.Total() || pointerLowClose < this.lowCloses.Total() || pointerHighClose < this.highCloses.Total()){
           int lowIndex =  pointerLow == this.lows.Total()? INT_MAX: this.lows.At(pointerLow);
           int lowCloseIndex =  pointerLowClose == this.lowCloses.Total()? INT_MAX: this.lowCloses.At(pointerLowClose);
           int highIndex =  pointerHigh == this.highs.Total()? INT_MAX: this.highs.At(pointerHigh);
           int highCloseIndex =  pointerHighClose == this.highCloses.Total()? INT_MAX: this.highCloses.At(pointerHighClose);

            if(lowIndex<=lowCloseIndex && lowIndex<=highIndex && lowIndex<=highCloseIndex){
                  touchPoints.Add(new TouchPoint(MODE_LOW, -1, lowIndex));
                  pointerLow++;
            }else if(lowCloseIndex<=lowIndex && lowCloseIndex<=highIndex && lowCloseIndex<=highCloseIndex){
                touchPoints.Add(new TouchPoint(MODE_LOW, MODE_CLOSE, lowCloseIndex));
                pointerLowClose++;
            }else if(highIndex<=lowIndex && highIndex<=lowCloseIndex && highIndex<=highCloseIndex){
                touchPoints.Add(new TouchPoint(MODE_HIGH, -1, highIndex));
                pointerHigh++;
            }else if(highCloseIndex<=lowIndex && highCloseIndex<=lowCloseIndex && highCloseIndex<=highIndex){
                  touchPoints.Add(new TouchPoint(MODE_HIGH, MODE_CLOSE, highCloseIndex));
                  pointerHighClose++;
            }
       }

      return touchPoints;
   }


  /**
     return the actual candle index
  **/
  public: int candleIndex(int arrIndex, int mode, int modeType){
    if(mode == MODE_LOW){
            if(modeType == MODE_CLOSE){
               return lowCloses[arrIndex];
            }else{
                return lows[arrIndex];
            }
      }else if(mode == MODE_HIGH){
             if(modeType == MODE_CLOSE){
                return highCloses[arrIndex];
            }else{
                return highs[arrIndex];
            }
      }

      //addLog("ZoneStore incorrect parameters passed to candleIndex() method");
      ExpertRemove();
      return -1;
  }
   
   public: double price(int arrIndex, int mode , int modeType = -1){
      if(mode == MODE_LOW){
            if(modeType == MODE_CLOSE){
               return close(lowCloses[arrIndex]);
            }else{
                return low(lows[arrIndex]);
            }
      }else if(mode == MODE_HIGH){
             if(modeType == MODE_CLOSE){
                return close(highCloses[arrIndex]);
            }else{
                return high(highs[arrIndex]);
            }
      }
      
     // addLog("ZoneStore incorrect parameters passed to price() method");
      ExpertRemove();
      return -1;
   }

   private: void copyArrayToCArrayInt(const int &src[], CArrayInt &dest)
   {
      dest.Clear(); // Ensure destination array is empty before copying
      int size = ArraySize(src);
      for(int i = 0; i < size; i++)
      {
         dest.Add(src[i]); // Add elements one by one
      }
  }


  
   
};







ZoneStore *store;

void setZoneStore(ZoneStore* zoneStore){
    store = zoneStore;
}




/*max distance allowed for a touch point to be valid and added to a zone*/
double maxTouchDistanceToZone(){
  double error_threshold = ATR::average();
  return error_threshold;
}


double minReactionZone(){
  double threshold = ATR::average() * 0.5;
  return threshold; 
}
